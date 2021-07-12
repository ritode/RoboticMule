function a_vals = solve_cubic(start_p, end_p, start_v, end_v, t1)
%SOLVE_CUBIC Solves a cubic equation
% Assume the cubic function to be the following:
%   p(t) = a0 + a1*t + a2*(t^2) + a3*(t^3)
% This function solves for the values of a0, a1, a2 and a3 using the
% constraints given to the function. The constraints are given as
% parameters (refer to parameters / function arguments)
% Function arguments:
%   start_p: Starting position (p at t = 0)
%   end_p: Ending position (p at t = t1)
%   start_v: Starting velocity (p' at t = 0)
%   end_v: Ending velocity (p' at t = t1)
%   t1: Time duration, time in which motion has to be completed
% 
% Through matrix linear algebra, this function computes the parameters and
% returns the values computed for the coefficients in the form of a matrix
% (refer to returns)
% Function returns:
%   a_vals: A 4x1 vector having values [a0; a1; a2; a3] (coefficients)
%
% Note:
% - Units: It is suggested that you give all units in SI units, that is
% start_p and end_p must be in radians, start_v and end_v must be in rads
% per second and t1 must be in seconds. However, giving your own custom
% units will also generate the coefficients, since the equation will be
% realised in your custom units.
%
% See also: INV

% Main function code
    A = [
        1 0 0 0
        1 t1 t1^2 t1^3
        0 1 0 0
        0 1 2*t1 3*t1^2
        ];
    B = [
        start_p
        end_p
        start_v
        end_v
        ];
    a_vals = A \ B;     % a_vals = inv(A) * B
end