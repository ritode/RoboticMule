%% Visualize the motor profile
%
% Arguments:
%   fname: File name
%       The file must have two columns: time_stamp, position_value
% Returns:
%   vals: A matrix having the readings of the file

function vals = pos_viz(fname)
    vals = load(fname);
    t_vals = vals(:, 1);
    p_vals = vals(:, 2);
    figure;
    plot(t_vals, p_vals, 'r.');
    xlabel('Time');
    ylabel('Position');
    title('Position Vs Time plot');
end