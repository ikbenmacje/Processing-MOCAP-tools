// STRUCT to sue as data container vor the convert Quarternion to Eular Angles
class Quat4d{
  
  // --> VARS
  float x,y,z,w;

  // --> CONSTRUCTOR
  Quat4d(){
  }
}


//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> RIGIDBODY
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
class RigidBody {

  // --> VARS
  PVector WorldPos, LocalPos;
  PVector WorldOr, LocalOr;
  String name;
  color col;

  // --> CONSTRUCTOR
  RigidBody(String _name)
  {
    name = _name;
    col = color(255);
    WorldPos = new PVector(0, 0, 0);
    LocalPos = new PVector(0, 0, 0);
    WorldOr = new PVector(0, 0, 0);
    LocalOr = new PVector(0, 0, 0);
  }

  RigidBody(String _name, PVector _pos, Quat4d q1)
  {
    name = _name;
    col = color(255);
    WorldPos = _pos.get();
    LocalPos = _pos.get();
    WorldOr = convertQuart(q1);
    LocalOr = convertQuart(q1);
  }

  // --> METHODS
  void setPos(PVector _pos)
  {
    WorldPos = _pos.get();
  }

  void setOrientation(Quat4d q1)
  {
    LocalOr = convertQuart(q1);
    WorldOr = convertQuart(q1);
  }

  void printData()
  {
    println("-----"+name+"--------------------------");
    println("LocalPos: "+LocalPos);
    println("WorldPos: "+WorldPos);
    println("--------------------------");
  }
  
  void showData(PVector pos)
  {
    textSize(12);
    String t = "-----"+name+"------------\n";
    t += "LocalPos: "+LocalPos+"\n";
    t += "WorldPos: "+WorldPos+"\n";
    t += "--------------------------\n";
    text(t,pos.x,pos.y);
  }

  void reMap()
  {
    // MOCAP
    // x = front to back
    // y == up and down
    // z = left to right

    // PRocessing
    // x = left to right
    // y = front back
    // z = up and down
    float y = map(WorldPos.z, Ymap[0], Ymap[1], Ymap[2], Ymap[3]);
    float x = map(WorldPos.x, Xmap[0], Xmap[1], Xmap[2], Xmap[3]);
    float z = map(WorldPos.y, Zmap[0], Zmap[1], Zmap[2], Zmap[3]);

    LocalPos.set(x, y, z);
    //print(x, y, z);
  }

  void display()
  {
    pushMatrix();
    translate(LocalPos.x, LocalPos.y, LocalPos.z);
    rotateX(LocalOr.x);
    rotateY(LocalOr.y);
    rotateZ(LocalOr.z);
    fill(col, 100);
    noStroke();
    box(4);
    stroke(0, 0, 255);
    strokeWeight(2);
    line(0, 0, 0, 20);
    stroke(255, 0, 0);
    line(0, 0, 20, 0);
    stroke(0, 255, 0);
    line(0, 0, 0, 0, 0, 20);
    popMatrix();
  }
}

//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> SKELETON
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

class Skeleton {

  //ArrayList<RigidBody> rigidbodies;
  HashMap<String, RigidBody> rigidbodies;
  boolean hasJoints = false;
  String name;
  color col;

  Skeleton(String _name)
  {
    //rigidbodies = new ArrayList<RigidBody>();
    rigidbodies = new HashMap<String, RigidBody>();
    name = _name;
    col = color(random(50, 200), random(150, 210), random(150, 180));
  }

  void initJoints(OscMessage theOscMessage)
  {
    println("##### START INIT SKELETON: ", name);
    // get number of Joints
    // each joint consists of 8 numbers
    // minus two because first two arguments are the name and Id of the skeleton
    int numVar = theOscMessage.typetag().length() -2;
    int numJoints = numVar / 8;
    //println("numJoints "+numJoints);

    for (int i=0; i<numVar; i+=8)
    {
      // offset because first two values are the id and name of the skeleton
      int index = i+2;
      String label = theOscMessage.get(index).stringValue();
      // Get rid of the skeleton name if it is infornt of the bone name
      // BEWARE OF UNDERSCORE IN SKELETONNAMES !!!
      int underscorePos = label.indexOf("_");
      if (underscorePos != -1) {
        label = label.substring(underscorePos+1);
      }
      //println(label);

      PVector pos = new PVector(theOscMessage.get(index+1).floatValue(), theOscMessage.get(index+2).floatValue(), theOscMessage.get(index+3).floatValue());
      
      Quat4d q1 = new Quat4d();
      q1.x = theOscMessage.get(index+4).floatValue();
      q1.y = theOscMessage.get(index+5).floatValue();
      q1.z = theOscMessage.get(index+6).floatValue();
      q1.w = theOscMessage.get(index+7).floatValue();

      RigidBody rm = new RigidBody(label, pos, q1);
      rm.reMap();
      rm.col = col;
      //println(label);
      rigidbodies.put(label, rm); 
    }
  }


  void updateJoints(OscMessage theOscMessage)
  {

    // get number of Joints
    // each joint consists of 8 numbers
    // minus two because first two arguments are the name and Id of the skeleton
    int numVar = theOscMessage.typetag().length() -2;
    int numJoints = numVar / 8;
    //println("numJoints: ", numJoints);

    int index = 2; 
    for (Map.Entry me : rigidbodies.entrySet ()) {
      RigidBody rb = (RigidBody) me.getValue();

      PVector pos = new PVector(theOscMessage.get(index+1).floatValue(), theOscMessage.get(index+2).floatValue(), theOscMessage.get(index+3).floatValue());
      //println(rb.name,pos);
      Quat4d q1 = new Quat4d();
      q1.x = theOscMessage.get(index+4).floatValue();
      q1.y = theOscMessage.get(index+5).floatValue();
      q1.z = theOscMessage.get(index+6).floatValue();
      q1.w = theOscMessage.get(index+7).floatValue();

      rb.setPos(pos);
      rb.reMap();
      rb.setOrientation(q1);
     
      // Add to the index
      index += 8;
    }
  }

  void display()
  {

    // loop through the hashmap
    for (Map.Entry me : rigidbodies.entrySet ()) {
      RigidBody rb = (RigidBody) me.getValue();
      rb.display();
    }
  }
  
  void printData()
  {
    // loop through the hashmap
    for (Map.Entry me : rigidbodies.entrySet ()) {
      RigidBody rb = (RigidBody) me.getValue();
      if(rb.name.equals("Hip")){
        rb.printData();
      }
    }
  }
}