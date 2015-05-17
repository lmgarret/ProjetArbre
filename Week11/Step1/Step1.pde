import processing.core.PApplet;
import processing.core.PImage;
import java.util.*;
import processing.video.Capture;


public class Step1 extends PApplet{ 
  PImage img;
  PImage result;
    Capture cam;
  ArrayList<Integer> bestCandidates=new ArrayList<Integer>();
    //INPUT -> HUE/Brightness/Saturation thresholding -> Blurring -> Intensity thresholding ->Sobel -> HoughTransform
    
  public void setup(){
    size(800,600);
    //img = loadImage("board1.jpg");
        String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }
      cam = new Capture(this, cameras[0]);
      cam.start();
      img = cam.get();
    }
       //noLoop();
  }
  void draw() {
    if (cam.available() == true) {
      cam.read();
      img = cam.get();
      image(img, 0, 0);
      if(img != null){
         
    PImage sobelImg = Sobel(img);
    image(sobelImg,0,0);
    List<PVector> lines = hough(sobelImg);
    List<PVector> allLines = getIntersections(lines);
    
    QuadGraph quadGraph= new QuadGraph();
    quadGraph.build(lines, width, height);
    
    List<int[]> quads = quadGraph.findCycles();
    List<int[]> filteredQuads = new ArrayList<int[]>();
    for (int[] cy : quads) {
          //if(quadGraph.isConvex(lines.get(cy[0]), lines.get(cy[1]),lines.get(cy[2]),lines.get(cy[3])) && quadGraph.validArea(lines.get(cy[0]), lines.get(cy[1]),lines.get(cy[2]),lines.get(cy[3]), width, height) && quadGraph.nonFlatQuad(lines.get(cy[0]), lines.get(cy[1]),lines.get(cy[2]),lines.get(cy[3]))){
             filteredQuads.add(cy); 
          //}
    }

    for (int[] quad : filteredQuads) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
      PVector l4 = lines.get(quad[3]);
      // (intersection() is a simplified version of the
      // intersections() method you wrote last week, that simply
      // return the coordinates of the intersection between 2 lines)
      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      // Choose a random, semi-transparent colour
      Random random = new Random();
      fill(color(min(255, random.nextInt(300)),
      min(255, random.nextInt(300)),
      min(255, random.nextInt(300)), 50));
      quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
    } 
      }
    }
}
  
  public PImage blurr(PImage img){
    float[][] kernel = {
      {9,12,9},
      {12,15,12},
      {9,12,9}
    };
    float weight = 1.f;
    PImage result = createImage(img.width, img.height, ALPHA);
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
              
  
 public PImage Sobel(PImage img){
 PImage preResult = createImage(img.width, img.height, ALPHA);
 float[][] hKernel = {{0,1,0},
                      {0,0,0},
                     {0,-1,0}};
  float[][] vKernel = {{0,0,0},
                      {1,0,-1},
                     {0,0,0}};
   int pixelHue;
   int pixelBright;
   int pixelSat;
   float minColor = 100; 
   float maxColor = 140; 
   float minBright = 20; 
   float maxBright = 150; 
   float minSat =80; 
   float maxSat = 255; 
   float maxBrightv2 =60; 
   float minBrightv2 = 40;
   
   for(int x=1; x<img.width-1; x++){
    for(int y=1; y<img.height-1; y++){
      pixelHue = (int)hue(img.pixels[y*img.width + x]);
      pixelBright = (int)brightness(img.pixels[y*img.width +x ]);
      pixelSat = (int)saturation(img.pixels[y * img.width +x]);
      if(pixelHue>maxColor || pixelHue <minColor || pixelBright < minBright || pixelBright>maxBright ||pixelSat<minSat ||pixelSat>maxSat){
      preResult.pixels[y*img.width + x] = color(0);    
      }else {
        preResult.pixels[y*img.width + x] = color(255);
      }
  }
 
  }
   
                     
   PImage result = blurr(preResult);
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
   
   float max=0;
   float[] buffer = new float[img.width*img.height];
   
   int N = 3;

  for(int x=1; x<img.width-1; x++){
    for(int y=1; y<img.height-1; y++){
      float sumh = 0;
      float sumv = 0;           
      for(int a=-N/2;a<=N/2 ;a++){
        for(int b=-N/2;b<=N/2 ;b++){
         sumh += brightness(preResult.pixels[(x+a)+(y+b)*img.width])*hKernel[a+N/2][b+N/2];  
         sumv += brightness(preResult.pixels[(x+a)+(y+b)*img.width])*vKernel[a+N/2][b+N/2];  
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
      fill(255,128,0);
      ellipse(x,y,10,10);
    }
  }
  return intersections;
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
  
  
public ArrayList<PVector> hough(PImage img) {
 ArrayList<PVector> retValue = new ArrayList<PVector>();
 
 float discretizationStepsPhi =0.02f;
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
 /*  for(int idx=0;idx<accumulator.length ;idx++) {
    if(accumulator[idx]>200){
      bestCandidates.add(idx);
    }
   }*/
   //Here begin the optimization
   
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
   //Here it ends
 Collections.sort(bestCandidates, new HoughComparator(accumulator));
 int nLines = 4;
 for(int i=0; i<nLines;i++){
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
      
      stroke(204,102,0);
      if(y0>0){
        if(x1>0)
          line(x0,y0,x1,y1);
        else if(y2>0)
           line(x0,y0,x2,y2);
        else
           line(x0,y0,x3,y3);
      }
      else {
        if(x1>0) {
          if(y2 >0)
            line(x1,y1,x2,y2);
          else
            line(x1,y1,x3,y3);
          }
         else   
         line(x2,y2,x3,y3); 
      } 
 }/*
  for(int idx=0;idx<accumulator.length ;idx++) {
    if(accumulator[idx]>200){
      int accPhi = (int) (idx / (rDim+2)) -1;
      int accR = idx - (accPhi +1) * (rDim+2) -1;
      float r =(accR- (rDim-1) *0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      
      int x0=0;
      int y0=(int) (r/sin(phi));
      int x1= (int) (r/cos(phi));
      int y1 =0;
      int x2 = img.width;
      int y2 = (int) (-cos(phi) / sin(phi) *x2+r /sin(phi));
      int y3 = img.width;
      int x3 = (int)(-(y3-r/sin(phi)) * (sin(phi) /cos(phi)));
      
      stroke(204,102,0);
      if(y0>0){
        if(x1>0)
          line(x0,y0,x1,y1);
        else if(y2>0)
           line(x0,y0,x2,y2);
        else
           line(x0,y0,x3,y3);
      }
      else {
        if(x1>0) {
          if(y2 >0)
            line(x1,y1,x2,y2);
          else
            line(x1,y1,x3,y3);
          }
         else   
         line(x2,y2,x3,y3); 
      }  
    }
  }*/
  bestCandidates.clear();
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
}
  
