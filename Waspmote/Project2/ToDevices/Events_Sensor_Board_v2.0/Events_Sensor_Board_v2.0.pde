#include <WaspXBeeZB.h>
#include <WaspFrame.h>

#include <WaspSensorEvent_v20.h>

// Variable to store the read value
float value;


// Destination MAC address (MAC Address of the XBeeProS2 on the gateway)
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A200409E2EF1";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "node_01";


// define variable
uint8_t error;

char frameMessageBuffer[200]="";




void setup()
{
  
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  // Turn on the sensor board
  SensorEventv20.ON();
  // Turn on the RTC
  RTC.ON();
  // Firstly, wait for signal stabilization  
  while( digitalRead(DIGITAL5) == 1 )
  {    
    USB.println(F("...wait for stabilization"));
    delay(1000);
  }

  // Enable interruptions from the board
  SensorEventv20.attachInt();
  
  // init Accelerometer
  ACC.ON();
  USB.println(F("Sending packets over ZigBee"));
  
  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );
  
  // init XBee : The ON() function initializes all the global variables, opens the correspondent UART and switches the XBee ON.
  xbeeZB.ON();
  
  delay(3000);
  
  //////////////////////////
  // 2. check XBee's network parameters
  //////////////////////////
  checkNetworkParams();
  
}


void loop()
{
  RTC.ON();
  ///////////////////////////////////////
  // 1. Read the sensor voltage output
  ///////////////////////////////////////

  // Read the sensor voltage output
  value = SensorEventv20.readValue(SENS_SOCKET7);

  // Print the info
  USB.print(F("Sensor output: "));    
  USB.print(value);
  USB.println(F(" Volts"));

   ///////////////////////////////////////
  // 2. Go to deep sleep mode  
  ///////////////////////////////////////
  USB.println(F("enter deep sleep"));
  PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, SENSOR_ON);

  USB.ON();
  USB.println(F("wake up\n"));

   ///////////////////////////////////////
  // 3. Check Interruption Flags
  ///////////////////////////////////////
   
  // 3.1. Check interruption from Sensor Board
  if(intFlag & SENS_INT)
  {
    interrupt_function();
  }

  // 3.2. Check interruption from RTC alarm
  if( intFlag & RTC_INT )
  {   
    USB.println(F("-----------------------------"));
    USB.println(F("RTC INT captured"));
    USB.println(F("-----------------------------"));
  
    // clear flag
    intFlag &= ~(RTC_INT);
  }

  
  
  
  int temp = RTC.getTemperature();
  RTC.OFF(); 
  snprintf( frameMessageBuffer, sizeof(frameMessageBuffer),  "name:%s,temp:%d,BAT:%d,ACC:%d;%d;%d,EVENT:%d", WASPMOTE_ID, temp, (int)PWR.getBatteryLevel(),ACC.getX(), ACC.getY(), ACC.getZ(),(int)value);  
 
  USB.println(frameMessageBuffer); 
  

  ///////////////////////////////////////////
  // 2. Send packet
  ///////////////////////////////////////////  

  // send XBee packet
  //error = xbeeZB.send( RX_ADDRESS, frame.buffer, frame.length ); 
   error = xbeeZB.send( RX_ADDRESS, frameMessageBuffer); 
  
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
    // blink green LED
    Utils.blinkGreenLED();
    
  }
  else 
  {
    USB.println(F("send error"));
    
    // blink red LED
    Utils.blinkRedLED();
  }

  // wait for one seconds
  delay(500);
}



/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
  xbeeZB.getAssociationIndication();
 
  while( xbeeZB.associationIndication != 0 )
  { 
    delay(2000);
    
    // get operating 64-b PAN ID
    //Each ZigBee network is defined by both 64-bit and 16-bit operating PAN IDs. Devices on the same ZigBee network must share the same 64-bit and 16-bit PAN IDs.
  //ZigBee routers and end devices should be configured with the operating 64-bit PAN ID the coordinator is working on. 
  //If a joining node has set its PAN ID, it will only join a network with that operating 64-bit PAN ID. 
  //They acquire the 16-bit PAN ID from the coordinator when they join a network.
    xbeeZB.getOperating64PAN();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();     
    
    xbeeZB.getAssociationIndication();
  }

  USB.println(F("\nJoined a network!"));

  // 3. get network parameters 
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

}

/**********************************************
 *
 * interrupt_function()
 *  
 * Local function to treat the sensor interruption
 *
 *
 ***********************************************/
void interrupt_function()
{  
  // Disable interruptions from the board
  SensorEventv20.detachInt();

  // Load the interruption flag
  SensorEventv20.loadInt();  

  // In case the interruption came from socket 7
  if( SensorEventv20.intFlag & SENS_SOCKET7)
  {
    USB.println(F("-----------------------------"));
    USB.println(F("Interruption from socket 7"));
    USB.println(F("-----------------------------"));
  }

  // Printing and enabling interruptions
  USB.println(F("Presence detected\n"));   

  // User should implement some warning
  // In this example, now wait for signal
  // stabilization to generate a new interruption
  while( digitalRead(DIGITAL5) == 1 )
  {    
    USB.println(F("...wait for stabilization"));
    delay(1000);
  }

  // Clean the interruption flag
  intFlag &= ~(SENS_INT);

  // Enable interruptions from the board
  SensorEventv20.attachInt();

}





