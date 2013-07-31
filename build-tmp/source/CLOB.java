import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CLOB extends PApplet {



SimpleOpenNI context;
boolean       autoCalib=true;

public void setup()
{
  // Initialise une nouveau contexte qui communique avec la Kinnect
  context = new SimpleOpenNI(this);
 
  // Autorise de collecter des donn\u00e9es en profondeur
  context.enableDepth();
  
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
 
  background(0);
  stroke(0,0,0);
  strokeWeight(6);
  smooth(); 
  
  // Cr\u00e9e une fen\u00eatre de la m\u00eame taille que le champ 3D
  size(context.depthWidth(), context.depthHeight());
 
}

public void draw()
{
  // update the camera
  context.update();
 
  // draw scene Image
  image(context.depthImage(), 0, 0);
  background (255);
  
  // for all users from 1 to 10
  int i;
  for (i=1; i<=10; i++)
  {
    // check if the skeleton is being tracked
    if(context.isTrackingSkeleton(i))
    {
      
      drawSkeleton(i);  // draw the skeleton
    }
  }
}
// draw the skeleton with the selected joints
//void drawSkeleton(int userId)
//{
//  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK); //drawLimb() is the function for drawing a line between joints 
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER); // This one draws the line of the left shoulder 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
// 
//}

public void drawSkeleton(int userId)
{
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_RIGHT_HAND);
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_LEFT_HAND);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_FOOT);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_LEFT_FOOT);

}

// when a user enters the field of view
public void onNewUser(int userId)
{
  println("New User Detected - userId: " + userId);

    if(autoCalib)
    context.requestCalibrationSkeleton(userId,true);
  else    
    context.startPoseDetection("Psi",userId);
}
 
//  // start pose detection
//   context.startPoseDetection("Psi", userId);
// }
 
// when a person ('user') leaves the field of view 
public void onLostUser(int userId)
{
  println("User Lost - userId: " + userId);
}

// // when a user begins a pose
// void onStartPose(String pose,int userId)
// {
//   println("Start of Pose Detected  - userId: " + userId + ", pose: " + pose);
 
//   // stop pose detection
//   context.stopPoseDetection(userId); 
 
//   // start attempting to calibrate the skeleton
//   context.requestCalibrationSkeleton(userId, true); 
// }
 
 
 // when calibration begins
public void onStartCalibration(int userId)
{
  println("Beginning Calibration - userId: " + userId);
}
 
// when calibaration ends - successfully or unsucessfully 
public void onEndCalibration(int userId, boolean successfull)
{
  println("Calibration of userId: " + userId + ", successfull: " + successfull);
 
  if (successfull) 
  { 
    println("  User calibrated !!!");
 
    // begin skeleton tracking
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
 
    // Start pose detection
    context.startPoseDetection("Psi", userId);
  }
}

// when a user begins a pose
public void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
// stop pose detection
  context.stopPoseDetection(userId);
  // start attempting to calibrate the skeleton 
  context.requestCalibrationSkeleton(userId, true);
 
}

public void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CLOB" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
