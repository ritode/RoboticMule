%% About file
% This file is to visualize forward and inverse kinematic solutions as well
% as visualize the workspace of a 2R manipulator, which is a simple
% representation of a quadruped leg
% 
% This file requires the following:
% - A file named robot_link_lengths.mat: Which has len1, len2 and len3
% (robot link length parameters)
% This file saves data from operations in a folder named "Backup" at the
% pwd.
%
%% Setup
clc;clearvars;close all;
%% Configuration space
% Begin configuration space

% Robot work limits
% Joint angles
joint_1_min_ang = -45; % Minimum angle for joint 1 (in degrees) (default as -45)
joint_1_max_ang = 45;  % Maximum angle for joint 1 (in degrees) (default as 45)
joint_2_min_ang = -90;   % Minimum angle for joint 2 (in degrees) (default as -90)
joint_2_max_ang = 90;  % Maximum angle for joint 2 (in degrees) (default as 90)
jpres_val = [100 100];  % Resolution for joint 1, joint 2
% Convert degrees to radians
joint_1_min_ang = deg2rad(joint_1_min_ang);
joint_1_max_ang = deg2rad(joint_1_max_ang);
joint_2_min_ang = deg2rad(joint_2_min_ang);
joint_2_max_ang = deg2rad(joint_2_max_ang);
j1_vals = linspace(joint_1_min_ang, joint_1_max_ang, jpres_val(1));
j2_vals = linspace(joint_2_min_ang, joint_2_max_ang, jpres_val(2));
% End configuration space
%% Work
mkdir Backups
% Load forward and inverse kinematic equations and symbols
fk_ik_equs;
load robot_link_lengths.mat
link_len1 = len2;
link_len2 = len3;
% Plot for end points
pts = arrayfun(@(j1, j2) ...
            reshape(XY_subs(j1, j2, link_len1, link_len2), 2, 1), ...
            j1_vals, j2_vals, 'UniformOutput', 0);
pts = cell2mat(pts)';   % Convert to points
xpts = pts(:, 1);
ypts = pts(:, 2);
plot(xpts, ypts, 'r.'); hold on;
xpts_ext = xpts;    % Extreme X points
ypts_ext = ypts;    % Extreme Y points
xpts = zeros(length(j1_vals) * length(j2_vals), 1);
ypts = zeros(length(j1_vals) * length(j2_vals), 1);
% Plot for work space
for i = 1:length(j1_vals)
    for j = 1:length(j2_vals)
        pt = XY_subs(j1_vals(i), j2_vals(j), link_len1, link_len2);
        xpts((i-1) * length(j2_vals) + (j-1) + 1) = pt(1);
        ypts((i-1) * length(j2_vals) + (j-1) + 1) = pt(2);
    end
end
plot(xpts, ypts, 'b.');
xlabel('X axis');
ylabel('Y axis');

%% Saving in backups
save Backups/robot_workspace.mat xpts ypts
save Backups/complete_run.mat