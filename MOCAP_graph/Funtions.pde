PVector getMocapPositon(OscMessage theOscMessage, int index){
   
    float x = theOscMessage.get(index).floatValue();
    float y = theOscMessage.get(index++).floatValue();
    float z = theOscMessage.get(index++).floatValue();
    PVector pos = new PVector(x,y,z);
    return pos;
}

Quaternion getMocapRotation(OscMessage theOscMessage, int index){
   
    float x = theOscMessage.get(index).floatValue();
    float y = theOscMessage.get(index++).floatValue();
    float z = theOscMessage.get(index++).floatValue();
    float w = theOscMessage.get(index++).floatValue();
    Quaternion q = new Quaternion(x,y,z,w);
    return q;
}
