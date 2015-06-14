class Mover {
  PVector location;
  PVector velocity;
  PVector gravity;
  float rSphere = 10;
  Mover() {
    location = new PVector(0, -rSphere/2, 0);
    velocity = new PVector(2, 0, 2);
    gravity = new PVector(1,0,1);
  }
  void update() {
    gravity.x = sin(rotZ) * gravityConstant;
    gravity.z = sin(rotX) * gravityConstant;
    
    float normalForce = 1;
    float mu = 0.201;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    checkCylinderCollision();
    velocity.add(gravity);
    velocity.add(friction);
    location.add(velocity);
  }
  void display(PGraphics g) {
    g.pushMatrix();
    g.translate(location.x,location.y, -location.z);
    g.sphere(rSphere);
    g.popMatrix();
  }
  void checkEdges() {
   if ((location.x > boxWidth/2) ||(location.x < -boxWidth/2)) {
      velocity.x = velocity.x*-1;
      userPoints -= Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      oldScore.add(userPoints);
      location.x = boxWidth/2*Math.abs(location.x)/location.x;
    }
    if ((location.z > boxWidth/2) ||(location.z < -boxWidth/2)) {
      velocity.z = velocity.z*-1;
      userPoints -= Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      oldScore.add(userPoints);
      location.z = boxWidth/2*Math.abs(location.z)/location.z;
    }
  }
  void checkCylinderCollision(){
    for(Cylinder c : cylList){
        PVector cRealPosition = new PVector(-c.position.x, 0, c.position.y);
    //   System.out.println("c.position : "+ cRealPosition.x+", "+cRealPosition.z+". c.falseposition : "+c.position.x+", "+c.position.y+". ballPosition : "+location.x+", "+location.y+", "+location.z+".");
      if(location.dist(cRealPosition)<rSphere+c.cylBS){
     //   System.out.println("this is working" + location.dist(cRealPosition));
      PVector n = new PVector(location.x - cRealPosition.x, 0, location.z - cRealPosition.z);
       n.normalize();  
       n.mult(2*(velocity.dot(n)));
      velocity.sub(n);
      userPoints += Math.round(Math.sqrt(Math.pow(velocity.x,2)+Math.pow(velocity.z,2)));
      oldScore.add(userPoints);
      location.add(velocity);
    }
  }
  }
}
