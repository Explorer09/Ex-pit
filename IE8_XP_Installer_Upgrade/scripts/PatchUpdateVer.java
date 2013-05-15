import java.io.FileInputStream;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.FileNotFoundException;

public class PatchUpdateVer {

public static void main(String[] args) {
    if (args.length < 2) {
        System.err.println("This program patches the \"update.ver\" file in the IE8 installer with the entries in an IE8 update.");
        System.err.println("Usage: java PatchUpdateVer original_file patch_file branch");
        System.err.println("Result is printed in standard output.");
        System.exit(0);
    }
    branch = GDR;
    if (args.length == 3 && args[2].equals("QFE")) {
        branch = QFE;
    }
    try {
        originalFileInput_ = new Scanner(new FileInputStream(args[0]));
    } catch (FileNotFoundException exception) {
        throw new RuntimeException(exception);
    }
    String originalLine;
    String patchLine;
    // For each line name in originalFile
    while (originalFileInput_.hasNextLine()) {
        originalLine = originalFileInput_.nextLine();
        String[] tokens = originalLine.split("=", 2);
        String filename = tokens[0]; //should be something like "mshtml.dll"
        // If there is the same file name in patchFileInput_
        patchLine = findEntry(filename, args[1]);
        if (patchLine != null) {
            // Output the replaced line
            if (branch == QFE) {
                System.out.println(patchLine.replaceFirst("(?i)SP[23]QFE", ""));
            } else {
                System.out.println(patchLine.replaceFirst("(?i)SP[23]GDR", ""));
            }
        } else {
            System.out.println(originalLine);
        }
    }
    originalFileInput_.close();
}

private static String findEntry(String filenameToMatch, String patchFileName){
    try {
        patchFileInput_ = new Scanner(new FileInputStream(patchFileName));
    } catch (FileNotFoundException exception) {
        throw new RuntimeException();
    }
    String line;
    while (patchFileInput_.hasNextLine()) {
        line = patchFileInput_.nextLine();
        // The backslashes here have to be double-escaped. One escape is for
        // compiling String objects; the other is for regular expression.
        if (branch == QFE) {
            if (line.matches("(?i)^SP[23]QFE\\\\.*")) {
                line = line.replaceFirst("(?i)^SP[23]QFE\\\\", "");
            }
        } else {
            if (line.matches("(?i)^SP[23]GDR\\\\.*")) {
                line = line.replaceFirst("(?i)^SP[23]GDR\\\\", "");
            }
        }
        if (line.startsWith(filenameToMatch)) {
            patchFileInput_.close();
            return line;
        }
    }
    patchFileInput_.close();
    return null;
}

private static final int QFE = 1;
private static final int GDR = 0;
private static int branch = GDR;

private static Scanner originalFileInput_;
private static Scanner patchFileInput_;

}
