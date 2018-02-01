/*  
 *  ------ [ZB_03] - send packets to a gateway -------- 
 *  
 *  Explanation: This program shows how to send packets to a gateway
 *  indicating the MAC address of the receiving XBee module.  
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBeeZB.h>
#include <WaspFrame.h>
#include <WaspSensorGas_v20.h>

#define GAINCO2  7  //GAIN of the sensor stage
#define GAINO2  100 //GAIN of the sensor stage
#define GAINCO  1      // GAIN of the sensor stage
#define RESISTOR 100  // LOAD RESISTOR of the sensor stage

// Destination MAC address (MAC Address of the XBeeProS2 on the gateway)
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A200409E2EF1";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "node_01";


// define variable
uint8_t error;

char frameMessageBuffer[200]="";

float humidity; 
float coVal;
float co2Val;
float o2Val;



void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);
  // Turn on the sensor board
  SensorGasv20.ON();

  // Turn on the RTC
  RTC.ON();


  // Configure the O2 sensor socket
  SensorGasv20.configureSensor(SENS_O2, GAINO2);
  // Turn on the O2 sensor and wait for stabilization and
  // sensor response time
  SensorGasv20.setSensorMode(SENS_ON, SENS_O2);
  delay(10);

  // Configure the CO sensor on socket 4
  SensorGasv20.configureSensor(SENS_SOCKET4CO, GAINCO, RESISTOR);

  // Configure the CO2 sensor socket
  SensorGasv20.configureSensor(SENS_CO2, GAINCO2);
  // Turn on the CO2 sensor and wait for stabilization and
  // sensor response time
  SensorGasv20.setSensorMode(SENS_ON, SENS_CO2);
  delay(40000); 


 
  
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
  ///////////////////////////////////////////
  // 1. Create ASCII frame
  ///////////////////////////////////////////  

  // create new frame
  //frame.createFrame(ASCII);  
  
  // add frame fields
  //frame.addSensor(SENSOR_STR, "new_sensor_frame");
  //frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 

  //frame.addSensor(SENSOR_BAT, RTC.getTemperature());
  RTC.ON();
  /// Read the sensor CO2
  co2Val = SensorGasv20.readValue(SENS_CO2);
  char co2ValSend[10];
  dtostrf( co2Val, 1, 3, co2ValSend);
  // Print the result through the USB
  //USB.print(F("CO2: "));
  //USB.println(co2Val);
  
  // Read the sensor O2
  o2Val = SensorGasv20.readValue(SENS_O2);
  char o2ValSend[10];
  dtostrf( o2Val, 1, 3, o2ValSend);
  // Print the result through the USB
  //USB.print(F("O2: "));
  //USB.println(o2Val);
  
// Read the humidity sensor
  humidity = SensorGasv20.readValue(SENS_HUMIDITY);

  // Read the sensor CO
  coVal = SensorGasv20.readValue(SENS_SOCKET4CO);
  char coValSend[10];
  dtostrf( coVal, 1, 3, coValSend);
  
  //USB.print(F("CO: "));
  //USB.println(coVal);
  
  int temp = RTC.getTemperature();
  RTC.OFF(); 
  snprintf( frameMessageBuffer, sizeof(frameMessageBuffer),  "name:%s,temp:%d,hum:%d,BAT:%d,ACC:%d;%d;%d,CO2:%s,O2:%s,CO:%s", 
  WASPMOTE_ID, temp,(int)humidity, (int)PWR.getBatteryLevel(),ACC.getX(), ACC.getY(), ACC.getZ(), co2ValSend, o2ValSend, coValSend);  
 
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




