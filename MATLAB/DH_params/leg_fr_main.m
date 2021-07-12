%% Setup
clc;clearvars;close all;
%% DH and Base frame conventions
% Leg 1
[bf_tf_1, dh_tf_1] = leg_dh(1, 1);
disp(' ========= Information for Leg 1 ============')
disp(' Base frame transformation to leg frame ')
disp(bf_tf_1)
disp(' DH Parameter transformation from leg frame ')
disp(dh_tf_1)
disp(' Final transformation ')
Tf_leg1 = simplify(bf_tf_1 * dh_tf_1);
disp(Tf_leg1)
input('Press Enter to proceed')
% Leg 2
[bf_tf_2, dh_tf_2] = leg_dh(-1, 1);
disp(' ========= Information for Leg 2 ============')
disp(' Base frame transformation to leg frame ')
disp(bf_tf_2)
disp(' DH Parameter transformation from leg frame ')
disp(dh_tf_2)
disp(' Final transformation ')
Tf_leg2 = simplify(bf_tf_2 * dh_tf_2);
disp(Tf_leg2)
input('Press Enter to proceed')
% Leg 3
[bf_tf_3, dh_tf_3] = leg_dh(-1, -1);
disp(' ========= Information for Leg 3 ============')
disp(' Base frame transformation to leg frame ')
disp(bf_tf_3)
disp(' DH Parameter transformation from leg frame ')
disp(dh_tf_3)
disp(' Final transformation ')
Tf_leg3 = simplify(bf_tf_3 * dh_tf_3);
disp(Tf_leg3)
input('Press Enter to proceed')
% Leg 4
[bf_tf_4, dh_tf_4] = leg_dh(1, -1);
disp(' ========= Information for Leg 4 ============')
disp(' Base frame transformation to leg frame ')
disp(bf_tf_4)
disp(' DH Parameter transformation from leg frame ')
disp(dh_tf_4)
disp(' Final transformation ')
Tf_leg4 = simplify(bf_tf_4 * dh_tf_4);
disp(Tf_leg4)
input('Press Enter to proceed')

%% End
% Create symbols (for future use of equations)
syms('M1', 'M2', 'M3');  % Joint offsets
syms('t1', 't2', 't3'); % Joint angles
syms('L1', 'L2', 'L3'); % Link lengths
disp('Program ended');