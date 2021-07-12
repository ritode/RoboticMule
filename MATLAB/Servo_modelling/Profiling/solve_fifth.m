function a_vals = solve_fifth(sp, ep, sv, ev, sa, ea, t1)
%SOLVE_FIFTH Solves a fifth degree polynomial equation
% Assume the 5th degree equation to be the following:
%   p(t) = a0 + a1*t + a2*(t^2) + a3*(t^3) + a4*(t^4) + a5*(t^5)
% This function solves for the values of a0, a1, a2, a3, a4 and a5 using
% the constraints given to the function as function arguments.
% Function arguments:
%   sp: Starting position (p at t = 0)
%   ep: Ending position (p at t = t1)
%   sv: Starting velocity (p' at t = 0)
%   ev: Ending velocity (p' at t = t1)
%   sa: Starting acceleration (p'' at t = 0)
%   ea: Ending acceleration (p'' at t = t1)
%   t1: Time duration, time in which motion has to be completed
%
% Through matrix linear algebra, this function computed the parameters and
% returns the values computed for the coefficients in the form of a matrix.
% Function returns:
%   a_vals: A 6x1 vector having values [a0; a1; a2; a3; a4; a5]
%   (coefficients)
%
% Note:
% - Units: It is suggested that you give all units in SI units, that is
% start_p and end_p must be in radians, start_v and end_v must be in rads
% per second and t1 must be in seconds. However, giving your own custom
% units will also generate the coefficients, since the equation will be
% realised in your custom units.
%
% See also SOLVE_CUBIC

% Main program
    A = [
        1 0 0 0 0 0
        0 1 0 0 0 0
        0 0 2 0 0 0
        1 t1 t1^2 t1^3 t1^4 t1^5
        0 1 2*t1 3*t1^2 4*t1^3 5*t1^4
        0 0 2 6*t1 12*t1^2 20*t1^3
        ];
    B = [
        sp
        sv
        sa
        ep
        ev
        ea
        ];
    a_vals = A \ B;     % a_vals = inv(A) * B
end