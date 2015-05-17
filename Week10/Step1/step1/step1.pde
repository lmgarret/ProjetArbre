import java.util.*;
public class step1{
 setup(){
  new HoughComparator(null);
 } 
}

class HoughComparator implements Comparator<Integer> {
 int[] acc;
 public HoughComparator(int[] acc){
   this.acc=acc;
 }
 @Override
 public int compare(Integer l1, Integer l2){
   if(acc[l1]>acc[l2] ||acc[l1]==acc[l2] &&l1<l2){
     return -1;
   }
   return 1;
 }
  
  
}
