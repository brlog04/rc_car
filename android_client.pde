import hypermedia.net.*; // import UDP library
import ketai.sensors.*;  // import Ketai Sensor library
import ketai.ui.*;
import ketai.net.*;
import android.view.MotionEvent;

int app_start=1;
int DC_UPDATE = 1;//old 3 gives flickring on plane
byte P_ID = 1;
int dc_count = 0;
int lock = 0;
int gas = 0;
int rssi=0;
int vcc=0;
int l_speed = 0;
int r_speed = 0;
int vib_count = 0;
int rst_count = 0;
UDP udp;             // define the UDP object
KetaiSensor sensor;  // define the Ketai sensor object
KetaiVibrate vibe;
float accelerometerX, accelerometerY, accelerometerZ;
int exprt_flag = 0;
float diff_power = 2.2;
int remotPort = 6000;
int localPort = 2390;
int offsetl = 0;
int offsetr = 0;
String remotIp = "255.255.255.255";  // the remote IP address
Boolean remotIpLock = false;

float objX, objY;
float lastX1, lastY2;

int rectA = 500,rectB = 60,joyPadSize = 80, buttonSize = 160;
int x,y;
float steering, speed;

void getBroadcastAddress()
{
  String localIp[] = {"0","0","0","0"};

  if ( KetaiNet.getIP() != null)
    localIp = split(KetaiNet.getIP(), ".");
  println("My ip address is: " + localIp[0] + "." + localIp[1] + "." + localIp[2] + "." + localIp[3]);
  remotIp = localIp[0] + "." + localIp[1] + "." + localIp[2] + ".255"; //build broadcast/multicast adddress
  println("Broadcast address is: " + remotIp);
}

void setup()
{
  orientation(LANDSCAPE);
  size(displayWidth, displayHeight);
  udp = new UDP( this, localPort );
  udp.listen( true );
  getBroadcastAddress();
  sensor = new KetaiSensor(this);
  vibe = new KetaiVibrate(this);
  sensor.start();
  objX = width / 2;
  objY = height / 2;
  y = height;
  x = width;
  steering = x/4;
  speed = y/2;
}

void draw()
{
  background(125,255,200);
  fill(255);
  stroke(163);
  rect(x/4-rectA/2,2*y/3,rectA,rectB);
  rect(8*x/9-rectB/2,y/2-rectA/2,rectB,rectA);
  fill(color(50,100,255));
  circle(steering,2*y/3+rectB/2,joyPadSize);
  circle(8*x/9,speed,joyPadSize);
  fill(color(255,0,0));
  circle(2*x/3,2*y/3,buttonSize);
  fill(color(0,255,0));
  circle(x/2,2*y/3, buttonSize);
  fill(color(0,0,255));
  textSize(80);
  text("steering: " + steering,200,200);
  text("speed: " + speed,200,300);
  //steering = steering-x/4;
  //speed = y/2-speed;
  text("steering: " + (steering-x/4),200,400);
  text("speed: " + (y/2-speed),200,500);
  l_speed = (steering-x/4)<0?(int)speed+(int)(steering-x/4):(int)speed;
  r_speed = (steering-x/4)>0?(int)speed-(int)(steering-x/4):(int)speed;
  text("l_speed: " + l_speed,200,600);
  text("r_speed: " + r_speed,200,700);
    
   delay(1);
   dc_count++;
   if(dc_count >= DC_UPDATE)
  {
    rst_count++;
    if(rst_count >= 200)
    {
      vcc = 0;
      rssi = 0;
      if (remotIpLock)
      {
        remotIpLock=false;
        println("Connection with " + remotIp + " is lost !"); 
        getBroadcastAddress(); //reset bcast address if network changed       
      }
    }

   String msg = "" + P_ID + ",";  // prva vrednost je ID

    if(lock == 1){
      // Dodamo l_speed i r_speed kao stringove
      msg += l_speed + "," + r_speed;

      vib_count++;
      if(vcc < 35 && vib_count < 5){
        vibe.vibrate(1000);
      }
      if(vib_count >= 40) vib_count = 0;
    }
    else if(lock == 0){
      // Kada lock nije aktivan, šaljemo 1,1 kao string
      msg += "1,1";
    }
    
    //println(message[1]);
    //println(message[2]);
   // String msg = new String(message);
    udp.send( msg, remotIp, remotPort );
    //println("msgsend");
  }
   
}

void lockRemoteIp(String ip)
{
  remotIp=ip;
  remotIpLock = true;
  println("Remote ip is locked to: " + ip);
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  rst_count=0;
  rssi = data[1];
  vcc  = data[2]+3;
  if (! remotIpLock)
    lockRemoteIp(ip);
}

public boolean surfaceTouchEvent(MotionEvent event) {

  int count = event.getPointerCount();

  if (count >= 1) {
    float x1 = event.getX(0);
    float y1 = event.getY(0);
    if (event.getActionMasked() == MotionEvent.ACTION_MOVE) {
      if (x1>x/4-rectA/2 && x1<x/4+rectA/2 && y1>2*y/3-2*rectB && y1<2*y/3+2*rectB){
      steering = x1;   
      }
      if (x1 > 8*x/9-2*rectB && x1 < 8*x/9+2*rectB && y1 > y/2-rectA/ 2&& y1 < y/2+rectA/2){
        speed = y1;
      } 
    }
  }

  if (count >= 2) {
    float x1 = event.getX(0);
    float y1 = event.getY(0);
    float x2 = event.getX(1);
    float y2 = event.getY(1);

    if (event.getActionMasked() == MotionEvent.ACTION_MOVE) {
      if (x1>x/4-rectA/2 && x1<x/4+rectA/2 && y1>2*y/3-2*rectB && y1<2*y/3+2*rectB){
      steering = x1;   
      }
      if (x1 > 8*x/9-2*rectB && x1 < 8*x/9+2*rectB && y1 > y/2-rectA/ 2&& y1 < y/2+rectA/2){
        speed = y1;
      } 
      if (x2>x/4-rectA/2 && x2<x/4+rectA/2 && y2>2*y/3-2*rectB && y2<2*y/3+2*rectB){
      steering = x2;   
      }
      if (x2 > 8*x/9-2*rectB && x2 < 8*x/9+2*rectB && y2 > y/2-rectA/ 2&& y2 < y/2+rectA/2){
        speed = y2;
      } 
    }

  }

  return super.surfaceTouchEvent(event);
}