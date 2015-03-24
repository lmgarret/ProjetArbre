int depth = 450;
float rotY = 0;
float rotX = 0;
float rotZ = 0;
float speed = 1.0;
int mode = 0; //0 = normal, 1 = SHIFT-MODE
int boxHeight = 10;
int boxWidth = 300;

PGraphics dataBackgroundSurface;
PGraphics topViewSurface;
PGraphics gameGraphics;
PGraphics scoresSurface;
PGraphics bartChartSurface;

int userPoints;
int bestScore;

Mover mover;
float gravityConstant = 1;
ArrayList<Cylinder> cylList = new ArrayList<Cylinder>();
Cylinder cylinder = new Cylinder();

void setup(){
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
  gameGraphics.beginDraw();
  gameGraphics.noStroke();
  gameGraphics.background(200);
  gameGraphics.directionalLight(50, 100, 125, 0, 1, 0);
  gameGraphics.ambientLight(102, 102, 102);
  if(mode==0){
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
    if(c.position.y < boxWidth/2 && c.position.y > -boxWidth/2 && c.position.x < boxWidth/2 && c.position.x > -boxWidth/2)
     c.display(gameGraphics); 
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
    location = new PVector(0, -rSphere/2, 0);
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
    g.translate(location.x,location.y, -location.z);
    g.sphere(rSphere);
    g.popMatrix();
  }
  void checkEdges() {
   if ((location.x > boxWidth/2) ||(location.x < -boxWidth/2)) {
      velocity.x = velocity.x*-1;
      userPoints -= Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      location.x = boxWidth/2*Math.abs(location.x)/location.x;
    }
    if ((location.z > boxWidth/2) ||(location.z < -boxWidth/2)) {
      velocity.z = velocity.z*-1;
      userPoints -= Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      location.z = boxWidth/2*Math.abs(location.z)/location.z;
    }
  }
  void checkCylinderCollision(){
    for(Cylinder c : cylList){
        PVector cRealPosition = new PVector(-c.position.x, 0, c.position.y);
    //   System.out.println("c.position : "+ cRealPosition.x+", "+cRealPosition.z+". c.falseposition : "+c.position.x+", "+c.position.y+". ballPosition : "+location.x+", "+location.y+", "+location.z+".");
      if(location.dist(cRealPosition)<rSphere+c.cylBS){
     //   System.out.println("this is working" + location.dist(cRealPosition));
      PVector n = new PVector(location.x - cRealPosition.x, 0, location.z - cRealPosition.z);
       n.normalize();  
       n.mult(2*(velocity.dot(n)));
      velocity.sub(n);
      userPoints += Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      location.add(velocity);
    }
  }
  }
}

