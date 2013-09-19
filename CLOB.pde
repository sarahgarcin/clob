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
color        color_o = color(246,16,54);
// int          hsb_o;
float        colorH_O, colorS_O, colorB_O;

PImage       imgBleu;
color        color_b = color(86,127,173);
// int          hsb_b; 
float        colorH_B, colorS_B, colorB_B;

PImage       imgJaune;
color        color_j = color(215,176,81);
// int          hsb_j; 
float        colorH_J, colorS_J, colorB_J;

// How much to saturate the image by
float saturation = 1;
// The tolerance when comparing hues
float tolerance = 0.1f;


char       myFirstKey;

OpenCV opencv; // déclare un objet OpenCV principal
SimpleOpenNI kinectRGB; // déclare un objet SimpleOpenNI 

//------ déclaration des variables de couleur utiles ---- 
int         orange=color(255,0,0),
            jaune=color(255,255,0),
            bleu=color(0,0,255);

PVector      com = new PVector();                                   

void setup()
{
  size(640, 468);
  // size(640, 480);
  // --- initialisation context kinect 3D (infrarouge)---
  kinect3D = new SimpleOpenNI(this); // Initialise un nouveau contexte qui communique avec la kinect
 
  if(kinect3D.isInit() == false){
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }

  // kinect3D.setMirror(false); // disable mirror
  kinect3D.enableDepth(); // Autorise de collecter des données en profondeur
  // kinect3D.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL); // enable skeleton generation for all joints
  kinect3D.enableUser();// enable skeleton generation for all joints
  // enable skeleton generation for all joints
  // kinect3D.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  // --- initialisation fenêtre de base ---  
  // size(kinect3D.depthWidth(), kinect3D.depthHeight());// Crée une fenêtre de la même taille que le champ 3D
  // size(640, 480); // ouvre une fenêtre xpixels  x ypixels
  
  
  // --- initialisation paramètres graphiques utilisés ---
  background(255,255,255); // couleur fond fenetre
  strokeWeight(1);
  smooth(); 
  colorMode(RGB, 255,255,255); // fixe format couleur R G B pour fill, stroke, etc...
  rectMode(CORNER); // origine rectangle : CORNER = coin sup gauche | CENTER : centre 
  imageMode(CORNER); // origine image : CORNER = coin sup gauche | CENTER : centre
  frameRate(24);// Images par seconde
  //fill(0,0,255); // couleur remplissage RGB
  stroke (0,0,0); // couleur pourtour RGB
  // strokeWeight(3); // largeur pourtour



  // --- initialisation context kinect rgb (webcam) ---
  kinectRGB = new SimpleOpenNI(this);
  kinectRGB.enableRGB();
  
  // Orange
  int r = (color_o >> 16) & 0xFF;
  int g = (color_o >> 8) & 0xFF;
  int b = color_o & 0xFF;
  float[] hsb = Color.RGBtoHSB(r, g, b, null);
  colorH_O = hsb[0];
  colorS_O = hsb[1];
  colorB_O = hsb[2];
  println("RGB O: (" + r + ", " + g + ", " + b + ")");
  println("HSB O: (" + (colorH_O*360) + ", " + (colorS_O*100) + ", " + (colorB_O*100) +")");

  // Jaune
  r = (color_j >> 16) & 0xFF;
  g = (color_j >> 8) & 0xFF;
  b = color_j & 0xFF;
  hsb = Color.RGBtoHSB(r, g, b, null);
  colorH_J = hsb[0];
  colorS_J = hsb[1];
  colorB_J = hsb[2];
  println("RGB J: (" + r + ", " + g + ", " + b + ")");
  println("HSB J: (" + (colorH_J*360) + ", " + (colorS_J*100) + ", " + (colorB_J*100) +")");

  // bleu
  r = (color_b >> 16) & 0xFF;
  g = (color_b >> 8) & 0xFF;
  b = color_b & 0xFF;
  hsb = Color.RGBtoHSB(r, g, b, null);
  colorH_B = hsb[0];
  colorS_B = hsb[1];
  colorB_B = hsb[2];
  println("RGB B: (" + r + ", " + g + ", " + b + ")");
  println("HSB B: (" + (colorH_B*360) + ", " + (colorS_B*100) + ", " + (colorB_B*100) +")");


  // --- initialise objet OpenCV à partir du parent This
  opencv = new OpenCV(this);
  opencv.allocate(640,480);

  imgRGB = createImage (640,480, RGB);
  imgRGBOrange = createImage (640,480, RGB);
  imgRGBJaune = createImage (640,480, RGB);
  imgRGBBleu = createImage (640,480, RGB);

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

  // image(kinect3D.depthImage(), 0, 0); // draw scene Image
}

/**
* drawCleats
*/
void drawCleats(){

  kinectRGB.update();
  imgRGB = kinectRGB.rgbImage();
  image(imgRGB, 0, 0, width/2, height/2);   // affichage image video

  textSize(14) ;

  int rgb;
  int r, g, b; // Individual RGB components
  float[] hsb; // HSB color
  float h, s, br; // Individual HSB components


  // orange
  // imgOrange = kinectRGB.rgbImage();
  imgRGBOrange.loadPixels(); // charge les pixels
  for (int i = 0; i < width*height; i++) { 
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
    imgRGBOrange.pixels[i] = 0x00000000;
     
    // Starting with the hue, because it is the most distinctive component for our purpose
    if (h > colorH_O-tolerance && h < colorH_O+tolerance) {
      // The other components are still important for better precision
      if(s >= colorS_O && br >= colorB_O) {
        // If the color is within range, the pixel will be white
        imgRGBOrange.pixels[i] = 0xFFFFFFFF;
      }
    }
  }
  imgRGBOrange.updatePixels();  // met à jour les pixels 
  // imgRGBOrange.filter(THRESHOLD,1); // applique filtre seuil à la fenetre d'affichage
  if(myFirstKey == 'o')
    debugImageTreatment(imgRGBOrange, width/2, 0);

  // jaune
  kinectRGB.update();
  imgRGBJaune.loadPixels(); // charge les pixels de la fenetre d'affichage
  for (int i = 0; i < width*height; i++) { 
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
    imgRGBJaune.pixels[i] = 0x00000000;
     
    // Starting with the hue, because it is the most distinctive component for our purpose
    if (h > colorH_J-tolerance && h < colorH_J+tolerance) {
      // The other components are still important for better precision
      if(s >= colorS_J && br >= colorB_J) {
        // If the color is within range, the pixel will be white
        imgRGBJaune.pixels[i] = 0xFFFFFFFF;
      }
    }
  }
  imgRGBJaune.updatePixels();  // met à jour les pixels 
  // imgRGBJaune.filter(THRESHOLD,1); // applique filtre seuil à la fenetre d'affichage
  if(myFirstKey == 'j')
    debugImageTreatment(imgRGBJaune, 0, height/2);


  // bleu
  imgRGBBleu = kinectRGB.rgbImage();
  imgRGBBleu.loadPixels(); // charge les pixels de la fenetre d'affichage
  for (int i = 0; i < width*height; i++) { 
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
    imgRGBBleu.pixels[i] = 0x00000000;
     
    // Starting with the hue, because it is the most distinctive component for our purpose
    if (h > colorH_B-tolerance && h < colorH_B+tolerance) {
      // The other components are still important for better precision
      if(s >= colorS_B && br >= colorB_B) {
        // If the color is within range, the pixel will be white
        imgRGBBleu.pixels[i] = 0xFFFFFFFF;
      }
    }
  }
  imgRGBBleu.updatePixels();  // met à jour les pixels 
  // imgRGBBleu.filter(THRESHOLD,1); // applique filtre seuil à la fenetre d'affichage
  if(myFirstKey == 'b')
    debugImageTreatment(imgRGBBleu, width/2, height/2);




  //--- on rebascule dans OpenCV pour les blobs --- 
  opencv.copy(imgRGBOrange); // charge l'image modifiée dans le buffer opencv
  noTint();
  strokeWeight(3);

  // trouve les formes à l'aide de la librairie openCV
  // blobs(minArea, maxArea, maxBlobs, findHoles, [maxVertices]);
  Blob[] blobsOrange = opencv.blobs( 10, width*height/4, 4, false, OpenCV.MAX_VERTICES*4 );

  // draw blob results
  for( int i=0; i<blobsOrange.length; i++ ) { // passe en revue les blobs
    // tracé des formes détectées
    Point[] ext = getMaxAndMinPoints(blobsOrange[i].points);
    stroke(255, 0, 0);
    line(ext[0].x, ext[0].y, ext[1].x, ext[1].y);
  }


  opencv.copy(imgRGBBleu); // charge l'image modifiée dans le buffer opencv
  noTint();

  // trouve les formes à l'aide de la librairie openCV
  // blobs(minArea, maxArea, maxBlobs, findHoles, [maxVertices]);
  Blob[] blobsBleu = opencv.blobs( 10, width*height/4, 4, false, OpenCV.MAX_VERTICES*4 );

  // draw blob results
  for( int i=0; i<blobsBleu.length; i++ ) { // passe en revue les blobs
    // tracé des formes détectées
    Point[] ext = getMaxAndMinPoints(blobsBleu[i].points);
    stroke(0, 0, 255);
    line(ext[0].x, ext[0].y, ext[1].x, ext[1].y);
  }

  opencv.copy(imgRGBJaune); // charge l'image modifiée dans le buffer opencv
  noTint();

  // trouve les formes à l'aide de la librairie openCV
  // blobs(minArea, maxArea, maxBlobs, findHoles, [maxVertices]);
  Blob[] blobsJaune = opencv.blobs( 10, width*height/4, 4, false, OpenCV.MAX_VERTICES*4 );

  // draw blob results
  for( int i=0; i<blobsJaune.length; i++ ) { // passe en revue les blobs
    // tracé des formes détectées
    Point[] ext = getMaxAndMinPoints(blobsJaune[i].points);
    stroke(255,255,0);
    line(ext[0].x, ext[0].y, ext[1].x, ext[1].y);
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

void drawCenterOfMass(int userId){
  if(kinect3D.getCoM(userId,com))
    {
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com.x - 15,com.y,com.z);
        vertex(com.x + 15,com.y,com.z);
        
        vertex(com.x,com.y - 15,com.z);
        vertex(com.x,com.y + 15,com.z);

        vertex(com.x,com.y,com.z - 15);
        vertex(com.x,com.y,com.z + 15);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userId),com.x,com.y,com.z);
    }
}

void drawSkeleton(int userId){
  println("drawSkeleton - userId = " + userId);
  stroke(0,0,0);
  
  kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_LEFT_HAND);
  kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_FOOT);
  kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect3D.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, SimpleOpenNI.SKEL_LEFT_FOOT);
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
  float increment = 0.05;
  if(key == 'o' || key == 'j' || key == 'b'){
    myFirstKey = key;
  }
  if(key == 'r' || key == 'f' || key == 't' || key == 'g'){
    switch(key) {
      case 'r':
        tolerance += 0.01;
        break;
      case 'f':
        tolerance -= 0.01;
        break;
      case 't':
        tolerance += 0.1;
        break;
      case 'g':
        tolerance -= 0.1;
        break;
    }
    println("tolerance = "+tolerance);
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
  image(img, x, y, width/2, height/2); 
}