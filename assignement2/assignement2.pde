void setup () {
  size(1000,1000,P2D);
}
void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

class My2DPoint{
  float x;
  float y;
  My2DPoint(float x, float y){
    this.x=x;
    this.y=y;
  }
}
class My3DPoint{
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z){
    this.x=x;
    this.y=y;
    this.z=z;
  }
}
My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
 float[][] matrixT = {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {-eye.x, -eye.y, -eye.z, 1}};
 float[][] matrixP = {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 1/(-eye.z)}, {0, 0, 0, 0}};
 float[][] matrixPoint = {{p.x, p.y, p.z, 1}};
 
 float[][] result = matrixProduct(matrixP, matrixProduct(matrixT, matrixPoint));
 float coeffHom = result[0][3];
 return new My2DPoint(result[0][0]/coeffHom, result[0][1]/coeffHom);
 
}
float[][] matrixProduct(float[][] b, float[][] a){
 int rowsInA = a.length;
 int columnsInA = a[0].length; // same as rows in B
 int columnsInB = b[0].length;
 float[][] c = new float[rowsInA][columnsInB];
 for (int i = 0; i < rowsInA; i++) {
   for (int j = 0; j < columnsInB; j++) {
     for (int k = 0; k < columnsInA; k++) {
       c[i][j] = c[i][j] + a[i][k] * b[k][j];
     }
   }
 }
 return c;
}
class My2DBox {
  My2DPoint[] s;
  
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render(){
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[1].x, s[1].y, s[2].x, s[2].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[3].x, s[3].y, s[0].x, s[0].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[4].x, s[4].y, s[7].x, s[7].y);
    line(s[7].x, s[7].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[5].x, s[5].y);
    line(s[5].x, s[5].y, s[4].x, s[4].y);
  }
}
class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{
      new My3DPoint(x,y+dimY,z+dimZ),
      new My3DPoint(x,y,z+dimZ),
      new My3DPoint(x+dimX,y,z+dimZ),
      new My3DPoint(x+dimX,y+dimY,z+dimZ),
      new My3DPoint(x,y+dimY,z),
      origin,
      new My3DPoint(x+dimX,y,z),
      new My3DPoint(x+dimX,y+dimY,z)
    };
  }
  My3DBox(My3DPoint[] p) {
  this.p = p;
  }
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] projection = new My2DPoint[box.p.length];
  for(int i = 0; i< box.p.length; i++){
     projection[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(projection);
}

float[] homogeneous3DPoint(My3DPoint p) {
  float[] result = {p.x, p.y, p.z , 1};
  return result;
}
float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0 , 0 , 0},
  {0, cos(angle), sin(angle) , 0},
  {0, -sin(angle) , cos(angle) , 0},
  {0, 0 , 0 , 1}});
}
float[][] rotateYMatrix(float angle) {
  return(new float[][] {{cos(angle), 0 , -sin(angle) , 0},
  {0, 1, 0, 0},
  {sin(angle), 0 , cos(angle) , 0},
  {0, 0 , 0 , 1}});
}
float[][] rotateZMatrix(float angle) {
  return(new float[][] {{cos(angle), sin(angle), 0, 0},
  {-sin(angle), cos(angle), 0, 0},
  {0, 0, 1, 0},
  {0, 0 , 0 , 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  return (new float[][]{{x, 0, 0, 0},
    {0, y, 0, 0},
    {0, 0, z, 0},
    {0, 0, 0, 1}});
}
float[][] translationMatrix(float x, float y, float z) {
  return (new float[][]{{1, 0, 0, 0},
    {0, 1, 0, 0},
    {0, 0, 1, 0},
    {x, y, z, 1}});
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  float[][] homPoints = new float[box.p.length][4];
  for (int i=0; i<box.p.length; i++){
    homPoints[i] = homogeneous3DPoint(box.p[i]);
  }
  float[][] homTransf = matrixProduct(transformMatrix, homPoints);
  My3DPoint[] euclResult = new My3DPoint[homTransf.length];
  for (int i=0; i<euclResult.length; i++){
     euclResult[i] = euclidian3DPoint(homTransf[i]); 
  }
  return new My3DBox(euclResult);
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}
