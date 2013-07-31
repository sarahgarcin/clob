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
}
