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

PShape tree;

void setup(){
  size(900, 900, P3D);
  noStroke();
  tree = loadShape("data/3DModels/Obj/tree.obj");
  tree.scale(8);
  gameGraphics = createGraphics(width,height,P3D);
  dataBackgroundSurface = createGraphics(width, height/5, P2D);
  topViewSurface = createGraphics(height/5 - 20, height/5 - 20, P2D);
  scoresSurface = createGraphics(height/8 - 20, height/5 - 20, P2D);
  bartChartSurface = createGraphics(width-(topViewSurface.width+scoresSurface.width+2*10)-20, height/5 - 20, P2D);
  mover = new Mover();
  cylinder.init();
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
  topViewSurface.background(65, 105, 225);
  float factor = (topViewSurface.width)/(float)boxWidth;
  float rEllipse = mover.rSphere*factor;
  topViewSurface.fill(255,0,0);
  topViewSurface.ellipse((mover.location.x+boxWidth/2)*factor, topViewSurface.height-(mover.location.z+boxWidth/2)*factor, rEllipse*2, rEllipse*2);
  for(Cylinder c : cylList){
    float rCyl = c.cylBS*factor;
    topViewSurface.fill(255,255,255);
    topViewSurface.ellipse(topViewSurface.width-(c.position.x+boxWidth/2)*factor, topViewSurface.height-(c.position.y+boxWidth/2)*factor, rCyl*2, rCyl*2);
  }
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

