% Return Transformation matrix for DH Parameters chosen
%   Refer Page 1A for more
%   Parameters
%       p1 -> a(i-1) -> Link length -> Z<i-1> to Z<i> along X<i-1>
%       p2 -> al(i-1) -> Link twist -> Z<i-1> to Z<i> along X<i-1>
%       p3 -> d(i) -> Joint displacement -> X<i-1> to X<i> along Z<i>
%       p4 -> th(i) -> Joint angle -> X<i-1> to X<i> along Z<i>
%   All angles are in radians
function tf_mat = DH_tf(p1,p2,p3,p4)
    tf_mat = [
        cos(p4),            -sin(p4),                   0,          p1;
        cos(p2)*sin(p4),     cos(p2)*cos(p4),    -sin(p2),   -p3*sin(p2);
        sin(p2)*sin(p4),     sin(p2)*cos(p4),     cos(p2),    p3*cos(p2);
        0,                   0,                         0,             1;
       ];
    % Modified DH Parameters convention
end
