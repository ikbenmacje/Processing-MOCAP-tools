//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> RIGIDBODY CLASS
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
class RigidBody {

  // --> VARS
  PVector WorldPos, LocalPos;
  PVector orientation;
  String name;
  color col;

  // --> CONSTRUCTOR
  RigidBody(String _name)
  {
    name = _name;
    col = color(255);
    WorldPos = new PVector(0, 0, 0);
    LocalPos = new PVector(0, 0, 0);
    orientation = new PVector(0, 0, 0);
  }

  RigidBody(String _name, PVector _pos, Quaternion q1)
  {
    name = _name;
    col = color(255);
    WorldPos = _pos.copy();
    LocalPos = _pos.copy();
    orientation = q1.getEulerAngles();
  }

  // --> METHODS
  void setPos(PVector _pos)
  {
    WorldPos = _pos.copy();
  }

  void setOrientation(Quaternion q1)
  {
    orientation = q1.getEulerAngles();
  }

  void printData()
  {
    println("-----"+name+"--------------------------");
    println("LocalPos: "+LocalPos);
    println("WorldPos: "+WorldPos);
    println("--------------------------");
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
    float x = map(WorldPos.z, Xmap[0], Xmap[1], Xmap[2], Xmap[3]);
    float y = map(WorldPos.x, Ymap[0], Ymap[1], Ymap[2], Ymap[3]);
    float z = map(WorldPos.y, Zmap[0], Zmap[1], Zmap[2], Zmap[3]);

    LocalPos.set(x, y, z);
    //print(x, y, z);
  }

  void display()
  {
    pushMatrix();
    translate(LocalPos.x, LocalPos.y, LocalPos.z);
    rotateX(orientation.x);
    rotateY(orientation.y);
    rotateZ(orientation.z);
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
// --> SKELETON CLASS
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
class Skeleton {

  HashMap<String, RigidBody> rigidbodies;
  boolean hasJoints = false;
  String name;

  Skeleton(String _name)
  {
    rigidbodies = new HashMap<String, RigidBody>();
    name = _name;
  }


  // Update or init joint data
  void updateInitJoints(OscMessage theOscMessage)
  {

    int startIndex = 2;
    // Number items are either the incoming OSCmessage when first time otherwise
    // it is the number of bones we have.
    int numItems = (theOscMessage.typetag().length()-startIndex)/8;
    if (hasJoints) numItems = rigidbodies.size();

    for (int i = 0; i < numItems; i++) {
      int index = startIndex + i*8;

      // If we have initialized them then only update them
      if (hasJoints) {
        RigidBody rb = rigidbodies.get(theOscMessage.get(index).stringValue());
        rb.setPos(getMocapPositon(theOscMessage, index+1));
        rb.setOrientation(getMocapRotation(theOscMessage, index+4));
        rb.reMap();
      } 
      // ELSE when there are no bones yet make them
      else 
      {
        String label = theOscMessage.get(index).stringValue();
        RigidBody rb = new RigidBody(label, getMocapPositon(theOscMessage, index+1), getMocapRotation(theOscMessage, index+4));
        rigidbodies.put(label, rb);
      }
    }

    // This is the set first tim when it is run
    if (!hasJoints) hasJoints = true;
  }


  void addGraphs(ArrayList<Graph> graphs, String[] ids) {    

    for (int i=0; i < ids.length; i++)
    {
      // Naming convention of bones is nameSkeleton_nameRigidBody
      String boneName = name+"_"+ids[i];
      RigidBody rb = rigidbodies.get(boneName);
      println(boneName);
      graphs.add(new Graph(name, rb.name, graphX, graphY, 150, 100));
      setGraphPosition();
    }
  }

  void display()
  {
    // loop through the hashmap
    for (Map.Entry me : rigidbodies.entrySet()) {  
      RigidBody rb = (RigidBody) me.getValue();
      rb.display();
    }
  }
}



// Credits for the Quaternion class go to https://github.com/davidjonas
// this class is from: https://github.com/davidjonas/MoCap
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> QUARTERNION CLASS
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
public class Quaternion {
  public  float  X, Y, Z, W;

  public Quaternion() {
    X = 0.0;
    Y = 0.0;
    Z = 0.0;
    W = 1.0;
  }

  public Quaternion(float x, float y, float z, float w) {
    X = x;
    Y = y;
    Z = z;
    W = w;
  }

  // quaternion multiplication
  public Quaternion mult (Quaternion q) {
    float w = W*q.W - (X*q.X + Y*q.Y + Z*q.Z);

    float x = W*q.X + q.W*X + Y*q.Z - Z*q.Y;
    float y = W*q.Y + q.W*Y + Z*q.X - X*q.Z;
    float z = W*q.Z + q.W*Z + X*q.Y - Y*q.X;

    W = w;
    X = x;
    Y = y;
    Z = z;
    return this;
  }

  // conjugates the quaternion
  public Quaternion conjugate () {
    X = -X;
    Y = -Y;
    Z = -Z;
    return this;
  }

  // inverts the quaternion
  public Quaternion reciprical () {
    float norme = sqrt(W*W + X*X + Y*Y + Z*Z);
    if (norme == 0.0)
      norme = 1.0;

    float recip = 1.0 / norme;

    W =  W * recip;
    X = -X * recip;
    Y = -Y * recip;
    Z = -Z * recip;

    return this;
  }

  // sets to unit quaternion
  public Quaternion normalize() {
    float norme = sqrt(W*W + X*X + Y*Y + Z*Z);
    if (norme == 0.0)
    {
      W = 1.0; 
      X = Y = Z = 0.0;
    } else
    {
      float recip = 1.0/norme;

      W *= recip;
      X *= recip;
      Y *= recip;
      Z *= recip;
    }
    return this;
  }

  // Makes quaternion from axis
  public Quaternion fromAxis(float Angle, float x, float y, float z) { 
    float omega, s, c;

    s = sqrt(x*x + y*y + z*z);

    if (abs(s) > Float.MIN_VALUE)
    {
      c = 1.0/s;

      x *= c;
      y *= c;
      z *= c;

      omega = -0.5f * Angle;
      s = (float)sin(omega);

      X = s*x;
      Y = s*y;
      Z = s*z;
      W = (float)cos(omega);
    } else
    {
      X = Y = 0.0f;
      Z = 0.0f;
      W = 1.0f;
    }
    normalize();
    return this;
  }

  public Quaternion fromAxis(float Angle, PVector axis) {
    return this.fromAxis(Angle, axis.x, axis.y, axis.z);
  }

  // Rotates towards other quaternion
  public void slerp(Quaternion a, Quaternion b, float t)
  {
    float omega, cosom, sinom, sclp, sclq;

    cosom = a.X*b.X + a.Y*b.Y + a.Z*b.Z + a.W*b.W;


    if ((1.0f+cosom) > Float.MIN_VALUE)
    {
      if ((1.0f-cosom) > Float.MIN_VALUE)
      {
        omega = acos(cosom);
        sinom = sin(omega);
        sclp = sin((1.0f-t)*omega) / sinom;
        sclq = sin(t*omega) / sinom;
      } else
      {
        sclp = 1.0f - t;
        sclq = t;
      }

      X = sclp*a.X + sclq*b.X;
      Y = sclp*a.Y + sclq*b.Y;
      Z = sclp*a.Z + sclq*b.Z;
      W = sclp*a.W + sclq*b.W;
    } else
    {
      X =-a.Y;
      Y = a.X;
      Z =-a.W;
      W = a.Z;

      sclp = sin((1.0f-t) * PI * 0.5);
      sclq = sin(t * PI * 0.5);

      X = sclp*a.X + sclq*b.X;
      Y = sclp*a.Y + sclq*b.Y;
      Z = sclp*a.Z + sclq*b.Z;
    }
  }

  public Quaternion exp()
  {                               
    float Mul;
    float Length = sqrt(X*X + Y*Y + Z*Z);

    if (Length > 1.0e-4)
      Mul = sin(Length)/Length;
    else
      Mul = 1.0;

    W = cos(Length);

    X *= Mul;
    Y *= Mul;
    Z *= Mul; 

    return this;
  }

  public Quaternion log()
  {
    float Length;

    Length = sqrt(X*X + Y*Y + Z*Z);
    Length = atan(Length/W);

    W = 0.0;

    X *= Length;
    Y *= Length;
    Z *= Length;

    return this;
  }

  public int getGimbalPole() {
    final float t = Y*X+Z*W;
    return t > 0.499f ? 1 : (t < -0.499f ? -1 : 0);
  }

  //rotation around the z axis
  public float getRollRad() {
    final int pole = getGimbalPole();
    return pole == 0 ? atan2(2f*(W*Z + Y*X), 1f - 2f * (X*X + Z*Z)) : (float)pole * 2f * atan2(Y, W);
  }


  //rotation around the x axis
  public float getPitchRad() {
    final int pole = getGimbalPole();
    return pole == 0 ? (float)asin(clamp(2f*(W*X-Z*Y), -1f, 1f)) : (float)pole * PI * 0.5f;
  }

  //rotation around the y axis
  public float getYawRad() {
    return getGimbalPole() == 0 ? atan2(2f*(Y*W + X*Z), 1f - 2f*(Y*Y+X*X)) : 0f;
  }

  public PVector getEulerAngles()
  {
    return new PVector(getPitchRad(), getYawRad(), getRollRad());
  }

  public float clamp(float num, float min_lim, float max_lim)
  {
    if (num < min_lim)
    {
      return min_lim;
    }
    if (num > max_lim)
    {
      return max_lim;
    } else
    {
      return num;
    }
  }
}
