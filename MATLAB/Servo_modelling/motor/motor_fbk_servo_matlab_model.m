%%MOTOR_FBK_SERVO_MATLAB_MODEL Motor + Servo modelled in MATLAB
%
%
%
% See also MOTOR_MATLAB_MODEL_V1

%% Setup
clc;clearvars;close all;
% Load values
load motor_params_latest.mat;
syms s t;
time_vals = 0:0.005:5;  % Time values
% < User configuration area: begin >
input = 24; % Input Voltage (differential) = 24 volts
% < User configuration area: end >

%% Motor transfoer function
motor_tf = (Nm/No) * (Kt / (La*J*s^2 + (La*D + Ra*J)*s + (Ra*D + Kt*Kv)));
input_V = laplace(sym(input));

output_speed_laplace = motor_tf * input_V;
output_speed = ilaplace(output_speed_laplace);
output_speed_vals = double(subs(output_speed, t, time_vals));   % In rad per sec
output_speed_RPM = output_speed_vals * (60/(2*pi)) ;

%% Visualization of results
plot(time_vals, output_speed_RPM);

