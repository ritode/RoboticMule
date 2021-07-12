%% LEF_TRAJECTORY_VIZ Leg Trajectory Visualizer
% Visualize joint trajectories given to the system

%% Visualization of the robot following the joint
del_time = time_stamps(2) * 0.5;  % Delay time in animation 
figure('Name', 'Animation');
% Main animation
ef_xpts = [];
ef_ypts = [];
for i = 1:length(time_stamps)
    % Knee position
    kpt = XY_L1_subs(theta_lower_hip(i), theta_knee(i), l1, l2);
    % End effector position
    ept = XY_subs(theta_lower_hip(i), theta_knee(i), l1, l2);
    ef_xpts = [ef_xpts, ept(1)];
    ef_ypts = [ef_ypts, ept(2)];
    % Plot all data for this frame
    plot(0, 0, 'ro'); hold on;
    plot([0,kpt(1)], [0,kpt(2)], 'g--');
    plot(kpt(1), kpt(2), 'ro');
    plot([kpt(1), ept(1)], [kpt(2), ept(2)], 'g--');
    plot(ept(1), ept(2), 'ro');
    plot(ef_xpts, ef_ypts, 'y.');
    hold off;
    xlim([-0.5, l1 + l2]);
    ylim([-(l1+l2), l1+l2]);
    pause(del_time);
end
