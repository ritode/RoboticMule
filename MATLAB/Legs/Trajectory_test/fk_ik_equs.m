%% Setup
clc;clearvars;close all;
%% Forward kinematics model
syms('T1', 'T2');   % Joint angles
syms('L1', 'L2');   % Link lengths
% Equations
X_L1 = L1 * cos(T1);
Y_L1 = L1 * sin(T1);
X = L1 * cos(T1) + L2 * cos(T1 + T2);
Y = L1 * sin(T1) + L2 * sin(T1 + T2);
% Substitute in X and Y
X_subs = @(theta1, theta2, len1, len2) double(subs(X, [T1, T2, L1, L2], ...
                                        [theta1, theta2, len1, len2]));
Y_subs = @(theta1, theta2, len1, len2) double(subs(Y, [T1, T2, L1, L2], ...
                                        [theta1, theta2, len1, len2]));
X_L1_subs = @(theta1, theta2, len1, len2) double(subs(X_L1, ...
              [T1, T2, L1, L2], [theta1, theta2, len1, len2]));
Y_L1_subs = @(theta1, theta2, len1, len2) double(subs(Y_L1, ...
              [T1, T2, L1, L2], [theta1, theta2, len1, len2]));
% Substitute in for [X, Y]
XY_subs = @(theta1, theta2, len1, len2) [ ...
                    X_subs(theta1, theta2, len1, len2), ...
                    Y_subs(theta1, theta2, len1, len2)];
XY_L1_subs = @(theta1, theta2, len1, len2) [ ...
                X_L1_subs(theta1, theta2, len1, len2), ...
                Y_L1_subs(theta1, theta2, len1, len2)];
            

%% Inverse Kinematics model
syms('x', 'y');  % Points in inverse kinematics
r = (x^2 + y^2)^(0.5);  % Distance from (x, y)
alpha = atan(y/x);  % Origin to point (x, y) --- Mean line
% Equations (for inverse kinematics)
t2 = acos((r^2 - (L1^2 + L2^2))/(2*L1*L2));
t1 = alpha - acos((r^2 + L1^2 - L2^2)/(2*r*L1));
% Substitution for t1 and t2
alpha_subs = @(x_val, y_val) double(subs(alpha, [x, y], [x_val, y_val]));
t1_subs = @(x_val, y_val, len1, len2) double(subs(t1, [x, y, L1, L2], ...
                                    [x_val, y_val, len1, len2]));
t2_subs = @(x_val, y_val, len1, len2) double(subs(t2, [x, y, L1, L2], ...
                                    [x_val, y_val, len1, len2]));
% Substitution for [t1, t2]
t1t2_subs = @(x_val, y_val, len1, len2) [ ...
                    t1_subs(x_val, y_val, len1, len2), ...
                    t2_subs(x_val, y_val, len1, len2)];
% Substitution for [alpha, t1, t2]
mt1t2_subs = @(x_val, y_val, len1, len2) [ ...
                    alpha_subs(x_val, y_val), ...
                    t1_subs(x_val, y_val, len1, len2), ...
                    t2_subs(x_val, y_val, len1, len2)];

save fk_ik_equations.mat
