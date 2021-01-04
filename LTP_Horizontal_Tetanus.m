% LTP_Horizontal_Tetanus

% CREATED:
% Rachael Sumner, January 2019


% EDITED:
% Adapted for triggers using ppdev_mex. (Rachael Sumner, March 2020)


% NOTES:

% Hold 'p' to pause and 'q' to quit
% 1000 trials

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

% Change values according to presentation screen specifications in order 
% to calculate stimulus dimensions and flicker rate

screen_width = 29.8; % enter in degrees. Visual angle of screen (degrees) assumes sitting 1m away from 53.3cm wide screen
% screen_height = 29.8/1.778; %enter in degrees %Unused when stimulus is a circle
% will be used to ensure stimuli subtend ~8 degrees of visual angle

hz = 144;
screen_refresh = 1/hz; %calculates your screen refresh rate in seconds
% will be used to calculate: 
    % stimulus duration (as close to 33ms as possible)
    % isi (as close to 9 Hz as possible) 

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%% TO REPORT YOUR EXACT STIMULUS DURATION AND ISI USE THESE:

max_fit_stimulus_duration =  floor(0.033/screen_refresh); %lock stimulus duration to nearest number of screen refreshes possible to achieve ~9 Hz
stimulus_duration = max_fit_stimulus_duration * screen_refresh;

max_fit_isi = floor((1/9)/screen_refresh); %lock isi to nearest number of screen refreshes possible to achieve ~9 Hz 
isi = max_fit_isi * screen_refresh; 
% jitter uses half stimulus duration, to the nearest screen
% refresh to give jitter of +/- ~16ms



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%q
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
T_num_trial_per_con = 1000;
T_num_conditions = 1;
T_num_trials = T_num_trial_per_con * T_num_conditions;

T_isi_duration_1 = isi;
T_isi_duration_2 = isi - stimulus_duration/(round(0.5 * max_fit_stimulus_duration));
T_isi_duration_3 = isi + stimulus_duration/(round(0.5 * max_fit_stimulus_duration));
%create jitter according to isi
        %built in pseudorandom jitter +/- ~16 ms

PauseKey = 'p';
QuitKey = 'q';

%%%%STIMULI
degrees = 8; %degrees of visual angle stimuli will span
num_cycles = 8;
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
HorizontalGrating = Screen('MakeTexture', window, gratingImage, [], [], [], 90); %rotates StandardGrating by 90deg


%%%%TASK
Screen ('FillRect', window, grey);
Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
Screen('Flip', window);
WaitSecs(1);

for trial = 1:T_num_trials
    Screen('DrawTexture', window, HorizontalGrating)
    Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
    Screen('Flip', window);
    lptwrite(1, 2) % Send trigger
    WaitSecs(stimulus_duration)
    
    Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
    Screen('Flip', window);
    lptwrite(1, 0) % Clear trigger
    isiTypes = ([1 2 3]);
    isi = repmat(isiTypes, 1, T_num_trial_per_con); 
    isi = Shuffle(isi);
    if isi(trial) == 1
            WaitSecs(T_isi_duration_1);     
        elseif isi(trial) == 2
            WaitSecs(T_isi_duration_2);
        elseif isi(trial) == 3
            WaitSecs(T_isi_duration_3);
    end
    
    % Quit and pause key
    [keyIsDown, secs, keyCode] = KbCheck;
    if find(keyCode) == KbName(QuitKey)
          ppdev_mex('Close',1); % Close port (for triggers)
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
ppdev_mex('Close',1); % Close port (for triggers)
Screen ('CloseAll');
ShowCursor;
ListenChar (0);
Priority(0)