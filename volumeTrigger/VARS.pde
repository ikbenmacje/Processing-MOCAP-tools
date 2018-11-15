// Coordinates Remap
// MOCAP
// x = front to back
// y == up and down
// z = left to right

// PRocessing
// x = left to right
// y = front back
// z = up and down
// These are processing Ranges !
// Z MOCAP -> X Processing
/*
int[] Xmap = {
  -300, 300, -300, 300
};
// X MOCAP -> Y Processing 
int[] Ymap = {
  -300, 300, -300, 300
};
// Y MOCAP -> Z Processing
int[] Zmap = {
  0, 300, 0, 300
};
*/


int[] Xmap = {
  -3, 3, -300, 300
};
// X MOCAP -> Y Processing 
int[] Ymap = {
  -3, 3, -300, 300
};
// Y MOCAP -> Z Processing
int[] Zmap = {
  0, 3, 0, 300
};


/*

Hips
Spine
Spine1
Neck
Head
LeftShoulder
LeftArm
LeftForeArm
LeftHand
RightShoulder
RightArm
RightForeArm
RightHand
LeftUpLeg
LeftLeg
LeftFoot
RightUpLeg
RightLeg
RightFoot
LeftToeBase
RightToeBase



Hip
Ab
Chest
Neck
Head
LShoulder
LUArm
LFArm
LHand
RShoulder
RUArm
RFArm
RHand
LThigh
LShin
LFoot
RThigh
RShin
RFoot
LToe
RToe
LThumb1
LThumb2
LThumb3
LIndex1
LIndex2
LIndex3
LMiddle1
LMiddle2
LMiddle3
LRing1
LRing2
LRing3
LPinky1
LPinky2
LPinky3
RThumb1
RThumb2
RThumb3
RIndex1
RIndex2
RIndex3
RMiddle1
RMiddle2
RMiddle3
RRing1
RRing2
RRing3
RPinky1
RPinky2
RPinky3
*/
