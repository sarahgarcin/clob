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

public class blob_color_track extends PApplet {


// inclusion des librairies utilis\u00e9es 
 // importe la librairie vid\u00e9o et reconnaissance visuelle OpenCV
// cette librairie doit \u00eatre pr\u00e9sente dans le r\u00e9pertoire /libraries du r\u00e9pertoire Processing
// voir ici : http://ubaa.net/shared/processing/opencv/
// importe la librairie SimpleOpenNi pour utiliser le programme avec la kinect

// d\u00e9claration objets 
PImage currentFrame; // d\u00e9clare un/des objets PImage (conteneur d'image)
OpenCV opencv; // d\u00e9clare un objet OpenCV principal
SimpleOpenNI context; // d\u00e9clare un objet SimpleOpenNI 


//------ d\u00e9claration des variables de couleur utiles ---- 
int jaune=color(255,255,0); 
int vert=color(0,255,0); 
int rouge=color(255,0,0); 
int bleu=color(0,0,255); 
int noir=color(0,0,0); 
int blanc=color(255,255,255); 
int bleuclair=color(0,255,255); 
int violet=color(255,0,255); 


public void setup(){ // fonction d'initialisation ex\u00e9cut\u00e9e 1 fois au d\u00e9marrage

  // ---- initialisation param\u00e8tres graphiques utilis\u00e9s
  colorMode(RGB, 255,255,255); // fixe format couleur R G B pour fill, stroke, etc...
  fill(255,255,0); // couleur remplissage RGB
  stroke (255,0,0); // couleur pourtour RGB
  rectMode(CORNER); // origine rectangle : CORNER = coin sup gauche | CENTER : centre 
  imageMode(CORNER); // origine image : CORNER = coin sup gauche | CENTER : centre
  strokeWeight(3); // largeur pourtour
  frameRate(30);// Images par seconde

  // --- initialisation fen\u00eatre de base --- 
  size(640, 480); // ouvre une fen\u00eatre xpixels  x ypixels
  background(0,0,0); // couleur fond fenetre

  //======= Initialisation de la kinect ==========
  context = new SimpleOpenNI(this);
  context.enableRGB();

  //======== Initialisation Objets OpenCV (vid\u00e9o et reconnaissance visuelle =========

  opencv = new OpenCV(this); // initialise objet OpenCV \u00e0 partir du parent This
  
  currentFrame = createImage (640,480, RGB);
  opencv.allocate(640,480);

} // fin fonction Setup


public void  draw() { // fonction ex\u00e9cut\u00e9e en boucle

  context.update();
  currentFrame = context.rgbImage();
        
  opencv.copy(currentFrame, 0, 0, 640, 480, 0, 0, 640,480); // copie l'image de la kinect dans opencv

  image(currentFrame, 0, 0);   // affichage image video

  //----- 1\u00b0) application du "mixeur de canaux" avec sortie sur canal Rouge
  //---- coeff \u00e0 appliquer 
  float coefRouge=2.5f; 
  float coefVert=-2; 
  float coefBleu=-0; 

  loadPixels(); // charge les pixels de la fenetre d'affichage
         
  for (int i = 0; i < width*height; i++) { // passe en revue les pixels de l'image - index 0 en premier

    float r = (red(pixels[i])*coefRouge) + (green(pixels[i])*coefVert) + (blue(pixels[i])*coefBleu); // la couleur rouge
    //---- fonction mixeur de canaux
    //---- le canal rouge est le canal de sortie et a pour coeff 1
    //---- auquel on ajoute du vert avec coeff vert
    //---- et du bleu avec coeff bleu

    // les deux autres canaux restent inchang\u00e9s
    float g = green(pixels[i]); // la couleur verte
    float b = blue(pixels[i]); // la couleur bleue
    
    pixels[i] = color(r, g, b); // modifie le pixel en fonction 

  }
         
  updatePixels();  // met \u00e0 jour les pixels  

  //----- 2\u00b0) transformation de l'image en monochrome en se basant sur le canal rouge

  loadPixels(); // charge les pixels de la fenetre d'affichage

  for (int i = 0; i < width*height; i++) { // passe en revue les pixels de l'image - index 0 en premier

    float r = red(pixels[i]);// la couleur rouge
    float g = red(pixels[i]); // la couleur verte
    float b = red(pixels[i]); // la couleur bleue

    pixels[i] = color(r, g, b); // modifie le pixel en fonction 

  }

  updatePixels();  // met \u00e0 jour les pixels  

  //------ on applique filtre de seuillage --- 
  filter(THRESHOLD,1); // applique filtre seuil \u00e0 la fenetre d'affichage

  //--- on r\u00e9cup\u00e8re l'image transform\u00e9e --- 
  currentFrame=get(0,0,width,height); // r\u00e9cup\u00e8re image \u00e0 partir fenetre d'affichage 

  //--- on rebascule dans OpenCV --- 
  opencv.copy(currentFrame); // charge l'image modifi\u00e9e dans le buffer opencv

  // trouve les formes \u00e0 l'aide de la librairie openCV
  // blobs(minArea, maxArea, maxBlobs, findHoles, [maxVertices]);
  Blob[] blobs = opencv.blobs( 10, width*height/4, 5, false, OpenCV.MAX_VERTICES*4 );

  noTint();
  image( opencv.image(), 0, 0 );   // affichage image video

  // draw blob results
  for( int i=0; i<blobs.length; i++ ) { // passe en revue les blobs

    // trac\u00e9 des formes d\u00e9tect\u00e9es
    beginShape(); // d\u00e9but trac\u00e9 forme complexe
    
    for( int j=0; j<blobs[i].points.length; j++ ) {
      vertex( blobs[i].points[j].x, blobs[i].points[j].y ); // trac\u00e9 des points de la forme
    }
    
    endShape(CLOSE); // trac\u00e9 forme complexe
  }

        // while(true); // stoppe boucle draw

} // fin de la fonction draw()
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "blob_color_track" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
