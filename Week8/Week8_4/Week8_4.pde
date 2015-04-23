
import processing.core.PApplet;
import processing.core.PImage;
public class Week8_4 extends PApplet{
  PImage img;
  PImage result;
  public void setup(){
    size(800,600);
   img = loadImage("board1.jpg");
   //result = img;
    result = Sobel(img);
   //     noLoop();
  }
  
 public void draw(){
    image(result,0,0);
 }
 
public PImage Sobel(PImage img){
 float[][] hKernel = {{0,1,0},
                      {0,0,0},
                     {0,-1,0}};
  float[][] vKernel = {{0,0,0},
                      {1,0,-1},
                     {0,0,0}};
                     
   PImage result = createImage(img.width, img.height, ALPHA);
   
   for(int i=0; i<img.width*img.height;i++){
     result.pixels[i]=color(0);
   }
   float max=0;
   float[] buffer = new float[img.width*img.height];
   
   int N = 3;

  for(int x=1; x<img.width-1; x++){
    for(int y=1; y<img.height-1; y++){
      float sumh = 0;
      float sumv = 0;           
      for(int a=-N/2;a<N/2 +1;a++){
        for(int b=-N/2;b<N/2 +1;b++){
         sumh += brightness(img.pixels[(x+a)+(y+b)*img.width])*hKernel[a+N/2][b+N/2];  
         sumv += brightness(img.pixels[(x+a)+(y+b)*img.width])*vKernel[a+1][b+1];  
        }
      }
      double sum = sqrt(pow(sumh, 2)+pow(sumv, 2));
      buffer[y*img.width+x] = (float)sum;
      if(sum>max){
        max=(float)sum;
      }
    }
  }
   for(int y =2; y<img.height-2; y++){   
     for(int x =2; x<img.width-2; x++){
       if(buffer[y*img.width+x]>(int)(max*0.3)){
         result.pixels[y*img.width+x] = color(255);
       }else{
         result.pixels[y*img.width+x] = color(0);
       }
     }
   }                     
  return result;
}
}
