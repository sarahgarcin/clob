import SimpleOpenNI.*;
import hypermedia.video.*; // importe la librairie vidéo et reconnaissance visuelle OpenCV
// Java's Color class. Used to convert between RGB and HSB colorspaces
import java.awt.Color;
import java.awt.Point;
import java.util.Map;

SimpleOpenNI kinect3D;
boolean      autoCalib=true;

PImage       imgRGB; // déclare un/des objets PImage (conteneur d'image)
PImage       imgRGBOrange, imgRGBJaune, imgRGBBleu;

// tracked colors
color        tracked_color_o = color(246,16,54); // orange
color        tracked_color_b = color(86,127,173); // bleu
color        tracked_color_j = color(215,176,81); // jaune

// HSB variables by colors
float        colorH_O, colorS_O, colorB_O, tolerance_O = 1f; 
float        colorH_B, colorS_B, colorB_B, tolerance_B = 1f;
float        colorH_J, colorS_J, colorB_J, tolerance_J = 1f;

float        saturation = 0.5; // How much to saturate the image by

char         myFirstKey; // keyboard shortcut utilitis

OpenCV       opencv; // déclare un objet OpenCV principal
SimpleOpenNI kinectRGB; // déclare un objet SimpleOpenNI 

//------ cleats colors ---- 
int          orange=color(255,0,0),
             jaune=color(255,255,0),
             bleu=color(0,0,255);
int          cleat_width = 3;

PVector      com = new PVector();                                   

int          display_width = 1024;
int          display_height = 768;
int          src_width = 640;
int          src_height = 480;
int          control_width = 64*3;
int          control_height = 48*3;
int          marge = 10;

float        x_factor = 1.6;
float        y_factor = 1.6;

void setup()
{
  // size(640, 468);
  size(control_width+display_width+marge*2, display_height+marge*2);

  // println("");
  // --- initialisation context kinect 3D (infrarouge)---
  kinect3D = new SimpleOpenNI(this); // Initialise un nouveau contexte qui communique avec la kinect
 
  if(kinect3D.isInit() == false){
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }

  // kinect3D.setMirror(false); // disable mirror
  kinect3D.enableDepth(); // Autorise de collecter des données en profondeur
  kinect3D.enableUser();// enable skeleton generation for all joints

  // --- initialisation paramètres graphiques utilisés ---
  background(255,255,255); // couleur fond fenetre
  colorMode(RGB, 255,255,255); // fixe format couleur R G B pour fill, stroke, etc...
  rectMode(CORNER); // origine rectangle : CORNER = coin sup gauche | CENTER : centre 
  imageMode(CORNER); // origine image : CORNER = coin sup gauche | CENTER : centre
  frameRate(60);// Images par seconde
  //fill(0,0,255); // couleur remplissage RGB
  stroke (0,0,0); // couleur pourtour RGB
  strokeWeight(1);
  smooth();

  // --- initialisation context kinect rgb (webcam) ---
  kinectRGB = new SimpleOpenNI(this);
  kinectRGB.enableRGB();
  
  // Orange
  int r = (tracked_color_o >> 16) & 0xFF;
  int g = (tracked_color_o >> 8) & 0xFF;
  int b = tracked_color_o & 0xFF;
  float[] hsb = Color.RGBtoHSB(r, g, b, null);
  colorH_O = hsb[0];
  colorS_O = hsb[1];
  colorB_O = hsb[2];
  println("RGB O: (" + r + ", " + g + ", " + b + ")");
  println("HSB O: (" + (colorH_O*360) + ", " + (colorS_O*100) + ", " + (colorB_O*100) +")");

  // Jaune
  r = (tracked_color_j >> 16) & 0xFF;
  g = (tracked_color_j >> 8) & 0xFF;
  b = tracked_color_j & 0xFF;
  hsb = Color.RGBtoHSB(r, g, b, null);
  colorH_J = hsb[0];
  colorS_J = hsb[1];
  colorB_J = hsb[2];
  println("RGB J: (" + r + ", " + g + ", " + b + ")");
  println("HSB J: (" + (colorH_J*360) + ", " + (colorS_J*100) + ", " + (colorB_J*100) +")");

  // bleu
  r = (tracked_color_b >> 16) & 0xFF;
  g = (tracked_color_b >> 8) & 0xFF;
  b = tracked_color_b & 0xFF;
  hsb = Color.RGBtoHSB(r, g, b, null);
  colorH_B = hsb[0];
  colorS_B = hsb[1];
  colorB_B = hsb[2];
  println("RGB B: (" + r + ", " + g + ", " + b + ")");
  println("HSB B: (" + (colorH_B*360) + ", " + (colorS_B*100) + ", " + (colorB_B*100) +")");


  // --- initialise objet OpenCV à partir du parent This
  opencv = new OpenCV(this);
  opencv.allocate(src_width,src_height);

  imgRGB = createImage (src_width,src_height, RGB);
  imgRGBOrange = createImage (src_width,src_height, RGB);
  imgRGBJaune = createImage (src_width,src_height, RGB);
  imgRGBBleu = createImage (src_width,src_height, RGB);

}

void draw()
{
  kinect3D.update(); // update the 3D kinect context

  background(255,255,255); // clear the screen
  
  // draw depthImageMap
  // image(kinect3D.depthImage(),0,0);
  // image(kinect3D.userImage(),0,0);

  drawCleats();

  drawUsers();
  
  // draw the kinect cam
  // kinect3D.drawCamFrustum();

  stroke(0,0,0);
  strokeWeight(1);
  line(marge+control_width-1, marge-1, marge+control_width+10, marge-1);
  line(marge+control_width-1, marge-1, marge+control_width-1, marge+10);

  line(width-marge+1, marge-1, width-marge-10, marge-1);
  line(width-marge+1, marge-1, width-marge+1, marge+10);

  line(width-marge+1, height-marge+1, width-marge-10, height-marge+1);
  line(width-marge+1, height-marge+1, width-marge+1, height-marge-10);


  line(marge+control_width-1, height-marge+1, marge+control_width+10, height-marge+1);
  line(marge+control_width-1, height-marge+1, marge+control_width-1, height-marge-10);


  // image(kinect3D.depthImage(), 0, 0); // draw scene Image
}

/**
* drawCleats
*/
void drawCleats(){

  kinectRGB.update();
  imgRGB = kinectRGB.rgbImage();
  debugImageTreatment(imgRGB, 0, 0);
  // image(imgRGB, control_width+marge, marge, src_width*x_factor, src_height*y_factor); // debug purpose

  textSize(14) ;
  strokeWeight(0);
  // orange
  imgRGBOrange = filterHSBImage(colorH_O, colorS_O, colorB_O, tolerance_O);
  fill(Color.HSBtoRGB(colorH_O, colorS_O, colorB_O));
  rect(0, marge+control_height+10, control_width, 10);
  debugImageTreatment(imgRGBOrange, 0, (control_height+20));
  
  // jaune
  imgRGBJaune = filterHSBImage(colorH_J, colorS_J, colorB_J, tolerance_J);
  fill(Color.HSBtoRGB(colorH_J, colorS_J, colorB_J));
  rect(0, marge+(control_height+20)*2-10, control_width, 10);
  debugImageTreatment(imgRGBJaune, 0, (control_height+20)*2);
  
  // // bleu
  imgRGBBleu = filterHSBImage(colorH_B, colorS_B, colorB_B, tolerance_B);
  fill(Color.HSBtoRGB(colorH_B, colorS_B, colorB_B));
  rect(0, marge+(control_height+20)*3-10, control_width, 10);
  debugImageTreatment(imgRGBBleu, 0, (control_height+20)*3);

  strokeWeight(cleat_width);
  blobsAndDrawLines(imgRGBOrange, orange);  // draw blob results
  blobsAndDrawLines(imgRGBBleu, bleu);// draw blob results
  blobsAndDrawLines(imgRGBJaune, jaune);// draw blob results
}

PImage filterHSBImage(float colorH, float colorS, float colorB, float tolerance){
  int rgb;
  int r, g, b; // Individual RGB components
  float[] hsb; // HSB color
  float h, s, br; // Individual HSB components

  // kinectRGB.update();
  // PImage img = kinectRGB.rgbImage();
  PImage img = createImage (src_width,src_height, RGB);
  img.loadPixels(); // charge les pixels de la fenetre d'affichage
  for (int i = 0; i < src_width*src_height; i++) { 
    rgb = imgRGB.pixels[i];
    
    // Get individual RGB color components from the pixels color
    // (check "http://processing.org/reference/rightshift.html" on the reference)
    r = (rgb >> 16) & 0xFF;
    g = (rgb >> 8) & 0xFF;
    b = rgb & 0xFF;

    hsb = Color.RGBtoHSB(r, g, b, null);

    // The individual HSB components
    h = hsb[0];
    s = hsb[1]+saturation; // Saturarate colors, to make them more distinguishable
    s = constrain(s, 0, 1); // But maintain values within the appropriate range
    br = hsb[2];

    // Test if the found color is similar enough to the color we are looking for
    // If it's not, the pixel should be black
    img.pixels[i] = 0x00000000;
     
    // Starting with the hue, because it is the most distinctive component for our purpose
    if (h > colorH-tolerance && h < colorH+tolerance) {
      // The other components are still important for better precision
      if(s >= colorS && br >= colorB) {
        // If the color is within range, the pixel will be white
        img.pixels[i] = 0xFFFFFFFF;
      }
    }
  }
  img.updatePixels();  // met à jour les pixels 
  return img;
}

void blobsAndDrawLines(PImage imgrgb, color col){
  //--- on rebascule dans OpenCV pour les blobs --- 
  opencv.copy(imgrgb); // charge l'image modifiée dans le buffer opencv
  noTint();
  Blob[] blobs = opencv.blobs( 10, src_width*src_height/4, 4, false, OpenCV.MAX_VERTICES*4 ); // trouve les formes à l'aide de la librairie openCV

  for( int i=0; i<blobs.length; i++ ) { // passe en revue les blobs
    // tracé des formes détectées
    Point[] ext = getMaxAndMinPoints(blobs[i].points);
    stroke(col);
    line(control_width+marge+(ext[0].x*x_factor), marge+ext[0].y*y_factor, marge+control_width+(ext[1].x*x_factor), marge+ext[1].y*y_factor);
  } 
}

Point[] getMaxAndMinPoints(Point[] points){
  
  int maxX=0;
  int maxY=0;

  int minX=0;
  int minY=0;

  Point[] ext = new Point[2];


  for( int j=0; j<points.length; j++ ) {
    if (j==0){
      maxX=points[j].x;
      maxY=points[j].y;
      minX=points[j].x;
      minY=points[j].y;
    }
    else if (maxX<points[j].x){
      maxX=points[j].x;
      maxY=points[j].y;
    }
    else if (minX>points[j].x){
      minX=points[j].x;
      minY=points[j].y;
    }
  }
  ext[0] = new Point(minX, minY);
  ext[1] = new Point(maxX, maxY);

  return ext;
}


/**
* Users (3d skeletons)
*/

void drawUsers(){
  int[] userList = kinect3D.getUsers();
  
  for(int u=0;u<userList.length;u++)
  {
    println("userList: "+userList[u]);
    // check if the skeleton is being tracked
    if(kinect3D.isTrackingSkeleton(userList[u]))
      drawSkeleton(userList[u]);

    // drawCenterOfMass(userList[u]);
  }
}

// void drawCenterOfMass(int userId){
//   if(kinect3D.getCoM(userId,com))
//     {
//       stroke(100,255,0);
//       strokeWeight(1);
//       beginShape(LINES);
//         vertex(com.x - 15,com.y,com.z);
//         vertex(com.x + 15,com.y,com.z);
        
//         vertex(com.x,com.y - 15,com.z);
//         vertex(com.x,com.y + 15,com.z);

//         vertex(com.x,com.y,com.z - 15);
//         vertex(com.x,com.y,com.z + 15);
//       endShape();
      
//       fill(0,255,100);
//       text(Integer.toString(userId),com.x,com.y,com.z);
//     }
// }

void drawSkeleton(int userId){
  println("drawSkeleton - userId = " + userId);
  // kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_RIGHT_HAND);
  // kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_LEFT_HAND);
  // kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_FOOT);
  // kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_LEFT_FOOT);
  // kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_LEFT_HAND);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_FOOT);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, SimpleOpenNI.SKEL_LEFT_FOOT);
}

void drawLimb(int userId,int jointType1,int jointType2){
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float  confidence;
  
  // draw the joint position
  confidence = kinect3D.getJointPositionSkeleton(userId,jointType1,jointPos1);
  confidence = kinect3D.getJointPositionSkeleton(userId,jointType2,jointPos2);
  // println("confidence: "+confidence);
  // println("jointPos1: "+jointPos1);
  // println("jointPos2: "+jointPos2);

  PVector convertedJointPos1 = new PVector();
  PVector convertedJointPos2 = new PVector();
  kinect3D.convertRealWorldToProjective(jointPos1, convertedJointPos1);
  kinect3D.convertRealWorldToProjective(jointPos2, convertedJointPos2);

  // println("x_factor: "+x_factor);
  // println("y_factor: "+y_factor);

  stroke(0,0,0);
  strokeWeight(2);
  line(
    marge+control_width+(convertedJointPos1.x*x_factor),
    marge+convertedJointPos1.y*y_factor,
    marge+control_width+(convertedJointPos2.x*x_factor),
    marge+convertedJointPos2.y*y_factor
  );
  // line((jointPos1.x),jointPos1.y,(jointPos2.x),jointPos2.y);
}

void onNewUser(SimpleOpenNI curContext,int userId){
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  kinect3D.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext,int userId){
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext,int userId){
  //println("onVisibleUser - userId: " + userId);
}


/**
* events
*/
void keyPressed() {
  // println("key pressed : " + key);
  if(key == 'o' || key == 'j' || key == 'b'){
    myFirstKey = key;
  }
  if(myFirstKey == 'o' || myFirstKey == 'j' || myFirstKey == 'b'){
    if(key == 'a' || key == 'q' || key == 'z' || key == 's' || key == 'e' || key == 'd'){
      switch(myFirstKey){
        case 'o':
          switch(key) {
            case 'a':
              colorH_O += 0.01;
              println("colorH_O = "+colorH_O);
              break;
            case 'q':
              colorH_O -= 0.01;
              println("colorH_O = "+colorH_O);
              break;
            case 'z':
              colorS_O += 0.01;
              if(colorS_O > 0.999) colorS_O = 0.999;
              println("colorS_O = "+colorS_O);
              break;
            case 's':
              colorS_O -= 0.01;
              if(colorS_O < 0) colorS_O = 0;
              println("colorS_O = "+colorS_O);
              break;
            case 'e':
              colorB_O += 0.01;
              if(colorB_O > 0.999) colorB_O = 0.999;
              println("colorB_O = "+colorB_O);
              break;
            case 'd':
              colorB_O -= 0.01;
              if(colorB_O < 0) colorB_O = 0;
              println("colorB_O = "+colorB_O);
              break;
            case 'r':
              tolerance_O += 0.01;
              // if(colorB_O > 0.999) colorB_O = 0.999;
              println("tolerance_O = "+tolerance_O);
              break;
            case 'f':
              tolerance_O -= 0.01;
              // if(colorB_O < 0) colorB_O = 0;
              println("tolerance_O = "+tolerance_O);
              break;
          }
        break;
        case 'j':
          switch(key) {
            case 'a':
              colorH_J += 0.01;
              println("colorH_J = "+colorH_J);
              break;
            case 'q':
              colorH_J -= 0.01;
              println("colorH_J = "+colorH_J);
              break;
            case 'z':
              colorS_J += 0.01;
              if(colorS_J > 0.999) colorS_J = 0.999;
              println("colorS_J = "+colorS_J);
              break;
            case 's':
              colorS_J -= 0.01;
              if(colorS_J < 0) colorS_J = 0;
              println("colorS_J = "+colorS_J);
              break;
            case 'e':
              colorB_J += 0.01;
              if(colorB_J > 0.999) colorB_J = 0.999;
              println("colorB_J = "+colorB_J);
              break;
            case 'd':
              colorB_J -= 0.01;
              if(colorB_J < 0) colorB_J = 0;
              println("colorB_J = "+colorB_J);
              break;
            case 'r':
              tolerance_J += 0.01;
              // if(colorB_J > 0.999) colorB_J = 0.999;
              println("tolerance_J = "+tolerance_J);
              break;
            case 'f':
              tolerance_J -= 0.01;
              // if(colorB_J < 0) colorB_J = 0;
              println("tolerance_J = "+tolerance_J);
              break;
          }
        break;
        case 'b':
          switch(key) {
            case 'a':
              colorH_B += 0.01;
              println("colorH_B = "+colorH_B);
              break;
            case 'q':
              colorH_B -= 0.01;
              println("colorH_B = "+colorH_B);
              break;
            case 'z':
              colorS_B += 0.01;
              if(colorS_B > 0.999) colorS_B = 0.999;
              println("colorS_B = "+colorS_B);
              break;
            case 's':
              colorS_B -= 0.01;
              if(colorS_B < 0) colorS_B = 0;
              println("colorS_B = "+colorS_B);
              break;
            case 'e':
              colorB_B += 0.01;
              if(colorB_B > 0.999) colorB_B = 0.999;
              println("colorB_B = "+colorB_B);
              break;
            case 'd':
              colorB_B -= 0.01;
              if(colorB_B < 0) colorB_B = 0;
              println("colorB_B = "+colorB_B);
              break;
            case 'r':
              tolerance_B += 0.01;
              // if(colorB_B > 0.999) colorB_B = 0.999;
              println("tolerance_B = "+tolerance_B);
              break;
            case 'f':
              tolerance_B -= 0.01;
              // if(colorB_B < 0) colorB_B = 0;
              println("tolerance_B = "+tolerance_B);
              break;
          }
        break;
      }
    }
  }
}

void keyReleased() {
  if(key == 'o' || key == 'j' || key == 'b')
    myFirstKey = '0';
}

/**
* helpers
*/

void debugImageTreatment(PImage img, int x, int y){
  image(img, x, y+marge, control_width, control_height); 
}