%% GAIT_WALKING_AL All Leg gait trajectories 
% Code generates walking gait for all legs
%
% See also GEN_JOINT_TRAJECTORY_V2

%% Setup
clc;clearvars;close all;

% <User configuration area: begin >
gait_traj_time = 5;     % Trajectory time for the entire trajectory to be executed in cart. space (in s) [Default: 5]
num_timestamps = 200;   % Number of time stamps
curve_switching_time = (1.5)/(4.5) * gait_traj_time; % Switch curve after _ time (in s)
stride_len = 0.25;   % Stride length (in m)
stride_lift_height = 0.15;   % Lift height (in m)
x_offs = 701 ./ 1000;   % Offset in X (downward, towards the ground) (in m)
y_offs = 10 ./ 1000;    % Offset in Y (forwards, towards +X of robot) (in m)
rot_Z = deg2rad(90);    % Rotation along Z axis (to get it aligned in X, Y of the leg)
config = 0;             % Configuration for solver (0 for lower arm and 1 for upper arm)
phase_shift_lf = 0/4.5;     % Phase shift in left forward leg (in percentage)
mul_factor_lf = [0, 1, -1];   % Multiplication factors for LF (upper hip, lower hip, knee)
phase_shift_lh = 3/4.5;     % Phase shift in left hind leg (in percentage)
mul_factor_lh = [0, 1, -1];   % Multiplication factors for LH (upper hip, lower hip, knee)
phase_shift_rh = 1/4.5;     % Phase shift in right hind leg (in percentage)
mul_factor_rh = [0, -1, 1];   % Multiplication factors for RH (upper hip, lower hip, knee)
phase_shift_rf = 2/4.5;     % Phase shift in right front leg (in percentage)
mul_factor_rf = [0, -1, 1];   % Multiplication factors for RF (upper hip, lower hip, knee)
% <User configuration area: end >

% Generate trajectory profile
time_stamps = linspace(0, gait_traj_time, num_timestamps);
t_curve_switch_ind = find(time_stamps > curve_switching_time, 1);   % Index for switching time
t_parabola = time_stamps(1:t_curve_switch_ind);
x_para = linspace(0, stride_len, length(t_parabola));
y_para = -x_para .* (x_para - stride_len) .* (4/(stride_len^2)) .* (stride_lift_height);    % Equation for parabola
% Straight line
t_st_line = time_stamps(t_curve_switch_ind + 1:end);
x_line = linspace(stride_len, 0, length(t_st_line));
y_line = zeros(size(x_line));
% Final curve (in untransformed frame, gen frame - utf)
x_vals_utf = [x_para, x_line];
y_vals_utf = [y_para, y_line];
% Transform points
tf_mat = [
    cos(rot_Z) -sin(rot_Z) x_offs
    sin(rot_Z) cos(rot_Z) y_offs
    0 0 1
    ];
tf_point = @(x, y) tf_mat * [x;y;1];    % Transform a point from gen frame to 2R frame
x_vals_tf = zeros(size(x_vals_utf));
y_vals_tf = zeros(size(y_vals_utf));
for i = 1:length(time_stamps)
    tf_pt = tf_point(x_vals_utf(i), y_vals_utf(i));
    x_vals_tf(i) = tf_pt(1);
    y_vals_tf(i) = tf_pt(2);
end
% Load robot workspace points to compare with them
load robot_workspace.mat
xpts = xpts ./ 1000;
ypts = ypts ./ 1000;
% Visualize the curve generated
figure('Name','Point Visualization - Walking gait');
% Show untransformed points
subplot(2,2,1);
scatter(x_vals_utf, y_vals_utf, 25, time_stamps, 'filled');
colorbar;
title('Visualization plot (Gen frame)');
% Show transformed points
subplot(2,2,2);
scatter(x_vals_tf, y_vals_tf, 25, time_stamps, 'filled');
colorbar;
title('Visualization plot (2R frame)');
% Show workspace
subplot(2,2,3);
plot(xpts, ypts, 'b.');
xlabel('X');
ylabel('Y');
title('Workspace');
% Show workspace and transformed points in 2R frame
subplot(2,2,4);
plot(xpts, ypts, 'b.'); hold on;
xlabel('X');
ylabel('Y');
scatter(x_vals_tf, y_vals_tf, 25, time_stamps, 'filled');
colorbar;
title('Workspace and points (2R frame)');

%% Use inverse kinematics and get joint angles
% Load models
load fk_ik_equations.mat
load robot_link_lengths.mat
len1 = len1 ./ 1000;
len2 = len2 ./ 1000;
len3 = len3 ./ 1000;
% Link1_len (l1) and Link2_len (l2) for the FK and IK model
l1 = len2;
l2 = len3;
% Generate theta values using IK
theta_lower_hip = zeros(size(time_stamps));
theta_knee = zeros(size(time_stamps));
for i = 1:length(time_stamps)
    angles = mt1t2_subs(x_vals_tf(i), y_vals_tf(i), l1, l2);
    m = angles(1);
    t1 = angles(2);
    t2 = angles(3);
    % Get lower and upper arm solutions
    sols = leg_config_solver(m, t1, t2);
    if config == 0
        % Lower arm
        theta_lower_hip(i) = sols{1}(1, 2);
        theta_knee(i) = sols{1}(1, 3);
    else
        % Upper arm
        theta_lower_hip(i) = sols{1}(2, 2);
        theta_knee(i) = sols{1}(2, 3);
    end
end
theta_lower_hip_degrees = arrayfun(@(ang) rad2deg(ang), theta_lower_hip);
theta_knee_degrees = arrayfun(@(ang) rad2deg(ang), theta_knee);
% Visualize the joint values
figure('Name', 'Joint angles (idel leg) - Walking gait');
subplot(3, 1, 1);
plot(time_stamps, theta_lower_hip_degrees, 'b.');
title('Theta (Lower hips)');
subplot(3, 1, 2);
plot(time_stamps, theta_knee_degrees, 'r.');
title('Theta (Knee)');
subplot(3, 1, 3);
plot(time_stamps, theta_lower_hip_degrees, 'b.'); hold on;
plot(time_stamps, theta_knee_degrees, 'r.');
title('Theta (both)');

%% Generate trajectories for individual legs
% Left front
split_lf_tind = floor(phase_shift_lf * num_timestamps) + 1;
theta_lf_lower_hip = [theta_lower_hip(end-(split_lf_tind-1):end), ...
               theta_lower_hip(1:length(theta_lower_hip)-split_lf_tind)];
theta_lf_knee = [theta_knee(end-(split_lf_tind-1):end), ...
               theta_knee(1:length(theta_knee)-split_lf_tind)];
% Left hind
split_lh_tind = floor(phase_shift_lh * num_timestamps) + 1;
theta_lh_lower_hip = [theta_lower_hip(end-(split_lh_tind-1):end), ...
               theta_lower_hip(1:length(theta_lower_hip)-split_lh_tind)];
theta_lh_knee = [theta_knee(end-(split_lh_tind-1):end), ...
               theta_knee(1:length(theta_knee)-split_lh_tind)];
% Right hind
split_rh_tind = floor(phase_shift_rh * num_timestamps) + 1;
theta_rh_lower_hip = [theta_lower_hip(end-(split_rh_tind-1):end), ...
               theta_lower_hip(1:length(theta_lower_hip)-split_rh_tind)];
theta_rh_knee = [theta_knee(end-(split_rh_tind-1):end), ...
               theta_knee(1:length(theta_knee)-split_rh_tind)];
% Right front
split_rf_tind = floor(phase_shift_rf * num_timestamps) + 1;
theta_rf_lower_hip = [theta_lower_hip(end-(split_rf_tind-1):end), ...
               theta_lower_hip(1:length(theta_lower_hip)-split_rf_tind)];
theta_rf_knee = [theta_knee(end-(split_rf_tind-1):end), ...
               theta_knee(1:length(theta_knee)-split_rf_tind)];
% Upper hip angles (all 0 for now)
theta_lf_upper_hip = zeros(size(theta_lf_lower_hip));
theta_lh_upper_hip = zeros(size(theta_lh_lower_hip));
theta_rf_upper_hip = zeros(size(theta_rf_lower_hip));
theta_rh_upper_hip = zeros(size(theta_rh_lower_hip));
% Visualize the values
figure('Name', 'Joint data (Multiplication factor not adjusted) - Walking gait');
subplot(2,2,1);
plot(time_stamps, rad2deg(theta_lf_upper_hip), 'g.'); hold on;
plot(time_stamps, rad2deg(theta_lf_lower_hip), 'b.'); hold on;
plot(time_stamps, rad2deg(theta_lf_knee), 'r.');
legend('UH', 'LH', 'K');
title('Left Front');
subplot(2,2,3);
plot(time_stamps, rad2deg(theta_lh_upper_hip), 'g.'); hold on;
plot(time_stamps, rad2deg(theta_lh_lower_hip), 'b.'); hold on;
plot(time_stamps, rad2deg(theta_lh_knee), 'r.');
legend('UH', 'LH', 'K');
title('Left Hind');
subplot(2,2,4);
plot(time_stamps, rad2deg(theta_rh_upper_hip), 'g.'); hold on;
plot(time_stamps, rad2deg(theta_rh_lower_hip), 'b.'); hold on;
plot(time_stamps, rad2deg(theta_rh_knee), 'r.');
legend('UH', 'LH', 'K');
title('Right Hind');
subplot(2,2,2);
plot(time_stamps, rad2deg(theta_rf_upper_hip), 'g.'); hold on;
plot(time_stamps, rad2deg(theta_rf_lower_hip), 'b.'); hold on;
plot(time_stamps, rad2deg(theta_rf_knee), 'r.');
legend('UH', 'LH', 'K');
title('Right Front');


%% Multiplication factor adjustment (for mirroring joint angles)
% Multiply by the multiplication factors and get final joint angles
% (multiplication factors are quadruped specific) [Use variables with _vals
% to upload to file hereon]
% Left front
theta_lf_upper_hip_vals = mul_factor_lf(1) .* theta_lf_upper_hip;
theta_lf_lower_hip_vals = mul_factor_lf(2) .* theta_lf_lower_hip;
theta_lf_knee_vals = mul_factor_lf(3) .* theta_lf_knee;
% Left hind
theta_lh_upper_hip_vals = mul_factor_lh(1) .* theta_lh_upper_hip;
theta_lh_lower_hip_vals = mul_factor_lh(2) .* theta_lh_lower_hip;
theta_lh_knee_vals = mul_factor_lh(3) .* theta_lh_knee;
% Right hind
theta_rh_upper_hip_vals = mul_factor_rh(1) .* theta_rh_upper_hip;
theta_rh_lower_hip_vals = mul_factor_rh(2) .* theta_rh_lower_hip;
theta_rh_knee_vals = mul_factor_rh(3) .* theta_rh_knee;
% Right front
theta_rf_upper_hip_vals = mul_factor_rf(1) .* theta_rf_upper_hip;
theta_rf_lower_hip_vals = mul_factor_rf(2) .* theta_rf_lower_hip;
theta_rf_knee_vals = mul_factor_rf(3) .* theta_rf_knee;
% Convert all of them to degrees
% Left front
theta_lf_upper_hip_vals = rad2deg(theta_lf_upper_hip_vals);
theta_lf_lower_hip_vals = rad2deg(theta_lf_lower_hip_vals);
theta_lf_knee_vals = rad2deg(theta_lf_knee_vals);
% Left hind
theta_lh_upper_hip_vals = rad2deg(theta_lh_upper_hip_vals);
theta_lh_lower_hip_vals = rad2deg(theta_lh_lower_hip_vals);
theta_lh_knee_vals = rad2deg(theta_lh_knee_vals);
% Right hind
theta_rh_upper_hip_vals = rad2deg(theta_rh_upper_hip_vals);
theta_rh_lower_hip_vals = rad2deg(theta_rh_lower_hip_vals);
theta_rh_knee_vals = rad2deg(theta_rh_knee_vals);
% Right front
theta_rf_upper_hip_vals = rad2deg(theta_rf_upper_hip_vals);
theta_rf_lower_hip_vals = rad2deg(theta_rf_lower_hip_vals);
theta_rf_knee_vals = rad2deg(theta_rf_knee_vals);
% Visualize the values
figure('Name', 'Joint data (Multiplication factor adjusted) - Walking gait');
subplot(2,2,1);
plot(time_stamps, theta_lf_upper_hip_vals, 'g.'); hold on;
plot(time_stamps, theta_lf_lower_hip_vals, 'b.'); hold on;
plot(time_stamps, theta_lf_knee_vals, 'r.');
legend('UH', 'LH', 'K');
title('Left Front');
subplot(2,2,3);
plot(time_stamps, theta_lh_upper_hip_vals, 'g.'); hold on;
plot(time_stamps, theta_lh_lower_hip_vals, 'b.'); hold on;
plot(time_stamps, theta_lh_knee_vals, 'r.');
legend('UH', 'LH', 'K');
title('Left Hind');
subplot(2,2,4);
plot(time_stamps, theta_rh_upper_hip_vals, 'g.'); hold on;
plot(time_stamps, theta_rh_lower_hip_vals, 'b.'); hold on;
plot(time_stamps, theta_rh_knee_vals, 'r.');
legend('UH', 'LH', 'K');
title('Right Hind');
subplot(2,2,2);
plot(time_stamps, theta_rf_upper_hip_vals, 'g.'); hold on;
plot(time_stamps, theta_rf_lower_hip_vals, 'b.'); hold on;
plot(time_stamps, theta_rf_knee_vals, 'r.');
legend('UH', 'LH', 'K');
title('Right Front');

%% Save everything
save gait_walking_al_data.mat
