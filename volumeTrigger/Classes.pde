/***************************
 VolumeTrigger
 Send a trigger when object is inside
 
 - send OSC message when triggerd -> global client setting
 - send object name in osc message ?
 - x,y,z
 
 OSCmessage:
 Label: enter/inside/exit
 Values:
 - x/y/z postion object
 - speed ?
 
 Optie1:
 label is naam object en waardes zijn enter/inside/exit, naam triger en x/y/z positie en snelheid
 Optie2:
 label is enter/inside/exit en values zijn naam trigger en naam object x/y/z positie en snelheid
 ***************************/
class VolumeTrigger {

  // --> VARS
  PVector pos;
  PVector rot;
  PVector size;
  String name = "notset";
  boolean inside = false;
  boolean wasInside = false;

  // --> CONSTRUCTOR
  VolumeTrigger(String _name, PVector _pos, PVector _rot, PVector _size) {
    pos = _pos.copy();
    rot = _rot.copy();
    size = _size.copy();
    name = _name;
  }

  // --> METHODS
  // UPDATE using rigidbodies as input
  void update(HashMap<String, RigidBody> rigidbodies) {
    for (Map.Entry me : rigidbodies.entrySet ()) {
      RigidBody rb = (RigidBody) me.getValue();
      if(!rb.name.equals("Hyetograph")){
       update(rb.LocalPos,rb.name);
      }
    }
  }

  // OVERLAODED UPDATE using a PVector and name as input
  void update(PVector objPos, String objName) {

    //println(name+" -> "+objName+" :: "+pos+" :: "+objPos);
    // check if object is inside
    checkCollision(objPos);

    // sent triggers
    float[] v = {10.5}; // <-- Should become the speed at some point
    // list with the volume name and object name
    String[] names = {name,objName};
    // First time entering the volume
    if (wasInside == false && inside == true) {
      sendOSCMessage("/enter",names, v, remoteLocations); 
    } 
    // was already in the volume
    else if (wasInside == true && inside == true) {
      sendOSCMessage("/inside",names, v, remoteLocations);
    }
    // is exiting the volume
    else if (wasInside == true && inside == false) {
      sendOSCMessage("/exit",names, v, remoteLocations);
    }

    // set for next frame
    wasInside = inside;
  }


  void checkCollision(PVector objPos) {

    boolean xInside = false;
    boolean yInside = false;
    boolean zInside = false;

    // check X axis
    if (objPos.x < pos.x+(size.x/2) && objPos.x > pos.x-(size.x/2)) {
      xInside = true;
    }
    //println(objPos.x+" -> "+pos.x);

    // check y axis
    if (objPos.y < pos.y+(size.y/2) && objPos.y > pos.y-(size.y/2)) {
      yInside = true;
    }

    // check z axis
    if (objPos.z < pos.z+(size.z/2) && objPos.z > pos.z-(size.z/2)) {
      zInside = true;
    }

    // do final check
    // --> need to make a difference between just in or already in..
    if (xInside == true && yInside == true && zInside == true) { 
      inside=  true;
    } else {
      inside = false;
    }

    //println(frameCount,"inside->",inside, xInside, yInside, zInside);
  }



  void draw() {

    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateX(rot.x);
    rotateY(rot.y);
    rotateZ(rot.z);
    noFill();
    stroke(255);
    if (inside) {
      strokeWeight(5);
    } else {
      strokeWeight(1);
    }
    box(size.x, size.y, size.z);
    pushStyle();
    rotateX(rotations[0]);
    rotateY(rotations[1]);
    rotateZ(rotations[2]);
    textSize(18);
    textAlign(CENTER,CENTER);
    fill(255);
    text(name,0,0);
    popStyle();
    popMatrix();
  }

  
}