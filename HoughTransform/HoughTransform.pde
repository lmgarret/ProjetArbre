import processing.core.PApplet;
import processing.core.PImage;
import processing.video.Capture;

public class HoughTransform extends PApplet{
   Capture cam;
  PImage img;
  public void setup(){
      size(640,480);
      String[] cameras = Capture.list();
      if(cameras.length==0){
        println("sry no cam");
      }else{
        println("cam ok");
          for(int i=0;i<cameras.length;i++){
             println(cameras[i]);   
          }
        cam = new Capture(this, cameras[0]);
        cam.start();
      }
    
  }
  public void draw(){
   if(cam.available()){
    cam.read();
   }
  img=cam.get();
 image(img,0,0); 
  }
  
}
