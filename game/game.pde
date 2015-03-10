int depth = 450;
float rotY = 0;
float rotX = 0;
float rotZ = 0;
float speed = 1.0;

Mover mover;
float gravityConstant = 1;


void setup(){
  size(900, 900, P3D);
  noStroke();
  mover = new Mover();
}

void draw(){
  camera(width/2, height/2-400, depth, 0, 0, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  
  rotateX(rotX);
  rotateY(rotY);
  rotateZ(rotZ);
  
  mover.update();
  mover.checkEdges();
  mover.display();
  
  box(300, 20, 300);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      rotY -= PI*speed/128;
    } else if (keyCode == RIGHT) {
      rotY += PI*speed/128;
    }
  } else {
   
  }
}
void mouseDragged() 
{
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
class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  float rSphere = 10;
  Mover() {
    location = new PVector(0, 20, 0);
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
      location.x = 150*Math.abs(location.x)/location.x;
    }
    if ((location.z > 150) ||(location.z < -150)) {
      velocity.z = velocity.z*-1;
      location.z = 150*Math.abs(location.z)/location.z;
    }
  }
}
