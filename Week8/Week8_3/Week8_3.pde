import processing.core.PApplet;
import processing.core.PImage;


public class Week8_3 extends PApplet{
  HScrollbar thresholdBarDown;
  HScrollbar thresholdBarUp;
  PImage img;
  PImage result;
  public void setup(){
    size(800,600);
    thresholdBarDown = new HScrollbar(0,580,800,20);
    thresholdBarUp = new HScrollbar(0,555,800,20);
    img = loadImage("board3.jpg");
   // result = img;
    result = convolute(img);

       // noLoop();
  }
  
  public void draw(){
    image(result,0,0);
    thresholdBarDown.display();
    thresholdBarDown.update();
    thresholdBarUp.display();
    thresholdBarUp.update();
   // re();
  }
  public void re(){
        result = createImage(width, height, RGB);
    for(int i=0; i<img.width*img.height;i++){
       if(hue(img.pixels[i])>thresholdBarDown.getPos()*255 && hue(img.pixels[i])<thresholdBarUp.getPos()*255){
          result.pixels[i]=img.pixels[i];
       }else{
         result.pixels[i]=color(0,0,0);
    }
    }
   }
   
 public PImage convolute(PImage img){
 float[][] kernel = {{0,0,0},
                     {0,2,0},
                    {0,0,0}};
                   
  float weight = 1.f;
 
 PImage result = createImage(img.width, img.height, ALPHA);
int N = 3;

  for(int x=1; x<img.width-1; x++){
    for(int y=1; y<img.height-1; y++){
      double newValue = 0;
      for(int a=-N/2;a<N/2;a++){
        for(int b=-N/2;b<N/2;b++){
         newValue += brightness(img.pixels[(x+a)+(y+b)*img.width])*kernel[a+N/2][b+N/2];  
        }
      }
      newValue = newValue/weight;
      result.pixels[y*img.width + x] = color((int)newValue);
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

 
