float depth =2000;


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
  float rz = map(mouseY ,0 ,height,0,PI);
  float ry = map(mouseX ,0 ,width,0,PI);
  rotateZ(rz);
  rotateY(ry);
  
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
      //ry +=PI/8;
    }
    else if(keyCode == DOWN) {
      //ry -=PI/8;
    }
   
  }
}
