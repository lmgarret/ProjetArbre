  import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer playerBounce;
AudioPlayer soundtrack;
AudioPlayer soundtrackLight;
AudioPlayer playerGodlike; 
AudioPlayer playerGamePaused;
AudioPlayer playerGameResumed;
AudioPlayer playerWrongLocation;
AudioPlayer playerAddComplete;

int depth = 450;
float rotY = 0;
float rotX = 0;
float rotZ = 0;
float speed = 1.0;
int mode = 0; //0 = normal, 1 = SHIFT-MODE
int changelight=1;
float lightX=102;
float lightY=102;
float lightZ=102;
int boxHeight = 10;
int boxWidth = 300;
int newPoints=0;

PGraphics dataBackgroundSurface;
PGraphics topViewSurface;
PGraphics gameGraphics;
PGraphics scoresSurface;
PGraphics bartChartSurface;

int userPoints;
int bestScore;

float gravityConstant = 1;
Mover mover;
Cylinder cylinder = new Cylinder();
ArrayList<Cylinder> cylList = new ArrayList<Cylinder>();

void setup(){
  minim = new Minim(this);
  playerBounce = minim.loadFile("data/Audio/Sounds/bouce.mp3");
  soundtrack = minim.loadFile("data/Audio/Musics/soundtrack.mp3");
  soundtrackLight = minim.loadFile("data/Audio/Musics/soundtrackLightOn.mp3");
  playerGodlike = minim.loadFile("data/Audio/Sounds/godlike.mp3");
  playerGamePaused =minim.loadFile("data/Audio/Sounds/gamePaused.mp3");
  playerGameResumed =minim.loadFile("data/Audio/Sounds/gameResumed.mp3");
  playerWrongLocation= minim.loadFile("data/Audio/Sounds/wrongLocation.mp3");
  playerAddComplete =minim.loadFile("data/Audio/Sounds/addonComplete.mp3");
  size(900, 900, P3D);
  noStroke();
  gameGraphics = createGraphics(width,height,P3D);
  dataBackgroundSurface = createGraphics(width, height/5, P2D);
  topViewSurface = createGraphics(height/5 - 20, height/5 - 20, P2D);
  scoresSurface = createGraphics(height/8 - 20, height/5 - 20, P2D);
  bartChartSurface = createGraphics(width-(topViewSurface.width+scoresSurface.width+2*10)-20, height/5 - 20, P2D);
  mover = new Mover();
  cylinder.init();
  topViewSurface.beginDraw();
  topViewSurface.background(65, 105, 225);
  topViewSurface.endDraw();
}

void draw(){
  if(bestScore<userPoints){
    bestScore=userPoints;
  }
  if(newPoints>15){
    playerGodlike.play();
    playerGodlike.rewind();
  }
  gameGraphics.beginDraw();
  gameGraphics.noStroke();
  gameGraphics.directionalLight(50, 100, 125, 0, 1, 0);
    if(changelight==0){
  gameGraphics.ambientLight(lightX, lightY, lightZ);
  }else{
      gameGraphics.ambientLight(102, 102, 102);
      gameGraphics.background(200);
  }
  
  if(mode==0){
   if(!soundtrack.isPlaying() && changelight!=0){
     soundtrack.play();
   }
    gameGraphics.camera(width/2, height/2-700, depth, 0, 0, 0, 0, 1, 0);
    
    gameGraphics.pushMatrix();
    gameGraphics.rotateX(rotX);
    gameGraphics.rotateY(rotY);
    gameGraphics.rotateZ(rotZ);
  
    mover.update();
    mover.checkEdges();
    mover.display(gameGraphics);
    
    gameGraphics.translate(0, boxHeight,0);
    gameGraphics.box(boxWidth, boxHeight, boxWidth);
    gameGraphics.popMatrix();
  }else{

   gameGraphics.camera(0, -depth, 0, 0, 0, 0, 0, 0, 1);
    gameGraphics.translate(0, boxHeight,0);
    gameGraphics.box(boxWidth, boxHeight, boxWidth);
    cylinder.display(gameGraphics);
  }
  for(Cylinder c : cylList){
  if(c.position.y < boxWidth/2 && c.position.y > -boxWidth/2 && c.position.x < boxWidth/2 && c.position.x > -boxWidth/2){
     c.display(gameGraphics); 
    }
  }

  gameGraphics.endDraw();
  image(gameGraphics,0,0);
  
  drawDataVizualSurface();
}
void drawDataVizualSurface(){
  dataBackgroundSurface.beginDraw();
  dataBackgroundSurface.background(190, 180, 140);
  dataBackgroundSurface.endDraw();
  image(dataBackgroundSurface, 0, height-height/5);

  drawTopViewSurface();
  drawScores();
  drawBarChart();
}
void drawTopViewSurface(){
  topViewSurface.beginDraw();
  topViewSurface.noStroke();
  float factor = (topViewSurface.width)/(float)boxWidth;
  float rEllipse = mover.rSphere*factor;
  //topViewSurface.fill(255,0,0);
 // topViewSurface.ellipse((mover.location.x+boxWidth/2)*factor, topViewSurface.height-(mover.location.z+boxWidth/2)*factor, rEllipse*2, rEllipse*2);
  for(Cylinder c : cylList){
    float rCyl = c.cylBS*factor;
    topViewSurface.fill(255,255,255);
    topViewSurface.ellipse(topViewSurface.width-(c.position.x+boxWidth/2)*factor, topViewSurface.height-(c.position.y+boxWidth/2)*factor, rCyl*2, rCyl*2);
  }
  topViewSurface.stroke(0);
  topViewSurface.fill(175);
  topViewSurface.ellipse((mover.location.x+boxWidth/2)*factor, topViewSurface.height-(mover.location.z+boxWidth/2)*factor, rEllipse*2, rEllipse*2);
  topViewSurface.endDraw();
  image(topViewSurface, 10, height-height/5+10);
}
void drawScores(){
  scoresSurface.beginDraw();
  scoresSurface.noStroke();
  scoresSurface.background(200);
  scoresSurface.fill(190, 180, 140);
  scoresSurface.rect(5,5,scoresSurface.width-10, scoresSurface.height-10);
  scoresSurface.fill(100);
  scoresSurface.text("Total Score : \n"+userPoints+
  "\n\nVelocity :\n"+Math.round((Math.sqrt(Math.pow(mover.velocity.x,2)+Math.pow(mover.velocity.z,2)))*100.0)/100.0+
  "\n\nBest Score:\n"+bestScore,
  10, 20);
  scoresSurface.endDraw();
  image(scoresSurface, topViewSurface.width + 20,  height-height/5+10);
}
void drawBarChart(){
  bartChartSurface.beginDraw();
  bartChartSurface.noStroke();
  bartChartSurface.background(200);
  bartChartSurface.fill(190, 180, 140);
  bartChartSurface.rect(5,5,bartChartSurface.width-10, bartChartSurface.height-10);
  bartChartSurface.fill(100);
  bartChartSurface.endDraw();
  image(bartChartSurface, width-bartChartSurface.width-10,  height-height/5+10);
}
void keyPressed() {
  if (key == CODED) {
    if(keyCode == SHIFT){
      if(mode==0){
      playerGamePaused.play();
      playerGameResumed.rewind();
      soundtrack.pause();
      soundtrackLight.pause();
      }
      mode = 1;
    }if (keyCode == LEFT) {
      rotY -= PI*speed/128;
    } else if (keyCode == RIGHT) {
      rotY += PI*speed/128;
    }
  } else if(keyCode == TAB && mode==0){
     if(changelight==0){
       lightX=102;
       lightY=102;
       lightZ=102;
       changelight=1;
       soundtrackLight.pause();
       soundtrackLight.rewind();
       soundtrack.play();
     }else{
       changelight=0;
       soundtrack.pause();
       soundtrackLight.play();
     }
  }else{
  }
}
void keyReleased(){
   if(key==CODED){
    if(keyCode == SHIFT){
     mode=0;
     playerGameResumed.play();
     playerGamePaused.rewind();
     if(changelight==1){
       soundtrack.play();
     }else{
       soundtrackLight.play();
    }
   } else if (keyCode == ALT) {
     cylList.clear();
}
}
}

void mouseClicked(){
 if(mode==1){
   cylinder.fixPosition();
   cylList.add(cylinder);
   cylinder=new Cylinder();
   cylinder.init();
 }
}
void mouseDragged() 
{
  if(mode == 0){
    rotX = map(mouseX, 0, width, -PI/3, PI/3)*speed;
    rotZ = map(mouseY, 0, height, -PI/3, PI/3)*speed;
    
    if(rotX > PI/3){
       rotX = PI/3; 
    }else if(rotX < -PI/3){
       rotX = -PI/3;
    }
    if(rotZ > PI/3){
       rotZ = PI/3; 
    }else if(rotZ < -PI/3){
       rotZ = -PI/3;
    }
  }
}
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e>0){ //mouse wheel down
    speed -=0.05;
  }else if(e<0){ //mouse wheel up
    speed +=0.05;
  }
  if(speed<=0){
    speed = 0.05;
  }
}
class Cylinder{
 PVector position = new PVector(0,0,0);
 boolean fixedPosition =false;
 float cylBS=25;
 float cylH=25;
 int cylRes=40;
 PShape openCylinder = new PShape();
 PShape roof = new PShape();

 
 void init(){
   float angle=0;
   float[] x = new float[cylRes + 1];
   float[] y = new float[cylRes + 1];
  
   //get the x and y position on a circle for all the sides
   for(int i = 0; i < x.length; i++){
    angle = (TWO_PI / cylRes) * i;
    x[i] = sin(angle) * cylBS;
    y[i] = cos(angle) * cylBS;
   }
   openCylinder = createShape();
   openCylinder.beginShape(QUAD_STRIP);
   
   //draw the border of the cylinder
   for(int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i] , 0);
    openCylinder.vertex(x[i], y[i], cylH);
   }
   openCylinder.endShape();
   
   roof = createShape();
   roof.beginShape(TRIANGLE_FAN);
   for(int i =0; i<x.length;i++){
     roof.vertex(x[i],y[i], cylH);
   }
   roof.endShape();
   roof.beginShape(TRIANGLE_FAN);
   for(int i =0; i<x.length;i++){
     roof.vertex(x[i],y[i], 0);
   }
   roof.endShape();
}
void fixPosition(){
   fixedPosition = true;
   position.x = 540*(width/2-mouseX)/width;
   position.y = 540*(height/2-mouseY)/height;
   if(position.x>boxWidth/2 || position.x<-boxWidth/2 || position.y>boxWidth/2 || position.y<-boxWidth/2){
     playerWrongLocation.play();
     playerWrongLocation.rewind();
   }else{
     playerAddComplete.play();
     playerAddComplete.rewind();
   }
}
void display(PGraphics g){
  g.pushMatrix();
  if(mode == 0){
    g.rotateX(rotX);
    g.rotateY(rotY);
    g.rotateZ(rotZ);
    
    g.rotateX(PI/2.0);
    g.translate(-position.x, -position.y, -boxHeight/2);
    g.shape(openCylinder);
    g.shape(roof);
    
  }else{
    g.rotateX(PI/2.0);  
    if(fixedPosition){
      g.translate(-position.x, -position.y, boxHeight/2);
    }else{
      g.translate(540*(-width/2+mouseX)/width,540*(-height/2+mouseY)/height,boxHeight/2);
    }
    g.shape(openCylinder);
    g.shape(roof);
  }
  g.popMatrix();
}
}
class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  float rSphere = 10;
  Mover() {
    location = new PVector(0, rSphere/2, 0);
    velocity = new PVector(2, 0, 2);
    gravity = new PVector(1,0,1);
  }
  void update() {
    gravity.x = sin(rotZ) * gravityConstant;
    gravity.z = sin(rotX) * gravityConstant;
    
    float normalForce = 1;
    float mu = 0.201;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    checkCylinderCollision();
    velocity.add(gravity);
    velocity.add(friction);
    location.add(velocity);
  }
  void display(PGraphics g) {
    g.pushMatrix();
    g.translate(location.x,-location.y, -location.z);
    g.sphere(rSphere);
    g.popMatrix();
  }
  void checkEdges() {
   if ((location.x > boxWidth/2) ||(location.x < -boxWidth/2)) {
      if(changelight==0){
        lightX=(float)Math.abs(Math.floor(Math.random()*255));
        lightY=(float)Math.abs(Math.floor(Math.random()*255));
        lightZ=(float)Math.abs(Math.floor(Math.random()*255));
          background((int)Math.floor(Math.random()*255),(int)Math.floor(Math.random()*255),(int)Math.floor(Math.random()*255));
      }
      velocity.x = velocity.x*-1;
      newPoints=-(int)Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      userPoints += newPoints;
      playerBounce.play();
      playerBounce.rewind();
      location.x = boxWidth/2*Math.abs(location.x)/location.x;
    }
    if ((location.z > boxWidth/2) ||(location.z < -boxWidth/2)) {
      if(changelight==0){
        lightX=(float)Math.abs(Math.floor(Math.random()*255));
        lightY=(float)Math.abs(Math.floor(Math.random()*255));
        lightZ=(float)Math.abs(Math.floor(Math.random()*255));
          background((int)Math.floor(Math.random()*255),(int)Math.floor(Math.random()*255),(int)Math.floor(Math.random()*255));
      }
      velocity.z = velocity.z*-1;
      newPoints=-(int)Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      userPoints += newPoints;
        playerBounce.play();
        playerBounce.rewind();
      location.z = boxWidth/2*Math.abs(location.z)/location.z;
    }
  }
  void checkCylinderCollision(){
    for(Cylinder c : cylList){
        PVector cRealPosition = new PVector(-c.position.x, 0, c.position.y);
      if(location.dist(cRealPosition)<rSphere+c.cylBS){
      PVector n = new PVector(location.x - cRealPosition.x, 0, location.z - cRealPosition.z);
       n.normalize();  
       n.mult(2*(velocity.dot(n)));
      velocity.sub(n);
      newPoints = (int)Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      userPoints += newPoints;
        playerBounce.play();
        playerBounce.rewind();
      location.add(velocity);

      if(changelight==0){
          background((int)Math.floor(Math.random()*255),(int)Math.floor(Math.random()*255),(int)Math.floor(Math.random()*255));
        lightX=(float)Math.abs(Math.floor(Math.random()*255));
        lightY=(float)Math.abs(Math.floor(Math.random()*255));
        lightZ=(float)Math.abs(Math.floor(Math.random()*255));
      }
    }
  }
  }
}

