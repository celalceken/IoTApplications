/*  
 *  --[Ag_12] - Reading the Weather station at Agriculture v20 board-- 
 *  
 *  Explanation: Turn on the Agriculture v20 board and read the 
 *  Weather station every minute. Every time a new pluviometer 
 *  pulse is generated the interrruption is captured and stored
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Manuel Calahorra, Yuri Carmona
 */

#include <WaspSensorAgr_v20.h>
#include <WaspFrame.h>

// Variable to store the anemometer value
float anemometer;

// Variable to store the pluviometer value
float pluviometer1; //mm in current hour 
float pluviometer2; //mm in previous hour
float pluviometer3; //mm in last 24 hours

// Variable to store the vane value
int vane;

// variable to store the number of pending pulses
int pendingPulses;

// define node identifier
char nodeID[] = "node_WS";



void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("Example AG_12. Weather Station example"));

  // set node ID
  frame.setID( nodeID ); 

  // Turn on the sensor board
  SensorAgrv20.ON();  

  // Turn on the RTC
  RTC.ON();
  USB.print(F("Time:"));
  USB.println(RTC.getTime());

}



void loop()
{
  /////////////////////////////////////////////
  // 1. Enter sleep mode
  /////////////////////////////////////////////
  SensorAgrv20.sleepAgr("00:00:00:00", RTC_ABSOLUTE, RTC_ALM1_MODE5, SENSOR_ON, SENS_AGR_PLUVIOMETER);


  /////////////////////////////////////////////
  // 2.1. check pluviometer interruption
  /////////////////////////////////////////////
  if( intFlag & PLV_INT)
  {
    USB.println(F("+++ PLV interruption +++"));

    pendingPulses = intArray[PLV_POS];

    USB.print(F("Number of pending pulses:"));
    USB.println( pendingPulses );

    for(int i=0 ; i<pendingPulses; i++)
    {
      // Enter pulse information inside class structure
      SensorAgrv20.storePulse();

      // decrease number of pulses
      intArray[PLV_POS]--;
    }

    // Clear flag
    intFlag &= ~(PLV_INT); 
  }

  /////////////////////////////////////////////
  // 2.2. check RTC interruption
  /////////////////////////////////////////////
  if(intFlag & RTC_INT)
  {
    USB.println(F("+++ RTC interruption +++"));
    
    // switch on sensor board
    SensorAgrv20.ON();
    
    RTC.ON();
    USB.print(F("Time:"));
    USB.println(RTC.getTime());        

    // measure sensors
    measureSensors();

    // Clear flag
    intFlag &= ~(RTC_INT); 
  }  

}




/*******************************************************************
 *
 *  measureSensors
 *
 *  This function reads from the sensors of the Weather Station and 
 *  then creates a new Waspmote Frame with the sensor fields in order 
 *  to prepare this information to be sent
 *
 *******************************************************************/
void measureSensors()
{  

  USB.println(F("------------- Measurement process ------------------"));
  
  /////////////////////////////////////////////////////
  // 1. Reading sensors
  ///////////////////////////////////////////////////// 
  
  // Turn on the sensor and wait for stabilization and response time
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_ANEMOMETER);
  delay(10);

  // Read the anemometer sensor 
  anemometer = SensorAgrv20.readValue(SENS_AGR_ANEMOMETER);
  
  // Read the pluviometer sensor 
  pluviometer1 = SensorAgrv20.readPluviometerCurrent();
  pluviometer2 = SensorAgrv20.readPluviometerHour();
  pluviometer3 = SensorAgrv20.readPluviometerDay();
  
  // Read the vane sensor 
  vane = SensorAgrv20.readValue(SENS_AGR_VANE);

  // Turn off the sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_ANEMOMETER);


  /////////////////////////////////////////////////////
  // 2. USB: Print the weather values through the USB
  /////////////////////////////////////////////////////
  
  // Print the accumulated rainfall
  USB.print(F("Current hour accumulated rainfall (mm/h): "));
  USB.println( pluviometer1 );

  // Print the accumulated rainfall
  USB.print(F("Previous hour accumulated rainfall (mm/h): "));
  USB.println( pluviometer2 );

  // Print the accumulated rainfall
  USB.print(F("Last 24h accumulated rainfall (mm/day): "));
  USB.println( pluviometer3 );
  
  // Print the anemometer value
  USB.print(F("Anemometer: "));
  USB.print(anemometer);
  USB.println(F("km/h"));
    
  // Print the vane value
  char vane_str[10] = {0};
  USB.print(F("Vane: "));
  switch(SensorAgrv20.vaneDirection)
  {
  case  SENS_AGR_VANE_N   :  snprintf( vane_str, sizeof(vane_str), "N" );
                             break;
  case  SENS_AGR_VANE_NNE :  snprintf( vane_str, sizeof(vane_str), "NNE" );
                             break;  
  case  SENS_AGR_VANE_NE  :  snprintf( vane_str, sizeof(vane_str), "NE" );
                             break;    
  case  SENS_AGR_VANE_ENE :  snprintf( vane_str, sizeof(vane_str), "ENE" );
                             break;      
  case  SENS_AGR_VANE_E   :  snprintf( vane_str, sizeof(vane_str), "E" );
                             break;    
  case  SENS_AGR_VANE_ESE :  snprintf( vane_str, sizeof(vane_str), "ESE" );
                             break;  
  case  SENS_AGR_VANE_SE  :  snprintf( vane_str, sizeof(vane_str), "SE" );
                             break;    
  case  SENS_AGR_VANE_SSE :  snprintf( vane_str, sizeof(vane_str), "SSE" );
                             break;   
  case  SENS_AGR_VANE_S   :  snprintf( vane_str, sizeof(vane_str), "S" );
                             break; 
  case  SENS_AGR_VANE_SSW :  snprintf( vane_str, sizeof(vane_str), "SSW" );
                             break; 
  case  SENS_AGR_VANE_SW  :  snprintf( vane_str, sizeof(vane_str), "SW" );
                             break;  
  case  SENS_AGR_VANE_WSW :  snprintf( vane_str, sizeof(vane_str), "WSW" );
                             break; 
  case  SENS_AGR_VANE_W   :  snprintf( vane_str, sizeof(vane_str), "W" );
                             break;   
  case  SENS_AGR_VANE_WNW :  snprintf( vane_str, sizeof(vane_str), "WNW" );
                             break; 
  case  SENS_AGR_VANE_NW  :  snprintf( vane_str, sizeof(vane_str), "WN" );
                             break;
  case  SENS_AGR_VANE_NNW :  snprintf( vane_str, sizeof(vane_str), "NNW" );
                             break;  
  default                 :  snprintf( vane_str, sizeof(vane_str), "error" );
                             break;    
  }

  USB.println( vane_str );
  USB.println(F("----------------------------------------------------\n"));
  
  

  /////////////////////////////////////////////////////
  // 3. Create Waspmote Frame
  /////////////////////////////////////////////////////
  
  // Create new frame
  frame.createFrame(ASCII); 
  
  // add pluviometer value
  frame.addSensor( SENSOR_PLV1, pluviometer1 );
  // add pluviometer value
  frame.addSensor( SENSOR_PLV2, pluviometer2 );
  // add pluviometer value
  frame.addSensor( SENSOR_PLV3, pluviometer3 );
  // add anemometer value
  frame.addSensor( SENSOR_ANE, anemometer );
  // add pluviometer value
  frame.addSensor( SENSOR_WV, SensorAgrv20.vaneDirection );
  
  // Print frame
  frame.showFrame();
  
}



