int depth = 450;
float rotY = 0;
float rotX = 0;
float rotZ = 0;
float speed = 1.0;
int mode = 0; //0 = normal, 1 = SHIFT-MODE
int boxHeight = 20;
int boxWidth = 300;

Mover mover;
float gravityConstant = 1;
ArrayList<Cylinder> cylList = new ArrayList<Cylinder>();
Cylinder cylinder = new Cylinder();
PGraphics bgDataVisu;

int userPoints;

void setup(){
  size(900, 900, P3D);
  noStroke();
  mover = new Mover();
  cylinder.init();
  userPoints=0;
  bgDataVisu = createGraphics(width,height/5,P2D);
}

void drawSurfaces(){
  bgDataVisu.beginDraw();
  bgDataVisu.background(143,188,143);
  bgDataVisu.rect(10,10,boxWidth/2,boxWidth/2);
    bgDataVisu.fill(220,20,60);
  bgDataVisu.ellipse((boxWidth/2 + mover.location.x)/2 + 10,(boxWidth/2 - mover.location.z)/2 + 10,mover.rSphere,mover.rSphere);
  bgDataVisu.fill(102,102,102);
  for(Cylinder c : cylList){
    if(c.position.y < 150 && c.position.y > -150 && c.position.x < 150 && c.position.x > -150){
      bgDataVisu.ellipse((boxWidth/2 - c.position.x)/2 +10, (boxWidth/2 - c.position.y)/2 +10, c.cylBS, c.cylBS);
    }
  }
  bgDataVisu.endDraw();
}

void draw(){
  background(200);
  pushMatrix();
    directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  if(mode==0){
    camera(width/2, height/2-400, depth, 0, 0, 0, 0, 1, 0);
    pushMatrix();
    rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);
  
    mover.update();
    mover.checkEdges();
    mover.display();
    
    translate(0, boxHeight,0);
    box(300, boxHeight, 300);
    popMatrix();
  }else{
    camera(0, -depth, 0, 0, 0, 0, 0, 0, 1);
    translate(0, boxHeight,0);
    box(300, boxHeight, 300);
    cylinder.display();
  }
  for(Cylinder c : cylList){
    if(c.position.y < 150 && c.position.y > -150 && c.position.x < 150 && c.position.x > -150)
     c.display(); 
  }
  popMatrix();
  drawSurfaces();
  image(bgDataVisu,0,4*height/5);
}
void keyPressed() {
  if (key == CODED) {
    if(keyCode == SHIFT){
      mode = 1;
    }if (keyCode == LEFT) {
      rotY -= PI*speed/128;
    } else if (keyCode == RIGHT) {
      rotY += PI*speed/128;
    }
  } else {
     
  }
}
void keyReleased(){
   if(key==CODED){
    if(keyCode == SHIFT){
     mode=0;
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
 float cylBS=10;
 float cylH=30;
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
}
void display(){
  pushMatrix();
  if(mode == 0){
    rotateX(rotX);
    rotateY(rotY);
    rotateZ(rotZ);
    
    rotateX(PI/2.0);
    translate(-position.x, -position.y, -boxHeight/2);
    shape(openCylinder);
    shape(roof);
    
  }else{
    rotateX(PI/2.0);  
    if(fixedPosition){
      translate(-position.x, -position.y, boxHeight/2);
    }else{
      translate(540*(-width/2+mouseX)/width,540*(-height/2+mouseY)/height,boxHeight/2);
    }
    shape(openCylinder);
    shape(roof);
  }
  popMatrix();
}
}
class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  float rSphere = 10;
  Mover() {
    location = new PVector(0, 0, 0);
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
  void display() {
    pushMatrix();
    translate(location.x,-location.y, -location.z);
    sphere(rSphere);
    popMatrix();
  }
  void checkEdges() {
   if ((location.x > 150) ||(location.x < -150)) {
      velocity.x = velocity.x*-1;
      userPoints -= Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2));
      location.x = 150*Math.abs(location.x)/location.x;
    }
    if ((location.z > 150) ||(location.z < -150)) {
      velocity.z = velocity.z*-1;
      userPoints -= Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2));
      location.z = 150*Math.abs(location.z)/location.z;
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
      userPoints += Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2));
      location.add(velocity);
    }
  }
  }
}

