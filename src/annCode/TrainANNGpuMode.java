package annCode;

import java.util.Random;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import jcuda.Pointer;
import jcuda.Sizeof;
import jcuda.driver.CUdeviceptr;
import jcuda.driver.JCudaDriver;
import jcuda.utils.KernelLauncher;
import threadHandlers.JavaTrainingThreadTask;

/**
 * This class involves code that will execute code on GPU.
 * It extends TrainANN abstract classes and implements its abstract method.
 * @author praveen_kulkarni
 */
public class TrainANNGpuMode extends TrainANN {

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
     * Used in modifying layer 2 weights.
     * It depends on error calculated for current iteration,
     */
    private float deltaLayer2;
    /**
     * Holds error for current iteration.
     */
    private float currentError = 0.0f;
    /**
     * This member groups different host variables to be communicated to GPU.
     * This helps us avoid multiple copies to GPU
     * Size for communicationDataArray is 4 as
     * communicationDataArray[0] will contain teacherInput
     * communicationDataArray[1] will contain teacherOutput
     * communicationDataArray[2] will contain learningConstant
     * communicationDataArray[3] will contain deltaLayer2
     */
    private float[] communicationDataArray = new float[4];
    /**
     * Below members points to GPU global memory.
     */
    private CUdeviceptr communicationDataArrayDevicePointer = new CUdeviceptr();
    private CUdeviceptr layer1Weight1VectorDevicePointer = new CUdeviceptr();
    private CUdeviceptr layer1Weight2VectorDevicePointer = new CUdeviceptr();
    private CUdeviceptr layer2Weight1VectorDevicePointer = new CUdeviceptr();
    private CUdeviceptr layer2OutputVectorDevicePointer = new CUdeviceptr();
    private CUdeviceptr deltaLayer1VectorDevicePointer = new CUdeviceptr();
    private CUdeviceptr tempArrayToStorePartialSumsDevicePointer = new CUdeviceptr();
    /**
     * Below variables holds references to KernelLauncher that will help
     * launch kernels on GPU.
     */
    private KernelLauncher computeLayer2OutputAndPartialSumsForTrainingOutcomeKernelLauncher;
    private KernelLauncher computeDeltaLayer1VectorKernelLauncher;
    private KernelLauncher modifyWeightsKernelLauncher;

    /**
     * See TrainANN class for more explanation.
     * @param teacherInput
     * @param teacherOutput
     */
    @Override
    public void loadData(float[] teacherInput, float[] teacherOutput) {
        try {
            int count = 0;
            for (float x : teacherInput) {
                this.teacherInputArray[count] = x;
                count++;
            }
            count = 0;
            for (float x : teacherOutput) {
                this.teacherOutputArray[count] = x;
                count++;
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
            JOptionPane.showMessageDialog(new JFrame(),
                    "Error details: /n" + e.getMessage(),
                    "ERROR DURING LOADING DATA [GPU MODE]", JOptionPane.ERROR_MESSAGE);
        }
    }

    /**
     * In this methods the kernel code is represented as String and compiled 
     * using KernelLauncher class in jcudaUtils zip file.
     */
    public void compileKernels() {
        try {
            // Explanation of partial sums calculation.
            // To get the outputLayer output we have to add hidden layers output multiplied by layer2 weights.
            // We know that for every block we have 512 such values that must be aggregated.
            // Thus partial sum is a sum of 512 such values in a block.
            // So suppose we have 30 blocks launched then we have 30 partial sums.
            // In this kernel we calculate partial sums using striding technique and store them on global
            // memory. Host code will add this partial sums and then the product of augmented input with
            // its corresponding weight. So finally we get our outputLayer output which will then undergo
            // exp operation (see host code in trainANN() method of this class).
            String computeLayer2OutputAndPartialSumsForTrainingOutcome = ""
                    + "     extern \"C\"                                                                " + "\n"
                    + "     __global__ void computeLayer2OutputAndPartialSumsForTrainingOutcome(        " + "\n"
                    + "                 float* communicationDataArrayArg,                               " + "\n"
                    + "                 float* layer1Weight1VectorArg,                                  " + "\n"
                    + "                 float* layer1Weight2VectorArg,                                  " + "\n"
                    + "                 float* layer2Weight1VectorArg,                                  " + "\n"
                    + "                 float* layer2OutputVectorArg,                                   " + "\n"
                    + "                 float* tempArrayToStorePartialSumsArg)                          " + "\n"
                    + "     {                                                                           " + "\n"
                    + "         __shared__ float partialSums[" + threadsPerBlock + "];                  " + "\n"
                    + "         unsigned int tid = threadIdx.x;                                         " + "\n"
                    + "         unsigned int bid = blockIdx.x;                                          " + "\n"
                    + "         unsigned int index = bid*blockDim.x+tid;                                " + "\n"
                    + "         float layer2Output;                                                     " + "\n"
                    + "         layer2Output=communicationDataArrayArg[0]*                              " + "\n"
                    + "                 layer1Weight1VectorArg[index]-layer1Weight2VectorArg[index];    " + "\n"
                    + "         layer2Output=2.0f/(1.0f+expf(-layer2Output))-1.0f;                      " + "\n"
                    + "         partialSums[tid]=layer2Output*layer2Weight1VectorArg[index];            " + "\n"
                    + "         layer2OutputVectorArg[index]=layer2Output;                              " + "\n"
                    + "         for(index = " + (threadsPerBlock / 2) + "; index>=1 ; index=index/2){   " + "\n"
                    + "             __syncthreads();                                                    " + "\n"
                    + "             if(tid<index)partialSums[tid]+=partialSums[tid+index];              " + "\n"
                    + "         }                                                                       " + "\n"
                    + "         tempArrayToStorePartialSumsArg[bid]=partialSums[0];                     " + "\n"
                    + "     };                                                                          ";

            computeLayer2OutputAndPartialSumsForTrainingOutcomeKernelLauncher =
                    KernelLauncher.compile(computeLayer2OutputAndPartialSumsForTrainingOutcome,
                    "computeLayer2OutputAndPartialSumsForTrainingOutcome");
            computeLayer2OutputAndPartialSumsForTrainingOutcomeKernelLauncher.setGridSize(numberOfBlocks, 1);
            computeLayer2OutputAndPartialSumsForTrainingOutcomeKernelLauncher.setBlockSize(threadsPerBlock, 1, 1);



            String computeDeltaLayer1Vector = ""
                    + "     extern \"C\"                                                                " + "\n"
                    + "     __global__ void computeDeltaLayer1Vector(                                   " + "\n"
                    + "                 float* deltaLayer1VectorArg,                                    " + "\n"
                    + "                 float* communicationDataArrayArg,                               " + "\n"
                    + "                 float* layer2Weight1VectorArg,                                  " + "\n"
                    + "                 float* layer2OutputVectorArg)                                   " + "\n"
                    + "     {                                                                           " + "\n"
                    + "         unsigned int index = blockIdx.x*blockDim.x+threadIdx.x;                 " + "\n"
                    + "         float temp0=communicationDataArrayArg[3]*layer2Weight1VectorArg[index]; " + "\n"
                    + "         float temp1=layer2OutputVectorArg[index];                               " + "\n"
                    + "         deltaLayer1VectorArg[index]=0.5f * (1.0f - temp1 * temp1) * temp0;      " + "\n"
                    + "     };                                                                          ";

            computeDeltaLayer1VectorKernelLauncher =
                    KernelLauncher.compile(computeDeltaLayer1Vector, "computeDeltaLayer1Vector");
            computeDeltaLayer1VectorKernelLauncher.setGridSize(numberOfBlocks, 1);
            computeDeltaLayer1VectorKernelLauncher.setBlockSize(threadsPerBlock, 1, 1);




            String modifyWeights = ""
                    + "     extern \"C\"                                                                " + "\n"
                    + "     __global__ void modifyWeights(                                              " + "\n"
                    + "                 float* communicationDataArrayArg,                               " + "\n"
                    + "                 float* deltaLayer1VectorArg,                                    " + "\n"
                    + "                 float* layer1Weight1VectorArg,                                  " + "\n"
                    + "                 float* layer1Weight2VectorArg,                                  " + "\n"
                    + "                 float* layer2Weight1VectorArg,                                  " + "\n"
                    + "                 float* layer2OutputVectorArg)                                   " + "\n"
                    + "     {                                                                           " + "\n"
                    + "         unsigned int index = blockIdx.x*blockDim.x+threadIdx.x;                 " + "\n"
                    + "         float learningConstant = communicationDataArrayArg[2];                  " + "\n"
                    + "         float temp0 = learningConstant*                                         " + "\n"
                    + "                 deltaLayer1VectorArg[index]*communicationDataArrayArg[0];       " + "\n"
                    + "         layer2Weight1VectorArg[index]+=learningConstant                         " + "\n"
                    + "                 *communicationDataArrayArg[3]                                   " + "\n"
                    + "                 *layer2OutputVectorArg[index];                                  " + "\n"
                    + "         layer1Weight1VectorArg[index]+=temp0;                                   " + "\n"
                    + "         layer1Weight2VectorArg[index]+=temp0;                                   " + "\n"
                    + "     };                                                                          ";

            modifyWeightsKernelLauncher = KernelLauncher.compile(modifyWeights, "modifyWeights");
            modifyWeightsKernelLauncher.setGridSize(numberOfBlocks, 1);
            modifyWeightsKernelLauncher.setBlockSize(threadsPerBlock, 1, 1);

        } catch (Error e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(new JFrame(),
                    "Please make sure that required JCuda drivers(JCuda 3.1 drivers for windows) are accessible.\n"
                    + "You can place them in bin folder inside Java installation directory.\n"
                    + "Try any sample JCuda program to check your configuration.\n\n\n"
                    + e.getMessage(),
                    "CAN'T COMPILE THE KERNELS", JOptionPane.ERROR_MESSAGE);
        }
    }

    /**
     * This methods allocate memory and copies data to GPU which will be used by Kernel.
     */
    public void allocateMemoryAndCopyDataToGpgpu() {
        try {

            JCudaDriver.cuMemAlloc(communicationDataArrayDevicePointer, 5 * Sizeof.FLOAT);
            JCudaDriver.cuMemAlloc(layer1Weight1VectorDevicePointer, layer2Neurons * Sizeof.FLOAT);
            JCudaDriver.cuMemAlloc(layer1Weight2VectorDevicePointer, layer2Neurons * Sizeof.FLOAT);
            JCudaDriver.cuMemAlloc(layer2Weight1VectorDevicePointer, layer2Neurons * Sizeof.FLOAT);
            JCudaDriver.cuMemAlloc(layer2OutputVectorDevicePointer, layer2Neurons * Sizeof.FLOAT);
            JCudaDriver.cuMemAlloc(deltaLayer1VectorDevicePointer, layer2Neurons * Sizeof.FLOAT);
            JCudaDriver.cuMemAlloc(tempArrayToStorePartialSumsDevicePointer, numberOfBlocks * Sizeof.FLOAT);

            JCudaDriver.cuMemcpyHtoD(layer1Weight1VectorDevicePointer,
                    Pointer.to(layer1Weight1Vector), layer2Neurons * Sizeof.FLOAT);
            JCudaDriver.cuMemcpyHtoD(layer1Weight2VectorDevicePointer,
                    Pointer.to(layer1Weight2Vector), layer2Neurons * Sizeof.FLOAT);
            JCudaDriver.cuMemcpyHtoD(layer2Weight1VectorDevicePointer,
                    Pointer.to(layer2Weight1Vector), layer2Neurons * Sizeof.FLOAT);

        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(new JFrame(), "Error details:\n" + e.getMessage(),
                    "ERROR DURING COPYING DATA TO GPGPU", JOptionPane.ERROR_MESSAGE);
        }
    }

    /**
     * This method has a mixture of CPU code and GPU code call.
     * Sequential code is executed on host whereas parallel code execution is
     * done with help of kernel calls on GPU.
     * Such combination helps increase performance.
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
                if (javaTrainingThreadTask.isTrainingPaused == true) {
                    break;
                }

                // communicating details to GPU
                communicationDataArray[0] = teacherInputArray[patternCount];
                communicationDataArray[1] = teacherOutputArray[patternCount];
                communicationDataArray[2] = learningConstantArg;
                JCudaDriver.cuMemcpyHtoD(communicationDataArrayDevicePointer,
                        Pointer.to(communicationDataArray),
                        Sizeof.FLOAT * communicationDataArray.length);

                // computing hidden layer output done by kernel call.
                // computing partial sums (for more info see the kernel in compileKernels() method)
                computeLayer2OutputAndPartialSumsForTrainingOutcomeKernelLauncher.call(
                        communicationDataArrayDevicePointer, layer1Weight1VectorDevicePointer,
                        layer1Weight2VectorDevicePointer, layer2Weight1VectorDevicePointer,
                        layer2OutputVectorDevicePointer, tempArrayToStorePartialSumsDevicePointer);

                // getting the partial sums for hidden layer
                float[] partialSumsFromBlock = new float[numberOfBlocks];
                JCudaDriver.cuMemcpyDtoH(Pointer.to(partialSumsFromBlock),
                        tempArrayToStorePartialSumsDevicePointer,
                        Sizeof.FLOAT * numberOfBlocks);

                // calculating output layer output
                // This is done on host as most part is sequential.
                // If done on GPU the execution is slow.
                float currentOutput = 0.0f;
                for (float temp : partialSumsFromBlock) {
                    currentOutput += temp;
                }
                currentOutput -= layer2Weight2;
                currentOutput = (float) (2.0f / (1.0f + Math.exp(-currentOutput)) - 1.0f);
                trainingOutcomeArray[patternCount] = currentOutput;

                // calculating deltaLayer2 which will be used to modify weights
                deltaLayer2 = (float) (0.5f * (teacherOutputArray[patternCount]
                        - currentOutput) * (1.0f - Math.pow(currentOutput, 2)));

                // communicating deltaLayer2 value to GPU so that kernel to modify weights can use it.
                communicationDataArray[3] = deltaLayer2;
                JCudaDriver.cuMemcpyHtoD(communicationDataArrayDevicePointer,
                        Pointer.to(communicationDataArray),
                        Sizeof.FLOAT * communicationDataArray.length);

                // calculating deltaLayer1Vector on GPU
                computeDeltaLayer1VectorKernelLauncher.call(
                        deltaLayer1VectorDevicePointer,
                        communicationDataArrayDevicePointer,
                        layer2Weight1VectorDevicePointer,
                        layer2OutputVectorDevicePointer);

                // modify weights with help of kernel code
                modifyWeightsKernelLauncher.call(
                        communicationDataArrayDevicePointer,
                        deltaLayer1VectorDevicePointer,
                        layer1Weight1VectorDevicePointer,
                        layer1Weight2VectorDevicePointer,
                        layer2Weight1VectorDevicePointer,
                        layer2OutputVectorDevicePointer);

                // modify layer2Weight2 on host i.e. CPU
                layer2Weight2 -= learningConstantArg * deltaLayer2;
            }

            // calculating error for this iteration which is sum of errors that occurred for each pattern.
            for (int count = 0; count < numberOfInputPatterns; count++) {
                this.currentError = (float) (this.currentError + 0.5f
                        * Math.pow(teacherOutputArray[count] - trainingOutcomeArray[count], 2));
            }
        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(new JFrame(), "Error details:/n" + e.getMessage(),
                    "ERROR DURING TRAINING ANN [GPU MODE]", JOptionPane.ERROR_MESSAGE);
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

    /**
     * After training is entirely stopped call to this method will ensure that
     * allocated memory will be freed.
     */
    public void freeGpgpuAfterTraining() {
        try {


            JCudaDriver.cuMemFree(communicationDataArrayDevicePointer);
            JCudaDriver.cuMemFree(layer1Weight1VectorDevicePointer);
            JCudaDriver.cuMemFree(layer1Weight2VectorDevicePointer);
            JCudaDriver.cuMemFree(layer2Weight1VectorDevicePointer);
            JCudaDriver.cuMemFree(layer2OutputVectorDevicePointer);
            JCudaDriver.cuMemFree(deltaLayer1VectorDevicePointer);
            JCudaDriver.cuMemFree(tempArrayToStorePartialSumsDevicePointer);


        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(new JFrame(), "Error details:/n" + e.getMessage(),
                    "ERROR DURING FREEING GPGPU AFTER TRAINING", JOptionPane.ERROR_MESSAGE);
        }
    }
}
