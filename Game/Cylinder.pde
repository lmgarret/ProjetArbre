class Cylinder{
 PVector position = new PVector(0,0,0);
 boolean fixedPosition =false;
 float cylBS=25;
 float cylH=25;
 int cylRes=40;
 PShape openCylinder = new PShape();
 PShape roof = new PShape();

 
 void init(){
   float angle=0;
   float[] x = new float[cylRes + 1];
   float[] y = new float[cylRes + 1];
  
   //get the x and y position on a circle for all the sides
   for(int i = 0; i < x.length; i++){
    angle = (TWO_PI / cylRes) * i;
    x[i] = sin(angle) * cylBS;
    y[i] = cos(angle) * cylBS;
   }
   openCylinder = createShape();
   openCylinder.beginShape(QUAD_STRIP);
   
   //draw the border of the cylinder
   for(int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i] , 0);
    openCylinder.vertex(x[i], y[i], cylH);
   }
   openCylinder.endShape();
   
   roof = createShape();
   roof.beginShape(TRIANGLE_FAN);
   for(int i =0; i<x.length;i++){
     roof.vertex(x[i],y[i], cylH);
   }
   roof.endShape();
   roof.beginShape(TRIANGLE_FAN);
   for(int i =0; i<x.length;i++){
     roof.vertex(x[i],y[i], 0);
   }
   roof.endShape();
}
void fixPosition(){
   fixedPosition = true;
   position.x = 540*(width/2-mouseX)/width;
   position.y = 540*(height/2-mouseY)/height;
}
void display(PGraphics g){
  g.pushMatrix();
  if(mode == 0){
    g.rotateX(rotX);
    g.rotateY(rotY);
    g.rotateZ(rotZ);
    
    g.rotateX(PI);
    g.translate(-position.x, -boxHeight/2, position.y);
    g.shape(tree);

   // g.shape(roof);
    
  }else{
    g.rotateX(PI);  
    if(fixedPosition){
      g.translate(-position.x, boxHeight/2, position.y);
    }else{
      g.translate(540*(-width/2+mouseX)/width,boxHeight/2,-540*(-height/2+mouseY)/height);
    }
    g.shape(tree);
  
  //  g.shape(roof);
  }
  g.popMatrix();
}
}
