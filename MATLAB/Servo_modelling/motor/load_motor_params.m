%% LOAD_MOTOR_PARAMS Loads the motor parameters
% Saves the parameters as motor_params_latest.mat

% Clear data
clc;clearvars;close all;

% Number of gears on the output
No = 230;
% Number of gears on the motor end
Nm = 1;
% Torque constant (in Nm/A)
Kt = 30.2 * 1e-3;   % 30.2 mNm/A (from datasheet)
% Armature Inductance (in H)
La = 0.082 * 1e-3;  % 0.082 mH (from datasheet)
% Armature Resistance (in Ohm)
Ra = 0.299; % 0.299 Ohm (from datasheet)
% Back EMF constant (in V/rps, where rps is Radians per second)
Kv = (1/317) * 60/(2*pi);   % Kw = 317 RPM/V (from datasheet)
% Rotational damping (in Kg m^2 / s)
Dmotor = 0.005;     % Value not given in datasheet
Dgearbox = 0;   % Value not given in datasheet
Dexternal = 0;
D = Dmotor + (Nm / No)^2 * (Dgearbox + Dexternal);    % Total rotational damping (in kg m^2 / s)
% Rotational inertia (in Kg m^2)
Jmotor = 142 * 1e-3 * (1e-2)^2; % Rotor inertia = 142 g cm^2 (from datasheet)
Jgearbox = 16.8 * 1e-3 * (1e-2)^2;  % Gearbox inertia = 16.8 g cm^2 (from datasheet)
Jexternal = 0;  % External loading after the gearbox (in kg m^2)
J = Jmotor + (Nm / No)^2 * (Jgearbox + Jexternal);    % Total rotational inertia (in kg m^2)

save motor_params_latest.mat
