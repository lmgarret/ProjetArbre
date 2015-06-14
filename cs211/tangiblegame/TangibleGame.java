import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 
import processing.video.*; 
import processing.core.PApplet; 
import processing.core.PImage; 
import java.util.*; 
import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

import papaya.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TangibleGame extends PApplet {

int depth = 450;
float rotY = 0;
float rotX = 0;
float rotZ = 0;
float speed = 1.0f;
int mode = 0; //0 = normal, 1 = SHIFT-MODE
int boxHeight = 10;
int boxWidth = 300;

PGraphics dataBackgroundSurface;
PGraphics topViewSurface;
PGraphics gameGraphics;
PGraphics videoGraphics;
PGraphics scoresSurface;
PGraphics bartChartSurface;

int userPoints;
int bestScore;

Mover mover;
float gravityConstant = 1;
ArrayList<Cylinder> cylList = new ArrayList<Cylinder>();
Cylinder cylinder = new Cylinder();

PShape tree;


public void setup(){
  size(700, 700, P3D);
  PImage firstInputImage = null;
  if(useCamera){
        String[] cameras = Capture.list();
        if (cameras.length == 0) {
           println("There are no cameras available for capture.");
           exit();
         } else {
           println("Available cameras:");
           for (int i = 0; i < cameras.length; i++) {
             println(cameras[i]);
           }
          
           // The camera can be initialized directly using an 
           // element from the array returned by list():
           cam = new Capture(this, cameras[0]);
           cam.start();
           firstInputImage = cam.get();
         }  
         //while(!cam.available() && forceCameraUse){cam.read();}
     }else if(useVideo){
        mov = new Movie(this, currentVideo); //Put the video in the same directory
        mov. loop();
        firstInputImage = mov.get();
     }
  if(imgProcessOnly){
     videoGraphics = createGraphics(640,480, P2D);
     //println(mov.width+" "+mov.height);
     calculate2D3DAngles();
  }else{
    videoGraphics = createGraphics(160,120, P2D);
     //println(mov.width+" "+mov.height);
     calculate2D3DAngles();
    //GAME MODE
    noStroke();
    tree = loadShape("data/3DModels/Obj/tree_no_tex.obj");
    tree.scale(6);
    gameGraphics = createGraphics(width,height,P3D);
    dataBackgroundSurface = createGraphics(width, height/5, P2D);
    topViewSurface = createGraphics(height/5 - 20, height/5 - 20, P2D);
    scoresSurface = createGraphics(height/8 - 20, height/5 - 20, P2D);
    bartChartSurface = createGraphics(width-(topViewSurface.width+scoresSurface.width+2*10)-20, height/5 - 20, P2D);
    mover = new Mover();
    cylinder.init();
  }
 /* */
}

public void draw(){
  
  if(imgProcessOnly && (useCamera || useVideo)){
      calculate2D3DAngles();
  }else if(imgProcessOnly && !useCamera && !useVideo){
    //Static image, we don't do anything
  }else{
    //GAME MODE
    if(bestScore<userPoints){
      bestScore=userPoints;
    }
    gameGraphics.beginDraw();
    gameGraphics.noStroke();
    gameGraphics.background(200);
    gameGraphics.directionalLight(50, 100, 125, 0, 1, 0);
    gameGraphics.ambientLight(102, 102, 102);
    if(mode==0)  {
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
    if(mode == 0 ){
      calculate2D3DAngles();
      /*PImage smallImg = null;
      if(useVideo){
       smallImg = mov.get();
      }else if(useCamera){
       smallImg = cam.get();
      }
      smallImg.resize(640/4,480/4);
      image(smallImg,0,0);*/
  }

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

 
 public void init(){
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
public void fixPosition(){
   fixedPosition = true;
   position.x = 540*(width/2-mouseX)/width;
   position.y = 540*(height/2-mouseY)/height;
}
public void display(PGraphics g){
  g.pushMatrix();
  if(mode == 0){
    g.rotateX(rotX);
    g.rotateY(rotY);
    g.rotateZ(rotZ);
    
    g.rotateX(PI);
    g.translate(-position.x, -boxHeight/2, position.y);
    g.shape(tree);

   // g.shape(roof);
    
  }else{
    g.rotateX(PI);  
    if(fixedPosition){
      g.translate(-position.x, boxHeight/2, position.y);
    }else{
      g.translate(540*(-width/2+mouseX)/width,boxHeight/2,-540*(-height/2+mouseY)/height);
    }
    g.shape(tree);
  
  //  g.shape(roof);
  }
  g.popMatrix();
}
}
ArrayList<Integer> oldScore = new ArrayList<Integer>();
public void drawDataVizualSurface(){
  dataBackgroundSurface.beginDraw();
  dataBackgroundSurface.background(190, 180, 140);
  dataBackgroundSurface.endDraw();
  image(dataBackgroundSurface, 0, height-height/5);

  drawTopViewSurface();
  drawScores();
  drawBarChart();
}
public void drawTopViewSurface(){
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
public void drawScores(){
  scoresSurface.beginDraw();
  scoresSurface.noStroke();
  scoresSurface.background(200);
  scoresSurface.fill(190, 180, 140);
  scoresSurface.rect(5,5,scoresSurface.width-10, scoresSurface.height-10);
  scoresSurface.fill(100);
  scoresSurface.text("Total Score : \n"+userPoints+
  "\n\nVelocity :\n"+Math.round((Math.sqrt(Math.pow(mover.velocity.x,2)+Math.pow(mover.velocity.z,2)))*100.0f)/100.0f+
  "\n\nBest Score:\n"+bestScore,
  10, 20);
  scoresSurface.endDraw();
  image(scoresSurface, topViewSurface.width + 20,  height-height/5+10);
}
public void drawBarChart(){
  final int xBase = 5;
  final int yBase = bartChartSurface.height-10;
  final int espace = 2;
  int squareSize = (bartChartSurface.width)/40 - espace;
  //System.out.println("squareSize = "+squareSize+". Width= "+bartChartSurface.width);
  bartChartSurface.beginDraw();
  bartChartSurface.noStroke();
  bartChartSurface.background(200);

  bartChartSurface.fill(190, 180, 140);
  bartChartSurface.rect(5,5,bartChartSurface.width-10, bartChartSurface.height-10);
  bartChartSurface.fill(100); //useless?
  while((oldScore.size())*(squareSize+espace)>=bartChartSurface.width){
    oldScore.remove(0);
  }
  for(int i=0; i<oldScore.size();i++){
   drawLine(i, oldScore.get(oldScore.size()-1-i), squareSize, espace);
  }
  
  bartChartSurface.endDraw();
  image(bartChartSurface, width-bartChartSurface.width-10,  height-height/5+10);
}

public void drawLine(final int index, final int score, final int squareSize, final int espace){
  int max = (score * bartChartSurface.height / (bestScore+1))/(squareSize+espace);
  if(max<0){
    max=0;
  }
  for(int i=0; i<max; i++){
     bartChartSurface.fill(100);
      bartChartSurface.rect(bartChartSurface.width-5- (index+1)*(squareSize+espace), bartChartSurface.height-5- (i+1)*(squareSize+espace), squareSize, squareSize); 
  }
}

 
 
 
 



 
 
 

 
 
 
 
 
 
 
 


PImage img;
PImage result;
//int width = 1500;
//int height = 325;
ArrayList<Integer> bestCandidates=new ArrayList<Integer>();
Capture cam;
Movie mov;
boolean useCamera = false;
boolean useVideo = true;
boolean imgProcessOnly = false;
boolean showInput = true;
String currentImage = "data/Images/board1.jpg";
String currentVideo = sketchPath("Video/testvideo.mp4");

    //INPUT -> HUE/Brightness/Saturation thresholding -> Blurring -> Intensity thresholding ->Sobel -> HoughTransform
    
  public void calculate2D3DAngles(){
    videoGraphics.beginDraw();
    //videoGraphics.noStroke();
    if(!imgProcessOnly){
      videoGraphics.scale(1/4.0f);
    }
    if(useCamera){
      if (cam.available() == true) {
        cam.read();
        img = cam.get();
        
        if(showInput){
          videoGraphics.image(img,0,0);
        }

      }else{
           img = loadImage(currentImage);
      }
    }else if(useVideo){
      mov.read();
      img = mov.get();    
      if(showInput){
          videoGraphics.image(img,0,0);
        }
    }else{
      img = loadImage(currentImage);
    }
    //image(img,0,0);
    PImage intensityFilteredImg = IntensityFilter(blurr(PreFilters(img)));
    ArrayList<PVector> houghLines = hough(Sobel(img, intensityFilteredImg));
    List<int[]> quads = getQuads(houghLines);
    ArrayList<PVector> intersections = getIntersections(houghLines);    
    if(!intersections.isEmpty()){
    TwoDThreeD tdtd = new TwoDThreeD(img.width, img.height);
    PVector rotationVector = tdtd.get3DRotations(TwoDThreeD.sortCorners(intersections));
    println(currentImage+": rx="+rotationVector.x*180.0f/Math.PI+", ry="+rotationVector.y*180.0f/Math.PI+", rz="+rotationVector.z*180.0f/Math.PI);
    rotX = rotationVector.x;
    rotY= rotationVector.y;
    rotZ = rotationVector.z;
    
    }
    if(!imgProcessOnly){
      videoGraphics.scale(4.0f);
    }
    videoGraphics.endDraw();
    image(videoGraphics,0,0);

  }
  
  public List<int[]> getQuads(ArrayList<PVector> lines){
    QuadGraph qgraph = new QuadGraph();
    qgraph.build(lines, width, height);
    List<int[]> quads = qgraph.findCycles();
    List<int[]> quadsFiltered = new ArrayList<int[]>();
    for (int[] quad : quads) {
        PVector l1 = lines. get(quad[0]);
        PVector l2 = lines. get(quad[1]);
        PVector l3 = lines. get(quad[2]);
        PVector l4 = lines. get(quad[3]);
           
        // (intersection() is a simplified version of the
        // intersections() method you wrote last week, that simply
        // return the coordinates of the intersection between 2 lines)
        PVector c12 = intersection(l1, l2);
        PVector c23 = intersection(l2, l3);
        PVector c34 = intersection(l3, l4);
        PVector c41 = intersection(l4, l1);
       if(QuadGraph.isConvex(c12,c23,c34,c41) && QuadGraph.validArea(c12,c23,c34,c41, width*height,0) && QuadGraph.nonFlatQuad(c12,c23,c34,c41)){
          quadsFiltered.add(quad);
       }
    }
    
    if(showInput){
      drawQuads(quadsFiltered, lines);
    }
    return quadsFiltered;
  }
  private void drawQuads(List<int[]> quads, ArrayList<PVector> lines){
    //translate(2*width/3.0,0);
     for (int[] quad : quads) {
         PVector l1 = lines. get(quad[0]);
         PVector l2 = lines. get(quad[1]);
         PVector l3 = lines. get(quad[2]);
         PVector l4 = lines. get(quad[3]);
         
         // (intersection() is a simplified version of the
         // intersections() method you wrote last week, that simply
         // return the coordinates of the intersection between 2 lines)
         PVector c12 = intersection(l1, l2);
         PVector c23 = intersection(l2, l3);
         PVector c34 = intersection(l3, l4);
         PVector c41 = intersection(l4, l1);

         // Choose a random, semi-transparent colour
         Random random = new Random();
         videoGraphics.fill(color(min(255, random. nextInt(300)),
         min(255, random. nextInt(300)),
         min(255, random. nextInt(300)), 50));
         videoGraphics.quad(c12. x, c12. y, c23. x, c23. y, c34. x, c34. y, c41. x, c41. y);
    }
   // translate(-2*width/3.0,0);
  }
  public PVector intersection(PVector line1, PVector line2){
      double P1 = line1.y;
      double P2 = line2.y;
      double R1 = line1.x;
      double R2 = line2.x;
      double d = Math.cos(P2)*Math.sin(P1) - Math.cos(P1)*Math.sin(P2);
      float x = (float)((R2*Math.sin(P1) - R1*Math.sin(P2))/d);
      float y = (float)((-1*R2*Math.cos(P1)+R1*Math.cos(P2))/d);
      return new PVector((int)x,(int)y);
  }
  public void drawHough(int[] accumulator, int rDim, int phiDim){
   PImage houghImg = createImage(rDim+2, phiDim+2, ALPHA);
   for(int i=0; i<accumulator.length;i++) {
       houghImg.pixels[i] = color(min(255,accumulator[i]));
   }
   houghImg.updatePixels();
   houghImg.resize(width/3,325);
   //videoGraphics.image(houghImg,width/3,0);
  }
  

  public PImage blurr(PImage img){
    PImage result = createImage(img.width, img.height, ALPHA);
    float[][] kernel = {
      {9,12,9},
      {12,15,12},
      {9,12,9}
    };
    float weight = 1.f;
    int ksize = 3;
    
      for(int x = 1; x<img.width-1; x++){
        for(int y =1; y<img.height-1;y++){
          int res = 0;
          for(int i =x-1; i<x+2;i++){
            for(int j =y-1;j<y+2; j++){
               res+= brightness(img.pixels[j*img.width + i]) * kernel[i+1-x][j+1-y];
            }
          }
          result.pixels[y*img.width + x] = (int)(res/weight);
        }
      }
      return result;
  }
    
              
 public PImage PreFilters(PImage img){
   PImage result = createImage(img.width, img.height, ALPHA);
   int pixelHue;
   int pixelBright;
   int pixelSat;
   float minColor = 100; 
   float maxColor = 140; 
   float minBright = 30; 
   float maxBright = 150; 
   float minSat =80; 
   float maxSat = 255;
   
   for(int x=1; x<img.width-1; x++){
    for(int y=1; y<img.height-1; y++){
      pixelHue = (int)hue(img.pixels[y*img.width + x]);
      pixelBright = (int)brightness(img.pixels[y*img.width +x ]);
      pixelSat = (int)saturation(img.pixels[y * img.width +x]);
      if(pixelHue>maxColor || pixelHue <minColor || pixelBright < minBright || pixelBright>maxBright ||pixelSat<minSat ||pixelSat>maxSat){
        result.pixels[y*img.width + x] = color(0);    
      }else {
        result.pixels[y*img.width + x] = color(255);
      }
  }
 
  } 
  return result;
 } 
 
 
 public PImage IntensityFilter(PImage img){
   float maxBrightv2 =170; 
   float minBrightv2 = 50;
   int pixelBright;
   PImage result = createImage(img.width, img.height, ALPHA);
   
   for(int x=1; x<img.width-1; x++){
    for(int y=1; y<img.height-1; y++){
      pixelBright = (int)brightness(img.pixels[y*img.width +x ]);
      if(pixelBright > maxBrightv2 || pixelBright<minBrightv2){
        result.pixels[y*img.width + x] = color(0);    
      }else{
        result.pixels[y*img.width + x] = color(255);    
      }
    }
   }
   return result;
 }
 
 
 public PImage Sobel(PImage img, PImage result){
 float[][] hKernel = {{0,1,0},
                      {0,0,0},
                     {0,-1,0}};
  float[][] vKernel = {{0,0,0},
                      {1,0,-1},
                     {0,0,0}};
   float max=0;
   float[] buffer = new float[img.width*img.height]; 
   int N = 3;

  for(int x=1; x<img.width-1; x++){
    for(int y=1; y<img.height-1; y++){
      float sumh = 0;
      float sumv = 0;           
      for(int a=-N/2;a<=N/2 ;a++){
        for(int b=-N/2;b<=N/2 ;b++){
         sumh += brightness(result.pixels[(x+a)+(y+b)*img.width])*hKernel[a+N/2][b+N/2];  
         sumv += brightness(result.pixels[(x+a)+(y+b)*img.width])*vKernel[a+N/2][b+N/2];  
        }
      }
      double sum = sqrt(pow(sumh, 2)+pow(sumv, 2));
      buffer[y*img.width+x] = (float)sum;
      if(sum>max){
        max = (float)sum;
      }
    }
  }
   for(int y =2; y<img.height-2; y++){   
     for(int x =2; x<img.width-2; x++){
       if(buffer[y*img.width+x]>(int)(max *0.3f)){
         result.pixels[y*img.width+x] = color(255);
       }else{
         result.pixels[y*img.width+x] = color(0);
       }
     }
   }                
  return result;
}

  
  public ArrayList<PVector> getIntersections(List<PVector> lines){
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  
  for(int i = 0; i<lines.size() -1;i++){
    PVector line1 = lines.get(i);
    for(int j=i+1; j<lines.size(); j++){
      PVector line2 = lines.get(j);
      double P1 = line1.y;
      double P2 = line2.y;
      double R1 = line1.x;
      double R2 = line2.x;
      double d = Math.cos(P2)*Math.sin(P1) - Math.cos(P1)*Math.sin(P2);
      float x = (float)((R2*Math.sin(P1) - R1*Math.sin(P2))/d);
      float y = (float)((-1*R2*Math.cos(P1)+R1*Math.cos(P2))/d);
      intersections.add(new PVector((int)x,(int)y));
      if(showInput){
        videoGraphics.fill(255,128,0);
        videoGraphics.ellipse(x,y,10,10);
      }
    }
  }
  return intersections;
}
  
  
  public ArrayList<PVector> hough(PImage img) {
     ArrayList<PVector> retValue = new ArrayList<PVector>();
     bestCandidates.clear();
     
     float discretizationStepsPhi =0.005f;
     float discretizationStepsR = 2.5f;
     int phiDim = (int) (Math.PI / discretizationStepsPhi);
     int rDim = (int) (((img.width + img.height)*2 + 1) / discretizationStepsR);
     int[] accumulator = new int [(phiDim +2 ) * (rDim + 2)];
     
     for(int y=0 ; y<img.height ;y++) {
       for(int x=0 ;x<img.width;x++){
         if(brightness(img.pixels[y*img.width + x]) != 0) {
           int r =0;
           int phi =0;
           double Rmax = 0;
           for(phi=0 ;phi< phiDim ;phi++) {
             r = (int)Math.round(x * cos(phi*discretizationStepsPhi) + y* sin(phi*discretizationStepsPhi));
             r=(int)(r/(discretizationStepsR) + (rDim+1)/2);
             accumulator[phi*(rDim+2)+r]+=1;      
          }        
        }
       } 
     }
       
      int neighbourhood = 10;
      int minVotes = 200;
    
    for(int accR = 0; accR<rDim; accR++){
      for(int accPhi=0; accPhi<phiDim; accPhi++){
        int idx = (accPhi+1)*(rDim+2) + accR + 1;
        if(accumulator[idx] > minVotes){
          boolean bestCandidate = true;
          for(int dPhi=-neighbourhood/2;dPhi<neighbourhood/2 + 1; dPhi++){
            if(accPhi+dPhi<0 || accPhi+dPhi >= phiDim) continue;
            for(int dR = -neighbourhood/2; dR<neighbourhood/2 +1;dR++){
              if(accR+dR<0 || accR + dR>=rDim) continue;
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
              if(accumulator[idx]<accumulator[neighbourIdx]){
                bestCandidate=false;
                break;
              }
            }if(!bestCandidate) break;
          }
          if(bestCandidate){
            bestCandidates.add(idx);
          }
        }
      }
    }
    
     Collections.sort(bestCandidates, new HoughComparator(accumulator));
     int nLines = 4;
     for(int i=0; i<nLines && bestCandidates.size() >=nLines;i++){
          int accPhi = (int) (bestCandidates.get(i) / (rDim+2)) -1;
          int accR = bestCandidates.get(i) - (accPhi +1) * (rDim+2) -1;
          float r =(accR- (rDim-1) *0.5f) * discretizationStepsR;
          float phi = accPhi * discretizationStepsPhi;
          
          retValue.add(new PVector(r,phi)); // WARNING : PVector const. takes (x,y) as args. We are dealing with serious polar coordinates here.
          
          int x0=0;
          int y0=(int) (r/sin(phi));
          int x1= (int) (r/cos(phi));
          int y1 =0;
          int x2 = img.width;
          int y2 = (int) (-cos(phi) / sin(phi) *x2+r /sin(phi));
          int y3 = img.width;
          int x3 = (int)(-(y3-r/sin(phi)) * (sin(phi) /cos(phi)));
          
          if(showInput){
            videoGraphics.stroke(204,102,0);
            if(y0>0){
              if(x1>0)
                videoGraphics.line(x0,y0,x1,y1);
              else if(y2>0)
                 videoGraphics.line(x0,y0,x2,y2);
              else
                 videoGraphics.line(x0,y0,x3,y3);
            } else {
              if(x1>0) {
                if(y2 >0)
                  videoGraphics.line(x1,y1,x2,y2);
                else
                  videoGraphics.line(x1,y1,x3,y3);
              } else   
                videoGraphics.line(x2,y2,x3,y3); 
            } 
            drawHough(accumulator, rDim, phiDim);
          } 
       }
      return retValue;
   }



class HoughComparator implements Comparator<Integer> {
 int[] acc;
 public HoughComparator(int[] acc){
   this.acc=acc;
 }
 @Override
 public int compare(Integer l1, Integer l2){
   if(acc[l1]>acc[l2] ||acc[l1]==acc[l2] &&l1<l2){
     return -1;
   }
   return 1;
 } 
}
public void keyPressed() {
  if (key == CODED) {
    if(keyCode == SHIFT){
      mode = 1;
      mov.pause();
    }if (keyCode == LEFT) {
      rotY -= PI*speed/128;
    } else if (keyCode == RIGHT) {
      rotY += PI*speed/128;
    }
  } else {
     
  }
}
public void keyReleased(){
   if(key==CODED){
    if(keyCode == SHIFT){
     mov.play();
     mode=0;
    }
   } 
}

public void mouseClicked(){
 if(mode==1){
   cylinder.fixPosition();
   cylList.add(cylinder);
   cylinder=new Cylinder();
   cylinder.init();
 }
}
/*void mouseDragged() 
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
}*/
public void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e>0){ //mouse wheel down
    speed -=0.05f;
  }else if(e<0){ //mouse wheel up
    speed +=0.05f;
  }
  if(speed<=0){
    speed = 0.05f;
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
  public void update() {
    gravity.x = sin(rotZ) * gravityConstant;
    gravity.z = sin(rotX) * gravityConstant;
    
    float normalForce = 1;
    float mu = 0.201f;
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
  public void display(PGraphics g) {
    g.pushMatrix();
    g.translate(location.x,location.y, -location.z);
    g.sphere(rSphere);
    g.popMatrix();
  }
  public void checkEdges() {
   if ((location.x > boxWidth/2) ||(location.x < -boxWidth/2)) {
      velocity.x = velocity.x*-1;
      userPoints -= Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      oldScore.add(userPoints);
      location.x = boxWidth/2*Math.abs(location.x)/location.x;
    }
    if ((location.z > boxWidth/2) ||(location.z < -boxWidth/2)) {
      velocity.z = velocity.z*-1;
      userPoints -= Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      oldScore.add(userPoints);
      location.z = boxWidth/2*Math.abs(location.z)/location.z;
    }
  }
  public void checkCylinderCollision(){
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
      oldScore.add(userPoints);
      location.add(velocity);
    }
  }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TangibleGame" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
