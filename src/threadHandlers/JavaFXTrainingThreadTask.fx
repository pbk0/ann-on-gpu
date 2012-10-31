
package threadHandlers;

import javafx.async.JavaTaskBase;
import javafx.async.RunnableFuture;

/**
 * This class help in launching a prallel thread which takes about training of ANN
 * @author praveen_kulkarni
 */
public class JavaFXTrainingThreadTask extends JavaTaskBase {

    // This listner helps in updating JavaFX UI
    public-init var listener: TrainingThreadListener;
    // This class corresponds to Java class which will be taking care of launching thread
    public-init var javaTrainingThreadTask: JavaTrainingThreadTask;

    // returns javaTrainingThreadTask whose run() method is goinig to get called
    protected override function create(): RunnableFuture {
        return javaTrainingThreadTask;
    }

}
