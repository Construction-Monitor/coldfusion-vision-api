# coldfusion-vision-api
Basic CFC and instructions for accessing Google's Cloud Vision API from CFML code. Is not a full fledged wrapper, but could be with some additional work.

VisionBuilder is used to make the API object described in vision.

I assume use of javaloader, other methods could be used with some rewriting. like Application.javasettings

Here are where I downloaded all libaries:
		https://github.com/markmandel/JavaLoader
		https://github.com/google/guava
		https://developers.google.com/api-client-library/java/apis/vision/v1

I only had use for one method, so it's all I made. The code could be scaffolded up in a variety of ways to make different functions.