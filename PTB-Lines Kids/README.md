#PTB-Lines Kids (ptblineskids.m)

Darko Odic (http://odic.psych.ubc.ca) <br />
Last Edit: Sep/6/2015 <br />

This Psychtoolbox script is used to generate random line stimuli for line discrimination experiments *used with children* aged 3 - 10. It works similar to the PTB-Lines AOI script, but provides a series of functions that make it easier to display and work with children, including kid-friendly characters, a progress bar, kid-friendly feedback, etc. 

## Quick Overview
To run the script as an experiment, you need to adjust the config.txt file, including:

  * `debug` ("on" or "off"): the debug mode runs the program in windowed mode (so you can read the console errors). It is recommended you run this mode the first time you try out the script. 
  * `pracSN` (default: 999): the subject number used for your "practice" runs that significantly shortens the experiment.
  *  `isi` in miliseconds (default: 1200): the number of ms that the dots will stay on the screen. This value will strongly depend on age, but in general 800 - 1200 ms will be fine for kids 3 - 10. 
  *  `defaultLengthPx`: the length of average line from which other lines will be made (default: 100). 
  * `ratios` (default: [2.0, 1.50, 1.20, 1.10]): the list of ratios that will be presented, separated by semicolons. For example [20,10;10,20] means that the participant will see a line of 100px and another either 50px or 200px. *Make sure that there are no spaces between the commas or semicolons when you type in these values, as this will cause the line to not be read in properly*. 
  * `orientations` array (default: [22, 66, 110, 132]): the list of orientations that lines will be shown in. When it comes to line-length discrimination experiments, two things are important to keep in mind: cardinal orientations (45, 90) are represented differently than non-cardinals, and if two lines have identical orientation the participant can just compare the tips rather than actual lengths. So you have to make sure orientations are jittered and non-cardinal. 
  * `trialsPerBin` (default: 2): the number of fully balanced trials that will happen in the experiment. For example, if you have the default 4 ratios x 2 trialsPerBin = 8 trials total.
  * `color1rgb` and `color2rgb` in RGB values (defaults: [255,255,0] and [0,0,255]: the colours for the two sets of lines.
  * `key1` and `key2` in char (default: 'f' and 'j'): keys used for answering in your task. *We do not recommend allowing kids younger than 8 to press their own keys*. Instead, they can tap the screen or vocalize the response. 
  * `character1` and `character2` (default: "spongebob" and "smurf"): the PNG files of the two kid-friendly characters associated with each line. The script also provides 'bigbird' and 'grover'. You can feel free to use your own so long as they are transparent background PNG files.
  * `feedback` (default: "on"): whether or not the child will receive kid-friendly audio feedback after each trial. The feedback trials are in the /Sounds/ folder. 
  * `freezeFirstTrial` (default: "on"): an option setting whether there will be one extra very easy first trial with an infinite ISI. This is useful for showing young kids what the lines look like and what they need to do.
  * `progressBar` (default: "on"): an optional setting for showing a filling progress bar in the bottom of the display. This is very useful for knowing how far in the experiment you are and for motivating kids to keep going.
 
## Advice for helping kids understand the task
There is no method that works with every kid at every age. In general, however, line experiments are much easier for kids to grasp and like than dot experiments. There are a few tips on helping kids understand the task:

*  Start by introducing them to the two characters. Be excited! Tell them that each character has a box (wow! a box!). Point on the screen as you say whose box is whose (this helps in case they don't know both the characters or are colour-blind). 
* The simplest game is to have kids tell you which character has a longer line (you can replace lines with sticks, or batons, whatever). If they tell you that those are not lines but something else - go with it! 
* If they clearly did not understand what to do, force-quit the program (q by default) and start again. Two exceptions: don't do this after they've done more than 5-10 trials, and don't quit more than once! Some kids just won't get it, and that's alright. It's not **that** good of a game after all. 
* Having young kids press the response buttons is just going to be a bad time for everyone. Encourage them to say or yell the answer or point to the screen or do an interpretive dance. Just don't have them push the buttons (spacebar being needed for the next trial to begin is a useful tool). 
* Some kids get dissuaded by the negative feedback. If you notice this, either mute the computer, or tell them that even you didn't know the answer to that one! If you guys are working together against this silly game they will usually truck along (just don't give them the answers).
* The progress bar can be an excellent tool for showing them how far they've come and how soon you will both be done! 

## Basic Overview of Functions
The script has three functions:

1. `ptblineskids`: this is the main function through which the entire experiment runs.
  * This function takes no inputs.
  * This function gives no outputs, but uses all the `Screen()` functions and terminates the experiment. 

2. `writeData`: helper function for outputting data.
  * This function takes as input the `output` structure defined at the end of each trial (see `output`) and the `fn` file, defined at the start of the script.
  * It will then write the designated columns to the file.

3. `drawLines`: the function used to create lines of particular length and orientation. It is a very straightforward function. 
  * There are many inputs, but the most relevant ones are the `lengthSet` (which specifies the length of each line in pixels), and the `centerSet` (which specifies the location of the center of each line). 
  * It has one direct output: `didIt`, which returns a boolean depending on whether the function successfully made the lines and placed them on the screen without overlap (it may fail if, e.g., the lines are too long and can't fit on the screeen). 