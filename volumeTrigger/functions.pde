//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> XML RELATED FUNCTIONS 
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
void loadData() {
  // Load XML file
  xml = loadXML("data/data.xml");
  // Get all the child nodes named "volume"
  XML[] children = xml.getChildren("volume");

  for (int i = 0; i < children.length; i++) {

    // The position element has two attributes: x and y
    XML positionElement = children[i].getChild("position");
    // Note how with attributes we can get an integer or float via getInt() and getFloat()
    float xp = positionElement.getFloat("x");
    float yp = positionElement.getFloat("y");
    float zp = positionElement.getFloat("z");

    // The position element has two attributes: x and y
    XML scaleElement = children[i].getChild("size");
    // Note how with attributes we can get an integer or float via getInt() and getFloat()
    float xs = scaleElement.getFloat("x");
    float ys = scaleElement.getFloat("y");
    float zs = scaleElement.getFloat("z");

    // The label is the content of the child named "label"
    XML labelElement = children[i].getChild("label");
    String label = labelElement.getContent();

    VolumeTrigger vt = new VolumeTrigger(label, new PVector(xp, yp, zp), new PVector(0, 0, 0), new PVector(xs, ys, zs));
    volumetriggers.put(label, vt);
    scrollList.addItem(label, count);
    count++;
  }
}  

void saveData(VolumeTrigger vt) {

  boolean isNewVolume = true;
  XML[] children = xml.getChildren("volume");
  // see if volume is already presetn in XML
  for (int i = 0; i < children.length; i++) {
    XML labelElement = children[i].getChild("label");
    String label = labelElement.getContent();
    // IF it is already present then update it
    if (label.equals(vt.name)) {

      println(" UPDATE not NEW");
      // not a new volume update ..
      isNewVolume = false;

      // The position element has two attributes: x and y
      XML positionElement = children[i].getChild("position");
      positionElement.setFloat("x", vt.pos.x);
      positionElement.setFloat("y", vt.pos.y);
      positionElement.setFloat("z", vt.pos.z);

      // The position element has two attributes: x and y
      XML scaleElement = children[i].getChild("size");
      // Note how with attributes we can get an integer or float via getInt() and getFloat()
      scaleElement.setFloat("x", vt.size.x);
      scaleElement.setFloat("y", vt.size.y);
      scaleElement.setFloat("z", vt.size.z);

      // Save a new XML file
      saveXML(xml, "data/data.xml");
      break;
    }
  }

  // It is a new volume so add it..
  if (isNewVolume) {
    // save data
    // Create a new XML bubble element
    XML volume = xml.addChild("volume");

    // Set the poisition element
    XML position = volume.addChild("position");
    // Here we can set attributes as integers directly
    position.setFloat("x", vt.pos.x);
    position.setFloat("y", vt.pos.y);
    position.setFloat("z", vt.pos.z);

    // Set the poisition element
    XML size = volume.addChild("size");
    // Here we can set attributes as integers directly
    size.setFloat("x", vt.size.x);
    size.setFloat("y", vt.size.y);
    size.setFloat("z", vt.size.z);

    XML label = volume.addChild("label");
    label.setContent(vt.name);

    // Save a new XML file
    saveXML(xml, "data/data.xml");
    println("save NEW...");
  }
}

void deleteData(String name) {
  
  XML[] children = xml.getChildren("volume");
  // see if volume is already presetn in XML
  for (int i = 0; i < children.length; i++) {
    XML labelElement = children[i].getChild("label");
    String label = labelElement.getContent();
    // IF it is already present then update it
    if (label.equals(name)) {
      xml.removeChild(children[i]);
      break;
    }
  }
  saveXML(xml, "data/data.xml");
  println("deleted from XML");
}


//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> GUI RELATED FUNCTIONS 
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
void displayGui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void setupGui() {

  int sliderW = 120;
  int xpad = 5;
  int minSL = -300;
  int maxSL = 300;
  int minSize = 10;
  int maxSize = 400;

  g3 = cp5.addGroup("g3")
    .setPosition(20, 20)
    .setSize(170, 300)
    .setBackgroundColor(color(255, 100))
    ;

  scrollList = cp5.addScrollableList("volumelist")
    .setPosition(xpad, 135)
    .setSize(sliderW, 100)
    .setGroup(g3);

  cp5.addButton("delete selected")
    .setValue(0)
    .setPosition(xpad, 75)
    .setSize(sliderW, 9)
    .setGroup(g3);
  ;

  cp5.addTextfield("input")
    .setPosition(xpad, 90)
    .setSize(sliderW, 15)
    .setFocus(true)
    .setGroup(g3);
  ;

  cp5.addButton("create")
    .setValue(0)
    .setPosition(xpad+30, 110)
    .setSize(sliderW-30, 9)
    .setGroup(g3);
  ;

  // ADD sliders for position
  cp5.addSlider("Xpos")
    .setPosition(xpad, 10)
    .setSize(sliderW, 9)
    .setRange(minSL, maxSL)
    .setGroup(g3)
    ;

  cp5.addSlider("Ypos")
    .setPosition(xpad, 20)
    .setSize(sliderW, 9)
    .setRange(minSL, maxSL)
    .setGroup(g3)
    ;

  cp5.addSlider("Zpos")
    .setPosition(xpad, 30)
    .setSize(sliderW, 9)
    .setRange(minSL, maxSL)
    .setGroup(g3)
    ;

  // ADD sliders for scale
  cp5.addSlider("Xscale")
    .setPosition(xpad, 40)
    .setSize(sliderW, 9)
    .setRange(minSize, maxSize)
    .setGroup(g3)
    ;
  cp5.addSlider("Yscale")
    .setPosition(xpad, 50)
    .setSize(sliderW, 9)
    .setRange(minSize, maxSize)
    .setGroup(g3)
    ;
  cp5.addSlider("Zscale")
    .setPosition(xpad, 60)
    .setSize(sliderW, 9)
    .setRange(minSize, maxSize)
    .setGroup(g3)
    ;
}


//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> OSC MESSAGE RELATED FUNCTIONS 
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
void sendOSCMessage(String label, float[] values, NetAddress[] locations) {

  OscMessage myMessage = new OscMessage(label);
  // add all the values
  for (int i=0; i < values.length; i++) {
    myMessage.add(values[i]);
  }
  // send to all recipients
  for (int i=0; i<locations.length; i++) {
    oscP5.send(myMessage, locations[i]);
  }

  println(label);
}

void sendOSCMessage(String label, String[] vals1, float[] vals2, NetAddress[] locations) {

  OscMessage myMessage = new OscMessage(label);
  // add all the values
  for (int i=0; i < vals1.length; i++) {
    myMessage.add(vals1[i]);
  }
  for (int i=0; i < vals2.length; i++) {
    myMessage.add(vals2[i]);
  }
  // send to all recipients
  for (int i=0; i<locations.length; i++) {
    oscP5.send(myMessage, locations[i]);
  }
}

//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> MISC FUNCTIONS 
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
PVector convertQuart(float x, float y, float z, float w) {
  double test = x*y + z*w;
  double heading =0;
  double attitude =0;
  double bank =0;


  if (test > 0.499) { // singularity at north pole
    heading =  2 * Math.atan2(x, w);
    attitude = Math.PI/2;
    bank = 0;
    //return;
  }
  if (test < -0.499) { // singularity at south pole
    heading = -2 * Math.atan2(x, w);
    attitude = - Math.PI/2;
    bank = 0;
    //return;
  }
  double sqx = x * x;
  double sqy = y * y;
  double sqz = z* z;
  heading = Math.atan2(2* y* w-2* x* z, 1 - 2*sqy - 2*sqz);
  attitude = Math.asin(2*test);
  bank = Math.atan2(2* x* w-2* y* z, 1 - 2*sqx - 2*sqz);

  PVector data = new PVector((float)heading, (float)attitude, (float)bank);
  return data;
}

PVector convertQuart(Quat4d q1) {
  double test = q1.x*q1.y + q1.z*q1.w;
  double heading =0;
  double attitude =0;
  double bank =0;


  if (test > 0.499) { // singularity at north pole
    heading =  2 * Math.atan2(q1.x, q1.w);
    attitude = Math.PI/2;
    bank = 0;
    //return;
  }
  if (test < -0.499) { // singularity at south pole
    heading = -2 * Math.atan2(q1.x, q1.w);
    attitude = - Math.PI/2;
    bank = 0;
    //return;
  }
  double sqx = q1.x*q1.x;
  double sqy = q1.y*q1.y;
  double sqz = q1.z*q1.z;
  heading = Math.atan2(2*q1.y*q1.w-2*q1.x*q1.z, 1 - 2*sqy - 2*sqz);
  attitude = Math.asin(2*test);
  bank = Math.atan2(2*q1.x*q1.w-2*q1.y*q1.z, 1 - 2*sqx - 2*sqz);

  PVector data = new PVector((float)heading, (float)attitude, (float)bank);
  return data;
}

boolean insidePolygon2(float x, float y, PVector[] p) {

  int i, j, c = 0;
  for (i = 0, j = p.length-1; i < p.length; j = i++) {
    if ((((p[i].y <= y) && (y < p[j].y)) || ((p[j].y <= y) && (y < p[i].y))) && (x < (p[j].x - p[i].x) * (y - p[i].y) / (p[j].y - p[i].y) + p[i].x)) c = (c+1)%2;
  }
  return c==1;
}

// Renders a vector object 'v' as an arrow and a location 'loc'
void drawVector(PVector v, PVector loc, float scayl, color col) {
  pushMatrix();
  float arrowsize = 4;
  // Translate to location to render vector
  translate(loc.x, loc.y);
  stroke(col);
  // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
  rotate(v.heading2D());
  // Calculate length of vector & scale it to be bigger or smaller if necessary
  float len = v.mag()*scayl;
  //  println("len: "+len);
  // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
  line(0, 0, len, 0);
  line(len, 0, len-arrowsize, +arrowsize/2);
  line(len, 0, len-arrowsize, -arrowsize/2);
  popMatrix();
}


void setCamera(int distance, float[] pos, float[] rot, int time) {
  PeasyCam camTemp;
  camTemp = new PeasyCam(this, distance  );
  camTemp.setRotations(rot[0], rot[1], rot[2]); // rotations are applied in that order
  camTemp.lookAt(pos[0], pos[1], pos[2]);
  CameraState state = camTemp.getState(); // get a serializable settings object for current state
  cam.setState(state, time); // set the camera to the given saved state
}


//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
// --> SHOW GRID
//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
void grid(int lines, float scale) {

  float gridRadius = lines * scale;
  float step = (lines*scale)/lines;
  int halfway = int(lines/2);

  pushStyle();
  strokeWeight(2);
  pushMatrix();
  translate(halfway*-step, halfway*-step, 0);

  for (int i = 0; i <= lines; i++) {

    float pos = i*step;
    if (i==halfway) {
      //X-axis red
      stroke(255, 0, 0, 128);
      line(0, pos, 0, gridRadius, pos, 0);
      //Y-axis green
      stroke(0, 255, 0);
      line(pos, 0, 0, pos, gridRadius, 0);
      //Z axis blue
      stroke(0, 0, 255, 128);
      line(pos, pos, -gridRadius, pos, pos, gridRadius);
    } else {
      stroke(140, 140, 140, 128);
      line(pos, 0, 0, pos, gridRadius, 0);
      line(0, pos, 0, gridRadius, pos, 0);
    }
  }


  popMatrix();
  popStyle();
}