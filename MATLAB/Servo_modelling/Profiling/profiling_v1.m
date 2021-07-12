%% PROFILING_V1 Display cubic and fifth degree profiling curves
% Run using the following command
%       profiling_v1
% 
% In the end, you'll have plots for 3rd and 5th degree curves
% The coefficients for 3rd degree polynomial are stored in third_deg_coeffs
% 5th degree polynomial are stored in fifth_deg_coeffs (ascending order of degree)
% 
% See also SOLVE_CUBIC, SOLVE_FIFTH

%% Setup
clc;clearvars;close all;

%% Curve parameters
start_angle = 0;    % Start angle (in degrees) (default = 0)
end_angle = 90;     % End angle (in degrees) (default = 90)
start_vel = 0;      % Starting angular velocity (in degrees per second) (default = 0)
end_vel = 0;        % Ending angular velocity (in degrees per second) (default = 0)
start_accl = 0;     % Starting acceleration (in deg per s^2) (default = 0)
end_accl = 0;       % Ending acceleration (in deg per s^2) (default = 0)
time = 0.5;         % Time to complete the motion (in seconds) (default = 0.5)
% Convert to SI
start_angle = deg2rad(start_angle);
end_angle = deg2rad(end_angle);
start_vel = deg2rad(start_vel);
end_vel = deg2rad(end_vel);
start_accl = deg2rad(start_accl);
end_accl = deg2rad(end_accl);

%% Cubic profiling
% Get coefficients
a_vals = solve_cubic(start_angle, end_angle, start_vel, end_vel, time);
a0 = a_vals(1);
a1 = a_vals(2);
a2 = a_vals(3);
a3 = a_vals(4);
third_deg_coeffs = a_vals;
% Profiling equation
f1_eq = @(t) a0 + a1 * t + a2 * t^2 + a3 * t^3;
% Generating the data
t_vals = linspace(0, 0.5, 1000)';
p_vals = arrayfun(@(t) f1_eq(t), t_vals);    % Position
p_vals_deg = p_vals * 180 / pi;     % Position in deg
w_vals = [diff(p_vals); 0];      % Speed
w_vals_deg_sec = w_vals * 180 / pi; % Speed in deg per second
a_vals = [diff(w_vals); 0];     % Acceleration
a_vals_deg_sec2 = a_vals * 180 / pi;    % Acceleration in deg per sec ^ 2
% Plot position
figure('Name', 'Cubic Profiling');
subplot(311);
plot(t_vals, p_vals_deg, 'c.');
title('Position plot');
xlabel('Time');
ylabel('Position');
grid on;
% Plot velocity
subplot(312);
plot(t_vals, w_vals_deg_sec, 'b.');
title('Speed plot');
xlabel('Time');
ylabel('Velocity');
grid on;
% Plot acceleration
subplot(313);
plot(t_vals, a_vals_deg_sec2, 'r.');
title('Acceleration plot');
xlabel('Time');
ylabel('Acceleration');
grid on;

%% Fifth degree profiling
% Get coefficients
a_vals = solve_fifth(start_angle, end_angle, ...
                     start_vel, end_vel, ...
                     start_accl, end_accl, time);
a0 = a_vals(1);
a1 = a_vals(2);
a2 = a_vals(3);
a3 = a_vals(4);
a4 = a_vals(5);
a5 = a_vals(6);
fifth_deg_coeffs = a_vals;
% Profiling equation
f2_eq = @(t) a0 + a1 * t + a2 * t^2 + a3 * t^3 + a4 * t^4 + a5 * t^5;
% Generating the data
t_vals = linspace(0, 0.5, 1000)';
p_vals = arrayfun(@(t) f2_eq(t), t_vals);    % Position
p_vals_deg = p_vals * 180 / pi;     % Position in deg
w_vals = [diff(p_vals); 0];      % Speed
w_vals_deg_sec = w_vals * 180 / pi; % Speed in deg per second
a_vals = [diff(w_vals); 0];     % Acceleration
a_vals_deg_sec2 = a_vals * 180 / pi;    % Acceleration in deg per sec ^ 2
% Plot position
figure('Name', 'Fifth degree Profiling');
subplot(311);
plot(t_vals, p_vals_deg, 'c.');
title('Position plot');
xlabel('Time');
ylabel('Position');
grid on;
% Plot velocity
subplot(312);
plot(t_vals, w_vals_deg_sec, 'b.');
title('Speed plot');
xlabel('Time');
ylabel('Velocity');
grid on;
% Plot acceleration
subplot(313);
plot(t_vals, a_vals_deg_sec2, 'r.');
title('Acceleration plot');
xlabel('Time');
ylabel('Acceleration');
grid on;
