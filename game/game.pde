int depth = 450;
float rotY = 0;
float rotX = 0;
float rotZ = 0;
float speed = 1.0;


void setup(){
  size(900, 900, P3D);
  noStroke();
}

void draw(){
  camera(width/2, height/2-400, depth, 0, 0, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  
  rotateX(rotX);
  rotateY(rotY);
  rotateZ(rotZ);

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
