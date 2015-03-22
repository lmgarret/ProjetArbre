float depth =2000;
float rotX =0;
float rotY =0;

void setup() {
  size(500,500,P3D); 
  noStroke();
}

void draw() {
  camera(width/2,height/2,depth,250,250,0,0,1,0);
  directionalLight(50,100,125,0,-1,0);
  ambientLight(102,102,102);
  background(200);
  translate(width/2,height/2,0);
  rotateX(rotX);
  rotateY(rotY);
  for(int x =-2 ; x <=2 ;x++) {
    for(int y = -2 ; y<= 2 ;y++) {
      for (int z = -2;z <= 2;z++) {
        pushMatrix();
        translate(100*x,100*y,-100*z);
        box(50);
        popMatrix();
      }
    }
  }
}

void keyPressed() {
  if (key==CODED) {
    if(keyCode == UP) {
      rotX += PI/18;
    }
    else if(keyCode == DOWN) {
      rotX -=PI/18;
    } 
    else if(keyCode == LEFT) {
   rotY -= PI/18;
   
  }else if (keyCode == RIGHT) {
    rotY += PI/18;
  }
}
}
