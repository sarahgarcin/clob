import SimpleOpenNI.*;

SimpleOpenNI context;
boolean autoCalib=true;

void setup()
{
  // Initialise une nouveau contexte qui communique avec la Kinnect
  context = new SimpleOpenNI(this);
 
  // Autorise de collecter des données en profondeur
  context.enableDepth();
  
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
 
  background(0);
  stroke(0,0,0);
  strokeWeight(6);
  smooth(); 
  
  // Crée une fenêtre de la même taille que le champ 3D
  size(context.depthWidth(), context.depthHeight());
 
}

void draw()
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
void drawSkeleton(int userId)
{
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_RIGHT_HAND);
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_LEFT_HAND);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_FOOT);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_LEFT_FOOT);

}

// when a user enters the field of view
void onNewUser(int userId)
{
  println("New User Detected - userId: " + userId);

  if(autoCalib)
    context.requestCalibrationSkeleton(userId,true);
  else    
    context.startPoseDetection("Psi",userId);
}
 
// when a person ('user') leaves the field of view 
void onLostUser(int userId)
{
  println("User Lost - userId: " + userId);
}

// when calibration begins
void onStartCalibration(int userId)
{
  println("Beginning Calibration - userId: " + userId);
}
 
// when calibaration ends - successfully or unsucessfully 
void onEndCalibration(int userId, boolean successfull)
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
void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
// stop pose detection
  context.stopPoseDetection(userId);
  // start attempting to calibrate the skeleton 
  context.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

