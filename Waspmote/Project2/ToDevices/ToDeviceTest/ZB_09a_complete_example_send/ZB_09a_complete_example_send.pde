/*  
 *  ------ [ZB_09a] - complete example send  ------
 *  
 *  Explanation: This is a complete example for XBee-ZigBee
 *  This example shows how to send a packet using unicast 64-bit
 *  destination address. After sending the packet, Waspmote waits
 *  for the response of the receiver and prints all available 
 *  information  
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
//char RX_ADDRESS[] = "0013A200409E2EF1";
char RX_ADDRESS[] = "0000000000000000"; //Broadcast yapınca coordinator alabildi
//////////////////////////////////////////

// define variable
uint8_t error;



void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("Complete example (TX node)"));

  // set Waspmote identifier
  frame.setID("node_TX");

  //////////////////////////
  // 1. init XBee
  //////////////////////////
  xbeeZB.ON();  

  delay(3000);

  //////////////////////////
  // 2. check XBee's network parameters
  //////////////////////////
  checkNetworkParams();
}



void loop()
{ 
  //////////////////////////
  // 1. create frame
  //////////////////////////  

  // 1.1. create new frame
  frame.createFrame(ASCII);  

  // 1.2. add frame fields
  frame.addSensor(SENSOR_STR, "Complete example message"); 
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() ); 
  
  USB.println(F("\n1. Created frame to be sent"));
  frame.showFrame();

  //////////////////////////
  // 2. send packet
  //////////////////////////  

  // send XBee packet
  error = xbeeZB.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  USB.println(F("\n2. Send a packet to the RX node: "));
  
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


  //////////////////////////
  // 3. receive answer
  //////////////////////////  
  
  USB.println(F("\n3. Wait for an incoming message"));
  
  // receive XBee packet
  error = xbeeZB.receivePacketTimeout( 10000 );

  // check answer  
  if( error == 0 ) 
  {
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Data: "));  
    USB.println( xbeeZB._payload, xbeeZB._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Length: "));  
    USB.println( xbeeZB._length,DEC);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Source MAC address: "));      
    USB.printHex( xbeeZB._srcMAC[0] );    
    USB.printHex( xbeeZB._srcMAC[1] );    
    USB.printHex( xbeeZB._srcMAC[2] );    
    USB.printHex( xbeeZB._srcMAC[3] );    
    USB.printHex( xbeeZB._srcMAC[4] );    
    USB.printHex( xbeeZB._srcMAC[5] );    
    USB.printHex( xbeeZB._srcMAC[6] );    
    USB.printHex( xbeeZB._srcMAC[7] );    
    USB.println();
  }
  else
  {
    // Print error message:
    /*
     * '7' : Buffer full. Not enough memory space
     * '6' : Error escaping character within payload bytes
     * '5' : Error escaping character in checksum byte
     * '4' : Checksum is not correct	  
     * '3' : Checksum byte is not available	
     * '2' : Frame Type is not valid
     * '1' : Timeout when receiving answer   
    */
    USB.print(F("Error receiving a packet:"));
    USB.println(error,DEC);     
  }
  
  // wait for 5 seconds
  USB.println(F("\n----------------------------------"));
  delay(5000);

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
    printAssociationState();

    delay(2000);

    // get operating 64-b PAN ID
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





/*******************************************
 *
 *  printAssociationState - Print the state 
 *  of the association flag
 *
 *******************************************/
void printAssociationState()
{
  switch(xbeeZB.associationIndication)
  {
  case 0x00  :  
    USB.println(F("Successfully formed or joined a network"));
    break;
  case 0x21  :  
    USB.println(F("Scan found no PANs"));
    break;    
  case 0x22  :  
    USB.println(F("Scan found no valid PANs based on current SC and ID settings"));
    break;    
  case 0x23  :  
    USB.println(F("Valid Coordinator or Routers found, but they are not allowing joining (NJ expired)"));
    break;    
  case 0x24  :  
    USB.println(F("No joinable beacons were found"));
    break;    
  case 0x25  :  
    USB.println(F("Unexpected state, node should not be attempting to join at this time"));
    break;
  case 0x27  :  
    USB.println(F("Node Joining attempt failed"));
    break;
  case 0x2A  :  
    USB.println(F("Coordinator Start attempt failed"));
    break;
  case 0x2B  :  
    USB.println(F("Checking for an existing coordinator"));
    break;
  case 0x2C  :  
    USB.println(F("Attempt to leave the network failed"));
    break;
  case 0xAB  :  
    USB.println(F("Attempted to join a device that did not respond."));
    break;
  case 0xAC  :  
    USB.println(F("Secure join error: network security key received unsecured"));
    break;
  case 0xAD  :  
    USB.println(F("Secure join error: network security key not received"));
    break;
  case 0xAF  :  
    USB.println(F("Secure join error: joining device does not have the right preconfigured link key"));
    break;
  case 0xFF  :  
    USB.println(F("Scanning for a ZigBee network (routers and end devices)"));
    break;
  default    :  
    USB.println(F("Unkown associationIndication"));
    break;  
  }
}


