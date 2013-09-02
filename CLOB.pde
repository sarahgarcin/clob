import SimpleOpenNI.*;
import hypermedia.video.*; // importe la librairie vidéo et reconnaissance visuelle OpenCV

SimpleOpenNI context3D;
boolean autoCalib=true;

PImage imgRGB; // déclare un/des objets PImage (conteneur d'image)
OpenCV opencv; // déclare un objet OpenCV principal
SimpleOpenNI contextRGB; // déclare un objet SimpleOpenNI 

//------ déclaration des variables de couleur utiles ---- 
int jaune=color(255,255,0); 
int vert=color(0,255,0); 
int rouge=color(255,0,0); 
int bleu=color(0,0,255); 
int noir=color(0,0,0); 
int blanc=color(255,255,255); 
int bleuclair=color(0,255,255); 
int violet=color(255,0,255); 

void setup()
{
  // Initialise un nouveau contexte qui communique avec la kinect
  context3D = new SimpleOpenNI(this);
 
  // Autorise de collecter des données en profondeur
  context3D.enableDepth();
  
  // enable skeleton generation for all joints
  context3D.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
 
  background(0);
  strokeWeight(1);
  smooth(); 
  
  // Crée une fenêtre de la même taille que le champ 3D
  size(context3D.depthWidth(), context3D.depthHeight());

  contextRGB = new SimpleOpenNI(this);
  contextRGB.enableRGB();

   // ---- initialisation paramètres graphiques utilisés
  colorMode(RGB, 255,255,255); // fixe format couleur R G B pour fill, stroke, etc...
  //fill(0,0,255); // couleur remplissage RGB
  stroke (0,0,0); // couleur pourtour RGB
  rectMode(CORNER); // origine rectangle : CORNER = coin sup gauche | CENTER : centre 
  imageMode(CORNER); // origine image : CORNER = coin sup gauche | CENTER : centre
  // strokeWeight(3); // largeur pourtour
  frameRate(24);// Images par seconde

  // --- initialisation fenêtre de base --- 
  size(640, 480); // ouvre une fenêtre xpixels  x ypixels
  // background(0,0,0); // couleur fond fenetre

  opencv = new OpenCV(this); // initialise objet OpenCV à partir du parent This
  
  imgRGB = createImage (640,480, RGB);
  opencv.allocate(640,480);
 
}

void draw()
{
  // update the camera
  context3D.update();
  
 
  // draw scene Image
  image(context3D.depthImage(), 0, 0);
  background (255);
  
  // for all users from 1 to 10
  int u;
  for (u=1; u<=10; u++)
  {
    // check if the skeleton is being tracked
    if(context3D.isTrackingSkeleton(u))
    {
      drawSkeleton(u);  // draw the skeleton
    }
  }


  contextRGB.update();
  imgRGB = contextRGB.rgbImage();
 //image(imgRGB, 0, 0);   // affichage image video

  //----- 1°) application du "mixeur de canaux" avec sortie sur canal Rouge
  //---- coeff à appliquer 
  float coefRouge=2.5; 
  float coefVert=-2; 
  float coefBleu=-0; 

  imgRGB.loadPixels(); // charge les pixels de la fenetre d'affichage
         
  for (int i = 0; i < width*height; i++) { // passe en revue les pixels de l'image - index 0 en premier

    float r = (red(imgRGB.pixels[i])*coefRouge) + (green(imgRGB.pixels[i])*coefVert) + (blue(imgRGB.pixels[i])*coefBleu); // la couleur rouge
    //---- fonction mixeur de canaux
    //---- le canal rouge est le canal de sortie et a pour coeff 1
    //---- auquel on ajoute du vert avec coeff vert
    //---- et du bleu avec coeff bleu

    // les deux autres canaux restent inchangés
    float g = green(imgRGB.pixels[i]); // la couleur verte
    float b = blue(imgRGB.pixels[i]); // la couleur bleue
    
    imgRGB.pixels[i] = color(r, g, b); // modifie le pixel en fonction 

  }
         
  imgRGB.updatePixels();  // met à jour les pixels  

  //----- 2°) transformation de l'image en monochrome en se basant sur le canal rouge

  imgRGB.loadPixels(); // charge les pixels de la fenetre d'affichage

  for (int i = 0; i < width*height; i++) { // passe en revue les pixels de l'image - index 0 en premier

    float r = red(imgRGB.pixels[i]);// la couleur rouge
    float g = red(imgRGB.pixels[i]); // la couleur verte
    float b = red(imgRGB.pixels[i]); // la couleur bleue

    imgRGB.pixels[i] = color(r, g, b); // modifie le pixel en fonction 

  }

  imgRGB.updatePixels();  // met à jour les pixels  

  //------ on applique filtre de seuillage --- 
  imgRGB.filter(THRESHOLD,1); // applique filtre seuil à la fenetre d'affichage

  //--- on récupère l'image transformée --- 
  // imgRGB=get(0,0,width,height); // récupère image à partir fenetre d'affichage 

  //--- on rebascule dans OpenCV --- 
  opencv.copy(imgRGB); // charge l'image modifiée dans le buffer opencv

  // trouve les formes à l'aide de la librairie openCV
  // blobs(minArea, maxArea, maxBlobs, findHoles, [maxVertices]);
  Blob[] blobs = opencv.blobs( 10, width*height/4, 4, false, OpenCV.MAX_VERTICES*4 );

  //recharge l'image vidéo
  noTint();
  //image(opencv.image(), 0, 0 );   // affichage image video

  // draw blob results
  for( int i=0; i<blobs.length; i++ ) { // passe en revue les blobs

    // tracé des formes détectées
    // beginShape(); // début tracé forme complexe
    
    // for( int j=0; j<blobs[i].points.length; j++ ) {
    //   vertex( blobs[i].points[j].x, blobs[i].points[j].y ); // tracé des points de la forme
    // }

    int maxX=0;
    int maxY=0;

    int minX=0;
    int minY=0;

    for( int j=0; j<blobs[i].points.length; j++ ) {
      // Object p = blobs[i].points[j];
      // println("p: "+p);
      if (j==0){
        maxX=blobs[i].points[j].x;
        maxY=blobs[i].points[j].y;
        minX=blobs[i].points[j].x;
        minY=blobs[i].points[j].y;
      }
      else if (maxX<blobs[i].points[j].x){
        maxX=blobs[i].points[j].x;
        maxY=blobs[i].points[j].y;
      }
      else if (minX>blobs[i].points[j].x){
        minX=blobs[i].points[j].x;
        minY=blobs[i].points[j].y;
      }
    }

    line(maxX, maxY, minX, minY);
    

    // endShape(CLOSE); // tracé forme complexe

  }


}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  context3D.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_RIGHT_HAND);
  context3D.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_LEFT_HAND);
  context3D.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_FOOT);
  context3D.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_LEFT_FOOT);

}

// when a user enters the field of view
void onNewUser(int userId)
{
  println("New User Detected - userId: " + userId);

  if(autoCalib)
    context3D.requestCalibrationSkeleton(userId,true);
  else    
    context3D.startPoseDetection("Psi",userId);
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
    context3D.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
 
    // Start pose detection
    context3D.startPoseDetection("Psi", userId);
  }
}

// when a user begins a pose
void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
// stop pose detection
  context3D.stopPoseDetection(userId);
  // start attempting to calibrate the skeleton 
  context3D.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

