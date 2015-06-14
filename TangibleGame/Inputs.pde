void keyPressed() {
  if (key == CODED) {
    if(keyCode == SHIFT){
      mode = 1;
      mov.pause();
    }if (keyCode == LEFT) {
      rotY -= PI*speed/128;
    } else if (keyCode == RIGHT) {
      rotY += PI*speed/128;
    }
  } else {
     
  }
}
void keyReleased(){
   if(key==CODED){
    if(keyCode == SHIFT){
     mov.play();
     mode=0;
    }
   } 
}

void mouseClicked(){
 if(mode==1){
   cylinder.fixPosition();
   cylList.add(cylinder);
   cylinder=new Cylinder();
   cylinder.init();
 }
}
/*void mouseDragged() 
{
  if(mode == 0){
    rotX = map(mouseX, 0, width, -PI/3, PI/3)*speed;
    rotZ = map(mouseY, 0, height, -PI/3, PI/3)*speed;
    
    if(rotX > PI/3){
       rotX = PI/3; 
    }else if(rotX < -PI/3){
       rotX = -PI/3;
    }
    if(rotZ > PI/3){
       rotZ = PI/3; 
    }else if(rotZ < -PI/3){
       rotZ = -PI/3;
    }
  }
}*/
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e>0){ //mouse wheel down
    speed -=0.05;
  }else if(e<0){ //mouse wheel up
    speed +=0.05;
  }
  if(speed<=0){
    speed = 0.05;
  }
}



