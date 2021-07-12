%% GEN_JOINT_TRAJECTORY_V1 Ver 1 for generating joint trajectories
% Generates oscillatory trajectories for each joint 
% Joint 1 is knee
% Joint 2 is hip_lower
% Joint 3 is hip_upper
% 
% See also GEN_JOINT_TRAJECTORY_V2

%% Setup
clc;clearvars;close all;
% < User input area: begin >
file_name = 'cmd_data_latest_temp.txt';  % File name to write data into
format_specifier = '%f, %d, %f\n';  % Line format
num_j = 1;          % Number of joints the data is being generated for
time_freq = 10;     % Time frequency (for sampling points) (in Hz)
w1 = (2*pi)/(10);   % Frequency for joint 1 (2*pi*f)
a1 = 50;            % Amplitude of oscillation (deg)
% < User input area: end >
time = 0:1/time_freq:30;   % Run everythiong for 10 seconds

%% Generate functions
fnc1 = a1 * sin(w1 * time);

%% Visualize data 
plot(time, fnc1, 'b.');

%% Write in file
fhdlr = fopen(file_name, 'w');
for i = 1:length(time)
    fprintf(fhdlr, format_specifier, time(i), num_j, fnc1(i));
end
fclose(fhdlr);
