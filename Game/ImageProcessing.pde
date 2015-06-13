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


PImage img;
PImage result;
//int width = 1500;
//int height = 325;
ArrayList<Integer> bestCandidates=new ArrayList<Integer>();
Capture cam;
Movie mov;
boolean useCamera = false;
boolean useVideo = true;
boolean forceCameraUse = useCamera;
boolean imageProcessingDisplayMode = true;
String currentImage = "data/Images/board1.jpg";
String currentVideo = sketchPath("Video/testvideo.mp4");

    //INPUT -> HUE/Brightness/Saturation thresholding -> Blurring -> Intensity thresholding ->Sobel -> HoughTransform
    
  public void calculate2D3DAngles(){
    if(useCamera){
      if (cam.available() == true) {
        cam.read();
        img = cam.get();
        
        if(imageProcessingDisplayMode){
          image(img,0,0);
        }

      }else{
           img = loadImage(currentImage);
      }
    }else if(useVideo){
      mov.read();
      img = mov.get();    
      if(imageProcessingDisplayMode){
          image(img,0,0);
        }
    }else{
      img = loadImage(currentImage);
    }
    image(img,0,0);
    PImage intensityFilteredImg = IntensityFilter(blurr(PreFilters(img)));
    ArrayList<PVector> houghLines = hough(Sobel(img, intensityFilteredImg));
    List<int[]> quads = getQuads(houghLines);
    ArrayList<PVector> intersections = getIntersections(houghLines);    
    if(!intersections.isEmpty()){
    TwoDThreeD tdtd = new TwoDThreeD(img.width, img.height);
    PVector rotationVector = tdtd.get3DRotations(TwoDThreeD.sortCorners(intersections));
    println(currentImage+": rx="+rotationVector.x*180.0/Math.PI+", ry="+rotationVector.y*180.0/Math.PI+", rz="+rotationVector.z*180.0/Math.PI);
    }
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
    
    if(imageProcessingDisplayMode){
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
         fill(color(min(255, random. nextInt(300)),
         min(255, random. nextInt(300)),
         min(255, random. nextInt(300)), 50));
         quad(c12. x, c12. y, c23. x, c23. y, c34. x, c34. y, c41. x, c41. y);
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
   image(houghImg,width/3,0);
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
   float minBright = 20; 
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
      if(imageProcessingDisplayMode){
        fill(255,128,0);
        ellipse(x,y,10,10);
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
          
          if(imageProcessingDisplayMode){
            stroke(204,102,0);
            if(y0>0){
              if(x1>0)
                line(x0,y0,x1,y1);
              else if(y2>0)
                 line(x0,y0,x2,y2);
              else
                 line(x0,y0,x3,y3);
            } else {
              if(x1>0) {
                if(y2 >0)
                  line(x1,y1,x2,y2);
                else
                  line(x1,y1,x3,y3);
              } else   
                line(x2,y2,x3,y3); 
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
