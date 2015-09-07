% PTB-Lines All-In-One (GitHub Version)
% Darko Odic (http://odic.psych.ubc.ca)
% University of British Columbia

% Last Update: Sep/6/2015
% Please read README.md before using. 
function [] = ptblinesaoi()
    HideCursor;
    clear all;
    warning off;
    rand('twister',sum(100*clock));
    AssertOpenGL;
    KbName('UnifyKeyNames');

    %% OPEN CONFIG FILE
    inputFile = fopen('config.txt');
    inputCells = textscan(inputFile,'%s\t %s\n');

    %% OPEN SCREEN
    % Note that both debug being on and off turns off Sync Tests (due to Mac issues)
    % If it doesn't cause problems on your machine, I would turn Sync Tests back on. 
    if(strcmp(inputCells{2}{strcmp('debug',inputCells{1})},'on'))
        ListenChar(0);
        sub = input('Subject number:   ', 's');
        isi = str2num(inputCells{2}{strcmp('isi',inputCells{1})});    
        trialsPerBin = str2num(inputCells{2}{strcmp('trialsPerBin',inputCells{1})});
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127],[0 0 800 600]);
    else
        prompt = {'Subject Number:', 'ISI', 'TrialsPerBin'};
        defaults = {'999', inputCells{2}{strcmp('isi',inputCells{1})}, inputCells{2}{strcmp('trialsPerBin',inputCells{1})}};
        answer = inputdlg(prompt, 'Lines Discrimination', 1, defaults);
        [sub, isi, trialsPerBin] = deal(answer{:});
        isi = str2num(isi);
        trialsPerBin = str2num(trialsPerBin);
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127]);
        ListenChar(2);
    end
    Screen('TextFont', w, 'Helvetica');
    Screen('TextSize', w, 24);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %% MAKE DATA FILE 
    fn = strcat('Data/PTBLines', '_', datestr(now, 'mmdd'),'_', sub,'.xls');
    fid = fopen(fn, 'a+');
    sub = str2num(sub); %#ok<ST2NM>
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', ...
        'SubNum',...
        'DidIt',...
        'TrialNum',...
        'TimeStamp',...
        'ISI',...
        'Color1String',...
        'Color2String',...
        'Length1',...
        'Length2',...
        'Ratio',...
        'Orientation1',...
        'Orientation2',...
        'KeyPressed',...
        'RT',...
        'Correct');
    fclose(fid);
    
    %% LINE & TRIAL PROPERTIES
    % Specify the centres of the two lines (here separated to left and
    % right)
    drawCenter1 = [rect(3)*0.25, rect(4)*0.50];
    drawCenter2 = [rect(3)*0.75, rect(4)*0.50];

    %Default Length (read from config.txt) in pixels.
    %This length will then be modulated +/- by the ratio
    defaultLength = str2num(inputCells{2}{strcmp('defaultLengthPx',inputCells{1})});
    
    color1rgb = str2num(inputCells{2}{strcmp('color1rgb',inputCells{1})});
    color2rgb = str2num(inputCells{2}{strcmp('color2rgb',inputCells{1})});
    color1string = inputCells{2}{strcmp('color1string',inputCells{1})};
    color2string = inputCells{2}{strcmp('color2string',inputCells{1})};
    key1 = inputCells{2}{strcmp('key1',inputCells{1})};
    key2 = inputCells{2}{strcmp('key2',inputCells{1})};
    
    %TRIAL ARRAY
    if(sub == str2num(inputCells{2}{strcmp('pracSN',inputCells{1})}))
        trialsPerBin = 2;
    end
    %2.0; 1.5; 1.2; 1.14; 1.11
    ratioArray = str2num(inputCells{2}{strcmp('ratios',inputCells{1})});
    ratioArray = horzcat(ratioArray,1./ratioArray); %make inverse of ratio for other colour to win
    orientationArray = inputCells{2}{strcmp('orientations',inputCells{1})}; %we will randomly rotate to make sure comparison is harder
    
    trialArray = repmat(rot90(ratioArray),[trialsPerBin,1]);
    totalTrials = length(trialArray);
    shuffledArray = trialArray(randperm(size(trialArray,1)),:);

    %% SHOW INSTRUCTIONS
    % To make your own, go to the /Instructions/ folder, edit the Powerpoint file and save as image. 
    if(strcmp(inputCells{2}{strcmp('debug',inputCells{1})},'off'))
        imageID = strcat('Instructions/instructions1.png'); 
        [im , ~, ~] = imread(imageID);
        picIndex = Screen('MakeTexture', w, im);             
        [y,x,~] = size(im); %get size of image
        Screen('DrawTexture', w, picIndex, [0 0 x y], rect);   
        Screen('Flip',w);
        RestrictKeysForKbCheck([KbName('c')]); %hard-coded for participant to not quickly advance
        KbWait();

        imageID = strcat('Instructions/instructions2.png'); 
        [im , ~, ~] = imread(imageID);
        picIndex = Screen('MakeTexture', w, im);             
        [y,x,~] = size(im); %get size of image
        Screen('DrawTexture', w, picIndex, [0 0 x y], rect);   
        Screen('Flip',w);
        RestrictKeysForKbCheck([KbName('b')]); %different from first button so no quick advance.
        KbWait();
    end
  
    %% RUN TRIALS
    Priority(9);
    timeStart = GetSecs;
    for currentTrial = 1:totalTrials
        %Setup individual trial
        trialRatio= shuffledArray(currentTrial,1);        
        
        %We don't want the defaultLength to always be the winner or loser
        %so we randomly make one the default, and vary the other by the 
        %ratio. This means that participants can't just learn to identify
        %the one that is the default length and use that as cue.
        if(rand()>0.5)
            trialLength1 = defaultLength; %first is default
            trialLength2 = trialLength1 * trialRatio; %second is default by ratio.
        else
            trialLength2 = defaultLength; %second is default
            trialLength1 = trialLength2 * trialRatio; %first is default by ratio.
        end
        
        pickOrientation = randperm(length(orientationArray)); %randperm so no repeats
        trialOrientation1 = orientationArray(pickOrientation(1));
        trialOrientation2 = orientationArray(pickOrientation(2));
        
        RestrictKeysForKbCheck([KbName('Space')]);
        DrawFormattedText(w,['What''s longer: the ',color1string,' line (',key1,') or the ',color2string,' line (',key2,')?'],'center','center',0);
        Screen('Flip',w);
        KbWait();

        Screen('DrawText',w,'+',rect(3)/2,rect(4)/2,0,0,0);
        Screen('Flip',w);
        WaitSecs(250/1000);
        Screen('Flip',w);
        
        didIt = drawLine(... 
            w,... %screen
            [trialLength1,trialLength2],... %lengthSet
            [drawCenter1;drawCenter2],... %drawCenter, if identical then lines are intermixed/overlapped
            [color1rgb; color2rgb],... %colorSet
            [trialOrientation1, trialOrientation2]); %orientationSet   
        Screen('Flip',w);
 
        rt=0; %#ok<NASGU>
        kdown = 0;
        keyCode = 0;
        RestrictKeysForKbCheck([KbName(key1) KbName(key2) KbName('q')]);
        T1 = GetSecs;
        while((kdown == 0))
            [keyIsDown, ~, keyCode] = KbCheck;
            kdown=keyIsDown;
            T2 = GetSecs;
            rt = (T2-T1)*1000;
            if(rt >= isi)
                Screen('Flip',w);
            end
        end
        T2 = GetSecs;
        Screen('Flip',w);
        buttonPressed = find(keyCode);
        rt = (T2-T1)*1000;
 
        correct = 0;
        if((buttonPressed==KbName(key1))&&(trialLength1>trialLength2))  
            correct = 100;
        elseif((buttonPressed==KbName(key2))&&(trialLength2>trialLength1))  
            correct = 100;
        elseif(buttonPressed==KbName('q')) %hard-code break key
            break;
        end

        output{1} = sub;
        output{2} = didIt;
        output{3} = currentTrial;
        output{4} = (GetSecs-timeStart)/60; %timestamp
        output{5} = isi;
        output{6} = color1string;
        output{7} = color2string;
        output{8} = trialLength1;
        output{9} = trialLength2;
        output{10} = max(trialRatio,1/trialRatio);
        output{11} = trialOrientation1;
        output{12} = trialOrientation2;
        output{13} = KbName(buttonPressed);
        output{14} = rt;
        output{15} = correct;
       
        writeData(output,fn);
    end
    Priority(0);
    
    %% CLEAN UP
    Screen('Flip',w);
    DrawFormattedText(w,'You are done this part of the experiment! Please alert your experimenter.', 'center','center',0);
    Screen('Flip',w);
    WaitSecs(2);
    ListenChar(0);
    ShowCursor;
    Screen('CloseAll');
end

%DATAOUT FUNCTION
function [] = writeData(output,file)

    fid = fopen(file, 'a+');
    fprintf(fid, '%4d\t %4d\t %4d\t %4f\t %4f\t %4s\t %4s\t %4d\t %4d\t %4f\t %4d\t %4d\t %4s\t %4f\t %4d\n', ...
        output{1},...
        output{2},...
        output{3},...
        output{4},...
        output{5},...
        output{6},...
        output{7},...
        output{8},...
        output{9},...
        output{10},...
        output{11},...
        output{12},...
        output{13},...
        output{14},...
        output{15});
    fclose(fid);
end

function[didIt] = drawLine(w, lengthSet, centerSet, colorSet, orientationSet)
    for currentLine = 1:length(lengthSet)
        %get length
        lineLength = lengthSet(currentLine);
        
        %get center
        setXY = centerSet(currentLine,:);
        centerX = round(setXY(1));
        centerY = round(setXY(2));
        
        %get orientation
        orientation = orientationSet(currentLine);
        
        %get color
        color = colorSet(currentLine, :);
        
        %determine coordinates
        coords = [centerX-(cos(degtorad(orientation))*lineLength/2),...
            centerX+(cos(degtorad(orientation))*lineLength/2);...
            centerY-(sin(degtorad(orientation))*lineLength/2),...
            centerY+(sin(degtorad(orientation))*lineLength/2)];
        
        %draw line
        Screen('DrawLines', w, coords, 4, color, [], 2);
    end
    didIt = true;
end%function

