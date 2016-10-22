component{
	/*Almost all jars were downloaded from Google's API Java reference
	Guava came from github guava project.
	
	jars aren't included because I didn't want to figure out license issues
		https://github.com/google/guava
		https://developers.google.com/api-client-library/java/apis/vision/v1
	
	Jars needed:
		google-api-services-vision-v1-rev24-1.22.0.jar
		google-api-client-1.22.0.jar,
		google-http-client-1.22.0.jar,
		google-http-client-jackson2-1.22.0.jar,
		jackson-core-2.1.3.jar,
		google-oauth-client-1.22.0.jar,
		guava-19.0.jar
	Java settings used in application.cfc
	this.javaSettings = {loadPaths="path\to\jars\",loadColdfFusionClassPath=true,reloadOnChange=false};
		
	The maximum payload size for a request is 8 MB.
	The maximum payload size for a single image was 4 MB
	Any image over 4 MB needs to be shrunk for sure
	My testing showed images overs 3.5MB needed to be shrunk,
	probably because the limit is on the base64 data
	Not the binary data
	
	I did not include the code to do that interally in the library, because it is best handled elsewhere
	More so, because cfimage resize has garbage performance, even on highestPerformance.
	
	I personally used graphicsMagick, and cfexecute, imageMagick would work well too.
	
	The way I determined shrinking an image, was I checked if it was over 3MB (to be safe).
	If it was, I shrunk it by the percentage needed. So if it was 4MB, I did 3MB / 4 MB.
	Then I resized the image to 75% of the size.
	I had worse results when I tried to check for images over a certain resolution.
		
	*/
	
	function init(required string jsonCredFile,required string appname){
		variables.httpTransport = createObject("java","com.google.api.client.http.javanet.NetHttpTransport").init();
		variables.jsonFactory = createObject("java","com.google.api.client.json.jackson2.JacksonFactory").init();
		variables.visionScope = createObject("java","com.google.api.services.vision.v1.VisionScopes");
		variables.immutableList = createObject("java","com.google.common.collect.ImmutableList");
		variables.jsonCredFile = createObject("java","java.io.FileInputStream").init(jsonCredFile);
		variables.credential = createObject("java","com.google.api.client.googleapis.auth.oauth2.GoogleCredential").fromStream(variables.jsonCredFile).createScoped([visionScope.CLOUD_PLATFORM]);
		visionAPIbuilder = createObject("java","com.google.api.services.vision.v1.Vision$Builder").init(variables.httpTransport,variables.jsonFactory,variables.credential).setApplicationName(arguments.appname);
		variables.visionAPI = visionAPIbuilder.build();
		return this;
	}
	
	//Binary == byteArray, use FileReadBinary() from disk if inclined
	//Requires additional engineering to make it more re-usable, the idea would be the batch could reuse this
	function textDetectionFromBinary(required binary imageByteArray){
		var imageObj =  createImage(imageByteArray);
		var featureObj = createFeature("TEXT_DETECTION");
		var requestObj = createAnnotateImageRequest().setImage(imageObj).setFeatures(variables.immutableList.of(featureObj));
		var annoteBatch = createBatchAnnotateImagesRequest().setRequests(immutableList.of(requestObj));
		var annoteObj = variables.visionAPI.images().annotate(annoteBatch);
		//Have to disable GZIP, large images (unsure exact size, seemed to be over 3MBish), will silently fail and not do an outgoing request
		//You will just get an empty struct back without this.
		annoteObj.setDisableGZipContent(true);
		var response = annoteObj.execute();
		return response;
	}
	
	function textDetectionFromPath(imagePath){
		var imageByteArray = FileReadBinary(expandPath(imagePath));
		return textDetectionFromBinary(imageByteArray);
	}
	
	//Requires additional engineering I don't want to spend right now
	//Should get an array binary files, and build requests for all of them.
	function batchTextDetectionFromBinary(){
		
	}
	
	function batchTextDetectionFromDisk(){
		
	}
	
	function createBatchAnnotateImagesRequest(){
		return createObject("java","com.google.api.services.vision.v1.model.BatchAnnotateImagesRequest");
	}
	function createAnnotateImageRequest(){
		return createObject("java","com.google.api.services.vision.v1.model.AnnotateImageRequest");
	}
	function createImage(required binary imageByteArray){
		return createObject("java","com.google.api.services.vision.v1.model.Image").encodeContent(imageByteArray);
	}
	function createFeature(required string feature){
		return createObject("java","com.google.api.services.vision.v1.model.Feature").setType(feature);
	}
	
	//If you need the raw library for another reason then using my prebuilt methods
	function getVisionAPI(){
		return variables.visionAPI;
	}
	
	function getVariables(){
		return variables;
	}
}