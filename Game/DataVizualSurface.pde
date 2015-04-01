ArrayList<Integer> oldScore = new ArrayList<Integer>();
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
  final int xBase = 5;
  final int yBase = bartChartSurface.height-10;
  final int espace = 2;
  int squareSize = (bartChartSurface.width)/40 - espace;
  System.out.println("squareSize = "+squareSize+". Width= "+bartChartSurface.width);
  bartChartSurface.beginDraw();
  bartChartSurface.noStroke();
  bartChartSurface.background(200);

  bartChartSurface.fill(190, 180, 140);
  bartChartSurface.rect(5,5,bartChartSurface.width-10, bartChartSurface.height-10);
  bartChartSurface.fill(100); //useless?
  if(oldScore.size()*(squareSize+espace)>bartChartSurface.width){
    oldScore.remove(0);
  }
  for(int i=0; i<oldScore.size();i++){
   drawLine(i, oldScore.get(i), squareSize, espace);
  }
  
  bartChartSurface.endDraw();
  image(bartChartSurface, width-bartChartSurface.width-10,  height-height/5+10);
}

void drawLine(final int index, final int score, final int squareSize, final int espace){
  int max = (int)(Math.min(score, bartChartSurface.height))/(squareSize+espace);
  if(max<0){
    max=0;
  }
  for(int i=0; i<max; i++){
     drawSquare(bartChartSurface.width-5- (index+1)*(squareSize+espace), bartChartSurface.height-5- (i+1)*(squareSize+espace), squareSize); 
  }
}

void drawSquare(int iX, int iY, final int squareSize){
  bartChartSurface.fill(100);
 bartChartSurface.rect(iX,iY,squareSize, squareSize); 
}
