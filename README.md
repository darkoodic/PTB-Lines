# PTB-Lines
Psychtoolbox scripts used for generating, saving, and displaying approximate line discrimination displays.

## Created By
Darko Odic (http://odic.psych.ubc.ca) <br />
Department of Psychology <br />
University of British Columbia <br />
September 6th, 2015 <br />

We welcome contributions and revisions to this code, as it could definitely be optimized further! If interested, fork, change, send pull request. If you don't like git, clone/download, revise, then send me an email.

## Quick Start

1. Make sure you have downloaded the latest version of <a href="http://www.mathworks.com/products/matlab/">MATLAB</a> and <a href="http://psychtoolbox.org/">Psychtoolbox</a>. These scripts were built and tested on Psychtoolbox-3.0.12, but should work fine with later versions, as well. 
2. <a href="https://github.com/darkoodic/PTB-Lines/archive/master.zip">Download</a> or clone the repo (`git clone https://github.com/darkoodic/PTB-Lines.git`). This will give you all three script types that you can see below.
3. Open one of the two scripts in MATLAB, run the green arrow and enjoy. If there are any issues, we recommend going into the config.txt file and changing `debug` to "on". This will allow you to easily see errors in the console. 

## Versions
There are three different versions of the script:

1. **PTB-Lines All-In-One** (`ptblines-aoi.m`): To generate and immediately display line-length displays following various parameters, like changes in orientation, ratio, etc. This is the most common way for testing adults and children and generally has everything you need. Further information on this script is available in that folder's README.md file. 
2. **PTB-Lines Kids** (`ptblines-kids.m`): This version of the AOI script makes things simpler for testing children aged 3 - 10 by introducing boxes, cartoon characters, etc. Further information on this script is available in that folder's README.md file. 

## License
Code released under the MIT license.