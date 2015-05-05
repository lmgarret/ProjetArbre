import processing.core.PApplet;
import processing.core.PImage;


public class Week8_3 extends PApplet{
  double saveDown;
  double saveUp;
  HScrollbar thresholdBarDown;
  HScrollbar thresholdBarUp;
  PImage img;
  PImage result;
  PImage resultA;
  public void setup(){
    size(800,600);
    thresholdBarDown = new HScrollbar(0,580,800,20);
    thresholdBarUp = new HScrollbar(0,555,800,20);
    saveDown = 0;
    saveUp = 0;
    img = loadImage("board1.jpg");
    resultA = createImage(width, height, ALPHA);
    result = createImage(width, height, ALPHA);
      resultA =  re(img);
  }
  
  public void draw(){
  //  if(saveUp!=thresholdBarUp.getPos()){
   //   saveUp=thresholdBarUp.getPos();

   // }else if(saveDown!=thresholdBarDown.getPos()){
  //    saveDown = thresholdBarDown.getPos();
    result = Sobel(resultA);
    //}
    image(result,0,0);
    thresholdBarDown.display();
    thresholdBarDown.update();
    thresholdBarUp.display();
    thresholdBarUp.update();

    
  }
  public PImage re(PImage img){
        result = createImage(width, height, RGB);
    for(int i=0; i<img.width*img.height;i++){   
       if(hue(img.pixels[i])>105 && hue(img.pixels[i])<135){
         result.pixels[i]=color(255,255,255);        
       }else{
          result.pixels[i]=color(0,0,0);
    }
    }
    return result;
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
       if(buffer[y*img.width+x]>(int)(max*0.3f)){
         result.pixels[y*img.width+x] = color(255);
       }else{
         result.pixels[y*img.width+x] = color(0);
       }
     }
   }
return result;   
}
  
  class HScrollbar {
  float barWidth;  //Bar's width in pixels
  float barHeight; //Bar's height in pixels
  float xPosition;  //Bar's x position in pixels
  float yPosition;  //Bar's y position in pixels
  
  float sliderPosition, newSliderPosition;    //Position of slider
  float sliderPositionMin, sliderPositionMax; //Max and min values of slider
  
  boolean mouseOver;  //Is the mouse over the slider?
  boolean locked;     //Is the mouse clicking and dragging the slider now?

  /**
   * @brief Creates a new horizontal scrollbar
   * 
   * @param x The x position of the top left corner of the bar in pixels
   * @param y The y position of the top left corner of the bar in pixels
   * @param w The width of the bar in pixels
   * @param h The height of the bar in pixels
   */
  HScrollbar (float x, float y, float w, float h) {
    barWidth = w;
    barHeight = h;
    xPosition = x;
    yPosition = y;
    
    sliderPosition = xPosition + barWidth/2 - barHeight/2;
    newSliderPosition = sliderPosition;
    
    sliderPositionMin = xPosition;
    sliderPositionMax = xPosition + barWidth - barHeight;
  }
  /**
   * @brief Updates the state of the scrollbar according to the mouse movement
   */
  void update() {
    if (isMouseOver()) {
      mouseOver = true;
    }
    else {
      mouseOver = false;
    }
    if (mousePressed && mouseOver) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newSliderPosition = constrain(mouseX - barHeight/2, sliderPositionMin, sliderPositionMax);
    }
    if (abs(newSliderPosition - sliderPosition) > 1) {
      sliderPosition = sliderPosition + (newSliderPosition - sliderPosition);
    }
  }

  /**
   * @brief Clamps the value into the interval
   * 
   * @param val The value to be clamped
   * @param minVal Smallest value possible
   * @param maxVal Largest value possible
   * 
   * @return val clamped into the interval [minVal, maxVal]
   */
  float constrain(float val, float minVal, float maxVal) {
    return min(max(val, minVal), maxVal);
  }

  /**
   * @brief Gets whether the mouse is hovering the scrollbar
   *
   * @return Whether the mouse is hovering the scrollbar
   */
  boolean isMouseOver() {
    if (mouseX > xPosition && mouseX < xPosition+barWidth &&
      mouseY > yPosition && mouseY < yPosition+barHeight) {
      return true;
    }
    else {
      return false;
    }
  }

  /**
   * @brief Draws the scrollbar in its current state
   */ 
  void display() {
    noStroke();
    fill(204);
    rect(xPosition, yPosition, barWidth, barHeight);
    if (mouseOver || locked) {
      fill(0, 0, 0);
    }
    else {
      fill(102, 102, 102);
    }
    rect(sliderPosition, yPosition, barHeight, barHeight);
  }

  /**
   * @brief Gets the slider position
   * 
   * @return The slider position in the interval [0,1] corresponding to [leftmost position, rightmost position]
   */
  float getPos() {
    return (sliderPosition - xPosition)/(barWidth - barHeight);
  }
}

  
}

 
