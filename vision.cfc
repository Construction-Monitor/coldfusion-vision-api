component{
	/*Uses's Mark Mandel's Java loader
	Javaloader must have access to these libaries, here I'm using versioned files
	Almost all jars were downloaded from Google's API Java reference
	Guava came from github guava project.
	
	Javaloader and jars aren't included because I didn't want to figure out license issues
		https://github.com/markmandel/JavaLoader
		https://github.com/google/guava
		https://developers.google.com/api-client-library/java/apis/vision/v1
	
	Code used to construct javaloader outside of javaloader
		var jarlist = "
		google-api-services-vision-v1-rev24-1.22.0.jar
		google-api-client-1.22.0.jar,
		google-http-client-1.22.0.jar,
		google-http-client-jackson2-1.22.0.jar,
		jackson-core-2.1.3.jar,
		google-oauth-client-1.22.0.jar,
		guava-19.0.jar
		";
		var loadPaths = ArrayNew(1);
		for(var jar in jarlist){
			arrayAppend(loadpaths,expandPath("path\to\jars\#trim(jar)#"));
		}
		var javaloader = createObject("component", "javaloader.javaloader").init(loadPaths);
		
		In theory another javaloader would work, or using COldfusion's builtin application.javasettings,
		and replacing below references to javaloader to normal create statements.
		
		
	*/
	
	function init(required javaloader javaloader,required string jsonCredFile,required string appname){
		variables.javaloader = javaloader;
		variables.httpTransport = javaloader.create("com.google.api.client.http.javanet.NetHttpTransport").init();
		variables.jsonFactory = javaloader.create("com.google.api.client.json.jackson2.JacksonFactory").init();
		variables.visionScope = javaloader.create("com.google.api.services.vision.v1.VisionScopes");
		variables.immutableList = javaloader.create("com.google.common.collect.ImmutableList");
		variables.jsonCredFile = createObject("java","java.io.FileInputStream").init(jsonCredFile);
		variables.credential = javaloader.create("com.google.api.client.googleapis.auth.oauth2.GoogleCredential").fromStream(variables.jsonCredFile).createScoped([visionScope.CLOUD_PLATFORM]);
		visionAPIbuilder = javaloader.create("com.google.api.services.vision.v1.Vision$Builder").init(variables.httpTransport,variables.jsonFactory,variables.credential).setApplicationName(arguments.appname);
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
		var response = annoteObj.execute();
		return response['responses'][1]['textAnnotations'];
	}
	
	function textDetectionFromDisk(imagePath){
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
		return variables.javaloader.create("com.google.api.services.vision.v1.model.BatchAnnotateImagesRequest");
	}
	function createAnnotateImageRequest(){
		return variables.javaloader.create("com.google.api.services.vision.v1.model.AnnotateImageRequest");
	}
	function createImage(required binary imageByteArray){
		return variables.javaloader.create("com.google.api.services.vision.v1.model.Image").encodeContent(imageByteArray);
	}
	function createFeature(required string feature){
		return variables.javaloader.create("com.google.api.services.vision.v1.model.Feature").setType(feature);
	}
	
	//If you need the raw library for another reason then using my prebuilt methods
	function getVisionAPI(){
		return variables.visionAPI;
	}
	
	function getVariables(){
		return variables;
	}
}