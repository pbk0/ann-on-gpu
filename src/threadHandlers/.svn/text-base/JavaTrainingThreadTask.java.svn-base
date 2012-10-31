
package threadHandlers;

import com.sun.javafx.runtime.Entry;
import annCode.TrainANNCpuMode;
import annCode.TrainANNGpuMode;
import annCode.TrainANN;
import javafx.async.RunnableFuture;

/**
 * This class helps in launching of thread which will take care of training ANN.
 * Throughout the life of application this thread will run in parallel
 * @author praveen_kulkarni
 */
public class JavaTrainingThreadTask implements RunnableFuture {

    public Float currentError = 0.0f;
    public Float learningConstant = 0.0f;
    public Integer iterationsCompleted = 0;
    public Boolean isTrainingActive = false;
    public Boolean isTrainingPaused = true;
    private Integer selectedModeIndex = 0;
    public Long durationOfTraining = (long) 0;
    private TrainingThreadListener listener;
    public float[] teacherInputArray;
    public float[] teacherOutputArray;
    public float[] trainingOutcomeArray;
    public TrainANN trainANN;
    public boolean updateGraph = true;

    public JavaTrainingThreadTask(TrainingThreadListener listener) {
        this.listener = listener;
    }

    public void setSelectedModeIndex(int temp) {
        synchronized (this) {
            this.selectedModeIndex = temp;
        }
    }

    /**
     * This method launches the java thread in parallel which takes care of training ANN
     * @throws Exception
     */
    @Override
    public void run() throws Exception {

        TrainANN trainANN = null;   // = new TrainANNCpuGeneralMode();

        // loop infininetly
        while (true) {
            try {
                // Once compute button is clicked this loop will start and will end only when reset button is clicked.
                while (isTrainingActive) {
                    if (trainANN == null) {
                        // depending on mode selected create object of respective class
                        if (selectedModeIndex == 0) {
                            trainANN = new TrainANNCpuMode();
                            trainANN.loadData(teacherInputArray, teacherOutputArray);
                        } else if (selectedModeIndex == 1) {
                            trainANN = new TrainANNGpuMode();
                            trainANN.loadData(teacherInputArray, teacherOutputArray);
                            // GPU mode requires compilation and allocation of memory
                            ((TrainANNGpuMode) trainANN).compileKernels();
                            ((TrainANNGpuMode) trainANN).allocateMemoryAndCopyDataToGpgpu();
                        }
                    }

                    // Don't execute this code if stop button is clicked i.e. training is paused
                    if (!isTrainingPaused) {
                        long startTime = System.currentTimeMillis();
                        trainANN.trainANN(learningConstant, this);
                        long stopTime = System.currentTimeMillis();
                        // calculate time for one iteration and add to total time taken
                        durationOfTraining = durationOfTraining + (stopTime - startTime);
                        // get the output estimated by ANN for this iteration
                        trainingOutcomeArray = trainANN.getTrainingOutcome();
                        // get the error by which the ANN outcome is away from teacher output for this iteration
                        currentError = trainANN.getCurrentError();
                        // increment number of iterations finished
                        iterationsCompleted = iterationsCompleted + 1;
                        // execute postMessage() only when previous update of JavaFX UI is completed.
                        // This helps in avoiding muntiple execution of postMessage() while UI is still updating
                        if (updateGraph == true) {
                            postMessage();
                            // set to false telling other communicating programs that a call to postMessage() is done to update UI
                            updateGraph = false;
                        }
                       // if (iterationsCompleted == 1) {
                       //     System.out.println("...." + durationOfTraining);
                       //     isTrainingPaused = true;
                       //     isTrainingActive = false;
                       //     break;
                       // }
                    }
                }

                // execute only when trainANN != null
                if (trainANN != null) {
                    // If Gpu mode free memory on GPU
                    if (trainANN instanceof TrainANNGpuMode) {
                        ((TrainANNGpuMode) trainANN).freeGpgpuAfterTraining();
                    }
                    // reset the remaining values
                    durationOfTraining = 0l;
                    currentError = 0.0f;
                    iterationsCompleted = 0;
                    // reset the UI
                    postMessage();
                    // make trainANN null
                    trainANN = null;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * This method helps in updating UI
     * It creates a temporary thread that calls the methods which update UI and the thread dies.
     * This avoids the unnecessary waiting of thread that calls this method and thus helps the
     * above run method focus on training ANN rather than caring about UI update.
     */
    public void postMessage() {
        Entry.deferAction(
                new Runnable() {

                    @Override
                    public void run() {
                        listener.communicateCurrentError(currentError);
                        listener.communicateIterationsCompleted(iterationsCompleted);
                        listener.communicateDurationOfTraining(durationOfTraining);
                        listener.communicateTrainingOutcomeArray(trainingOutcomeArray);
                    }
                });
    }
}
