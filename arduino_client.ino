//**************************************************
// WiFi Controlled Tiny Airplane
// ESP8266 Firmware ino file
// By Ravi Butani
// Rajkot INDIA
// Instructables page: https://www.instructables.com/id/WIFI-CONTROLLED-RC-PLANE/
//***************************************************
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>

#define P_ID 1
#define ST_LED  2
#define L_MOTOR_A 3
#define L_MOTOR_B 4
#define R_MOTOR_A 5
#define R_MOTOR_B 6
#define DC_RSSI 1500  // Time in mS for send RSSI
#define DC_RX   900   // Time in mS for tx inactivity 200 old problem of motor stopping flickring
ADC_MODE(ADC_VCC);
unsigned int l_speed = 0;
unsigned int r_speed = 0;

unsigned long premillis_rssi = 0;
unsigned long premillis_rx   = 0;

int status = WL_IDLE_STATUS;
char ssid[] = "wifiplane";   //  your network SSID (name)
char pass[] = "wifiplane1234";    // your network password (use for WPA, or use as key for WEP)
int keyIndex = 0;            // your network key Index number (needed only for WEP)
IPAddress remotIp;
unsigned int localPort = 6000;      // local port to listen on
unsigned int remotPort = 2390;      // local port to talk on
char  packetBuffer[20]; //buffer to hold incoming packet
char  replyBuffer[]={P_ID,0x01,0x01,0x00}; // a string to send back
WiFiUDP Udp;

// the setup function runs once when you press reset or power the board
void setup() {
  WiFi.mode(WIFI_STA);
  //WiFi.setOutputPower(2.5);
  analogWriteRange(255);
  pinMode(L_MOTOR_A, OUTPUT);
  pinMode(R_MOTOR_A, OUTPUT);
  pinMode(L_MOTOR_B, OUTPUT);
  pinMode(R_MOTOR_B, OUTPUT);
  analogWrite(L_MOTOR_A,0);
  analogWrite(R_MOTOR_A,0);
  analogWrite(L_MOTOR_B,0);
  analogWrite(R_MOTOR_B,0);
  pinMode(ST_LED, OUTPUT);
  digitalWrite(ST_LED,HIGH);
  //Serial.begin(115200);
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) 
  {
    digitalWrite(ST_LED,LOW);
    delay(60);
    digitalWrite(ST_LED,HIGH);
    delay(1000);
    //Serial.print(".");
  }
  remotIp=WiFi.localIP();
  remotIp[3] = 255;
  Udp.begin(localPort);
}

// the loop function runs over and over again forever
void loop() {
  delay(5);
  if(WiFi.status() == WL_CONNECTED)
  {
    digitalWrite(ST_LED,LOW);
    // if there's data available, read a packet
    int packetSize = Udp.parsePacket();
    if (packetSize) 
    {
      // read the packet into packetBufffer
      int packetSize = Udp.parsePacket();
      if (packetSize) {
        int len = Udp.read(packetBuffer, sizeof(packetBuffer) - 1);
        if (len > 0) {
            packetBuffer[len] = '\0';  // OBAVEZNO
        }
    
        int rp_ID, l_speed, r_speed;
        char *token;
        
        token = strtok(packetBuffer, ",");
        rp_ID = atoi(token);
        
        token = strtok(NULL, ",");
        l_speed = atoi(token);
        
        token = strtok(NULL, ",");
        r_speed = atoi(token);

        if(rp_ID == P_ID)
        {
          if (l_speed < 0) {
            analogWrite(L_MOTOR_A, 0); // Set direction pin for left motor
            analogWrite(L_MOTOR_B, -1*l_speed); // Set speed for left motor
          } else {
            analogWrite(L_MOTOR_A, l_speed); // Set direction pin for left motor
            analogWrite(L_MOTOR_B, 0); // Set speed for left motor
          }
          if (r_speed < 0) {
            analogWrite(R_MOTOR_A, 0); // Set direction pin for left motor
            analogWrite(R_MOTOR_B, -1*r_speed); // Set speed for left motor
          } else {
            analogWrite(R_MOTOR_A, r_speed); // Set direction pin for left motor
            analogWrite(R_MOTOR_B, 0); // Set speed for left motor
          }
          
          //Serial.print(l_speed);
          //Serial.print(" \t");
          //Serial.println(r_speed);
          premillis_rx = millis();
        }
      }
      
    }
    if(millis()-premillis_rssi > DC_RSSI)
    {
       premillis_rssi = millis();
       long rssi = abs(WiFi.RSSI());
       float vcc = (((float)ESP.getVcc()/(float)1024.0)+0.75f)*10;
       replyBuffer[1] = (unsigned char)rssi;
       replyBuffer[2] = (unsigned char)vcc;
       
       Udp.beginPacket(remotIp, remotPort);
       Udp.write(replyBuffer);
       Udp.endPacket();
     }
     if(millis()-premillis_rx > DC_RX)
     {
       analogWrite(L_MOTOR_A,0);
       analogWrite(R_MOTOR_A,0);
       analogWrite(L_MOTOR_B,0);
       analogWrite(R_MOTOR_B,0);
       //Serial.println("nodata");
     }
  }
  else
  {
    digitalWrite(ST_LED,LOW);
    delay(60);
    digitalWrite(ST_LED,HIGH);
    delay(1000);
    analogWrite(L_MOTOR_A,0);
    analogWrite(R_MOTOR_A,0);
    analogWrite(L_MOTOR_B,0);
    analogWrite(R_MOTOR_B,0);
    digitalWrite(ST_LED,HIGH);
  }
}
