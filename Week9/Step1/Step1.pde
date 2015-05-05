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
       int accPhi =0;
       double Rmax = 0;
      for(accPhi=0 ;accPhi< phiDim ;accPhi++) {
         r = x * cos(accPhi*discretizationStepsPhi) + y* sin(accPhi*discretizationStepsPhi);
         r=r/discretizationStepsR + (rDim-1)/2;
         accumulator[(accPhi+1)*(rDim + 2) +(int) Math.floor(r+1)]++;
          
       } // WTF IS DAT ? genre pourquoi cette formule a la con qui donne un double je ne comprends pa
       
     }
   } 
 }
 
 PImage houghImg = createImage(rDim +2 , phiDim+2 , ALPHA);
 
   for(int i=0; i<accumulator.length;i++) {
     houghImg.pixels[i] = color(min(255,accumulator[i]));
    }
   houghImg.updatePixels();
  }  
}
