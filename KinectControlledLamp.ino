// ledPin1 controls the leftmost red/yellow LEDs
// ledPin2 controls the rightmost green/red LEDs
const int ledPin1 = 11;
const int ledPin2 = 10;

// Global variables to hold the Serial data as it's streaming in
int val, xVal, yVal;

int sensorValue;
int sensorPin = 0;

void setup()
{
  // Set both pins to be outputs
  pinMode(ledPin1, OUTPUT);
  pinMode(ledPin2, OUTPUT);
  
  Serial.begin(9600);
}

void loop()
{
  sensorValue = analogRead(sensorPin);
  Serial.println(sensorValue);
  
  delay(10);
  
  // Check to see if the starting "S" has been received
  // this will put the Serial data counter to have more than 2
  // bits
  if(Serial.available() > 2) {
    // Read the first Serial value
    val = Serial.read();
    
    // If the value of "val" is "S", this means that the next
    // data bits will be used to control the lights
    if(val == 'S') {
      // Read the first byte; this is the x-value of the hand
      xVal = Serial.read();
      // Read the second byte; this is the y-value of the hand
      yVal = Serial.read();
    }
  }
  
  // The leftmost red/yellow LEDs will become brighter
  // if the hand is towards the right of the screen;
  // these two will dim as the hand approaches the left of the
  // screen
  analogWrite(ledPin1, xVal);
  
  // The rightmost green/red LEDs will become brighter
  // if the hand approaches the top of the screen;
  // these two will dim as the hand approaches the bottom
  // of the screen
  analogWrite(ledPin2, yVal);
}
