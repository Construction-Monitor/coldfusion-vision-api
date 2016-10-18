component{
	
	function init(){
		var jsonFileLocation = expandPath("path\to\cred.json");
		variables.vision = createObject("component", "vision").init(jsonFileLocation,"your-app-name");
		return this;
	}
	
	function getVisionAPI(){
		return variables.vision;
	}
}