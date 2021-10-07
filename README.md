# flutter-samples

# Getting Started Beagle Native Sample
To run this code, just download the repository https://github.com/ZupIT/beagle-backend-kotlin

 Go to the beagle-backend-kotlin repository root folder and run the backend with the command: ./gradlew bootRun

# Those are the modules, choose android or ios module to run

## Here is the project scructure [fullscreen](add_to_app/fullscreen) with the structure as follows:
  1. android_fullscreen
  2. beagle_components
  3. flutter_module
  4. ios_fullscreen
## For android
Open the [Android](add_to_app/fullscreen/android_fullscreen) module with Android studio and run it to view the result.
## For iOS
Open the [iOS](add_to_app/fullscreen/ios_fullscreen/IOSFullScreen.xcworkspace) module with Xcode, and run it to view the result.

## The App running

<img src="https://github.com/hernandazevedozup/flutter-samples/blob/master/beagle_flutter_native_android.gif" width="500" height="800" />


## Things to know 

* This example shows a fullscreen beagle screen using a flutter module.
* The ios/android module is using the flutter module as dependency and it compiles every time you run your native platform app.
* Flutter uses Method channels to emmit/receive data from other platforms, and its being shown on the examples.
* Also to make beagle inform things to the native code, you can create a custom action to pass the data to the method channel and subscribe to it on your native code. Here is the flutter doc [Flutter Method Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)


## The dependency tree is:

[Your Native APP Android/IOS] -> flutter module -> beagle_components -> beagle

## Can you use a flutter module as a precompiled library 
This is a work in progress sample that can be found here [prebuilt_module](add_to_app/prebuilt_module)
