READ ME

#Libraries

Open CV
http://ubaa.net/shared/processing/opencv

Open Kinect
http://www.labx.fr/?p=322

Simple OpenNI
http://learning.codasign.com/index.php?title=Installing_OpenNi_for_Processing
https://code.google.com/p/simple-openni/wiki/Installation

https://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI-2.0/dist/all/SimpleOpenNI.zip



# Tuto

Processing General
http://www.learningprocessing.com/

Kinect and Processing
http://learning.codasign.com/index.php?title=Processing_and_the_Kinect

OpenCV
http://createdigitalmotion.com/2009/02/processing-tutorials-getting-started-with-video-processing-via-opencv/

Color Tracking
http://zugiduino.wordpress.com/2012/12/30/kinect-color-tracking/

Blobs 
http://ubaa.net/shared/processing/opencv/opencv_blobs.html
file://localhost/Users/sarahgarcin/Documents/Processing/libraries/OpenCV/reference/blob.html
--> http://ubaa.net/shared/processing/opencv/javadoc/
--> http://thefactoryfactory.com/wordpress/?p=1012

Blob and Color Tracking
http://www.mon-club-elec.fr/pmwiki_mon_club_elec/pmwiki.php?n=MAIN.OutilsProcessingOpenCVSuiviBalle


#Scripts

color_tracking_blob
source : 
	http://www.mon-club-elec.fr/pmwiki_mon_club_elec/pmwiki.php?n=MAIN.OutilsProcessingOpenCVSuiviBalle
	www.mon-club-elec.fr 
	par X. HINAULT - Mars 2011 - tous droits réservés
Description du programme:
	Utilise un/des objets PImage (conteneur d'image .jpeg .gif .png et .tga)
	Utilise la librairie OpenCV de capture vidéo et reconnaissance visuelle


Skeleton

	void drawSkeleton(int userId)
	{
	 context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK); //drawLimb() is the function for drawing a line between joints 

	 context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER); // This one draws the line of the left shoulder 
	 context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
	 context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

	 context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
	 context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
	 context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

	 context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
	 context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

	 context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
	 context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
	 context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

	 context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
	 context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
	 context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);

	}