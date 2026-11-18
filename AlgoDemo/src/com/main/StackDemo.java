package com.main;

import java.util.ArrayDeque;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Stack;

public class StackDemo {
    public static void main(String[] args) {
        /*
        Queue<String> queue = new ArrayDeque<>();
        queue.offer("abc");
         queue.poll()

        Queue<String> linkedList = new LinkedList<>();
        linkedList.offer("abc");
        linkedList.poll()
        */
        // Recommended : ArrayDeque
        ArrayDeque<String> newStack = new ArrayDeque<>(); // This is my stack data structure which will hold strings
        newStack.push("Harry potter");
        newStack.push("Ronald Weasley");
        newStack.push("hermione Granger");

        System.out.println("Stack: " + newStack);

        System.out.println("Peek is: " + newStack.peek());
        System.out.println("Pop is " + newStack.pop());
        System.out.println("Peek is: " + newStack.peek());
        System.out.println("size is: " + newStack.size());

        // Old way : Stack
        Stack<String> oldStack = new Stack<>();
        oldStack.push("frodo baggins");
        oldStack.push("samwell gamajee");
        System.out.println(oldStack);
    }
}
