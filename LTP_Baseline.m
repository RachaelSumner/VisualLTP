% LTP_Baseline

% CREATED:
% Rachael Sumner, January 2019


%EDITED:
% Adapted for triggers using ppdev_mex. (Rachael Sumner, March 2020)


% NOTES:

% Hold 'p' to pause and 'q' to quit
% 240 trials (120 per grating type)

% Runs on Psychtoolbox-3 http://psychtoolbox.org/

% Requires https://github.com/widmann/ppdev-mex for triggers, else add your
% own and remove all trigger related code.



%%
PsychDefaultSetup(2);

% Trigger setup % 

try
    ppdev_mex('Open',1); %initilise triggering
catch
    warning('ppdev_mex did not execute correctly - Any triggers will not work'); 
end

%               %

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%     ESSENTIAL PERSONALISATION   %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Change values according to screen specifications in order to calculate stimulus
% dimensions and flicker rate

screen_width = 29.8; % enter in degrees. Visual angle of screen (degrees) assumes sitting 1m away from 53.3cm wide screen
% screen_height = 29.8/1.778; %enter in degrees %Unused when stimulus is a circle 
% will be used to ensure stimuli subtend ~8 degrees of visual angle

hz = 144; %screen refresh rate 
screen_refresh = 1/hz; %calculates your screen refresh rate in seconds
% will be used to calculate: 
    % stimulus duration (as close to 33ms as possible)
    % isi (as close to 1 Hz as possible) 

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
%%% TO REPORT YOUR EXACT STIMULUS DURATION AND ISI USE THESE:

max_fit_stimulus_duration =  floor(0.033/screen_refresh); %lock stimulus duration to nearest number of screen refreshes possible to achieve ~1 Hz
stimulus_duration = max_fit_stimulus_duration * screen_refresh;

max_fit_isi = floor(1/screen_refresh); %lock isi to nearest number of screen refreshes possible to achieve ~1 Hz 
isi = max_fit_isi * screen_refresh; 
% jitter use multiples of stimulus duration


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% PARADIGM %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%BASIC SCREEN SETUP
Priority(1);
ListenChar(2); %prevent keyboard input going to the MATLAB window

screens = Screen('Screens'); %For projecting to external screen. Get the number of screens in the computer setup
screenNumber = max(screens); %Can change to 0 for single screen. Otherwise displays on the most external screen (grab max number)

[window, windowRect] = Screen('OpenWindow', screenNumber);
HideCursor;

ScreenRect = Screen ('Rect', window);
pixels_width = ScreenRect(3);
pixels_height = ScreenRect(4);
pixels_per_degree = pixels_width/screen_width;

black = BlackIndex(window);  % Retrieves the CLUT color code for black.
white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
grey = white / 2;  % Computes the CLUT color code for grey.

[xCenter, yCenter] = RectCenter(windowRect); %Finds centre of the screen - Used in Screen('DrawDots',...) for fixation dot


%%%% TRIAL SPECIFICATIONS
B_num_trial_per_con = 120;
B_num_conditions = 2;
B_num_trials = B_num_trial_per_con * B_num_conditions;

%create jitter according to isi
        %built in pseudorandom jitter +/- 1&2 * stimulus_duration (0 to
        %~66ms)
        
B_isi_jitter_1 = isi;
B_isi_jitter_2 = isi + stimulus_duration;
B_isi_jitter_3 = isi + 2 * stimulus_duration;
B_isi_jitter_4 = isi - stimulus_duration;
B_isi_jitter_5 = isi - 2 * stimulus_duration;

PauseKey = 'p';
QuitKey = 'q';

%%%%STIMULI
degrees = 8; %degrees of visual angle stimuli will span
num_cycles = 8; %cycles per degree/spatial freq of sine grating 
dia = floor(pixels_per_degree*degrees) - 1; 
radius = dia / 2;

x = 0 :1:dia;
gratingImage =(sin(((x *2* pi * num_cycles)/dia)+pi/2)+1) * 254 / 2 + 1; %(x *2* pi * numCycles)/dia freq of sine;  +pi/2 phase; amps scaling
gratingImage = repmat( gratingImage, [ ( dia + 1 ) 1 ] );


%Cut grating into a circle
for y = 0 : dia
    ycentred = y - radius;
    x = sqrt( radius * radius - ycentred * ycentred );
    gratingImage( y + 1, 1 : floor( radius - x ) ) = grey;
    gratingImage( y + 1, floor( radius + x + 1 ) : ( dia + 1 ) ) = grey;
end 

VerticalGrating  = Screen('MakeTexture', window, gratingImage);
HorizontalGrating = Screen('MakeTexture', window, gratingImage, [], [], [], 90); %90 rotates VerticalGrating by 90deg


%%%%TASK
Screen ('FillRect', window, grey);
Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
Screen('Flip', window);
WaitSecs(1);



for trial = 1:B_num_trials  
    TrialTypes = ([1 2]);
    AllTrials = repmat(TrialTypes, 1, B_num_trial_per_con); 
    AllTrials = Shuffle(AllTrials);
    if AllTrials(trial) == 1
            Screen('DrawTexture', window, VerticalGrating)
            Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
            Screen('Flip', window);
            lptwrite(1, 1); % Send trigger
        else
            Screen('DrawTexture', window, HorizontalGrating)
            Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
            Screen('Flip', window);
            lptwrite(1, 2); % Send trigger
    end
    WaitSecs(stimulus_duration)
    
    Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
    Screen('Flip', window);
    lptwrite(1, 0); % Clear trigger
    isiTypes = ([1 2 3 4 5]);
    isi = repmat(isiTypes, 1, B_num_trial_per_con); 
    isi = Shuffle(isi);
    if isi(trial) == 1
            WaitSecs(B_isi_jitter_1);     
        elseif isi(trial) == 2
                WaitSecs(B_isi_jitter_2);
        elseif isi(trial) == 3
                WaitSecs(B_isi_jitter_3);
        elseif isi(trial) == 4
                WaitSecs(B_isi_jitter_4);
        elseif isi(trial) == 5
                WaitSecs(B_isi_jitter_5);        
    end
    
    % Quit and pause key
    [keyIsDown, secs, keyCode] = KbCheck;
    if find(keyCode) == KbName(QuitKey)
          ppdev_mex('Close',1); %Close port (for triggers)
          Screen ('CloseAll');
          ShowCursor;
          ListenChar(0);
          return
      elseif find(keyCode) == KbName (PauseKey)   
          DrawFormattedText(window, 'Experiment Paused \n \nPress any key to continue', 'center', 'center', black)
          Screen('Flip', window);
          KbStrokeWait;
    end  
end

Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
Screen('Flip', window);
WaitSecs(1);

%%%%END
ppdev_mex('Close',1); %Close port (for triggers)
Screen ('CloseAll');
ShowCursor;
ListenChar (0);
Priority(0)