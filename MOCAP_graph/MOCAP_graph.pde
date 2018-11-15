// IMPORTS
import java.util.Map;
import oscP5.*;
import netP5.*;

// OSC
OscP5 oscP5;
NetAddress myRemoteLocation;

// MOCAP data containers
HashMap<String, RigidBody> rigidbodies;
HashMap<String, Skeleton> skeletons;

// Graph objects
ArrayList<Graph> graphs;

// start pos of graphs
int graphX = 90;
int graphY = 20;

// ID's of bones to watch
int[] boneIDS = {1, 2, 3, 4, 5, 6, 7, 8, 10, 20};

boolean isSetup =false;

// ----> SETUP
void setup()
{
  size(1024, 600, P3D);
  frameRate(30);

  // create a new osc properties object */
  OscProperties properties = new OscProperties();
  properties.setDatagramSize(6000);
  properties.setRemoteAddress("127.0.0.1", 12000);
  properties.setListeningPort(6200);
  // start oscP5
  oscP5 = new OscP5(this, properties);

  // init MOCAP data cobjects
  rigidbodies = new HashMap<String, RigidBody>();
  skeletons = new HashMap<String, Skeleton>();

  // init grsaphs objects
  graphs = new ArrayList<Graph>();


  smooth(8);

  // SET position of canvas
  //frame.setLocation(1440, 0);
  
  println("############ SETUP DONE ");
  isSetup = true; // only start processing OSC messages if setup is done
}

void draw()
{
  background(0);
  
  // Loop throough Graphs
  // Based on Rigidbodies
  // FIXME: add skeletons
  
  for (int i=0; i<graphs.size (); i++)
  {
    
    Graph g = graphs.get(i);
    if(g.skeletonName == "none"){
      RigidBody rb =  rigidbodies.get(g.rigidbodyName);
      g.update(rb);
      g.display();
    }
    else{
      Skeleton sk =  skeletons.get(g.skeletonName);
      RigidBody rb =  sk.rigidbodies.get(g.rigidbodyName);
      g.update(rb);
      g.display();
    }
  }
  
}

void setGraphPosition(){
  int xoffset = 360;
  
   if(graphX < width-xoffset){ 
     graphX += xoffset; 
   }
   else { 
     graphX = 90; graphY +=140; 
   }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if (isSetup) {
    /* print the address pattern and the typetag of the received OscMessage */
    //print("### received an osc message.");
    //print(" addrpattern: "+theOscMessage.addrPattern());
    //println(" typetag: "+theOscMessage.typetag()+" length: "+theOscMessage.typetag().length());
    
    // FIRST check if we are dealing with a rigidbody
    if (theOscMessage.checkAddrPattern("/rigidBody")) {

      // Make the rigidbody ID
      String RigidBodyID = theOscMessage.get(1).stringValue();

      // See if it is present in the hashmap
      if (rigidbodies.containsKey(RigidBodyID))
      {
        // Get the rigidbody from the hashmap
        RigidBody rb = rigidbodies.get(RigidBodyID);
        // SET Pos
        rb.setPos(getMocapPositon(theOscMessage,2));
        //SET Orientation
        rb.setOrientation(getMocapRotation(theOscMessage,5));
      }
      // Else Add point to list
      else
      {
        RigidBody rm = new RigidBody(RigidBodyID, getMocapPositon(theOscMessage,2), getMocapRotation(theOscMessage,5));
        rigidbodies.put(RigidBodyID, rm);

        // Create graph for rigid body
        graphs.add(new Graph("none", RigidBodyID, graphX, graphY, 150, 100));
        setGraphPosition();
      }
    } // end IF

    // CHECK if we are dealing with a skeleton
    if (theOscMessage.checkAddrPattern("/skeleton")) {
      String SkeletonName = theOscMessage.get(0).stringValue();
     
      if (skeletons.containsKey(SkeletonName))
      {
        Skeleton sk = skeletons.get(SkeletonName);
        sk.updateInitJoints(theOscMessage);
      }
      else {
        Skeleton sk = new Skeleton(SkeletonName);
        sk.updateInitJoints(theOscMessage);
        skeletons.put(SkeletonName, sk);
        String[] bones = {"Hip","Ab","Neck","LHand"};
        sk.addGraphs(graphs,bones);
        
      }
    }

  }
}
