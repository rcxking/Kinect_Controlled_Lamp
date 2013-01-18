import SimpleOpenNI.*;
import processing.serial.*;

// Kinect and Serial Port Objects
SimpleOpenNI kinect;
Serial myPort;

// handVec is the position of the hand according to the Kinect
// mapHandVec is the position of the hand in projective screen coordinates
PVector handVec = new PVector();
PVector mapHandVec = new PVector();

// The point that will track my hand is colored green (Red, Green, Blue)
color handPointCol = color(0, 255, 0);

int photoVal;

void setup()
{
  // Tell Processing that we want the Kinect object to initialize to this sketch
  kinect = new SimpleOpenNI(this);
  
  // enable mirror
  kinect.setMirror(true);
  
  // enable depthMap generation, hands and gestures
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableGesture();
  kinect.enableHands();
  
  // add focus gesture to initialize tracking
  kinect.addGesture("Wave");
  size(kinect.rgbWidth(), kinect.rgbHeight());
  
  // Create the Serial Port to talk to the Arduino
  //String portName = Serial.list()[1];
  myPort = new Serial(this, "COM10", 9600);
  myPort.bufferUntil('\n');
  //println(portName);
}

void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{
  kinect.removeGesture(strGesture);
  kinect.startTrackingHands(endPosition);
}

void onCreateHands(int handId, PVector pos, float time)
{
  handVec = pos;
  handPointCol = color(0, 255, 0);
}

void onUpdateHands(int handId, PVector pos, float time)
{
  handVec = pos;
}

void serialEvent(Serial myPort) {
  // get the ASCII String
  String inString = myPort.readStringUntil('\n');
  
  if(inString != null) {
    // Trim off any whitespaces
    inString = trim(inString);
    // Convert to an integer
    photoVal = int(inString);
  } else {
    println("No data to display");
  }
}

void draw()
{
  kinect.update();
  kinect.convertRealWorldToProjective(handVec, mapHandVec);
  
  //image(kinect.rgbImage(), 0, 0);
  
  if(photoVal < 500) {
    image(kinect.rgbImage(), 0, 0);
  } else {
    image(kinect.depthImage(), 0, 0);
  }
  
  println(photoVal);
  
  strokeWeight(10);
  stroke(handPointCol);
  point(mapHandVec.x, mapHandVec.y);
  
  // Send a marker to the Arduino to indicate that a hand wave has 
  // been seen and therefore we're ready to receive the data to control
  // the lights!
  myPort.write('S');
  
  // Send the value of the hand's X-Position
  myPort.write(int(255 * mapHandVec.x / width));
  
  // Send the value of the hand's Y-Position
  myPort.write(int(255 * mapHandVec.y / height));
}
