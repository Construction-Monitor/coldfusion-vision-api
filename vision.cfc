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