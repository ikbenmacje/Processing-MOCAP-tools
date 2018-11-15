class Graph
{
  // --> VARS
  PVector graphPos;
  PVector position, oldPosition, speed, maxSpeed;
  PVector orientation = new PVector(0,0,0);
  int w,h;
  float[] xp;
  float[] yp;
  float[] zp;
  float[] sp;
  int count;
  int[] mapX = {-3,3,0,0};
  int[] mapY = {3,0,0,0};
  int[] mapZ = {-3,3,0,0};
  int[] mapS = {5,0,0,0};
  String name = "";
  String skeletonName = "none";
  String rigidbodyName = "none";
  
  // --> CONSTRUCTOR
  Graph(String _skeletonName, String _rigidbodyName, int x, int y, int _w, int _h)
  {
    graphPos = new PVector(x,y);
    w = _w;
    h = _h;
    count = 0;
    skeletonName =  _skeletonName;
    rigidbodyName = _rigidbodyName;
    
    xp = new float[w];
    yp = new float[w];
    zp = new float[w];
    sp = new float[w];
    
    for(int i=0;i<xp.length;i++)
    {
      xp[i] = 0;
      yp[i] = 0;
      zp[i] = 0;
      sp[i] = 0;
    }
    
    // set height component
    mapX[3] = h;
    mapY[3] = h;
    mapZ[3] = h;
    mapS[3] = h;
    
    position = new PVector(0,0,0);
    speed = new PVector(0,0,0);
    oldPosition = new PVector(0,0,0);
    maxSpeed = new PVector(15,15,15);
  }
  
  // --> METHODS
  void display()
  {
    pushMatrix();
    translate(graphPos.x,graphPos.y);
    fill(100);
    noStroke();
    rect(0,0,w,h);
    beginShape();
    noFill();
    // X
    stroke(255,0,0);
    for(int i=0;i<xp.length;i++)
    {
      vertex(i,xp[i]);
    }
    endShape();
    
    // Y
    beginShape();
    stroke(0,255,0);
    for(int i=0;i<xp.length;i++)
    {
      vertex(i,yp[i]);
    }
    endShape();
    
    // Z
    stroke(0,0,255);
    beginShape();
    for(int i=0;i<xp.length;i++)
    {
      point(i,zp[i]);
    }
    endShape();
    
    // Speed
    stroke(255,255,0);
    beginShape();
    for(int i=0;i<xp.length;i++)
    {
      point(i,sp[i]);
    }
    endShape();
    
    stroke(0);
    int x = count%w;
    line(x,0,x,h);
    
    fill(255);
    textAlign(LEFT);
    text(name,0,-5);
    
    text("position:",-80,10);
    text("x: "+nf(position.x,2,2),-80,22);
    text("y: "+nf(position.y,2,2),-80,34);
    text("z: "+nf(position.z,2,2),-80,46);
    float mag = speed.mag();
    text("s: "+nf(mag,2,2),-80,58);
    
    pushMatrix();
    translate(w+50,25,0);
    rotateX(orientation.z);
    rotateY(orientation.x);
    rotateZ(orientation.y);
    box(25);
    popMatrix();
    
    
    OrientationCircle(orientation.x,w+20, 80,30, "x rot");
    OrientationCircle(orientation.y,w+55, 80,30, "y rot");
    OrientationCircle(orientation.z,w+90, 80,30, "z rot");
    speedBar(speed.x,maxSpeed.x, -30, h, color(255,0,0));
    speedBar(speed.y,maxSpeed.y, -20, h, color(0,255,0));
    speedBar(speed.z,maxSpeed.z, -12, h, color(0,0,255));
    
    //float mag = speed.mag();
    speedBar(mag,maxSpeed.z, -40, h, color(255,255,0));
    popMatrix();
  }
  
  void OrientationCircle(float or, int x, int y, int rad, String text)
  {
    pushMatrix();
    translate(x,y);
    float rx = sin(or) * rad/2;
    float ry = cos(or) * rad/2;
    
    line(0,0,rx,ry);
    textAlign(CENTER);
    text(text,0,-rad/2-5);
    ellipse(0,0,rad,rad);
    popMatrix();
    
    oldPosition = position.get();
    
    
  }
  
  void speedBar(float sp, float max, int x, int y, color col)
  {
    int w = 10;
    float h = map(abs(sp),0,max,0,-30);
    pushStyle();
    fill(col);
    rect(x,y,w,h);
    popStyle();
  }
  
  void update(RigidBody rb)
  {
    position = rb.WorldPos.copy();
    orientation = rb.orientation.copy();
    name = rb.name;
    
    speed = PVector.sub(position, oldPosition);
    //if(speed.x > maxSpeed.x) maxSpeed.x = speed.x;
    //if(speed.y > maxSpeed.y) maxSpeed.y = speed.y;
    //if(speed.z > maxSpeed.z) maxSpeed.z = speed.z;
    
    int i = count%w;
    xp[i] = map(position.x,mapX[0],mapX[1],mapX[2],mapX[3]);
    yp[i] = map(position.y,mapY[0],mapY[1],mapY[2],mapY[3]);
    zp[i] = map(position.z,mapZ[0],mapZ[1],mapZ[2],mapZ[3]);
    float sps = speed.mag();
    sp[i] = map(sps,mapS[0],mapS[1],mapS[2],mapS[3]);
    
    count ++;
  }

}