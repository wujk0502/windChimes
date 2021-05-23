import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
Minim minim;
Pendulum[] ball = new Pendulum[14];
AudioPlayer[] player = new AudioPlayer[14];
AudioInput input;
AudioRecorder recorder;
AudioOutput out;
FilePlayer fileplayer;
boolean recorded;

FFT[] fft = new FFT[9];
int amp = 0;
IntList currPlayers;
 
class Pendulum { 

  PVector location;
  float angularAcceleration;
  float angularVelocity;
  float angle;
  float string;  
  PVector origin;   
  float damping;
  int shapeIndex;
  

  Pendulum(float string_, float angle_) {
    location = new PVector(0, 0); 
    angle = angle_;
    angularVelocity = 0;
    angularAcceleration = 0;
    string = string_;
    origin = new PVector(width/2, 50);
    damping = 0.995;
    shapeIndex = int(random(3));
  }
  
  boolean clicked(){
    float d = dist(mouseX, mouseY, this.location.x, this.location.y);
    if (d < 30) {
      return true;
    }
    return false;
  }

  void update() {
      if (!clicked()){
      float gravity = 0.98; 
      angularAcceleration = -1 * sin(angle) * (gravity/string); 
      angularVelocity += angularAcceleration;
      angle += angularVelocity;
      angularAcceleration *= damping; 
      }
    }
    
  void sound(int index){
      if (clicked()){
        player[index].play();
        float volume = -10.0;
        player[index].setGain(volume); 
      }
  }
 
  void display() {
    location = new PVector(string * sin(angle), string * cos(angle)); 
    location.add(origin); 
    stroke(255,255,0);
    fill(random(255),random(255),random(255));
    line(origin.x, origin.y, location.x, location.y);
    if (shapeIndex == 0){
      ellipse(location.x, location.y, 30, 30);
    }
    if (shapeIndex == 1){
      rect(location.x, location.y, 30, 30);
    }
    if (shapeIndex == 2){
      triangle(location.x-10, location.y-10, location.x+10, location.y-5,
      location.x, location.y+10);
    }   
  }
}


void setup() {
  size(600, 600);
  for (int i=0; i<ball.length; i++) {
    ball[i] = new Pendulum(30*i, PI/4);
  }
  
  minim = new Minim(this);
  player[0]= minim.loadFile("birds.mp3"); 
  player[1]= minim.loadFile("ocean.mp3"); 
  player[2]= minim.loadFile("rain.wav"); 
  player[3]= minim.loadFile("cat meowing.mp3"); 
  player[4]= minim.loadFile("cat purring.mp3"); 
  player[5]= minim.loadFile("fire in firepit.mp3"); 
  player[6]= minim.loadFile("ripple.mp3"); 
  player[7]= minim.loadFile("strong wind.mp3"); 
  player[8]= minim.loadFile("thunderstorm rumbles.mp3"); 
  player[9]= minim.loadFile("cicada.mp3"); 
  player[10]= minim.loadFile("cows mooing.mp3"); 
  player[11]= minim.loadFile("frogs.mp3"); 
  player[12]= minim.loadFile("hail.mp3"); 
  player[13]= minim.loadFile("lava flow.mp3"); 
  out = minim.getLineOut(Minim.STEREO);
  recorder = minim.createRecorder(out, "My Music Remix.wav");

  frameRate(24);  
}

void draw() {
  background(0);
  stroke(255);
 
  currPlayers = new IntList();
  
  for (int i = 0; i < fft.length; i++) {
    if (player[i].isPlaying()){
      fft[i] = new FFT (player[i].bufferSize(), player[8].sampleRate());
      fft[i].forward(player[i].mix);
      currPlayers.append(i);
    }
  }

  //print(currPlayers.size(), " ");
  
  if (currPlayers.size() != 0) {
    for (int i = 0; i < fft[currPlayers.get(0)].specSize(); i++) {
      amp = 0;
      for (int j = 0; j < currPlayers.size(); j++) {
        amp += fft[currPlayers.get(j)].getBand(i);
      }
      fill(100 + i, 200 - i, 150 + i);
      ellipse(i, 400, 7, amp * 10);
    }
  }
  
  for (int i=0; i<ball.length; i++) {
    ball[i].update();
    ball[i].display();
    ball[i].sound(i);
  }
  
  if ( recorder.isRecording() )
  {
    text("Now recording, press the r key to stop recording.", 5, 15);
  }
  else if ( !recorded )
  {
    text("Press the r key to start recording.", 5, 15);
  }
  else
  {
    text("Press the s key to save the recording to disk.", 5, 15);
  }
  
}


void keyPressed(){
  
  if ( !recorded && key == 'r' ) 
  {
    if ( recorder.isRecording() ) 
    {
      recorder.endRecord();
      recorded = true;
    }
    else 
    {
      recorder.beginRecord();
    }
  }
  if ( recorded && key == 's' )
  {
   
    if ( fileplayer != null )
    {
        fileplayer.close();
    }
    fileplayer = new FilePlayer( recorder.save() );
  }
  
  for (int i=0; i<player.length; i++) {
    if (player[i].isPlaying()) {
      float volume = player[i].getGain();
      if (key == ' ') {
        player[i].pause();
        player[i].rewind();
      }
      if (keyCode == UP) {
        volume += 4.0;
        player[i].setGain(volume);
      }
      if (keyCode == DOWN) {
        volume -= 4.0;
        player[i].setGain(volume);
      }
    }
  }
  
  
}
