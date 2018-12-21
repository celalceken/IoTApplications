/***PIR Sensor Application***/

int counter=0;

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


  counter++;
  if(counter%40==0)
  {
    Serial.print(digitalRead(7));
    Serial.print(":");
    Serial.print(sicaklikC);
    Serial.println("\n");
    Serial.flush();
    
  }
  
  
  
  //String out= digitalRead(7) +":"+ sicaklikC;
  
  if (digitalRead(7))
  {
    Serial.print(digitalRead(7));
    Serial.print(":");
    Serial.print(sicaklikC);
    Serial.println("\n");

    Serial.flush();
    digitalWrite(4, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(3000);
    digitalWrite(4, LOW); 
    Serial.print(digitalRead(7));
    Serial.print(":");
    Serial.print(sicaklikC);
    Serial.println("\n");

    Serial.flush();
  }
  
 
 
  delay(500); 
}
