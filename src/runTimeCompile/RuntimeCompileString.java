
package runTimeCompile;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.Writer;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JFrame;
import javax.swing.JOptionPane;

/**
 * This class takes care of run time compilation and execution of formula entered by user.
 * Methods of this class create two temp files namely TempCompileStringClass.java and TempCompileStringClass.class
 * @author praveen_kulkarni
 */
public class RuntimeCompileString {

    private static File file;
    private static Object currentObject;
    private static Method computeMethod;

    /**
     * This method compiles the entered formula and returns true if success.
     * If compilation is not successful it throws error message box and returns false
     * @param formula Takes formula entered by user as String
     * @return Returns true if success and false if failure
     */
    public static boolean compile(String formula) {
        try {
            if (formula == null || formula.trim().equals("")) {
                JOptionPane.showMessageDialog(new JFrame(), 
                        "Please enter/select the formula", "NO FORMULA PROVIDED",
                        JOptionPane.ERROR_MESSAGE);
                return false;
            }


            if (formula.split("=").length != 2 || !formula.split("=")[0].trim().equals("y")) {
                JOptionPane.showMessageDialog(new JFrame(), 
                        "Formula entered is: " + formula + "\nPlease use proper formula of form y = f(x,y)",
                        "IMPROPER FORMULA PROVIDED", JOptionPane.ERROR_MESSAGE);
                return false;
            }

            formula = formula.split("=")[1];

            Writer output = null;
            String code = ""
                    + " public class TempCompileStringClass{                    \n"
                    + "     public float y = 0.0f;                              \n"
                    + "     public void compute(Float x){                       \n"
                    + "         y=(float)" + formula + ";                       \n"
                    + "     }                                                   \n"
                    + "     public String toString(){                           \n"
                    + "         return \"\"+y;                                  \n"
                    + "     }                                                   \n"
                    + "}                                                        ";

            try {
                file = new File(System.getProperty("user.dir") + File.separatorChar + "TempCompileStringClass.java");
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(new JFrame(),
                        "Error occured while creating temporary java file in directory " +
                        System.getProperty("user.dir") + ". \nCheck for permissions. \nError details:\n" + ex.getMessage(),
                        "ERROR OCCURED WHILE COMPILING COMMAND", JOptionPane.ERROR_MESSAGE);
                return false;
            }

            try {
                output = new BufferedWriter(new FileWriter(file));
                output.write(code);
                output.close();
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(new JFrame(),
                        "Error occured while writing to temporary java file in directory " +
                        System.getProperty("user.dir") + ". \nError details:\n" + ex.getMessage(),
                        "ERROR OCCURED WHILE COMPILING COMMAND", JOptionPane.ERROR_MESSAGE);
                return false;
            }

            com.sun.tools.javac.Main javacMain = null;
            try {
                javacMain = new com.sun.tools.javac.Main();
                javacMain.compile(new String[]{file.getPath()});

                URL url = file.getParentFile().toURL();
                URL[] urls = new URL[]{url};
                ClassLoader loader = new URLClassLoader(urls);

                Class currentClass = loader.loadClass("TempCompileStringClass");
                currentObject = currentClass.newInstance();

                Class[] paramsClassType = {Float.class};
                computeMethod = currentClass.getDeclaredMethod("compute", paramsClassType);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(new JFrame(),
                        "Error occured while compiling temporary java file in directory " +
                        System.getProperty("user.dir") + ". \nPlease check you have entered a proper formula "
                        + "that java compiler can compile.\n\nHint: Formula entered can use only two variables "
                        + "'x' and 'y' \nwith 'y' on LHS and function of 'x' and 'y' on RHS.\nYou can see more "
                        + "examples in dropdown provided to select precompiled formulas.\n\n \nError details:\n"
                        + ex.getMessage(),
                        "ERROR OCCURED WHILE COMPILING COMMAND", JOptionPane.ERROR_MESSAGE);
                return false;
            }catch (Error ex) {
                JOptionPane.showMessageDialog(new JFrame(), 
                        "Error occured while compiling temporary java file in directory "
                        + System.getProperty("user.dir") + ". \nPlease check you have entered a proper formula "
                        + "that java compiler can compile.\n\nHint: Formula entered can use only two variables "
                        + "'x' and 'y' \nwith 'y' on LHS and function of 'x' and 'y' on RHS.\nYou can see more "
                        + "examples in dropdown provided to select precompiled formulas.\n\n \nError details:\n"
                        + ex.getMessage(), "ERROR OCCURED WHILE COMPILING COMMAND", JOptionPane.ERROR_MESSAGE);
                return false;
            }


        } catch (Exception ex) {
            JOptionPane.showMessageDialog(new JFrame(), "Error details:\n" + ex.getMessage(),
                    "ERROR OCCURED WHILE COMPILING COMMAND", JOptionPane.ERROR_MESSAGE);
            return false;
        } catch (Error err) {
            JOptionPane.showMessageDialog(new JFrame(), "Error details:\n" + err.getMessage(),
                    "ERROR OCCURED WHILE COMPILING COMMAND", JOptionPane.ERROR_MESSAGE);
            return false;
        }
        
        return true;

    }


    /**
     * The compiled formula can be used by using this methods. You have to pass value of x for which y is to be computed
     * @param x Holds the value of x for which y is to be calculated
     * @return Returns the value of y for given x
     */
    public static float compute(Float x) {
        Float y = 0.0f;
        try {
            computeMethod.invoke(currentObject, x);
            y = Float.parseFloat(currentObject.toString());
        } catch (IllegalAccessException ex) {
            Logger.getLogger(RuntimeCompileString.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IllegalArgumentException ex) {
            Logger.getLogger(RuntimeCompileString.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InvocationTargetException ex) {
            Logger.getLogger(RuntimeCompileString.class.getName()).log(Level.SEVERE, null, ex);
        }
        return (Float) y;
    }

    /**
     * After compilation of files two temporary files are created. Call this method to delete those files.
     */
    public static void deleteTempFilesCreated() {
        file.delete();
        new File(System.getProperty("user.dir") + File.separatorChar + "TempCompileStringClass.class").delete();
    }
}
