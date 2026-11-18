package com.main;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

public class InsertionSort {

    public static void main(String[] args) {

        int[] a = new int[]{42,17,36,8,26};
        System.out.println("**********Custom Sort Impl***********");
        doSort(a);
        System.out.println("**********Inbuild Sort Impl***********");
        doSortInbuilt(a);
        System.out.println("***********Stream Sort****************");
        doSortUsingStream(a);
    }

    private static void doSortUsingStream(int[] a) {
       a = Arrays.stream(a).sorted().toArray();
        System.out.println(Arrays.toString(a));
    }

    private static void doSortInbuilt(int[] a) {
        Arrays.sort(a); // The sorting algorithm is a Dual-Pivot Quicksort
        System.out.println(Arrays.toString(a)); // Display array
    }

    private static void doSort(int[] a) { // [42,17,36,8,26]
        int n = a.length;

        for(int i=1; i<n;i++){ // i=1(key = 17) , i=2(key = 36) , i=3 (key =8), i=4(key=26)
            int key = a[i]; // key = 17
            int j = i-1; // j=0
                while(j>=0 &&  a[j] > key){  // 42 > 17
                    a[j+1] = a[j]; // a[1] = 42  [42,42,36,8,26]
                    j--; // j=-1
                } // while loop ends   [42,42,36,8,26]
            a[j+1] = key;  // [17,42,36,8,26]
        } // for loop ends

        System.out.println(Arrays.toString(a)); // Display array
    }

}
