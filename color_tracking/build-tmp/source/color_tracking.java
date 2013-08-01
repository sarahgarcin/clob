import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import hypermedia.video.*; 
import SimpleOpenNI.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class color_tracking extends PApplet {


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



OpenCV opencv;
SimpleOpenNI kinect;
// Frame
PImage currentFrame;
int trackColor;

// A Snake variable
Snake snake;

public void setup() {
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

public void draw() {
  
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
     int currentColor = currentFrame.pixels[loc];
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

  // // find blobs
  //   Blob[] blobs = opencv.blobs( 10, width*height/2, 100, true, OpenCV.MAX_VERTICES*4 );

  //   // draw blob results
  //   for( int i=0; i<blobs.length; i++ ) {
  //       beginShape();
  //       for( int j=0; j<blobs[i].points.length; j++ ) {
  //           vertex( blobs[i].points[j].x, blobs[i].points[j].y );
  //       }
  //       endShape(CLOSE);
  //   }
  
}

public void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
    saveFrame("blah.tif");
  int loc = mouseX + mouseY*(currentFrame.width);
 println (loc);
 
 trackColor = currentFrame.pixels[loc];
}


// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Exercise 16-5: Snake Class

class Snake {
  // x and y positions
  int[] xpos;
  int[] ypos;

  // The constructor determines the length of the snake
  Snake(int n) {
    xpos = new int[n];
    ypos = new int[n];
  }

  public void update(int newX, int newY) {
    // Shift all elements down one spot. 
    // xpos[0] = xpos[1], xpos[1] = xpos = [2], and so on. Stop at the second to last element.
    for (int i = 0; i < xpos.length-1; i ++ ) {
      xpos[i] = xpos[i+1]; 
      ypos[i] = ypos[i+1];
    }

    // Update the last spot in the array with the mouse location.
    xpos[xpos.length-1] = newX; 
    ypos[ypos.length-1] = newY;
  }

  public void display() {
    // Draw everything
    for (int i = 0; i < xpos.length; i ++ ) {
      // Draw an ellipse for each element in the arrays. 
      // Color and size are tied to the loop's counter: i.
      stroke(0);
      fill(255-i*5);
      ellipse(xpos[i],ypos[i],i,i); 
    }

  }

}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "color_tracking" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
