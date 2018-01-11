/***PIR Sensor Application***/

void setup() 
{
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(4, OUTPUT);
  pinMode(7,INPUT);
  Serial.begin(115200);
}

void loop() 
{
  float sicaklikC = (analogRead(A0)/1024.0)*5000/10;
  float sicaklikF = (sicaklikC*9)/5 + 32;
  Serial.print(digitalRead(7));
  Serial.print(":");
  Serial.println(sicaklikC);
  if (digitalRead(7))
  {
    digitalWrite(4, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(3000);
    digitalWrite(4, LOW); 
  }
  
 
 
  delay(1000); 
}
