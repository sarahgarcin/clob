// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Exercise 16-5: Take any Processing sketch you previously created that involves mouse interaction and 
// replace the mouse with color tracking. Create an environment for the camera that is simple and high contrast. 
// For example, point the camera at a black tabletop with a small white object. 
// Control your sketch with the object's, location. 

//import processing.video.*;
//
//// Variable for capture device
//Capture video;
//
//// A variable for the color we are searching for.
//color trackColor; 
import hypermedia.video.*;
import SimpleOpenNI.*;

OpenCV opencv;
SimpleOpenNI kinect;
// Frame
PImage currentFrame;
color trackColor;

// A Snake variable
Snake snake;

void setup() {
  size(640, 480);
  
 kinect = new SimpleOpenNI(this);
 kinect.enableRGB();
 
  opencv = new OpenCV(this);
  //opencv.capture( width, height );
 
 // Start off tracking for red
 trackColor = color (255,0,0);
 smooth ();
 
 currentFrame = createImage (640,480, RGB);
 opencv.allocate(640,480);  
  
//  video = new Capture(this,width,height,15);
//  // Start off tracking for red
//  trackColor = color(255,0,0);
//  smooth();
//  
  // Initialize the snake
  snake = new Snake(50);
  
}

void draw() {
  
   kinect.update();
 
   currentFrame = kinect.rgbImage ();
   
                          // create the bufer
    opencv.copy(currentFrame, 0, 0, 640, 480, 0, 0, 640,480);
//    opencv.brightness(200);
    opencv.contrast(50);
//    opencv.threshold(100);
    
    image( opencv.image(), 0, 0 );
   //image(currentFrame,0,0);
 
   currentFrame.loadPixels();
 
 // Before we begin searching, the "world record" for closest color is set to a high number that is easy for the first pixel to beat.
   float worldRecord = 500;
 
 // XY coordinate of closest color
   int closestX = 0;
   int closestY = 0;
 
 
//  // Capture and display the video
//  if (video.available()) {
//    video.read();
//  }
//  
//  video.loadPixels();
//  image(video,0,0);
//
//  // Before we begin searching, the "world record" for closest color is set to a high number that is easy for the first pixel to beat.
//  float worldRecord = 500; 
//
//  // XY coordinate of closest color
//  int closestX = 0;
//  int closestY = 0;

  // Begin loop to walk through every pixel
 for (int x = 0; x < currentFrame.width; x ++ ) {
   for (int y = 0; y < currentFrame.height; y ++ ) {
     int loc = x + y*currentFrame.width;
     // What is current color
     color currentColor = currentFrame.pixels[loc];
     float r1 = red(currentColor);
     float g1 = green(currentColor);
     float b1 = blue(currentColor);
     float r2 = red(trackColor);
     float g2 = green(trackColor);
     float b2 = blue(trackColor);

      // Using euclidean distance to compare colors
      float d = dist(r1,g1,b1,r2,g2,b2); // We are using the dist( ) function to compare the current color with the color we are tracking.

      // If current color is more similar to tracked color than
      // closest color, save current location and current difference
      if (d < worldRecord) {
        worldRecord = d;
        closestX = x;
        closestY = y;
      }
    }
  }

  // We only consider the color found if its color distance is less than 10. 
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
  if (worldRecord < 10) { 
    // Update the snake's location
    snake.update(closestX,closestY);
  }
  
  snake.display();
  
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
    saveFrame("blah.tif");
  int loc = mouseX + mouseY*(currentFrame.width);
 println (loc);
 
 trackColor = currentFrame.pixels[loc];
}


