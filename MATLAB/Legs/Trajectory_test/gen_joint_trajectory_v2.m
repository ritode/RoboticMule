%% GEN_JOINT_TRAJECTORY_V2 Ver 2 for generating joint trajectories
% Generates the parabolic and straight line profile for a single leg
% (allows the user to choose upper arm or lower arm configuration)
%
% Just to test the proof of concept
% See also GEN_JOINT_TRAJECTORY_V1

%% Setup
clc;clearvars;close all;
%% Generate curve
% < User configuration area: begin >
max_time = 5;      % Maximum time for the profile (in s)
num_timestamps = 100;   % Number of time stamps
curve_switching_time = 0.6 * max_time;   % Switch curve after _ time (in s)
stride_len = 0.2;   % Stride length (in m)
stride_lift_height = 0.1;   % Lift height (in m)
x_offs = 701 ./ 1000;   % Offset in X (downward, towards the ground) (in m)
y_offs = 50 ./ 1000;    % Offset in Y (forwards, towards +X of robot) (in m)
rot_Z = deg2rad(90);    % Rotation along Z axis (to get it aligned in X, Y of the leg)
config = 0;             % Configuration for solver (0 for lower arm and 1 for upper arm)
% < User configuration area: end >
t = linspace(0, max_time, num_timestamps);   % Time stamps
curve_sw_prof = find(t > curve_switching_time, 1); % Switch profile after 6 seconds
% Parabola
t_parabola = t(1:curve_sw_prof);
x_para = linspace(0, stride_len, length(t_parabola));
y_para = -x_para .* (x_para - stride_len) .* (4/(stride_len^2)) .* (stride_lift_height);    % Equation for parabola
% Straight line
t_st_line = t(curve_sw_prof + 1: end);
x_line = linspace(stride_len, 0, length(t_st_line));
y_line = zeros(size(x_line));
% Final curve (in untransformed frame - utf)
time_stamps = t;
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
figure('Name','Point Visualization');
% Show untransformed points
subplot(2,2,1);
scatter(x_vals_utf, y_vals_utf, 25, time_stamps, 'filled');
colorbar;
title('Visualization plot (Gen frame)');
% Show transformed points
subplot(2,2,2);
% figure;
scatter(x_vals_tf, y_vals_tf, 25, time_stamps, 'filled');
colorbar;
title('Visualization plot (2R frame)');
% Show workspace
subplot(2,2,3);
% figure;
plot(xpts, ypts, 'b.');
xlabel('X');
ylabel('Y');
title('Workspace');
% Show workspace and transformed points in 2R frame
subplot(2,2,4);
% figure;
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
figure('Name', 'Joint angles');
subplot(3, 1, 1);
plot(time_stamps, theta_lower_hip_degrees, 'b.');
title('Theta (Lower hips)');
subplot(3, 1, 2);
% figure;
plot(time_stamps, theta_knee_degrees, 'r.');
title('Theta (Knee)');
subplot(3, 1, 3);
% figure;
plot(time_stamps, theta_lower_hip_degrees, 'b.'); hold on;
plot(time_stamps, theta_knee_degrees, 'r.');
title('Theta (both)');

%% Visualization of the robot following the joint
del_time = time_stamps(2) * 0.5;  % Delay time in animation 
figure('Name', 'Animation');
% Main animation
ef_xpts = [];
ef_ypts = [];
for i = 1:length(time_stamps)
    % Knee position
    kpt = XY_L1_subs(theta_lower_hip(i), theta_knee(i), l1, l2);
    % End effector position
    ept = XY_subs(theta_lower_hip(i), theta_knee(i), l1, l2);
    ef_xpts = [ef_xpts, ept(1)];
    ef_ypts = [ef_ypts, ept(2)];
    % Plot all data for this frame
    plot(0, 0, 'ro'); hold on;
    plot([0,kpt(1)], [0,kpt(2)], 'g--');
    plot(kpt(1), kpt(2), 'ro');
    plot([kpt(1), ept(1)], [kpt(2), ept(2)], 'g--');
    plot(ept(1), ept(2), 'ro');
    plot(ef_xpts, ef_ypts, 'y.');
    hold off;
    xlim([-0.5, l1 + l2]);
    ylim([-(l1+l2), l1+l2]);
    pause(del_time);
end

%% Show the followed and actual trajectory 
figure('Name', 'Trajectory compare');
subplot(2,2,1);
scatter(x_vals_tf, y_vals_tf, 25, time_stamps, 'filled');
colorbar;
title('Desired points');
subplot(2,2,3);
scatter(ef_xpts, ef_ypts, 25, time_stamps, 'filled');
colorbar;
title('End effector');
subplot(2,2,[2,4]);
plot(x_vals_tf, y_vals_tf, 'r.'); hold on;
plot(ef_xpts, ef_ypts, 'go');
title('Both');
