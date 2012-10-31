
package annCode;

import javax.swing.JFrame;
import javax.swing.JOptionPane;
import threadHandlers.JavaTrainingThreadTask;

/**
 * This abstract class is parent class for the two classes TrainANNCpuMode and TrainANNGpuMode.
 * It holds some common abstract methods which are to be implemented by child classes.
 *
 * @author praveen_kulkarni
 */
public abstract class TrainANN {

    /**
     * These are general variables used by both child classes.
     * For proper training the optimal number of neurons required in layer2 is (2*number of patterns)
     * i.e. 2 neurons per pattern
     * We assume here that numberOfInputPatterns is always multiple of 512
     */
    public static int layer2Neurons;
    public static int numberOfInputPatterns;

    /**
     * These are CUDA architecture related variables and are used in TrainANNGpuMode class.
     * threadsPerBlock must be a multiple of 32 and less than thread limit per block.
     */
    public static int numberOfBlocks;
    public static int threadsPerBlock;

    /**
     * This method is executed for getting numberOfInputPatterns and accordingly set the remaining
     * variables of this class. This is the first method to get executed.
     * @param numberOfInputPatterns Make sure that twice of this value is multiple of threads per block
     * limit for GPU mode to work properly
     */
    public static void setConfigurationVariables(int numberOfInputPatterns){
        // threadsPerBlock must be a multiple of 32 and less than thread limit per block
        TrainANN.threadsPerBlock = 512;

        // For proper training the optimal number of neurons required in layer2 is (2*number of patterns)
        TrainANN.layer2Neurons = numberOfInputPatterns*2;

        // display warning to user that layer2Neurons must be multiple of
        // threadsPerBlock limit and program may not work in case of GPU.
        if(TrainANN.layer2Neurons%TrainANN.threadsPerBlock!=0){
            JOptionPane.showMessageDialog(new JFrame(),
                    "Layer 2 neurons required is not the multiple of threads per block limit."
                    + "\nThis will work for CPU mode but not for GPU", "WARNING",
                    JOptionPane.ERROR_MESSAGE);
        }
        TrainANN.numberOfInputPatterns = numberOfInputPatterns;

        // calculate the number of blocks required
        TrainANN.numberOfBlocks = numberOfInputPatterns*2/TrainANN.threadsPerBlock;
    }


    /**
     * Implementation of this method by child classes is supposed to get teacher input and teacher 
     * output for which ANN is to be trained. Accordingly it will load its instance members.
     * @param teacherInputArray
     * @param teacherOutputArray
     */
    public abstract void loadData(float[] teacherInputArray, float[] teacherOutputArray);

    /**
     * Child classes must implement this method to implement training algorithm which will work on
     * data loaded by loadData() method
     * @param learningConstantArg learning constant at which ANN must be trained
     * @param javaTrainingThreadTask Helps to communicate data computed to UI (JavaFx program) and display it
     */
    public abstract void trainANN(float learningConstantArg,JavaTrainingThreadTask javaTrainingThreadTask);

    /**
     * You can call this method to get the outcome of ANN which is undergoing training.
     * Each training iteration will store the estimated output for current iteration in
     * trainingOutcome array. This helps us to view the small progress done by trainANN() method
     * @return Float array is returned which can be plotted on graph to see how close
     * we are to the required function
     */
    public abstract float[] getTrainingOutcome();

    /**
     * As the training proceeds the error will reduce. This method can be used to get the error that
     * is occurred due to current training iteration.
     * @return returns the current error
     */
    public abstract float getCurrentError();

}
