//package cs211;

import processing.core.PApplet;
import processing.core.PImage;

public class Week8_1 extends PApplet{
  PImage img;
  PImage result;
  public void setup(){
    size(800,600);
    img = loadImage("board1.jpg");
    result = createImage(width, height, RGB);
    for(int i=0; i<img.width*img.height;i++){
       if(brightness(img.pixels[i])>128){
          result.pixels[i]=color(255,255,255);
       }else{
         result.pixels[i]=color(0,0,0);
    }
    }
    noLoop();
  }
  
  public void draw(){
    image(result,0,0);
  }
}
