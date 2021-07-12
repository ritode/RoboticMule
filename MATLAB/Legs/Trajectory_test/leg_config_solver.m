%% Leg configuration slver
% Pass the three angles as parameters:
%   alpha: Mean angle (in radians); The angle (x,y) subtends at the origin 
%          along with X axis
%   t1: Theta1 (in radians) (joint 1 angle)
%   t2: Theta2 (in radians) (joint 2 angle)
% This function returns the following:
% - The passed angles are for upper elbow or lower elbow solution
% - The upper and the lower elbow solutions for the robot
% Returns object sols (1 by 2 cell)
%   sols{1}: Upper and lower elbow solutions
%       It contains a 2 by 3 solution, 1st row is lower arm and 2nd row is
%       upper arm solutions. Column 1 is same for both (alpha), column 2 is
%       theta1 and column 3 is theta2
%   sols{2}: The passed angles were for upper or lower elbow / arm
%       It contains a 2 by 1 matrix, [1;0] if lower elbow, [0;1] if upper
%       elbow.
%   Special cases:
%       - Singularity: This means that the arm is at the extreme, sols{2}
%       is [0;0] then and sols{1} is invalid.

function sols = leg_config_solver(alpha, t1, t2)
    sols = cell(2,1);
    sols{1} = zeros(2,3);   % Row 1 for lower arm, 2 for upper arm
    % Check if lower elbow or upper elbow
    if (t1 < alpha)
        % Passed solution is lower elbow
        sols{2} = [1;0];
        sols{1}(1, :) = [alpha, t1, t2];
        % Calculate the upper arm equivalent angles
        ua_alpha = alpha;
        del_t1 = alpha - t1;    % Delta theta
        ua_t1 = alpha + del_t1; % Upper arm theta 1 (has to be greater)
        assert(t2 > 0, 'Invalid results by IK solver'); % theta2 is positive for lower arm
        ua_t2 = -t2;    % theta2 is negative for upper arm
        sols{1}(2, :) = [ua_alpha, ua_t1, ua_t2];   % Upper arm solutions
    elseif (t1 > alpha)
        % Passed solution is upper elbow
        sols{2} = [0;1];
        sols{1}(2, :) = [alpha, t1, t2];
        % Calculate the lower arm equivalent angles
        la_alpha = alpha;
        del_t1 = t1 - alpha;    % Delta theta
        la_t1 = alpha - del_t1; % Lower arm theta 1 (has to be lesser)
        assert(t2 < 0, 'Invalid results by IK solver'); % theta2 is negative for upper arm
        la_t2 = -t2;    % theta2 is positive for lower arm
        sols{1}(1, :) = [la_alpha, la_t1, la_t2];
    elseif (t1 == alpha)
        % Singularity
        sols{2} = [0;0];
    else
        % Invalid case
    end
    
    
end