%%MOTOR_VOLTAGE_VS_RPM Motor Voltage Vs RPM plot
% Plots the Supply Voltage Vs RPM graph for the given motor
% Requires an excel file with the following headers:
%     'Supply Voltage'    'Time_1R'    'Time_5R'    'Time_10R'
%     'Supply Voltage': Supply voltage to motor
%     'Time_1R': Time taken to complete one revolution
%     'Time_5R': Time taken to complete five revolutions
%     'Time_10R': Time taken to complete ten revolutions
%
% See also XLSREAD

%% Program setup
clc;clearvars;close all;

% <User editable area: begin>
[vals, headers, raw_data] = xlsread('speed_data\voltage_vs_rev_time.xlsx');
% <User editable area: end>

% Get voltages
v_vals = vals(:, 1);
v_vals = flip(v_vals);
% Time using mean averaging
t_mean_vals = (vals(:, 2) + vals(:, 3)/5 + vals(:, 4)/10)/3;
t_mean_vals = flip(t_mean_vals);
rpm_tm_vals = 1 ./ (t_mean_vals .* (1 ./60));     % RPM 1
% Time using weighed averaging
t_wmean_vals = (vals(:, 2) + vals(:, 3) + vals(:, 4))/(1 + 5 + 10);
t_wmean_vals = flip(t_wmean_vals);
rpm_twm_vals = 1 ./ (t_wmean_vals .* (1 ./60));   % RPM 2
% Through visual inspection, chose the weighed averaging for having a
% better fit
tb1 = table(v_vals, rpm_twm_vals, 'VariableNames', {'Voltage', 'RPM'});
lm = fitlm(tb1);
coeffs = lm.Coefficients.Estimate;
fprintf('Speed constant is (in RPM / Volt) %f\n', coeffs(2));

%% Visualize data
figure('Name', 'Speed constant comparison');
subplot(2, 2, 1);
plot(v_vals, rpm_tm_vals, 'r');
subplot(2, 2, 2);
plot(v_vals, rpm_twm_vals, 'b');
subplot(2, 2, [3, 4]);
plot(v_vals, rpm_tm_vals, 'r'); hold on;
plot(v_vals, rpm_twm_vals, 'b');
legend('Direct mean', 'Weighed mean');
figure('Name', 'Speed Constant');
plot(v_vals, rpm_twm_vals, 'b');
xlabel('Voltage (V)');
ylabel('RPM');