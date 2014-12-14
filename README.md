HeatKey is an iPhone app that demonstrates using the FLIR One infrared
camera to simulate a green screen.

Video of HeatKey demo:
https://vimeo.com/114477456

Also included is Heat Tracker, a demo that allows a FLIR One infrared camera
track nearby people using a Motrr Galileo motion base.  Because this code is
only useful to people who have a Galileo motion base, it's checked in as a
branch named "galileo".

Video of Heat Tracker demo:
https://vimeo.com/114480355

Both demos require the FLIR One SDK available at:
http://www.flir.com/flirone/developer.CFM

Place the "FLIROneSDK" folder in the same folder that contains the top-level
"HeatKey" folder.  That is:

  .../something/FlirOneSDK  
  .../something/HeatKey

If you do this, Your should be able to build and run HeatKey without any
additional effort.  If you can't please file a bug.

Heat Tracker (the Galileo demo) requires the Galileo SDK available at:
http://dev.motrr.com/blog/
Unfortunately, you may need to delete and re-add the Galileo SDK to build
correctly.  This will be fixed in the future.

This project is based on CVFunhouse computer vision framework for iOS:
https://github.com/jeradesign/CVFunhouse

And the OpenCV computer vision library:
http://opencv.org

Enjoy!
