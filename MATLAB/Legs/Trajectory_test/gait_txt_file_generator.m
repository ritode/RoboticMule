%% GAIT_TXT_FILE_GENERATOR Generate txt data file for gait

% Setup
clc;clearvars;close all;
% <User configuration area: begin>
% Load gait file
load gait_walking_al_data.mat
% Parameters
date_str = datestr(now, 'ddd_dd_mmm_yy_HH_MM_SS')
data_file_name = sprintf('data/cmd_data_%s.txt', date_str);
adj_data_file_name = sprintf('data/adj_data_%s.txt', date_str);
gait_data_file_name = sprintf('data/gait_data_%s.txt', date_str);
adjustment_time = 2;    % Number of seconds to adjust to the first value of gait (from 0) (in s)
num_timestamps_ajd = 20;    % Number of timestamps in adjustments
% <User configuration area: end>

%% Save gait data
% Save the gait values in the data file
gait_time_stamps = time_stamps;
fhdlr = fopen(gait_data_file_name, 'w');
for i = 1:length(time_stamps)
    fprintf(fhdlr, ... 
        '%f, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f\n', ...
        gait_time_stamps(i), 12, ...
        theta_lf_knee_vals(i), theta_lf_lower_hip_vals(i), theta_lf_upper_hip_vals(i), ...
        theta_lh_knee_vals(i), theta_lh_lower_hip_vals(i), theta_lh_upper_hip_vals(i), ...
        theta_rh_knee_vals(i), theta_rh_lower_hip_vals(i), theta_rh_upper_hip_vals(i), ...
        theta_rf_knee_vals(i), theta_rf_lower_hip_vals(i), theta_rf_upper_hip_vals(i) ...
    );
end
fclose(fhdlr);

%% Adjustment data
% Create adjustment data for all joints with time sync
adj_time_stamps = linspace(0, adjustment_time, num_timestamps_ajd);
% Left front
adj_theta_lf_knee_vals = linspace(0, theta_lf_knee_vals(1), length(adj_time_stamps));
adj_theta_lf_lower_hip_vals = linspace(0, theta_lf_lower_hip_vals(1), length(adj_time_stamps));
adj_theta_lf_upper_hip_vals = linspace(0, theta_lf_upper_hip_vals(1), length(adj_time_stamps));
% Left hind
adj_theta_lh_knee_vals = linspace(0, theta_lh_knee_vals(1), length(adj_time_stamps));
adj_theta_lh_lower_hip_vals = linspace(0, theta_lh_lower_hip_vals(1), length(adj_time_stamps));
adj_theta_lh_upper_hip_vals = linspace(0, theta_lh_upper_hip_vals(1), length(adj_time_stamps));
% Right hind
adj_theta_rh_knee_vals = linspace(0, theta_rh_knee_vals(1), length(adj_time_stamps));
adj_theta_rh_lower_hip_vals = linspace(0, theta_rh_lower_hip_vals(1), length(adj_time_stamps));
adj_theta_rh_upper_hip_vals = linspace(0, theta_rh_upper_hip_vals(1), length(adj_time_stamps));
% Right front
adj_theta_rf_knee_vals = linspace(0, theta_rf_knee_vals(1), length(adj_time_stamps));
adj_theta_rf_lower_hip_vals = linspace(0, theta_rf_lower_hip_vals(1), length(adj_time_stamps));
adj_theta_rf_upper_hip_vals = linspace(0, theta_rf_upper_hip_vals(1), length(adj_time_stamps));
% Save data in adjustment file
fhdlr = fopen(adj_data_file_name, 'w');
for i = 1:length(adj_time_stamps)
    fprintf(fhdlr, ... 
        '%f, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f\n', ...
        adj_time_stamps(i), 12, ...
        adj_theta_lf_knee_vals(i), adj_theta_lf_lower_hip_vals(i), adj_theta_lf_upper_hip_vals(i), ...
        adj_theta_lh_knee_vals(i), adj_theta_lh_lower_hip_vals(i), adj_theta_lh_upper_hip_vals(i), ...
        adj_theta_rh_knee_vals(i), adj_theta_rh_lower_hip_vals(i), adj_theta_rh_upper_hip_vals(i), ...
        adj_theta_rf_knee_vals(i), adj_theta_rf_lower_hip_vals(i), adj_theta_rf_upper_hip_vals(i) ...
    );
end
fclose(fhdlr);

%% Merging the data and saving in the main data file
all_time_stamps = [adj_time_stamps, (time_stamps(2:end) + adj_time_stamps(end))];
% Left front
all_theta_lf_knee_vals = [adj_theta_lf_knee_vals, theta_lf_knee_vals(2:end)];
all_theta_lf_lower_hip_vals = [adj_theta_lf_lower_hip_vals, theta_lf_lower_hip_vals(2:end)];
all_theta_lf_upper_hip_vals = [adj_theta_lf_upper_hip_vals, theta_lf_upper_hip_vals(2:end)];
% Left hind
all_theta_lh_knee_vals = [adj_theta_lh_knee_vals, theta_lh_knee_vals(2:end)];
all_theta_lh_lower_hip_vals = [adj_theta_lh_lower_hip_vals, theta_lh_lower_hip_vals(2:end)];
all_theta_lh_upper_hip_vals = [adj_theta_lh_upper_hip_vals, theta_lh_upper_hip_vals(2:end)];
% Right hind
all_theta_rh_knee_vals = [adj_theta_rh_knee_vals, theta_rh_knee_vals(2:end)];
all_theta_rh_lower_hip_vals = [adj_theta_rh_lower_hip_vals, theta_rh_lower_hip_vals(2:end)];
all_theta_rh_upper_hip_vals = [adj_theta_rh_upper_hip_vals, theta_rh_upper_hip_vals(2:end)];
% Right front
all_theta_rf_knee_vals = [adj_theta_rf_knee_vals, theta_rf_knee_vals(2:end)];
all_theta_rf_lower_hip_vals = [adj_theta_rf_lower_hip_vals, theta_rf_lower_hip_vals(2:end)];
all_theta_rf_upper_hip_vals = [adj_theta_rf_upper_hip_vals, theta_rf_upper_hip_vals(2:end)];
% Save data in all data file
fhdlr = fopen(data_file_name, 'w');
for i = 1:length(all_time_stamps)
    fprintf(fhdlr, ... 
        '%f, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f\n', ...
        all_time_stamps(i), 12, ...
        all_theta_lf_knee_vals(i), all_theta_lf_lower_hip_vals(i), all_theta_lf_upper_hip_vals(i), ...
        all_theta_lh_knee_vals(i), all_theta_lh_lower_hip_vals(i), all_theta_lh_upper_hip_vals(i), ...
        all_theta_rh_knee_vals(i), all_theta_rh_lower_hip_vals(i), all_theta_rh_upper_hip_vals(i), ...
        all_theta_rf_knee_vals(i), all_theta_rf_lower_hip_vals(i), all_theta_rf_upper_hip_vals(i) ...
    );
end
fclose(fhdlr);
