# Sudoku Solver
iOS Application that solves Sudoku using computer vision and a home cooked solving algorithm.

<video src="Assets/SudokuSolver-SpeedTest.MP4" width="390" height="844"></video>

## How it works

### Step 1: Identify Sudoku
CoreML object detection is used to identify a Sudoku in frame
[Roboflow Training Data](https://app.roboflow.com/pete-mksb1/sudoku-vision/overview)

### Step 2: Parse Cells
After Sudoku has been detected with adequate confidence, the puzzle is captured and the cells parsed.
[Roboflow Training Data](https://app.roboflow.com/pete-mksb1/sudoku-cell-vision/overview)

The cell is classified as either filled or empty along with it's location on the page.

### Step 3: Classifying cells
"Filled" cells are assumed to hold starting digits. The cell is passed through a shader to convert to the MNIST expected format of black background with white lettering.
After shading, the digit is isolated and a slight margin is added back to ensure cell boundaries are not interpeted as puzzle values.
Once the cell has been formatted, it is passed to CoreMLs MNIST Classifier Model and classified as a digit 1-9.
Pretrained models are available in [Apple's Model Garden.](https://developer.apple.com/machine-learning/models/)

### Step 4: Puzzle Data
After classifying the filled cells, values are put into a 9x9 `[[Int]]` and passed to the solving engine.
The solving engine returns the solution or throws an error and the user is prompted to try again.

### Solving Engine
The solving engine uses a home made elimination based strategy to solve Sudokus in fractions of a second.
Local benchmarks have shown solutions being produced for expert level Sudoku in as little as 100ms


Here's an step by step demo of the computer vision

<video src="Assets/SudokuSolver-Demo.MP4" width="390" height="844"></video>
