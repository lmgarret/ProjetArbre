import processing.core.PApplet;
import processing.core.PImage;

public class Step1 extends PApplet{ 
  PImage img;
  PImage result;
  
  public void setup(){
    size(800,600);
   img = loadImage("board1.jpg");
   //result = img;
    hough(img);
       //noLoop();
  }
  
public void hough(PImage img) {
 
 
 float discretizationStepsPhi =0.06f;
 float discretizationStepsR = 2.5f;

 int phiDim = (int) (Math.PI / discretizationStepsPhi);
 int rDim = (int) (((img.width + img.height)*2 + 1) / discretizationStepsR);
 
 int[] accumulator = new int [(phiDim +2 ) * (rDim + 2)];
 
 for(int y=0 ; y<img.height ;y++) {
   for(int x=0 ;x<img.width;x++){
     
     if(brightness(img.pixels[y*img.width + x]) != 0) {
       double r =0;
       float phi =0;
       double Rmax = 0;
       int i =0;
       for(phi=0 ;phi< PI ;phi+=discretizationStepsPhi) {
         r = x * cos(phi) + y* sin(phi);
         i++;
           accumulator[ i *(rDim + 2) +(int) Math.floor(r)] +=1;
          
       } // WTF IS DAT ? genre pourquoi cette formule a la con qui donne un double je ne comprends pa
       
     }
   } 
 }
 
 PImage houghImg = createImage(rDim +2 , phiDim+2 , ALPHA);
 
   for(int i=0; i<accumulator.length;i++) {
     houghImg.pixels[i] = color(min(255,accumulator[i]));
    }
   for(int i=0;i<accumulator.length;i++){
   if(accumulator[i]>200){
   int accPhi = (int)(i/(rDim+2))-1;
   int accR = i - (accPhi+1)*(rDim+2) - 1;
   float r = (accR - (rDim -1)*0.5f) * discretizationStepsR;
   float phi = accPhi * discretizationStepsPhi;
   
   int x0=0;
   int x1=(int)(r/cos(phi));
   int y0=(int)(r/sin(phi));
   int y1=0;
   int x2=img.width;
   int y2=(int)(-cos(phi)/sin(phi) *x2 + r/sin(phi));
   int y3=img.width;
   int x3=(int)(-(y3-r  /sin(phi))*  (sin(phi)/cos(phi)));
   
   stroke(204, 102, 0);
     if(y0>0){
       if(x1>0){
         line(x0,y0,x1,y1);
       }else if(y2>0){
          line(x0,y0,x2,y2);
       }else{
         line(x0,y0,x3,y3);
       }
     }else{
       if(x1>0){
         if(y2>0){
         line(x1,y1,x2,y2);
       }else{
         line(x1,y1,x3,y3);
       }
      }else{
         line(x2, y2, x3, y3);
      }       
       
     }
   }
   }
   houghImg.updatePixels();
  }  
}
