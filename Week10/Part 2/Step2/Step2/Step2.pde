public ArrayList<PVector> getInteresections(List<PVector> lines){
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for(int i = 0; i<lines.size() -1;i++){
    PVector line1 = lines.get(i);
    for(int j=i+1; j<lines.size(); j++){
      PVector line2 = lines.get(j);
      double P1 = line1.y;
      double P2 = line2.y;
      double R1 = line1.x;
      double R2 = line2.x;
      double d = Math.cos(P2)*Math.sin(P1) - Math.cos(P1)*Math.sin(P2);
      int x = (R2*Math.sin(P1) - R1*Math.sin(P2))/d;
      int y = (-1*R2*Math.cos(P1)+R1*Math.cos(P2))/d;
      
      fill(255,128,0);
      ellipse(x,y,10,10);
    }
  }
  return intersections;
}
