import SimpleOpenNI.*;

SimpleOpenNI context;

void setup()
{
  // Initialise une nouveau contexte qui communique avec la Kinnect
  context = new SimpleOpenNI(this);
 
  // Autorise de collecter des données en profondeur
  context.enableDepth();
    
  // Autorise Scene Analyser qui permet de reconnaître les gens ou les objets en mouvements
  context.enableScene();
 
  // Crée une fenêtre de la même taille que le champ 3D
  size(context.depthWidth(), context.depthHeight());
 
}

void draw()
{
  // update the camera
  context.update();
 
  // draw scene Image
  image(context.sceneImage(), 0, 0);
  
   // gives you a label map, 0 = no person, 0+n = person n
   int[] map = context.sceneMap();
 
  // set foundPerson to false at beginning of each frame
  boolean foundPerson = false;
 
  // go through all values in the array
  for (int i=0; i<map.length; i++){
     // if something in the foreground has been identified
     if(map[i] > 0){
       // change the flag to true
       foundPerson = true;
     }
   }
   if (foundPerson)
     println("Found Person");
 
}
