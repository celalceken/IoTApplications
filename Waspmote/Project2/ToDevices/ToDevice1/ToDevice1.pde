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
  // init USB port
  USB.ON();
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
  int temp = RTC.getTemperature();
  RTC.OFF(); 
  snprintf( frameMessageBuffer, sizeof(frameMessageBuffer),  "name:%s,temp:%d,BAT:%d,ACC:%d;%d;%d", WASPMOTE_ID, temp, (int)PWR.getBatteryLevel(),ACC.getX(), ACC.getY(), ACC.getZ());  
 
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



