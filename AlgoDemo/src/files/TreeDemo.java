package files;

import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;

public class TreeDemo {
    public static void main(String[] args) throws IOException {
        // Display the entire tree of the directory AlgoDemo
        Files.walk(Path.of("D:\\hex_fsd_sept_2026\\AlgoDemo\\src"))
                .toList().forEach(System.out::println);



    }
}
