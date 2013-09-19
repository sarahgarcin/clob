import SimpleOpenNI.*;
import hypermedia.video.*; // importe la librairie vidéo et reconnaissance visuelle OpenCV

SimpleOpenNI kinect3D;
boolean      autoCalib=true;

PImage       imgRGB; // déclare un/des objets PImage (conteneur d'image)
PImage       imgOrange;
float        coefRouge_O, coefVert_O, coefBleu_O;

PImage       imgBleu;
float        coefRouge_B, coefVert_B, coefBleu_B;

PImage       imgJaune;
float        coefRouge_J, coefVert_J, coefBleu_J;

char       myFirstKey;

//OpenCV opencv; // déclare un objet OpenCV principal
SimpleOpenNI kinectRGB; // déclare un objet SimpleOpenNI 

//------ déclaration des variables de couleur utiles ---- 
// int         jaune=color(255,255,0),
//             vert=color(0,255,0),
//             rouge=color(255,0,0),
//             bleu=color(0,0,255),
//             noir=color(0,0,0),
//             blanc=color(255,255,255),
//             bleuclair=color(0,255,255),
//             violet=color(255,0,255); 

// color[]       userClr = new color[]{ color(255,0,0),
//                                      color(0,255,0),
//                                      color(0,0,255),
//                                      color(255,255,0),
//                                      color(255,0,255),
//                                      color(0,255,255)
//                                    };

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
  
  coefRouge_O=1.1;  // 100 % de rouge
  coefVert_O=1.5;   // 80 % de vert
  coefBleu_O=-2;    // -200% de bleu

  coefRouge_J=-1;   // 100 % de rouge
  coefVert_J=1;     // 80 % de vert
  coefBleu_J=-2;    // -200% de bleu

  coefRouge_B=-2;   // 100 % de rouge
  coefVert_B=1.8;   // 80 % de vert
  coefBleu_B=2;     // -200% de bleu

  // --- initialise objet OpenCV à partir du parent This
//  opencv = new OpenCV(this);
//  opencv.allocate(640,480);

  // imgRGB = createImage (640,480, RGB);



}

void draw()
{
  kinect3D.update(); // update the 3D kinect context

  background(255,255,255); // clear the screen
  
  // draw depthImageMap
  //image(kinect3D.depthImage(),0,0);
  // image(kinect3D.userImage(),0,0);

  drawCleats();

  drawUsers();
  
  // draw the kinect cam
  // kinect3D.drawCamFrustum();

  // image(kinect3D.depthImage(), 0, 0); // draw scene Image
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
* drawCleats
*/

void drawCleats(){

  kinectRGB.update();
  imgRGB = kinectRGB.rgbImage();
  image(imgRGB, 0, 0, width/2, height/2);   // affichage image video

  imgOrange = kinectRGB.rgbImage();
  imgBleu = kinectRGB.rgbImage();
  imgJaune = kinectRGB.rgbImage();

  textSize(14) ;

  // orange
  imgOrange.loadPixels(); // charge les pixels de la fenetre d'affichage
  for (int i = 0; i < width*height; i++) { 
    float r = (red(imgOrange.pixels[i])*coefRouge_O) + (green(imgOrange.pixels[i])*coefVert_O) + (blue(imgOrange.pixels[i])*coefBleu_O); // la couleur rouge
    // les deux autres canaux restent inchangés
    float g = green(imgOrange.pixels[i]); // la couleur verte
    float b = blue(imgOrange.pixels[i]); // la couleur bleue
    imgOrange.pixels[i] = color(r, g, b); // modifie le pixel en fonction 
  }
  imgOrange.updatePixels();  // met à jour les pixels 
  // imgOrange.filter(THRESHOLD,1); // applique filtre seuil à la fenetre d'affichage
  if(myFirstKey == 'o')
    debugImageTreatment(imgOrange, coefRouge_O, coefVert_O, coefBleu_O, width/2, 0);

  // jaune
  imgJaune.loadPixels(); // charge les pixels de la fenetre d'affichage
  for (int i = 0; i < width*height; i++) { 
    float g = (red(imgJaune.pixels[i])*coefRouge_J) + (green(imgJaune.pixels[i])*coefVert_J) + (blue(imgJaune.pixels[i])*coefBleu_J); // la couleur rouge
    // les deux autres canaux restent inchangés
    float r = red(imgJaune.pixels[i]); // la couleur verte
    float b = blue(imgJaune.pixels[i]); // la couleur bleue
    imgJaune.pixels[i] = color(r, g, b); // modifie le pixel en fonction 
  }
  imgJaune.updatePixels();  // met à jour les pixels 
  // imgJaune.filter(THRESHOLD,1); // applique filtre seuil à la fenetre d'affichage
  if(myFirstKey == 'j')
    debugImageTreatment(imgJaune, coefRouge_J, coefVert_J, coefBleu_J, 0, height/2);


  // bleu
  imgBleu.loadPixels(); // charge les pixels de la fenetre d'affichage
  for (int i = 0; i < width*height; i++) { 
    float b = (red(imgBleu.pixels[i])*coefRouge_B) + (green(imgBleu.pixels[i])*coefVert_B) + (blue(imgBleu.pixels[i])*coefBleu_B); // la couleur rouge
    // les deux autres canaux restent inchangés
    float r = red(imgBleu.pixels[i]); // la couleur verte
    float g = green(imgBleu.pixels[i]); // la couleur bleue
    imgBleu.pixels[i] = color(r, g, b); // modifie le pixel en fonction 
  }
  imgBleu.updatePixels();  // met à jour les pixels 
  // imgBleu.filter(THRESHOLD,1); // applique filtre seuil à la fenetre d'affichage
  if(myFirstKey == 'b')
    debugImageTreatment(imgBleu, coefRouge_B, coefVert_B, coefBleu_B, width/2, height/2);


//   //--- on récupère l'image transformée --- 
//   // imgRGB=get(0,0,width,height); // récupère image à partir fenetre d'affichage 

//   //--- on rebascule dans OpenCV --- 
//   opencv.copy(imgRGB); // charge l'image modifiée dans le buffer opencv

//   // trouve les formes à l'aide de la librairie openCV
//   // blobs(minArea, maxArea, maxBlobs, findHoles, [maxVertices]);
//   Blob[] blobs = opencv.blobs( 10, width*height/4, 4, false, OpenCV.MAX_VERTICES*4 );

//   //recharge l'image vidéo
//   noTint();
//   //image(opencv.image(), 0, 0 );   // affichage image video

//   // draw blob results
//   for( int i=0; i<blobs.length; i++ ) { // passe en revue les blobs

//     // tracé des formes détectées
//     // beginShape(); // début tracé forme complexe
    
//     // for( int j=0; j<blobs[i].points.length; j++ ) {
//     //   vertex( blobs[i].points[j].x, blobs[i].points[j].y ); // tracé des points de la forme
//     // }

//     int maxX=0;
//     int maxY=0;

//     int minX=0;
//     int minY=0;

//     for( int j=0; j<blobs[i].points.length; j++ ) {
//       // Object p = blobs[i].points[j];
//       // println("p: "+p);
//       if (j==0){
//         maxX=blobs[i].points[j].x;
//         maxY=blobs[i].points[j].y;
//         minX=blobs[i].points[j].x;
//         minY=blobs[i].points[j].y;
//       }
//       else if (maxX<blobs[i].points[j].x){
//         maxX=blobs[i].points[j].x;
//         maxY=blobs[i].points[j].y;
//       }
//       else if (minX>blobs[i].points[j].x){
//         minX=blobs[i].points[j].x;
//         minY=blobs[i].points[j].y;
//       }
//     }

//     line(maxX, maxY, minX, minY);
    
//   }
//     // endShape(CLOSE); // tracé forme complexe
}

void keyPressed() {
  // println("key pressed : " + key);
  float increment = 0.05;
  if(key == 'o' || key == 'j' || key == 'b'){
    myFirstKey = key;
  }else{
    switch(myFirstKey){
      case 'o':
        switch(key){
          case 'q':
            coefRouge_O += increment;
            break;
          case 'w':
            coefRouge_O -= increment;
            break;
          case 's':
            coefVert_O += increment;
            break;
          case 'x':
            coefVert_O -= increment;
            break;
          case 'd':
            coefBleu_O += increment;
            break;
          case 'c':
            coefBleu_O -= increment;
            break;
        }
      break;
      case 'j':
        switch(key){
          case 'q':
            coefRouge_J += increment;
            break;
          case 'w':
            coefRouge_J -= increment;
            break;
          case 's':
            coefVert_J += increment;
            break;
          case 'x':
            coefVert_J -= increment;
            break;
          case 'd':
            coefBleu_J += increment;
            break;
          case 'c':
            coefBleu_J -= increment;
            break;
        }
        break;
      case 'b':
        switch(key){
          case 'q':
            coefRouge_B += increment;
            break;
          case 'w':
            coefRouge_B -= increment;
            break;
          case 's':
            coefVert_B += increment;
            break;
          case 'x':
            coefVert_B -= increment;
            break;
          case 'd':
            coefBleu_B += increment;
            break;
          case 'c':
            coefBleu_B -= increment;
            break;
        }
        break;
    }
  }
}



void keyReleased() {
  if(key == 'o' || key == 'j' || key == 'b')
    myFirstKey = '0';

}


void debugImageTreatment(PImage img, float coefR, float coefV, float coefB, int x, int y){
  image(img, x, y, width/2, height/2); 
  text("coefRouge = "+coefR, x, y+20);
  text("coefVert = "+coefV, x, y+40);
  text("coefBleu = "+coefB, x, y+60);
}