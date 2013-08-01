
// inclusion des librairies utilisées 
import hypermedia.video.*; // importe la librairie vidéo et reconnaissance visuelle OpenCV
// cette librairie doit être présente dans le répertoire /libraries du répertoire Processing
// voir ici : http://ubaa.net/shared/processing/opencv/
import SimpleOpenNI.*;// importe la librairie SimpleOpenNi pour utiliser le programme avec la kinect

// déclaration objets 
PImage currentFrame; // déclare un/des objets PImage (conteneur d'image)
OpenCV opencv; // déclare un objet OpenCV principal
SimpleOpenNI kinect; // déclare un objet SimpleOpenNI 


//------ déclaration des variables de couleur utiles ---- 
int jaune=color(255,255,0); 
int vert=color(0,255,0); 
int rouge=color(255,0,0); 
int bleu=color(0,0,255); 
int noir=color(0,0,0); 
int blanc=color(255,255,255); 
int bleuclair=color(0,255,255); 
int violet=color(255,0,255); 


void setup(){ // fonction d'initialisation exécutée 1 fois au démarrage

  // ---- initialisation paramètres graphiques utilisés
  colorMode(RGB, 255,255,255); // fixe format couleur R G B pour fill, stroke, etc...
  fill(255,255,0); // couleur remplissage RGB
  stroke (255,0,0); // couleur pourtour RGB
  rectMode(CORNER); // origine rectangle : CORNER = coin sup gauche | CENTER : centre 
  imageMode(CORNER); // origine image : CORNER = coin sup gauche | CENTER : centre
  strokeWeight(3); // largeur pourtour
  frameRate(30);// Images par seconde

  // --- initialisation fenêtre de base --- 
  size(640, 480); // ouvre une fenêtre xpixels  x ypixels
  background(0,0,0); // couleur fond fenetre

  //======= Initialisation de la kinect ==========
  kinect = new SimpleOpenNI(this);
  kinect.enableRGB();

  //======== Initialisation Objets OpenCV (vidéo et reconnaissance visuelle =========

  opencv = new OpenCV(this); // initialise objet OpenCV à partir du parent This
  
  currentFrame = createImage (640,480, RGB);
  opencv.allocate(640,480);

} // fin fonction Setup


void  draw() { // fonction exécutée en boucle

  kinect.update();
  currentFrame = kinect.rgbImage();
        
  opencv.copy(currentFrame, 0, 0, 640, 480, 0, 0, 640,480); // copie l'image de la kinect dans opencv

  image(currentFrame, 0, 0);   // affichage image video

  //----- 1°) application du "mixeur de canaux" avec sortie sur canal Rouge
  //---- coeff à appliquer 
  float coefRouge=2.5; 
  float coefVert=-2; 
  float coefBleu=-0; 

  loadPixels(); // charge les pixels de la fenetre d'affichage
         
  for (int i = 0; i < width*height; i++) { // passe en revue les pixels de l'image - index 0 en premier

    float r = (red(pixels[i])*coefRouge) + (green(pixels[i])*coefVert) + (blue(pixels[i])*coefBleu); // la couleur rouge
    //---- fonction mixeur de canaux
    //---- le canal rouge est le canal de sortie et a pour coeff 1
    //---- auquel on ajoute du vert avec coeff vert
    //---- et du bleu avec coeff bleu

    // les deux autres canaux restent inchangés
    float g = green(pixels[i]); // la couleur verte
    float b = blue(pixels[i]); // la couleur bleue
    
    pixels[i] = color(r, g, b); // modifie le pixel en fonction 

  }
         
  updatePixels();  // met à jour les pixels  

  //----- 2°) transformation de l'image en monochrome en se basant sur le canal rouge

  loadPixels(); // charge les pixels de la fenetre d'affichage

  for (int i = 0; i < width*height; i++) { // passe en revue les pixels de l'image - index 0 en premier

    float r = red(pixels[i]);// la couleur rouge
    float g = red(pixels[i]); // la couleur verte
    float b = red(pixels[i]); // la couleur bleue

    pixels[i] = color(r, g, b); // modifie le pixel en fonction 

  }

  updatePixels();  // met à jour les pixels  

  //------ on applique filtre de seuillage --- 
  filter(THRESHOLD,1); // applique filtre seuil à la fenetre d'affichage

  //--- on récupère l'image transformée --- 
  currentFrame=get(0,0,width,height); // récupère image à partir fenetre d'affichage 

  //--- on rebascule dans OpenCV --- 
  opencv.copy(currentFrame); // charge l'image modifiée dans le buffer opencv

  // trouve les formes à l'aide de la librairie openCV
  // blobs(minArea, maxArea, maxBlobs, findHoles, [maxVertices]);
  Blob[] blobs = opencv.blobs( 10, width*height/4, 5, false, OpenCV.MAX_VERTICES*4 );

  noTint();
  image( opencv.image(), 0, 0 );   // affichage image video

  // draw blob results
  for( int i=0; i<blobs.length; i++ ) { // passe en revue les blobs

    // tracé des formes détectées
    beginShape(); // début tracé forme complexe
    
    for( int j=0; j<blobs[i].points.length; j++ ) {
      vertex( blobs[i].points[j].x, blobs[i].points[j].y ); // tracé des points de la forme
    }
    
    endShape(CLOSE); // tracé forme complexe
  }

        // while(true); // stoppe boucle draw

} // fin de la fonction draw()
