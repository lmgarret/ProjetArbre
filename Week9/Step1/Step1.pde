import processing.core.PApplet;
import processing.core.PImage;

public class Step1 extends PApplet{ 
  PImage img;
  PImage result;
  
  public void setup(){
    size(800,600);
   img = loadImage("board1.jpg");
   //result = img;
    img =Sobel(img);
    hough(img);
       //noLoop();
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
   float minColor = 110;
   float maxColor = 135;
   for(int x=1; x<img.width-1; x++){
    for(int y=1; y<img.height-1; y++){
      pixelHue = (int)hue(img.pixels[y*img.width + x]);
      if(pixelHue>maxColor || pixelHue <minColor){
      preResult.pixels[y*img.width + x] = color(0);    
      }else {
        preResult.pixels[y*img.width + x] = color(255);
      }
  }
 
  }
   
                     
   PImage result = createImage(img.width, img.height, ALPHA);
   
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
  
  
  
  
public void hough(PImage img) {
 
 
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
         r = (int)Math.round(x * cos(phi*discretizationStepsPhi)  + y* sin(phi*discretizationStepsPhi));
         r=(int)(r/(discretizationStepsR) + (rDim+1)/2);
         accumulator[phi*(rDim+2)+r]+=1;         
      }        
    }
   } 
 }
 
 PImage houghImg = createImage(rDim +2 , phiDim+2 , ALPHA);
 
   for(int i=0; i<accumulator.length;i++) {
     houghImg.pixels[i] = color(min(255,accumulator[i]));
    }
   houghImg.updatePixels();
   houghImg.resize(800,600);
   image(houghImg,0,0);
  }  
}
