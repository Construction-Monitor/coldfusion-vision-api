# coldfusion-vision-api
Basic CFC and instructions for accessing Google's Cloud Vision API from CFML code. Is not a full fledged wrapper, but could be with some additional work.

VisionBuilder is used to make the API object described in vision. It is an example of how to create the object, but you can create it however you need/want

I assume jar files will be in classpath, I recommend use of this.javasettings in application.cfc, jar files needed are listed in vision.cfc

Here are where you can download all libraries:
- https://github.com/google/guava
- https://developers.google.com/api-client-library/java/apis/vision/v1

I only had use for one method, so it's all I made. The code could be scaffolded up in a variety of ways to make different functions.