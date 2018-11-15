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

/*
JorenV2_Hip
JorenV2_Ab
JorenV2_Chest
JorenV2_Neck
JorenV2_Head
JorenV2_LShoulder
JorenV2_LUArm
JorenV2_LFArm
JorenV2_LHand
JorenV2_RShoulder
JorenV2_RUArm
JorenV2_RFArm
JorenV2_RHand
JorenV2_LThigh
JorenV2_LShin
JorenV2_LFoot
JorenV2_RThigh
JorenV2_RShin
JorenV2_RFoot
JorenV2_LToe
JorenV2_RToe
*/