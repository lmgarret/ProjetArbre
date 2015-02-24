void setup() {
  size (400 ,400 , P2D);
}

void draw() {
  line (200,200,400,400);
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x , float y) {
    this.x = x;
    this.y = y;
    
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y , float z) {
    this.x = x;
    this.y = y;
    this.z = z;
    
  }
}

My2DPoint projectPoint(My3DPoint eye ,My3DPoint p) {
  float [][] transformation = {{1,0,0,-eye.x} , {0,1,0,-eye.y}, {0,0,1,-eye.z} , {0,0,0,1}};
  float [][] projection = {{1,0,0,0} , {0,1,0,0} , {0,0,1,0},{0,0,(1/-eye.z),0}};
  float[][] yolo ={{p.x,p.y ,p.z ,1}}
  float [][] result = matrixMultiplication(matrixMultiplication(transformation,projection) , yolo );
  
  retrun result;
}

float[][] matrixMultiplication(float [][] a, float [][] b) {
       int rowsInA = a.length;
       int columnsInA = a[0].length;
       int columnsInB = b[0].length;
       int[][] c = new int[rowsInA][columnsInB];
       for (int i = 0; i < rowsInA; i++) {
           for (int j = 0; j < columnsInB; j++) {
               for (int k = 0; k < columnsInA; k++) {
                   c[i][j] = c[i][j] + a[i][k] * b[k][j];
               }
           }
       }
       return c;
   }
