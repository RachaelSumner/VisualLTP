%LTP Horizontal Tetanus Script. Rachael Sumner. January 2019.

%Update: Adapted to linux (new triggers using ppdev_mex). Rachael Sumner. March 2020.
%       :  Suresh  M. made  modifications April 2021

% Hold 'p' to pause and 'q' to quit
% 240 trials (120 per grating type)

% Runs on Psychtoolbox-3 http://psychtoolbox.org/

% Requires https://github.com/widmann/ppdev-mex for triggers, else add your
% own and remove all trigger related code.

% To report ISI use your own trigger output - variables for ISI have a
% buffer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%      SCRIPT PERSONALISATION     %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; 
screen_width = 29.8; %Size of screen - will be used to ensure stimuli subtend ~8 degrees of visual angle.
%These calculations are based on sitting 1m away from 53.3cm wide screen
%screen_height = 29.8/1.778; %Might be needed depending on monitor aspect ratio

target = 9; %frequency of stimulus
hz = 60;   %monitor refresh rate CHANGE TO YOUR SCREEN THEN CHANGE JITTER CYCLES
add_jitter = 1; %1 = yes 0 - no jitter+6
jitter_cycles = 1; %how many refreshes to add to make stimulus jitter - a good value depends on hz  (2 for 144 Hz screen)
T_num_trials = 1000; %number of flashes of the stimulus
on = 0.033 %length of time stimulus on for (might need adjusting depending on hz
debug = 0; %set to 0 or 1 

%Derived values
cycle_time = 1/hz; %length of one refresh in seconds
buffer_time =  cycle_time /2; %Half of a refresh cycle - used for queueing flips 

n_refresh = (1/ target) / cycle_time;   %number of refresh rates stim on for (144 is a multiple of 9 - others might need adjusting/rounding) 
isi = (n_refresh * cycle_time)- buffer_time %isi time - buffer

on_time = (ceil((on / cycle_time)) * cycle_time) - buffer_time; %on_time - buffer - might need adjusting for monitor

%%%% TRIAL SPECIFICATIONS

T_isi_duration_1 = isi;
T_isi_duration_2 = isi - (cycle_time * jitter_cycles); % add jitter
T_isi_duration_3 = isi + (cycle_time * jitter_cycles); % sub jitter

%create jitter according to isi -might need adjusting
if add_jitter ==1 
  temp =  [repmat(T_isi_duration_1,1,3) T_isi_duration_2  T_isi_duration_3]; %3 steady, 1 up, 1 down  = packets of 5
  T_isi_vector= []
  
  temp = repmat(temp, 1, 250);
  randomiser = randperm(length(temp));
  T_isi_vector = temp(randomiser);
  
else %no jitter
    T_isi_vector = ones([1 T_num_trials]) * isi;
end
%plot(T_isi_vector)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%% PARADIGM %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%From here things should be reasonably hardware-independent
PsychDefaultSetup(2);

try
    ppdev_mex('Open',1); %initialise triggering
catch
    warning('ppdev_mex did not execute correctly - Any triggers will not work'); 
end

%% %%%BASIC SCREEN SETUP
Priority(1);
ListenChar(2); %prevent keyboard input going to the MATLAB window

screens = Screen('Screens'); %For projecting to external screen. Get the number of screens in the computer setup
screenNumber = max(screens); %Can change to 0 for single screen. Otherwise displays on the most external screen (grab max number)

if debug
    [window, windowRect] = Screen('OpenWindow', screenNumber,[],[0 0 300 300]); %useful for debugging
else
    [window, windowRect] = Screen('OpenWindow', screenNumber);
end

actualhz=Screen('FrameRate', window); %Refresh rate

if abs((actualhz - hz)) > 1
   error('monitor refresh wrong') 
end

HideCursor;

ScreenRect = Screen ('Rect', window);
pixels_width = ScreenRect(3);
pixels_height = ScreenRect(4);
pixels_per_degree = pixels_width/screen_width;

black = BlackIndex(window);  % Retrieves the CLUT color code for black.
white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
grey = white / 2;  % Computes the CLUT color code for grey.

[xCenter, yCenter] = RectCenter(windowRect); %Finds centre of the screen - Used in Screen('DrawDots',...) for fixation dot

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

%% %%TASK
Screen ('FillRect', window, grey);
Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window);
when = VBLTimestamp + 1;

for trial = 1:T_num_trials
    Screen('DrawTexture', window, HorizontalGrating);
    Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
    %Flip the stimulus on
    [VBLTimestamp1 StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window, when);
    lptwrite(1, 2); % Send trigger
    when = VBLTimestamp1 +on_time;
    Screen('DrawDots', window, [xCenter; yCenter], 10, [255 0 0], [], 2);
    %Flip the stimuls off
    [VBLTimestamp2 StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window, when) ;
    when = VBLTimestamp1 + T_isi_vector(trial); %set the next onset time for around the loop 
    lptwrite(1, 0); % Port rest

     % Quit and pause key
    [keyIsDown, secs, keyCode] = KbCheck;
    if find(keyCode) == KbName(QuitKey)
          ppdev_mex('Close',1); %Close port
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

%% %%END
ppdev_mex('Close',1); %Close port
Screen ('CloseAll');
ShowCursor;
ListenChar (0);
Priority(0)