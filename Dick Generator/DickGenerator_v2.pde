float depth = 2000;

void setup(){
  size(500,500,P3D);
  noStroke();
}
void draw(){
    background(200);
    directionalLight(50, 100, 125, -1, 0, 0);
    ambientLight(244, 194, 194);
    camera(mouseX,mouseY,450,250,250,0,0,1,0);
    translate(width/2,height/2,0);
    rotateX(PI/8);
    rotateY(PI/8);
    translate(0, 130, 0);
    translate(0, -85, 0);
    box(80, 290, 80);
    translate(0, -135, 0);
    sphere(55);
    translate(-50, 250, 0);
    sphere(70);
    translate(100, 0, 0);
    sphere(70);
}


