#PTB-Lines All-In-One (ptblinesaoi.m)

Darko Odic (http://odic.psych.ubc.ca) <br />
Last Edit: Sep/6/2015 <br />

This Psychtoolbox script is used to generate random line stimuli for line discrimination experiments. Used for, e.g., estimating a Weber fraction of each individual participant. 

## Quick Overview
To run the script as an experiment, you need to adjust the config.txt file, including:

  * `debug` ("on" or "off"): the debug mode runs the program in windowed mode (so you can read the console errors). It is recommended you run this mode the first time you try out the script. 
  * `pracSN` (default: 999): the subject number used for your "practice" runs that significantly shortens the experiment.
  *  `isi` in miliseconds (default: 500): the number of ms that the dots will stay on the screen. 
  *  `defaultLengthPx`: the length of average line from which other lines will be made (default: 100). 
  * `ratios` (default: [2.0, 1.50, 1.20, 1.10]): the list of ratios that will be presented, separated by semicolons. For example [20,10;10,20] means that the participant will see a line of 100px and another either 50px or 200px. *Make sure that there are no spaces between the commas or semicolons when you type in these values, as this will cause the line to not be read in properly*. 
  * `orientations` array (default: [22, 66, 110, 132]): the list of orientations that lines will be shown in. When it comes to line-length discrimination experiments, two things are important to keep in mind: cardinal orientations (45, 90) are represented differently than non-cardinals, and if two lines have identical orientation the participant can just compare the tips rather than actual lengths. So you have to make sure orientations are jittered and non-cardinal. 
  * `trialsPerBin` (default: 2): the number of fully balanced trials that will happen in the experiment. For example, if you have the default 4 ratios x 2 trialsPerBin = 8 trials total.
  * `color1rgb` and `color2rgb` in RGB values (defaults: [255,255,0] and [0,0,255]: the colours for the two sets of lines.
  * `key1` and `key2` in char (default: 'f' and 'j'): keys used for answering in your task. 

## Basic Overview of Functions
The script has three functions:

1. `ptblinesaoi`: this is the main function through which the entire experiment runs.
  * This function takes no inputs.
  * This function gives no outputs, but uses all the `Screen()` functions and terminates the experiment. 

2. `writeData`: helper function for outputting data.
  * This function takes as input the `output` structure defined at the end of each trial (see `output`) and the `fn` file, defined at the start of the script.
  * It will then write the designated columns to the file.

3. `drawLines`: the function used to create lines of particular length and orientation. It is a very straightforward function. 
  * There are many inputs, but the most relevant ones are the `lengthSet` (which specifies the length of each line in pixels), and the `centerSet` (which specifies the location of the center of each line). 
  * It has one direct output: `didIt`, which returns a boolean depending on whether the function successfully made the lines and placed them on the screen without overlap (it may fail if, e.g., the lines are too long and can't fit on the screeen). 