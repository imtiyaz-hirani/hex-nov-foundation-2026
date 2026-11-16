package com.main;

import java.util.Arrays;
 import java.util.Collections;
import java.util.List;

public class AlgoMain {

    public static void main(String[] args) {
        List<Integer> list = Arrays.asList(4,2,7,9,1,3,5,8); // List of ids
        int num = 5; // This is the number i am searching
        System.out.println("Sample size, number of Ids " + list.size());
        System.out.println("************BRUTE FORCE**********");
        bruteForce(list,num);
        bruteForce(list,10);
        System.out.println("************DIVIDE AND CONQUER*********");
        divideAndConquer(list,num);
        divideAndConquer(list,7);

        System.out.println("************DIVIDE AND CONQUER EASY*********");
        divideAndConquerEasy(list,num);
        divideAndConquerEasy(list,7);
    }

    private static void divideAndConquerEasy(List<Integer> list, int num) {
        Collections.sort(list);
        int index = Arrays.binarySearch(list.toArray(),num);
        if(index < 0){
            System.out.println("Number Not Found: " + num);
        }
        else{
            System.out.println("Number Found at index : " + index);
        }
    }

    private static void divideAndConquer(List<Integer> list, int num) {
        int iterations = 0;
        // Step 1: Sort the list
           Collections.sort(list);
        // System.out.println(list);

        // Step 2: find the mid index
        int low = 0;
        int high = list.size() - 1;


        // Step 3: check if the num is equal to the element at index mid
        while(low <= high) {
            iterations++;
            int mid = (low + high) / 2;
            if (num == list.get(mid)) {
                System.out.println("Number found " + num);
                System.out.println("It took " + iterations + " Iterations");
                return;
            }

            if(list.get(mid) < num){ //4 < 7
                low = mid + 1;
            }
            else{
                high = mid - 1;
            }
        }
        System.out.println("Number Not Found: " + num);
        System.out.println("It took " + iterations + " Iterations");
    }

    private static void bruteForce(List<Integer> list, int num) {
        int iterations = 0;
        for(int e : list){ // I am iterating thru the list with each element saved in e at a time
            iterations++;
            if(num == e){
                System.out.println("Number Found: " + num);
                System.out.println("It took " + iterations + " Iterations");
                return; // method bruteForce ends here.
            }
        }
        System.out.println("Number Not Found: " + num);
        System.out.println("It took " + iterations + " Iterations");

    }


}
