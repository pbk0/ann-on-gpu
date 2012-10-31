package annCode;

import threadHandlers.JavaTrainingThreadTask;
import java.util.Random;
import javax.swing.JFrame;
import javax.swing.JOptionPane;

/**
 * This class involves code that will execute code on CPU in sequential way.
 * It extends TrainANN abstract classes and implements its abstract method.
 * @author praveen_kulkarni
 */
public class TrainANNCpuMode extends TrainANN {

    /**
     * Stores teacher input and output for which ANN is to be trained
     */
    private float[] teacherInputArray = new float[numberOfInputPatterns];
    private float[] teacherOutputArray = new float[numberOfInputPatterns];
    /**
     * Each training iteration will store the estimated output for current iteration in
     * trainingOutcomeArray. This helps us to view the small progress done by trainANN() method
     */
    private float[] trainingOutcomeArray = new float[numberOfInputPatterns];

    /**
     * Weights involved between input layer and hidden layer.
     * Instance member layer1Weight2Vector represents weights between augmented
     * input of input layer and hidden layer.
     */
    private float[] layer1Weight1Vector = new float[layer2Neurons];
    private float[] layer1Weight2Vector = new float[layer2Neurons];

    /**
     * Weights involved between hidden layer and output layer.
     * Instance member layer2Weight2 represents weight between augmented input
     * of hidden layer and output layer. Only one such weight exists as
     * we have only one output neuron in output layer.
     */
    private float[] layer2Weight1Vector = new float[layer2Neurons];
    private float layer2Weight2;

    /**
     * Represents output of hidden layer. Changer for  every iteration.
     */
    private float[] layer2OutputVector = new float[layer2Neurons];

    /**
     * Used in modifying layer 1 and layer 2 weights.
     * They depend on error calculated for current iteration,
     */
    private float[] deltaLayer1Vector = new float[layer2Neurons];
    private float deltaLayer2;

    /**
     * Holds error for current iteration.
     */
    private float currentError = 0.0f;

    /**
     * See TrainANN class for more explanation.
     * @param teacherInputArray
     * @param teacherOutputArray
     */
    @Override
    public void loadData(float[] teacherInput, float[] teacherOutput) {
        try {
            if(teacherInput!=null){
            int count=0;
            for(float x : teacherInput){
                this.teacherInputArray[count]=x;
                count++;
            }
            count=0;
            for(float x : teacherOutput){
                this.teacherOutputArray[count]=x;
                count++;
            }
            }

            Random randomGenerator = new Random(System.currentTimeMillis());
            for (int x = 0; x < layer1Weight1Vector.length; x++) {
                layer1Weight1Vector[x] = 2.0f * randomGenerator.nextFloat() - 1.0f;
            }
            for (int x = 0; x < layer1Weight2Vector.length; x++) {
                layer1Weight2Vector[x] = 2.0f * randomGenerator.nextFloat() - 1.0f;
            }
            for (int x = 0; x < layer2Weight1Vector.length; x++) {
                layer2Weight1Vector[x] = 2.0f * randomGenerator.nextFloat() - 1.0f;
            }
            layer2Weight2 = 2.0f * randomGenerator.nextFloat() - 1.0f;

        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(new JFrame(), e.getMessage(), "ERROR DURING LOADING DATA [CPU MODE]", JOptionPane.ERROR_MESSAGE);

        }
    }

    /**
     * See TrainANN class for more explanation.
     * @param learningConstantArg
     * @param javaTrainingThreadTask
     */
    @Override
    public void trainANN(float learningConstantArg, JavaTrainingThreadTask javaTrainingThreadTask) {
        try {
            this.currentError = 0.0f;
            int patternCount = -1;

            // iterations for all patterns
            while (++patternCount < numberOfInputPatterns) {
                // break training if user clicks stop button
                if(javaTrainingThreadTask.isTrainingPaused==true){
                    break;
                }

                // compte hidden layer output
                for (int count = 0; count < layer2Neurons; count++) {
                    layer2OutputVector[count] = teacherInputArray[patternCount] * layer1Weight1Vector[count] - layer1Weight2Vector[count];
                    layer2OutputVector[count] = (float) (2.0f / (1.0f + Math.exp(-layer2OutputVector[count])) - 1.0f);
                }

                // computing the output layer output for current pattern
                trainingOutcomeArray[patternCount]=0.0f;
                for (int count = 0; count < layer2Neurons; count++) {
                    trainingOutcomeArray[patternCount] += layer2OutputVector[count] * layer2Weight1Vector[count];
                }
                trainingOutcomeArray[patternCount] -= layer2Weight2;
                trainingOutcomeArray[patternCount] = (float) (2.0f / (1.0f + Math.exp(-trainingOutcomeArray[patternCount])) - 1.0f);

                // calculating deltaLayer2 which will be used to modify weights
                deltaLayer2 = (float) (0.5f * (teacherOutputArray[patternCount] - trainingOutcomeArray[patternCount]) * (1.0f - Math.pow(trainingOutcomeArray[patternCount], 2)));

                // calculating deltaLayer1Vector
                for (int count = 0; count < layer2Neurons; count++) {
                    float temp0 = deltaLayer2 * layer2Weight1Vector[count];
                    float temp1 = layer2OutputVector[count];
                    deltaLayer1Vector[count] = 0.5f * (1.0f - temp1 * temp1) * temp0;
                }

                // modyfying weights
                for (int count = 0; count < layer2Neurons; count++) {
                    layer2Weight1Vector[count] += learningConstantArg * deltaLayer2 * layer2OutputVector[count];
                    float temp2 = learningConstantArg * deltaLayer1Vector[count] * teacherInputArray[patternCount];
                    layer1Weight1Vector[count] += temp2;
                    layer1Weight2Vector[count] += temp2;
                }
                layer2Weight2 -= learningConstantArg * deltaLayer2;
            }

            // calculating error for this iteration which is sum of errors that occurred for each pattern.
            for (int count = 0; count < numberOfInputPatterns; count++) {
                this.currentError = (float) (this.currentError + 0.5f * Math.pow(teacherOutputArray[count] - trainingOutcomeArray[count], 2));
            }
        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(new JFrame(), e.getMessage(), "ERROR DURING TRAINING ANN [CPU MODE]", JOptionPane.ERROR_MESSAGE);
        }
    }

    /**
     * See TrainANN class for more explanation.
     * @return
     */
    @Override
    public float[] getTrainingOutcome() {
        return this.trainingOutcomeArray;
    }

    /**
     * See TrainANN class for more explanation.
     * @return
     */
    @Override
    public float getCurrentError() {
        return this.currentError;
    }
}
