% Refer to Page 1B for more information
% Get the transformation matrix from base of leg to end effetor (ONLY DH chain) and from
% c.o.m to base of leg
function [leg_rot_tf, leg_tf] = leg_dh(xno, yno)
    m = xno * yno;  % Buffer parameter
    % Symbolic variables
    syms('t1', 't2', 't3'); % Joint angles
    syms('L1', 'L2', 'L3'); % Link lengths
    M1 = DH_tf(0, 0, 0, t1);
    M2 = DH_tf(m * -L1, sym(pi)/2, 0, t2);
    M3 = DH_tf(m * -L2, sym(pi), 0, t3);
    M4 = DH_tf(m * -L3, 0, 0, 0);
    leg_tf = simplify(M1 * M2 * M3 * M4);
    leg_rotmat = [
        0 0 -1 * xno
        0 yno * 1 0
        1 * m 0 0
       ];
   syms('M1', 'M2', 'M3');  % Joint offsets
   leg_dp = [xno * M1; yno * M2; -M3];
   leg_rot_tf = [
       leg_rotmat leg_dp
       zeros(1,3) 1
       ];
end