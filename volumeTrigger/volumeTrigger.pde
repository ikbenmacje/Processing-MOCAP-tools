import java.util.*;
import oscP5.*;
import netP5.*;
import peasy.*;
import controlP5.*;

/*************************
 TODO:
 *************************/

OscP5 oscP5;
ControlP5 cp5;
ScrollableList scrollList;
Group g3;
NetAddress[] remoteLocations;
PeasyCam cam;

HashMap<String, VolumeTrigger> volumetriggers;
HashMap<String, RigidBody> rigidbodies;
HashMap<String, Skeleton> skeletons;
XML xml;


// --> VARS
boolean showGrid = true;
float[] rotations;
PFont font;

String[] labels = {"Xpos", "Ypos", "Zpos", "Xscale", "Yscale", "Zscale"};
String ctrlEventName = "";
String selectedVolume = "";
String rigidBody = "rigidBody";
String skeleton = "skeleton";
int count = 0;


void setup() {
  size(1024, 768, P3D);

  // GUI
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  setupGui();

  volumetriggers = new HashMap<String, VolumeTrigger>();

  // Load data from XML
  loadData();

  // INIT the rigidbodies
  rigidbodies = new HashMap<String, RigidBody>();

  // INIT the skeletons
  skeletons = new HashMap<String, Skeleton>();

  // Camera stuff
  cam = new PeasyCam(this, 600);
  cam.setMinimumDistance(0.001);
  cam.setMaximumDistance(2000);

  rotations = new float[3];

  /* start oscP5, listening for incoming messages at port 12000 */
  /* create a new osc properties object */
  OscProperties properties = new OscProperties();
  // Bigger datagram size means you can reciever bigger packets 
  properties.setDatagramSize(6000);
  properties.setListeningPort(6200);
  oscP5 = new OscP5(this, properties);
  
  // Remot elocations is an array so you cna send to mulitple clients
  remoteLocations = new NetAddress[2];
  remoteLocations[0] = new NetAddress("127.0.0.1", 1234);
  remoteLocations[1] = new NetAddress("10.200.200.173", 7000);

  // FONT
  font = createFont("Courier", 12);
  textFont(font);
}



void draw() {
  background(0);

  // SLIDER CAMERA HACK
  if (mouseX < 200 && mouseY < 300) { 
    cam.setActive(false);
  } else {
    cam.setActive(true);
  }


  // Camera Stuff
  rotations = cam.getRotations(); // x, y, and z rotations required to face camera in model space
  float[] position = cam.getPosition();
  //cam.setYawRotationMode();   // like spinning a globe
  //cam.setPitchRotationMode(); // like a somersault
  //cam.setRollRotationMode();  // like a radio knob
  //cam.setSuppressRollRotationMode();  // Permit pitch/yaw only

  if (showGrid) grid(30, 50);

  // drawVector(newV, oldV, 1, color(0,255,0));

  // Update the volumes if there are rigidbodies
  if (rigidbodies.size() > 0) {
    for (Map.Entry me : volumetriggers.entrySet ()) {
      VolumeTrigger vt = (VolumeTrigger) me.getValue();
      vt.update(rigidbodies);
    }
  }

  // Update the volumes if there are skeletons
  if (skeletons.size() > 0) {
    for (Map.Entry me1 : skeletons.entrySet ()) {
      Skeleton sk = (Skeleton) me1.getValue();
      for (Map.Entry me : volumetriggers.entrySet ()) {
        VolumeTrigger vt = (VolumeTrigger) me.getValue();
        vt.update(sk.rigidbodies);
      }
    }
  }

  // Display the volumes
  for (Map.Entry me : volumetriggers.entrySet ()) {
    VolumeTrigger vt = (VolumeTrigger) me.getValue();
    vt.draw();
  }

  // Display the rigid bodies
  for (Map.Entry me : rigidbodies.entrySet ()) {
    RigidBody rb = (RigidBody) me.getValue();
    rb.display();
    //rb.printData();
  }

  // Display Skeletons
  // loop through the hashmap
  for (Map.Entry me : skeletons.entrySet ()) {
    Skeleton sk = (Skeleton) me.getValue();
    sk.display();
    //sk.printData();
  }

  // Show Gui
  displayGui();
  frame.setTitle(int(frameRate) + " fps");
}


void keyReleased()
{
  if (key == '1')    // TOP
  {
    float[] rot = {0, 0, 0};
    setCamera(600, cam.getLookAt(), rot, 1000);
  }
  if (key == '2')  // FRONT
  {
    float[] rot = {-1.5, 0, 0};
    setCamera(600, cam.getLookAt(), rot, 1000);
  }
  if (key == '3') // RIGHT
  {
    float[] rot = {0, -1.5, HALF_PI};
    setCamera(600, cam.getLookAt(), rot, 1000);
  }

  if (key== 'g') showGrid = !showGrid;

  if ( key == 'q') { 
    if (g3.isVisible()) g3.setVisible(false);
    else g3.setVisible(true);
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  //print("### received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //println(" typetag: "+theOscMessage.typetag()+" length: "+theOscMessage.typetag().length());

  // FIRST check if we are dealing with a rigidbody
  if (theOscMessage.checkAddrPattern("/"+rigidBody)) {


    // GET LOCATION ORIENTATION
    PVector pos = new PVector( theOscMessage.get(2).floatValue(), theOscMessage.get(3).floatValue(), theOscMessage.get(4).floatValue());
    Quat4d q1 = new Quat4d();
    q1.x = theOscMessage.get(5).floatValue();
    q1.y = theOscMessage.get(6).floatValue();
    q1.z = theOscMessage.get(7).floatValue();
    q1.w = theOscMessage.get(8).floatValue();


    // Then make the rigidbody ID
    //String RigidBodyID = rigidBody+str(theOscMessage.get(0).intValue());
    String RigidBodyID = theOscMessage.get(1).stringValue();
    //println(RigidBodyID);

    // See if it is present in the hashmap
    if (rigidbodies.containsKey(RigidBodyID))
    {
      // Get the rigidbody from the hashmap
      RigidBody rb = rigidbodies.get(RigidBodyID);
      // SET Pos
      rb.setPos(pos);
      rb.reMap();
      //SET Orientation
      rb.setOrientation(q1);
    }
    // Add point to list
    else
    {
      RigidBody rm = new RigidBody(RigidBodyID, pos, q1);
      rigidbodies.put(RigidBodyID, rm);
    }
  } // end IF


  // SECOND check if we are dealing with skeletons
  if (theOscMessage.checkAddrPattern("/"+skeleton)) {
    String skeletonID = theOscMessage.get(1).stringValue(); 
    // See if it is present in the hashmap
    if (skeletons.containsKey(skeletonID))
    {
      //println("known skeleton: "+skeletonID);
      Skeleton sk = (Skeleton) skeletons.get(skeletonID);
      sk.updateJoints(theOscMessage);
    }
    // ADD new skeleton to the list
    else
    {
      println(" -----> new skeleton: "+skeletonID);
      Skeleton sk = new Skeleton(skeletonID);
      skeletons.put(skeletonID, sk);
      sk.initJoints(theOscMessage);
    }
  }
}


// Get the item from the list

public void volumelist(int n) {

  Map l =  (Map) cp5.get(ScrollableList.class, "volumelist").getItem(n);
  String name = (String) l.get("name");

  if (volumetriggers.containsKey(name)) {
    selectedVolume = name;
    println("selectedVolume: "+selectedVolume);

    VolumeTrigger vt = volumetriggers.get(selectedVolume);


    float[] values = {vt.pos.x, vt.pos.y, vt.pos.z, vt.size.x, vt.size.y, vt.size.z};

    // set sliders to values of object
    for (int i=0; i<labels.length; i++) {
      cp5.get(Slider.class, labels[i]).setBroadcast(false).setValue(values[i]).setBroadcast(true);
    }
  }
}

void controlEvent(ControlEvent theEvent) {
  println("got a control event from controller with name "+theEvent.getController().getName());


  // this is needed so that we are sure all the objects are laready made before we do event handeling
  if (frameCount > 1) { 
    // extra check to make sure that a volume is selected
    println("selectedVolume: "+selectedVolume);
    if (volumetriggers.containsKey(selectedVolume)) {
      VolumeTrigger vt = volumetriggers.get(selectedVolume);
      boolean update = false;

      if (theEvent.isFrom(cp5.getController("Xpos")) ) {
        vt.pos.x = theEvent.getController().getValue();
        update = true;
      } else if (theEvent.isFrom(cp5.getController("Ypos")) ) {
        vt.pos.y = theEvent.getController().getValue();
        update = true;
      } else if (theEvent.isFrom(cp5.getController("Zpos")) ) {
        vt.pos.z = theEvent.getController().getValue();
        update = true;
      } else if (theEvent.isFrom(cp5.getController("Xscale")) ) {
        vt.size.x = theEvent.getController().getValue();
        update = true;
      } else if (theEvent.isFrom(cp5.getController("Yscale")) ) {
        vt.size.y = theEvent.getController().getValue();
        update = true;
      } else if (theEvent.isFrom(cp5.getController("Zscale")) ) {
        vt.size.z = theEvent.getController().getValue();
        update = true;
      }

      // Save to XML
      if (update) {
        println("Control event save .. ");
        saveData(vt);
      }

      if (theEvent.isFrom(cp5.getController("delete selected")) ) {
        // delete selected !!
        println("delete: "+selectedVolume);
        deleteData(selectedVolume);
        cp5.get(ScrollableList.class, "volumelist").setBroadcast(false).removeItem(selectedVolume).setBroadcast(true);
        volumetriggers.remove(selectedVolume);
      }
    }

    if (theEvent.isFrom(cp5.getController("create")) || theEvent.isFrom(cp5.getController("input"))) {
      println("CREATE!");
      String  name = cp5.get(Textfield.class, "input").getText();
      VolumeTrigger vt = new VolumeTrigger(name, new PVector(0, 0, 0), new PVector(0, 0, 0), new PVector(40, 40, 40));
      volumetriggers.put(name, vt);
      scrollList.addItem(name, count);
      count++;

      // Save to XML
      saveData(vt);
    }
  }
}


// Uncomment to run without frame (ful screen from the ide)
/*
public void init() {
 frame.removeNotify(); 
 frame.setUndecorated(true); // works. //true
 
 // call PApplet.init() to take care of business
 super.init();  
 frame.addNotify();
 }
 */
