/*
 * Main.fx
 * This file holds the UI code for this application.
 * Created on Oct 11, 2010, 4:35:10 PM
 */
package main;

import javafx.stage.StageStyle;
import javafx.scene.paint.Color;
import javafx.util.Math;
import java.lang.Integer;
import java.lang.Float;
import java.lang.Long;
import threadHandlers.JavaFXTrainingThreadTask;
import threadHandlers.JavaTrainingThreadTask;
import threadHandlers.TrainingThreadListener;
import annCode.TrainANN;
import runTimeCompile.RuntimeCompileString;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javafx.scene.chart.LineChart.Data;
import javafx.scene.shape.Polygon;

/**
 * @author praveen_kulkarni
 */
var stage: javafx.stage.Stage;

public class Main {

    var message: String = "\n\n\n    Enter/Select the formula and click 'COMPUTE' button.";
    var numberOfTrainingIterationsCompleted: Integer = 0;
    var currentError: Number = 0.0;
    var isTrainingActive: Boolean = false;
    var isTrainingPaused: Boolean = true;
    var durationOfTraining: Integer = 0;
    var lookUpForUpdateGraph: Boolean[];
    var javaFxTrainingThreadTask: JavaFXTrainingThreadTask;

    // TrainingThreadListener interface is implemented so that we are able to listen the postMessage() method of JavaTrainingThreadTask
    // There are four methods in TrainingThreadListener interface which are called when postMessage() is executed.
    // All those methods are overridden below and will execute to update the GUI
    var trainingThreadListener: TrainingThreadListener = TrainingThreadListener {
                override public function communicateTrainingOutcomeArray(arg0: nativearray of Number): Void {
                    var count = 0;
                    for (y in arg0) {
                        annDataSeries.data[count].yValue = y;
                        count++;
                    }
                    // loop continiously till remaining methods are not finished
                    while (true) {
                        // postMessage() will execute after every training iteration but now suppose that while UI is still getting updated
                        // i.e. any of these four methods is executing and postMessage() gets executed by the seperate thread repersented
                        // by JavaTrainingThreadTask. In this case our UI will have lots of queued work to do.
                        // So solution here to this problem is that the condition below checks that all remaining three methods are executed.
                        // You can easily see that the fourth method is this method only and at this point the UI updation work for this
                        // method is over. So we are sure that all four methods are executed.
                        if (lookUpForUpdateGraph.size() == 3) {
                            // setting true signifies that all methods for updating UI are over and there is no need to skip execution of
                            // postMessage() method by thread represented by JavaTrainingThreadTask.
                            javaFxTrainingThreadTask.javaTrainingThreadTask.updateGraph = true;
                            // Empty the sequence lookUpForUpdateGraph to reuse it for next time.
                            delete  lookUpForUpdateGraph;
                            break;
                        }
                    }
                }
                override public function communicateIterationsCompleted(arg0: Integer): Void {
                    numberOfTrainingIterationsCompleted = arg0;
                    insert true into lookUpForUpdateGraph;
                }

                override public function communicateCurrentError(arg0: Float): Void {
                    currentError = arg0;
                    insert true into lookUpForUpdateGraph;
                }
                override public function communicateDurationOfTraining(arg0: Long): Void {
                    durationOfTraining = arg0;
                    insert true into lookUpForUpdateGraph;
                }
            }


    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:main
    public-read def rectangle1: javafx.scene.shape.Rectangle = javafx.scene.shape.Rectangle {
        opacity: 0.1
        layoutX: 730.0
        layoutY: 95.0
        width: 260.0
        height: 120.0
        arcWidth: 15.0
        arcHeight: 15.0
    }
    
    public-read def rectangle2: javafx.scene.shape.Rectangle = javafx.scene.shape.Rectangle {
        opacity: 0.15
        layoutX: 730.0
        layoutY: 230.0
        width: 260.0
        height: 205.0
        arcWidth: 15.0
        arcHeight: 15.0
    }
    
    public-read def rectangle3: javafx.scene.shape.Rectangle = javafx.scene.shape.Rectangle {
        opacity: 0.1
        layoutX: 730.0
        layoutY: 450.0
        width: 260.0
        height: 285.0
        arcWidth: 15.0
        arcHeight: 15.0
    }
    
    def __layoutInfo_minimizeButton: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 30.0
        height: 20.0
    }
    public-read def minimizeButton: javafx.scene.control.Button = javafx.scene.control.Button {
        cursor: javafx.scene.Cursor.HAND
        layoutX: 930.0
        layoutY: 25.0
        layoutInfo: __layoutInfo_minimizeButton
        text: "-"
        graphicTextGap: 0.0
        action: minimizeWindow
    }
    
    def __layoutInfo_helpButton: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 30.0
        height: 20.0
    }
    public-read def helpButton: javafx.scene.control.Button = javafx.scene.control.Button {
        visible: false
        cursor: javafx.scene.Cursor.HAND
        layoutX: 895.0
        layoutY: 25.0
        layoutInfo: __layoutInfo_helpButton
        text: "?"
    }
    
    def __layoutInfo_closeButton: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 30.0
        height: 20.0
    }
    public-read def closeButton: javafx.scene.control.Button = javafx.scene.control.Button {
        cursor: javafx.scene.Cursor.HAND
        layoutX: 965.0
        layoutY: 25.0
        layoutInfo: __layoutInfo_closeButton
        text: "x"
        action: closeWindow
    }
    
    public-read def inputAxis: javafx.scene.chart.part.NumberAxis = javafx.scene.chart.part.NumberAxis {
        cursor: null
        effect: null
        label: "input <x>"
        upperBound: 1.0
        lowerBound: 0.0
        formatTickLabel: inputAxisFormatTickLabel
        minorTickCount: 0
        tickUnit: 0.05
    }
    
    public-read def outputAxis: javafx.scene.chart.part.NumberAxis = javafx.scene.chart.part.NumberAxis {
        label: "output <y>"
        upperBound: 1.0
        lowerBound: -1.0
        formatTickLabel: outputAxisFormatTickLabel
        minorTickCount: 0
        tickUnit: 0.1
    }
    
    def __layoutInfo_timeTakenValueLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def timeTakenValueLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 860.0
        layoutY: 345.0
        layoutInfo: __layoutInfo_timeTakenValueLabel
        text: bind "{durationOfTraining}"
    }
    
    def __layoutInfo_learningConstantSlider: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 220.0
        height: 10.0
    }
    public-read def learningConstantSlider: javafx.scene.control.Slider = javafx.scene.control.Slider {
        cursor: javafx.scene.Cursor.HAND
        layoutX: 750.0
        layoutY: 260.0
        layoutInfo: __layoutInfo_learningConstantSlider
        max: 1.0
        value: 0.03
        blockIncrement: 1.0E-5
        showTickLabels: false
        showTickMarks: false
        labelFormatter: null
    }
    
    def __layoutInfo_currentErrorProgressBar: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 220.0
        height: 12.0
    }
    public-read def currentErrorProgressBar: javafx.scene.control.ProgressBar = javafx.scene.control.ProgressBar {
        layoutX: 750.0
        layoutY: 405.0
        layoutInfo: __layoutInfo_currentErrorProgressBar
        progress: bind currentError*10.0
    }
    
    def __layoutInfo_messageTextBox: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 661.0
        height: 122.0
    }
    public-read def messageTextBox: javafx.scene.control.TextBox = javafx.scene.control.TextBox {
        disable: true
        layoutX: 44.0
        layoutY: 613.0
        layoutInfo: __layoutInfo_messageTextBox
        effect: null
        text: bind message
        editable: true
        columns: 500.0
        font: null
        lines: 50.0
    }
    
    def __layoutInfo_trainingIterationLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def trainingIterationLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 750.0
        layoutY: 300.0
        layoutInfo: __layoutInfo_trainingIterationLabel
        text: "Training Iterations Completed:"
    }
    
    def __layoutInfo_trainingIterationValueLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def trainingIterationValueLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 908.0
        layoutY: 300.0
        layoutInfo: __layoutInfo_trainingIterationValueLabel
        text: bind "{numberOfTrainingIterationsCompleted}"
    }
    
    def __layoutInfo_currentErrorLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def currentErrorLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 750.0
        layoutY: 390.0
        layoutInfo: __layoutInfo_currentErrorLabel
        text: "Current Error:"
    }
    
    def __layoutInfo_currentErrorValueLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def currentErrorValueLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 860.0
        layoutY: 390.0
        layoutInfo: __layoutInfo_currentErrorValueLabel
        text: bind "{currentError}"
    }
    
    def __layoutInfo_learningConstantLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def learningConstantLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 750.0
        layoutY: 245.0
        layoutInfo: __layoutInfo_learningConstantLabel
        text: "Learning constant:"
    }
    
    def __layoutInfo_learningConstantValueLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def learningConstantValueLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 860.0
        layoutY: 245.0
        layoutInfo: __layoutInfo_learningConstantValueLabel
        text: bind "{learningConstantSlider.value}"
    }
    
    def __layoutInfo_selectExecutionModeDropDown: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 220.0
        height: 35.0
        hpos: javafx.geometry.HPos.CENTER
        vpos: javafx.geometry.VPos.CENTER
    }
    public-read def selectExecutionModeDropDown: javafx.scene.control.ChoiceBox = javafx.scene.control.ChoiceBox {
        cursor: javafx.scene.Cursor.HAND
        layoutX: 750.0
        layoutY: 160.0
        layoutInfo: __layoutInfo_selectExecutionModeDropDown
        onMouseClicked: null
        onMouseReleased: null
        items: [ "CPU MODE", "GPU MODE", ]
    }
    
    def __layoutInfo_timeTakenLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def timeTakenLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 750.0
        layoutY: 345.0
        layoutInfo: __layoutInfo_timeTakenLabel
        text: "Time taken in ms:"
    }
    
    def __layoutInfo_noOfPatternsSlider: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 220.0
    }
    public-read def noOfPatternsSlider: javafx.scene.control.Slider = javafx.scene.control.Slider {
        cursor: javafx.scene.Cursor.HAND
        layoutX: 750.0
        layoutY: 125.0
        layoutInfo: __layoutInfo_noOfPatternsSlider
        pickOnBounds: false
        min: 512.0
        max: 17920.0
        value: 1024.0
        blockIncrement: 512.0
        clickToPosition: false
        majorTickUnit: 25.0
        minorTickCount: 3
        snapToTicks: false
    }
    
    def __layoutInfo_noOfPatternsLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def noOfPatternsLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        opacity: 1.0
        layoutX: 750.0
        layoutY: 110.0
        layoutInfo: __layoutInfo_noOfPatternsLabel
        text: "Number of patterns:"
    }
    
    def __layoutInfo_noOfPatternsValueLabel: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        height: 15.0
    }
    public-read def noOfPatternsValueLabel: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 860.0
        layoutY: 110.0
        layoutInfo: __layoutInfo_noOfPatternsValueLabel
        text: bind "{numberOfPatterns}"
    }
    
    def __layoutInfo_cpuVsGpuButton: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 170.0
        height: 20.0
    }
    public-read def cpuVsGpuButton: javafx.scene.control.Button = javafx.scene.control.Button {
        cursor: javafx.scene.Cursor.HAND
        layoutX: 719.0
        layoutY: 25.0
        layoutInfo: __layoutInfo_cpuVsGpuButton
        onMouseClicked: cpuVsGpuButtonOnMouseClicked
        text: "SHOW CPU VS GPU CHART"
        action: null
    }
    
    def __layoutInfo_resetButton: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 60.0
        height: 60.0
    }
    public-read def resetButton: javafx.scene.control.Button = javafx.scene.control.Button {
        disable: true
        cursor: javafx.scene.Cursor.HAND
        layoutX: 910.0
        layoutY: 655.0
        layoutInfo: __layoutInfo_resetButton
        onMouseClicked: resetButtonOnMouseClicked
        text: "RESET"
    }
    
    def __layoutInfo_stopButton: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 60.0
        height: 60.0
    }
    public-read def stopButton: javafx.scene.control.Button = javafx.scene.control.Button {
        disable: true
        cursor: javafx.scene.Cursor.HAND
        layoutX: 830.0
        layoutY: 655.0
        layoutInfo: __layoutInfo_stopButton
        onMouseClicked: stopButtonOnMouseClicked
        text: "STOP"
    }
    
    def __layoutInfo_trainingProgressIndicator: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 661.0
        height: 121.0
    }
    public-read def trainingProgressIndicator: javafx.scene.control.ProgressIndicator = javafx.scene.control.ProgressIndicator {
        visible: bind not isTrainingPaused
        layoutX: 44.0
        layoutY: 614.0
        layoutInfo: __layoutInfo_trainingProgressIndicator
        effect: null
    }
    
    def __layoutInfo_startButton: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 60.0
        height: 60.0
        hfill: false
        vfill: false
        hgrow: null
        vgrow: null
    }
    public-read def startButton: javafx.scene.control.Button = javafx.scene.control.Button {
        disable: true
        cursor: javafx.scene.Cursor.HAND
        layoutX: 750.0
        layoutY: 655.0
        layoutInfo: __layoutInfo_startButton
        onMouseClicked: startButtonOnMouseClicked
        text: "START"
        action: null
    }
    
    def __layoutInfo_computeButton: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 100.0
        height: 30.0
    }
    public-read def computeButton: javafx.scene.control.Button = javafx.scene.control.Button {
        cursor: javafx.scene.Cursor.HAND
        layoutX: 750.0
        layoutY: 600.0
        layoutInfo: __layoutInfo_computeButton
        text: "COMPUTE"
        action: computeButtonAction
    }
    
    def __layoutInfo_formulaChoiceBox: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 220.0
        height: 30.0
    }
    public-read def formulaChoiceBox: javafx.scene.control.ChoiceBox = javafx.scene.control.ChoiceBox {
        layoutX: 750.0
        layoutY: 550.0
        layoutInfo: __layoutInfo_formulaChoiceBox
        onMouseClicked: formulaChoiceBoxOnMouseClicked
        items: [ "SELECT THE FORMULA", "Use formula entered above", "y = Math.sin(x*10)*0.7f", "y = Math.pow(Math.sin(x*10),3)*0.7f", "y = Math.sin((x+0.1f)*60)/((x+0.1f)*60)", "y = x*x*x", ]
    }
    
    def __layoutInfo_formulaEntryField: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 220.0
        height: 60.0
    }
    public-read def formulaEntryField: javafx.scene.control.TextBox = javafx.scene.control.TextBox {
        cursor: javafx.scene.Cursor.TEXT
        layoutX: 750.0
        layoutY: 470.0
        layoutInfo: __layoutInfo_formulaEntryField
        onMouseClicked: formulaEntryFieldOnMouseClicked
        promptText: "Enter java compatible formula here"
        selectOnFocus: false
    }
    
    public-read def label: javafx.scene.control.Label = javafx.scene.control.Label {
        layoutX: 114.0
        layoutY: 30.0
        text: "FUNCTION APPROXIMATION USING ARTIFICIAL NEURAL NETWORKS"
    }
    
    public-read def rectangle4: javafx.scene.shape.Rectangle = javafx.scene.shape.Rectangle {
        visible: false
        layoutX: 30.0
        layoutY: 75.0
        fill: javafx.scene.paint.Color.WHITE
        width: 964.0
        height: 663.0
        arcWidth: 20.0
        arcHeight: 20.0
    }
    
    public-read def numOfPatternsAxis: javafx.scene.chart.part.NumberAxis = javafx.scene.chart.part.NumberAxis {
        label: "Number of patterns"
        tickMarkStrokeWidth: 1.0
        upperBound: 17920.0
        minorTickCount: 16
        tickUnit: 1536.0
    }
    
    public-read def timeAxis: javafx.scene.chart.part.NumberAxis = javafx.scene.chart.part.NumberAxis {
        label: "Time taken in seconds"
        tickMarkStrokeWidth: 1.0
        upperBound: 590.0
        minorTickCount: 1
        tickUnit: 20.0
    }
    
    public-read def linearGradient: javafx.scene.paint.LinearGradient = javafx.scene.paint.LinearGradient {
        stops: [ javafx.scene.paint.Stop { offset: 0.0, color: javafx.scene.paint.Color.web ("#CCCCCC") }, javafx.scene.paint.Stop { offset: 1.0, color: javafx.scene.paint.Color.web ("#EEEEEE") }, ]
    }
    
    public-read def backGroundRectangle: javafx.scene.shape.Rectangle = javafx.scene.shape.Rectangle {
        opacity: 1.0
        layoutX: -1.0
        layoutY: -1.0
        onMouseClicked: null
        onMouseMoved: null
        fill: linearGradient
        width: 1024.0
        height: 768.0
        arcWidth: 68.26667
        arcHeight: 51.2
    }
    
    public-read def annDataSeries: javafx.scene.chart.LineChart.Series = javafx.scene.chart.LineChart.Series {
        name: "ANN Data"
        symbolCreator: null
        data: null
    }
    
    public-read def trainingDataSeries: javafx.scene.chart.LineChart.Series = javafx.scene.chart.LineChart.Series {
        name: "Training Data"
    }
    
    def __layoutInfo_lineChart: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 698.0
        height: 529.0
    }
    public-read def lineChart: javafx.scene.chart.LineChart = javafx.scene.chart.LineChart {
        cursor: null
        managed: true
        layoutX: 17.0
        layoutY: 85.0
        layoutInfo: __layoutInfo_lineChart
        onMouseEntered: null
        onMouseExited: null
        onMouseMoved: null
        chartBackgroundFill: javafx.scene.paint.Color.BLACK
        chartBackgroundStroke: javafx.scene.paint.Color.BLACK
        hoverStrokeWidth: 1.0
        legendGap: 8.0
        legendSide: javafx.scene.chart.part.Side.BOTTOM
        title: ""
        showSymbols: false
        symbolCreator: null
        data: [ trainingDataSeries, annDataSeries, ]
        xAxis: inputAxis
        yAxis: outputAxis
    }
    
    public-read def lineChartSeries: javafx.scene.chart.LineChart.Series = javafx.scene.chart.LineChart.Series {
        name: "lineChartSeries"
    }
    
    public-read def lineChartSeries2: javafx.scene.chart.LineChart.Series = javafx.scene.chart.LineChart.Series {
        name: "lineChartSeries2"
    }
    
    public-read def cpuDataChartSeries: javafx.scene.chart.LineChart.Series = javafx.scene.chart.LineChart.Series {
        name: "CPU"
        data: [ javafx.scene.chart.LineChart.Data { xValue: 512.0, yValue: 0.54 }, javafx.scene.chart.LineChart.Data { xValue: 1024.0, yValue: 1.91 }, javafx.scene.chart.LineChart.Data { xValue: 1536.0, yValue: 4.4 }, javafx.scene.chart.LineChart.Data { xValue: 2048.0, yValue: 7.837 }, javafx.scene.chart.LineChart.Data { xValue: 2560.0, yValue: 11.822 }, javafx.scene.chart.LineChart.Data { xValue: 3072.0, yValue: 17.032 }, javafx.scene.chart.LineChart.Data { xValue: 3584.0, yValue: 23.639 }, javafx.scene.chart.LineChart.Data { xValue: 4096.0, yValue: 30.265 }, javafx.scene.chart.LineChart.Data { xValue: 4608.0, yValue: 38.654 }, javafx.scene.chart.LineChart.Data { xValue: 5120.0, yValue: 47.324 }, javafx.scene.chart.LineChart.Data { xValue: 5632.0, yValue: 58.266 }, javafx.scene.chart.LineChart.Data { xValue: 6144.0, yValue: 68.255 }, javafx.scene.chart.LineChart.Data { xValue: 6656.0, yValue: 82.53 }, javafx.scene.chart.LineChart.Data { xValue: 7168.0, yValue: 92.05 }, javafx.scene.chart.LineChart.Data { xValue: 7680.0, yValue: 105.29 }, javafx.scene.chart.LineChart.Data { xValue: 8192.0, yValue: 121.08 }, javafx.scene.chart.LineChart.Data { xValue: 8704.0, yValue: 136.86 }, javafx.scene.chart.LineChart.Data { xValue: 9216.0, yValue: 151.75 }, javafx.scene.chart.LineChart.Data { xValue: 9728.0, yValue: 169.62 }, javafx.scene.chart.LineChart.Data { xValue: 10240.0, yValue: 187.02 }, javafx.scene.chart.LineChart.Data { xValue: 10752.0, yValue: 206.51 }, javafx.scene.chart.LineChart.Data { xValue: 11264.0, yValue: 226.54 }, javafx.scene.chart.LineChart.Data { xValue: 11776.0, yValue: 247.27 }, javafx.scene.chart.LineChart.Data { xValue: 12288.0, yValue: 270.69 }, javafx.scene.chart.LineChart.Data { xValue: 12800.0, yValue: 292.47 }, javafx.scene.chart.LineChart.Data { xValue: 13312.0, yValue: 317.06 }, javafx.scene.chart.LineChart.Data { xValue: 13824.0, yValue: 343.14 }, javafx.scene.chart.LineChart.Data { xValue: 14336.0, yValue: 367.41 }, javafx.scene.chart.LineChart.Data { xValue: 14848.0, yValue: 394.44 }, javafx.scene.chart.LineChart.Data { xValue: 15360.0, yValue: 421.66 }, javafx.scene.chart.LineChart.Data { xValue: 15872.0, yValue: 451.26 }, javafx.scene.chart.LineChart.Data { xValue: 16384.0, yValue: 482.53 }, javafx.scene.chart.LineChart.Data { xValue: 16896.0, yValue: 512.6 }, javafx.scene.chart.LineChart.Data { xValue: 17408.0, yValue: 545.08 }, javafx.scene.chart.LineChart.Data { xValue: 17920.0, yValue: 584.21 }, ]
    }
    
    public-read def gpuDataChartSeries: javafx.scene.chart.LineChart.Series = javafx.scene.chart.LineChart.Series {
        name: "GPU"
        data: [ javafx.scene.chart.LineChart.Data { xValue: 512.0, yValue: 0.725 }, javafx.scene.chart.LineChart.Data { xValue: 1024.0, yValue: 1.483 }, javafx.scene.chart.LineChart.Data { xValue: 1536.0, yValue: 2.165 }, javafx.scene.chart.LineChart.Data { xValue: 2048.0, yValue: 2.933 }, javafx.scene.chart.LineChart.Data { xValue: 2560.0, yValue: 3.541 }, javafx.scene.chart.LineChart.Data { xValue: 3072.0, yValue: 4.105 }, javafx.scene.chart.LineChart.Data { xValue: 3584.0, yValue: 5.172 }, javafx.scene.chart.LineChart.Data { xValue: 4096.0, yValue: 5.665 }, javafx.scene.chart.LineChart.Data { xValue: 4608.0, yValue: 6.558 }, javafx.scene.chart.LineChart.Data { xValue: 5120.0, yValue: 7.471 }, javafx.scene.chart.LineChart.Data { xValue: 5632.0, yValue: 8.165 }, javafx.scene.chart.LineChart.Data { xValue: 6144.0, yValue: 9.088 }, javafx.scene.chart.LineChart.Data { xValue: 6656.0, yValue: 10.39 }, javafx.scene.chart.LineChart.Data { xValue: 7168.0, yValue: 11.73 }, javafx.scene.chart.LineChart.Data { xValue: 7680.0, yValue: 12.1 }, javafx.scene.chart.LineChart.Data { xValue: 8192.0, yValue: 13.5 }, javafx.scene.chart.LineChart.Data { xValue: 8704.0, yValue: 13.74 }, javafx.scene.chart.LineChart.Data { xValue: 9216.0, yValue: 15.76 }, javafx.scene.chart.LineChart.Data { xValue: 9728.0, yValue: 16.03 }, javafx.scene.chart.LineChart.Data { xValue: 10240.0, yValue: 16.65 }, javafx.scene.chart.LineChart.Data { xValue: 10752.0, yValue: 18.37 }, javafx.scene.chart.LineChart.Data { xValue: 11264.0, yValue: 18.75 }, javafx.scene.chart.LineChart.Data { xValue: 11776.0, yValue: 19.91 }, javafx.scene.chart.LineChart.Data { xValue: 12288.0, yValue: 20.73 }, javafx.scene.chart.LineChart.Data { xValue: 12800.0, yValue: 22.28 }, javafx.scene.chart.LineChart.Data { xValue: 13312.0, yValue: 23.76 }, javafx.scene.chart.LineChart.Data { xValue: 13824.0, yValue: 24.62 }, javafx.scene.chart.LineChart.Data { xValue: 14336.0, yValue: 26.12 }, javafx.scene.chart.LineChart.Data { xValue: 14848.0, yValue: 27.33 }, javafx.scene.chart.LineChart.Data { xValue: 15360.0, yValue: 28.21 }, javafx.scene.chart.LineChart.Data { xValue: 15872.0, yValue: 30.68 }, javafx.scene.chart.LineChart.Data { xValue: 16384.0, yValue: 31.82 }, javafx.scene.chart.LineChart.Data { xValue: 16896.0, yValue: 32.93 }, javafx.scene.chart.LineChart.Data { xValue: 17408.0, yValue: 34.13 }, javafx.scene.chart.LineChart.Data { xValue: 17920.0, yValue: 35.08 }, ]
    }
    
    def __layoutInfo_cpuVsGpuChart: javafx.scene.layout.LayoutInfo = javafx.scene.layout.LayoutInfo {
        width: 904.0
        height: 603.0
    }
    public-read def cpuVsGpuChart: javafx.scene.chart.LineChart = javafx.scene.chart.LineChart {
        visible: false
        layoutX: 60.0
        layoutY: 105.0
        layoutInfo: __layoutInfo_cpuVsGpuChart
        title: "Number of patterns  vs time taken (for 10 iterations)"
        showSymbols: true
        symbolCreator: cpuVsGpuChartSymbolCreator
        data: [ cpuDataChartSeries, gpuDataChartSeries, ]
        xAxis: numOfPatternsAxis
        yAxis: timeAxis
    }
    
    public-read def scene: javafx.scene.Scene = javafx.scene.Scene {
        width: 1024.0
        height: 768.0
        content: getDesignRootNodes ()
        cursor: null
        fill: null
    }
    
    public-read def mainState: org.netbeans.javafx.design.DesignState = org.netbeans.javafx.design.DesignState {
    }
    
    public function getDesignRootNodes (): javafx.scene.Node[] {
        [ backGroundRectangle, rectangle1, rectangle2, rectangle3, minimizeButton, helpButton, closeButton, lineChart, timeTakenValueLabel, learningConstantSlider, currentErrorProgressBar, messageTextBox, trainingIterationLabel, trainingIterationValueLabel, currentErrorLabel, currentErrorValueLabel, learningConstantLabel, learningConstantValueLabel, selectExecutionModeDropDown, timeTakenLabel, noOfPatternsSlider, noOfPatternsLabel, noOfPatternsValueLabel, cpuVsGpuButton, resetButton, stopButton, trainingProgressIndicator, startButton, computeButton, formulaChoiceBox, formulaEntryField, label, rectangle4, cpuVsGpuChart, ]
    }
    
    public function getDesignScene (): javafx.scene.Scene {
        scene
    }
    // </editor-fold>//GEN-END:main

    

    var rectangle4Visible = false;

    // Actions related to cpuVsGpuButton. Makes the cpu vs gpu chart visible and invisible.
    function cpuVsGpuButtonOnMouseClicked(event: javafx.scene.input.MouseEvent): Void {
        if (rectangle4Visible) {
            rectangle4Visible = false;
            rectangle4.visible = rectangle4Visible;
            cpuVsGpuChart.visible = rectangle4Visible;
            rectangle4.blocksMouse = false;
            cpuVsGpuButton.text = "SHOW CPU VS GPU CHART";
        } else {
            rectangle4Visible = true;
            rectangle4.visible = rectangle4Visible;
            cpuVsGpuChart.visible = rectangle4Visible;
            rectangle4.blocksMouse = true;
            cpuVsGpuButton.text = "HIDE CPU VS GPU CHART";
        }

    }

    // when user tries to make a choice for formula entry set the value formulaEntryField.text to null
    function formulaChoiceBoxOnMouseClicked(event: javafx.scene.input.MouseEvent): Void {
        formulaEntryField.text = null;
    }

    // when user tries to enter formula in text field enable editing the text field and make a default entry of "y = "
    // If choice selected is different than 1 (i.e. 'Use formula entered above') then disable editing of field
    function formulaEntryFieldOnMouseClicked(event: javafx.scene.input.MouseEvent): Void {
        if (formulaChoiceBox.selectedIndex == 1) {
            formulaEntryField.editable = true;
            formulaEntryField.text = "y = ";
        } else {
            formulaEntryField.editable = false;
        }

    }

    // number of patterns selected by user
    var numberOfPatterns: Integer = bind Math.floor(noOfPatternsSlider.value / 512) * 512;

    // action to be taken when compute button is clicked.
    function computeButtonAction(): Void {
        if (formulaChoiceBox.selectedIndex == 0) {
            JOptionPane.showMessageDialog(new JFrame(), "Please enter/select the formula", "NO FORMULA PROVIDED", JOptionPane.ERROR_MESSAGE);
            return;
        }

        // Code to get the formula String and compiling it. If compiling is not succesfull return is executed.
        var formula: String = null;
        if (formulaChoiceBox.selectedIndex == 1) {
            formula = formulaEntryField.text;
        } else {
            formula = formulaChoiceBox.selectedItem as String;
        }
        if (not RuntimeCompileString.compile(formula)) {
            return;
        }


        // configure the variables which are dependent on numberOfPatterns entered.
        TrainANN.setConfigurationVariables(numberOfPatterns);

        // deleting previous data if any
        delete  trainingDataSeries.data;
        delete  annDataSeries.data;

        // calcuating deltax i.e distance between two patterns
        var deltax = 1.0 / (TrainANN.numberOfInputPatterns as Number);
        var x = 0.0;
        var y = 0.0;
        var xTeacherInputArray: Number[];
        var yTeacherInputArray: Number[];
        var yTrainingOutcomeArray: Number[];
        for (count in [1..TrainANN.numberOfInputPatterns]) {
            // calculate value of y for given x for given formula
            y = RuntimeCompileString.compute(x);println("{y}");
            insert Data {
                xValue: x
                yValue: y
            } into trainingDataSeries.data;
            insert Data {
                xValue: x
                yValue: 0.0
            } into annDataSeries.data;
            // make ready the teacher details for which ANN is to be trained
            insert x into xTeacherInputArray;
            insert y into yTeacherInputArray;
            // Initially set to zero but as the training proceeds values of this sequence are updated
            insert 0.0 into yTrainingOutcomeArray;
            // calculate value of x for next pattern
            x = x + deltax;
        }

        // delete the temporary .java and .class created with help of which we were generating values of y for given x
        RuntimeCompileString.deleteTempFilesCreated();

        // Assigining javaFx sequences to java array
        javaFxTrainingThreadTask.javaTrainingThreadTask.teacherInputArray = xTeacherInputArray as nativearray of Number;
        javaFxTrainingThreadTask.javaTrainingThreadTask.teacherOutputArray = yTeacherInputArray as nativearray of Number;
        javaFxTrainingThreadTask.javaTrainingThreadTask.trainingOutcomeArray = yTrainingOutcomeArray as nativearray of Number;

        // Assigining remaining required variables with proper values
        javaFxTrainingThreadTask.javaTrainingThreadTask.setSelectedModeIndex(selectExecutionModeDropDown.selectedIndex);
        formulaEntryField.disable = true;
        formulaChoiceBox.disable = true;
        noOfPatternsSlider.disable = true;
        selectExecutionModeDropDown.disable = true;
        computeButton.disable = true;
        startButton.disable = false;
        resetButton.disable = false;
        isTrainingActive = true;
        isTrainingPaused = true;
        javaFxTrainingThreadTask.javaTrainingThreadTask.currentError = 0.0;
        javaFxTrainingThreadTask.javaTrainingThreadTask.isTrainingActive = true;
        javaFxTrainingThreadTask.javaTrainingThreadTask.isTrainingPaused = true;
        message = "\n\tInput read successfully. \n\t\tTotal patterns for training: {TrainANN.numberOfInputPatterns}\n\t\tMode selected for training: {selectExecutionModeDropDown.selectedItem}\n\t\tLearning constant entered: {learningConstantSlider.value} \n\n\tClick 'START' button to start training. \n\tClick 'RESET' button to start from beginning.";
    }

    // action to be taken when stop button is clicked.
    function stopButtonOnMouseClicked(event: javafx.scene.input.MouseEvent): Void {
        message = "\n\tTraining stopped. \n\tClick 'START' button to continue with current training session. \n\tClick 'RESET' button to start from beginning. \n\tClick 'PLOT' button to plot the graph for currently trained weights.";

        stopButton.disable = true;
        computeButton.disable = true;
        startButton.disable = false;
        resetButton.disable = false;
        learningConstantSlider.disable = false;

        isTrainingPaused = true;
        javaFxTrainingThreadTask.javaTrainingThreadTask.isTrainingPaused = true;

    }

    // action to be taken when start button is clicked.
    function startButtonOnMouseClicked(event: javafx.scene.input.MouseEvent): Void {
        startButton.disable = true;

        isTrainingPaused = false;
        javaFxTrainingThreadTask.javaTrainingThreadTask.isTrainingPaused = false;
        javaFxTrainingThreadTask.javaTrainingThreadTask.learningConstant = learningConstantSlider.value;

        stopButton.disable = false;
        resetButton.disable = true;
        learningConstantSlider.disable = true;

        message = "\n\tTraining started. Click 'STOP' button to stop training.\n\n\n\tMay take few seconds in case of GPU mode before \n\ttraining is started as it requires compilation of kernels"
    }

    // action to be taken when reset button is clicked.
    function resetButtonOnMouseClicked(event: javafx.scene.input.MouseEvent): Void {

        formulaEntryField.disable = false;
        formulaChoiceBox.disable = false;

        noOfPatternsSlider.disable = false;
        resetButton.disable = true;
        computeButton.disable = false;
        startButton.disable = true;
        stopButton.disable = true;
        selectExecutionModeDropDown.disable = false;

        isTrainingActive = false;
        isTrainingPaused = true;

        javaFxTrainingThreadTask.javaTrainingThreadTask.isTrainingActive = false;
        javaFxTrainingThreadTask.javaTrainingThreadTask.isTrainingPaused = true;

        delete  annDataSeries.data;
        delete  trainingDataSeries.data;

        //javaFxTrainingThreadTask.javaTrainingThreadTask.teacherInputArray = null;
        //javaFxTrainingThreadTask.javaTrainingThreadTask.teacherOutputArray = null;
        //javaFxTrainingThreadTask.javaTrainingThreadTask.trainingOutcomeArray = null;

        message = "\n\tTraining resetted. Click 'COMPUTE' button to start again.";
    }

    // creating symbols for cpuVsGpuChart
    function cpuVsGpuChartSymbolCreator(series: javafx.scene.chart.LineChart.Series, seriesItem: Integer, item: javafx.scene.chart.LineChart.Data, itemIndex: Integer, fill: javafx.scene.paint.Paint): javafx.scene.Node {
        return Polygon {
                    points: [-2, -2, -2, 2, 2, 2, 2, -2]
                    fill: if (series.name.equals("CPU")) then Color.YELLOW else Color.GREEN;
                }
    }

    // formatting label of inputAxis
    function inputAxisFormatTickLabel(value: Number): String {
        var p = Math.pow(10, 2);
        var value1 = value * p;
        var tmp = Math.round(value1);
        return "{tmp / p}";
    }

    // formatting label of outputAxis
    function outputAxisFormatTickLabel(value: Number): String {
        var p = Math.pow(10, 2);
        var value1 = value * p;
        var tmp = Math.round(value1);
        return "{tmp / p}";
    }

    // action to be taken when minimize button is clicked.
    function minimizeWindow(): Void {
        stage.iconified = true;
    }

    // action to be taken when close button is clicked.
    function closeWindow(): Void {
        stage.close();
    }

}

// start point of the application
function run (): Void {
    var design = Main {};

    // Instantiating JavaFXTrainingThreadTask and launching a parallel threadwhich will be doing ANN training stuff
    // The thread launched will be executing infinitely in parallel till application is on.
    design.javaFxTrainingThreadTask = JavaFXTrainingThreadTask {
        listener: design.trainingThreadListener;
        javaTrainingThreadTask: new JavaTrainingThreadTask(design.trainingThreadListener);
    };
    design.javaFxTrainingThreadTask.start();

    // creating stage
    stage = javafx.stage.Stage {
        style:StageStyle.TRANSPARENT
        title: "Main"
        scene: design.getDesignScene ()
    }
    stage.scene.fill=Color.TRANSPARENT;
    stage;
}
