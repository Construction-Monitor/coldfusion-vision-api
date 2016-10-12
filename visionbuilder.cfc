component{
	//I use thsi to create a copy of my API
	//I create a filepath list of jars to create java loader
	//Then I create a filpath location for my json cred file from Google's API manager
	//Finally, I initlize the API, object, and store it in scope.
	//You can use the getVisionAPI to get a copy of the component, and put it in your DI framework if used
	function init(){
		var jarlist = "google-api-services-vision-v1-rev24-1.22.0.jar,google-api-client-1.22.0.jar,google-http-client-1.22.0.jar,google-http-client-jackson2-1.22.0.jar,jackson-core-2.1.3.jar,google-oauth-client-1.22.0.jar,guava-19.0.jar";
		var loadPaths = ArrayNew(1);
		for(var jar in jarlist){
			arrayAppend(loadpaths,expandPath("managed\vision\#trim(jar)#"));
		}
		var javaloader = createObject("component", "javaloader.javaloader").init(loadPaths);
		var jsonFileLocation = expandPath("managed\vision\Permit OCR-45da4c28bf45.json");
		variables.vision = createObject("component", "vision").init(javaloader,jsonFileLocation,"CMOCR");
		return this;
	}
	
	function getVisionAPI(){
		return variables.vision;
	}
}