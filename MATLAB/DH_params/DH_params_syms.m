% DH Parameters of a single leg using symbols
%   Have used Modified DH Parameter convention and performed forward
%   kinematics using that.
%   Refer to Page 1A for convention, placement of frames and equations
%   (result of what's the output here)

clc;clearvars;close all;

format short
% Theta values
syms t1 t2 t3
% Length values
syms L1 L2 L3
% Matrices
M1 = DH_tf(0, 0, 0, t1);
M2 = simplify(DH_tf(-L1, sym(pi/2), 0, t2));
M3 = simplify(DH_tf(-L2, sym(pi), 0, t3));
M4 = simplify(DH_tf(-L3, 0, 0, 0));
% Results
disp('M1 = '); disp(M1);
disp('M2 = '); disp(M2);
disp('M3 = '); disp(M3);
disp('M4 = '); disp(M4);
disp('Simplified Equations (till the knee)')
disp(simplify(M1 * M2 * M3))
disp('Simplefied Equations (till the end effector) [result]')
result = simplify(M1 * M2 * M3 * M4);
disp(result)