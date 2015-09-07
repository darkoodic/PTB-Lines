% PTB-Lines Kids (GitHub Version)
% Darko Odic (http://odic.psych.ubc.ca)
% University of British Columbia

% Last Update: Sep/6/2015
% Please read README.md before using. 
function [] = ptblineskids()
    HideCursor;
    clear all;
    warning off;
    rand('twister',sum(100*clock));
    AssertOpenGL;
    InitializePsychSound;
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
        feedback = inputCells{2}{strcmp('feedback',inputCells{1})};
        progressBar = inputCells{2}{strcmp('progressBar',inputCells{1})};
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127],[0 0 800 600]);
    else
        prompt = {'Subject Number:', 'Feedback (on/off):', 'Progress Bar (on/off):'};
        defaults = {'999', inputCells{2}{strcmp('feedback',inputCells{1})}, inputCells{2}{strcmp('progressBar',inputCells{1})}};
        answer = inputdlg(prompt, 'Kid Lines', 1, defaults);
        [sub, feedback, progressBar] = deal(answer{:});
        Screen('Preference','SkipSyncTests',1);
        [w,rect]=Screen('OpenWindow',max(Screen('screens')),[127 127 127]);
        ListenChar(2);
    end
    Screen('TextFont', w, 'Helvetica');
    Screen('TextSize', w, 24);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   
    %% MAKE DATA FILE
    fn = strcat('Data/PTBLineKids', '_', datestr(now, 'mmdd'),'_', sub,'.xls');
    fid = fopen(fn, 'a+');
    sub = str2num(sub); %#ok<ST2NM>
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n', ...
        'SubNum',...
        'DidIt',...
        'TrialNum',...
        'TimeStamp',...
        'ISI',...
        'Feedback',...
        'Character1',...
        'Character2',...
        'Color1',...
        'Color2',...
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

    leftDrawRect = [rect(3)*0.10, rect(4)*0.15, rect(3)*0.40, rect(4)*0.85];
    rightDrawRect = [rect(3)*0.60, rect(4)*0.15, rect(3)*0.90, rect(4)*0.85];
    leftFrameRect = [rect(3)*0.05, rect(4)*0.10, rect(3)*0.45, rect(4)*0.90];
    rightFrameRect = [rect(3)*0.55, rect(4)*0.10, rect(3)*0.95, rect(4)*0.90];
    color1rgb = str2num(inputCells{2}{strcmp('color1rgb',inputCells{1})});
    color2rgb = str2num(inputCells{2}{strcmp('color2rgb',inputCells{1})});
    color1string = inputCells{2}{strcmp('color1string',inputCells{1})};
    color2string = inputCells{2}{strcmp('color2string',inputCells{1})};
    key1 = inputCells{2}{strcmp('key1',inputCells{1})};
    key2 = inputCells{2}{strcmp('key2',inputCells{1})};
   
    %Make sure ISI is nice and long for young kids
    isi = str2num(inputCells{2}{strcmp('isi',inputCells{1})});    
    
    %Load in two kid-friendly characters so kids don't have to say colours.
    %Default is spongebob and smurf, you can also load big bird and grover
    %or include your own (must have transparent back and specify file in config.txt). 
    character1 = inputCells{2}{strcmp('character1',inputCells{1})};
    character2 = inputCells{2}{strcmp('character2',inputCells{1})};
    
    %Optional freeze first trial for explanation
    freezeFirst = inputCells{2}{strcmp('freezeFirstTrial',inputCells{1})};
    
    %Optional progress bar so you know how close to end. This is helpful
    %for being able to motivate the child by showing them how close they
    %are to being done. 
    progressBarRect = [rect(3)*0.45, rect(4)*0.95, rect(3)*0.55, rect(4)*0.98];
    
    %CARTOON TEXTURES
    leftCharacter = strcat('Characters/',character1,'.png'); 
    [lim , ~, alpha] = imread(leftCharacter);
    lim(:,:,4) = alpha(:,:);
    [ly,lx,~] = size(lim); %get size of image
    leftCharacterIndex = Screen('MakeTexture', w, lim);      

    rightCharacter = strcat('Characters/',character2,'.png'); 
    [rim , ~, alpha] = imread(rightCharacter);
    rim(:,:,4) = alpha(:,:);
    [ry,rx,~] = size(rim); %get size of image
    rightCharacterIndex = Screen('MakeTexture', w, rim);    
    
    %TRIAL ARRAY
    if(sub == str2num(inputCells{2}{strcmp('pracSN',inputCells{1})}))
        trialsPerBin = 1;
    else
        trialsPerBin = str2num(inputCells{2}{strcmp('trialsPerBin',inputCells{1})});
    end
    ratioArray = str2num(inputCells{2}{strcmp('ratios',inputCells{1})});
    ratioArray = horzcat(ratioArray,1./ratioArray); %make inverse of ratio for other colour to win
    orientationArray = inputCells{2}{strcmp('orientations',inputCells{1})}; %we will randomly rotate to make sure comparison is harder
    
    trialArray = repmat(rot90(ratioArray),[trialsPerBin,1]);
    totalTrials = length(trialArray);
    shuffledArray = trialArray(randperm(size(trialArray,1)),:);
 
    %First frame can be optionally set to freeze so that the displays can
    %be clearly shown to the kids. This is probably not needed for kids
    %older than 8. 
    if(strcmp(freezeFirst,'on'))
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
        RestrictKeysForKbCheck([KbName('Space')]);
        Screen('Flip',w);
        KbWait();
        
        WaitSecs(250/1000);
        
        %Show a very easy ratio. 
        didIt = drawLine(... 
            w,... %screen
            [defaultLength,defaultLength*2],... %lengthSet
            [drawCenter1;drawCenter2],... %drawCenter, if identical then lines are intermixed/overlapped
            [color1rgb; color2rgb],... %colorSet
            [22, 66]); %orientationSet   
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
        Screen('Flip',w);
        RestrictKeysForKbCheck([KbName('Space')]);
        KbWait();
        Screen('Flip',w);  
        WaitSecs(1);
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
        
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
        
        %Progress Bar   
        if(strcmp(progressBar,'on'))
            percentDone = (currentTrial-1)/totalTrials;
            xBar = progressBarRect(3) - progressBarRect(1);
            xBar = progressBarRect(1) + round(xBar*percentDone);
            Screen('FrameRect',w,[200 200 200],progressBarRect, 1);
            Screen('FillRect',w,[200 200 200],[progressBarRect(1), progressBarRect(2), xBar, progressBarRect(4)]);
        end
        RestrictKeysForKbCheck([KbName('Space')]);
        Screen('Flip',w);
        KbWait();
        
        WaitSecs(250/1000);
        didIt = drawLine(... 
            w,... %screen
            [trialLength1,trialLength2],... %lengthSet
            [drawCenter1;drawCenter2],... %drawCenter, if identical then lines are intermixed/overlapped
            [color1rgb; color2rgb],... %colorSet
            [trialOrientation1, trialOrientation2]); %orientationSet   
       
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
        
        %Progress Bar       
        if(strcmp(progressBar,'on'))
            percentDone = (currentTrial-1)/totalTrials;
            xBar = progressBarRect(3) - progressBarRect(1);
            xBar = progressBarRect(1) + round(xBar*percentDone);
            Screen('FrameRect',w,[200 200 200],progressBarRect, 1);
            Screen('FillRect',w,[200 200 200],[progressBarRect(1), progressBarRect(2), xBar, progressBarRect(4)]);
        end
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
                Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
                Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
                Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
                Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);
                %Progress Bar       
                if(strcmp(progressBar,'on'))
                    percentDone = (currentTrial-1)/totalTrials;
                    xBar = progressBarRect(3) - progressBarRect(1);
                    xBar = progressBarRect(1) + round(xBar*percentDone);
                    Screen('FrameRect',w,[200 200 200],progressBarRect, 1);
                    Screen('FillRect',w,[200 200 200],[progressBarRect(1), progressBarRect(2), xBar, progressBarRect(4)]);
                end
                Screen('Flip',w);
            end
        end
        T2 = GetSecs;
        Screen('FrameRect', w, color1rgb, leftFrameRect, 8);
        Screen('FrameRect', w, color2rgb, rightFrameRect, 8);
        Screen('DrawTexture', w, leftCharacterIndex, [0 0 lx ly], [rect(3)*0 rect(4)*0.80 rect(3)*0.12 rect(4)*1.0]);
        Screen('DrawTexture', w, rightCharacterIndex, [0 0 rx ry], [rect(3)*.92 rect(4)*0.80 rect(3)*1.00 rect(4)*1.0]);    
        
        %Progress Bar       
        if(strcmp(progressBar,'on'))
            percentDone = (currentTrial-1)/totalTrials;
            xBar = progressBarRect(3) - progressBarRect(1);
            xBar = progressBarRect(1) + round(xBar*percentDone);
            Screen('FrameRect',w,[200 200 200],progressBarRect, 1);
            Screen('FillRect',w,[200 200 200],[progressBarRect(1), progressBarRect(2), xBar, progressBarRect(4)]);
        end
        Screen('Flip',w);
        buttonPressed = find(keyCode);
        rt = (T2-T1)*1000;
 
        correct = 0;
        if((buttonPressed==KbName(key1))&&(trialLength1>trialLength2))
            correct = 100;
        elseif((buttonPressed==KbName(key2))&&(trialLength2>trialLength1))  
            correct = 100;
        elseif(buttonPressed==KbName('q')) %hard-coded quit key
            break;
        end
            
        %% PLAY FEEDBACK
        % Optional but will read in sounds from /Sounds/ directory.
        % There are 10 variations on Correct and 2 on Wrong in order to
        % keep things interesting for the child (and with the expectation
        % that they will get most trials correct).
        if(strcmp(feedback,'on'))
            if(correct == 100);
                [sound, freq] = wavread(['Sounds/Correct',num2str(randsample(10,1)),'.wav']);
                soundBuff = sound';
                nrchannels = size(soundBuff,1); 
                pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
                PsychPortAudio('FillBuffer', pahandle, soundBuff);
                PsychPortAudio('Start', pahandle, 1, 0, 1);
            else
                [sound, freq] = wavread(['Sounds/Wrong',num2str(randsample(2,1)),'.wav']);
                soundBuff = sound';
                nrchannels = size(soundBuff,1);
                pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
                PsychPortAudio('FillBuffer', pahandle, soundBuff);
                PsychPortAudio('Start', pahandle, 1, 0, 1);
            end
        end

        output{1} = sub;
        output{2} = didIt;
        output{3} = currentTrial;
        output{4} = (GetSecs-timeStart)/60; %timestamp
        output{5} = isi;
        output{6} = feedback;
        output{7} = character1;
        output{8} = character2;
        output{9} = color1string;
        output{10} = color2string;
        output{11} = trialLength1;
        output{12} = trialLength2;
        output{13} = trialRatio;
        output{14} = trialOrientation1;
        output{15} = trialOrientation2;
        output{16} = KbName(buttonPressed);
        output{17} = rt;
        output{18} = correct;
 
        writeData(output,fn);
    end
    Priority(0);

    %% CLEAN UP
    if(strcmp(feedback,'on'))
        PsychPortAudio('Close', pahandle); %delete audio
    end
    Screen('Flip',w);
    DrawFormattedText(w,'Yay! All Done!', 'center','center',0);
    Screen('Flip',w);
    ListenChar(0);
    ShowCursor;
    Screen('CloseAll');
end

%DATAOUT FUNCTION
function [] = writeData(output,file)
    fid = fopen(file, 'a+');
    fprintf(fid, '%4d\t %4d\t %4d\t %4f\t %4f\t %4s\t %4s\t %4s\t %4s\t %4s\t %4d\t %4d\t %4f\t %4d\t %4d\t %4s\t %4f\t %4d\n', ...
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
        output{15},...
        output{16},...
        output{17},...
        output{18});
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
