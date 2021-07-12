%% Setup
clc;clearvars;close all;
time = linspace(0, 5, 1000);
w = 2*pi*1;
a = 2;
x1_vals = 5 .* ones(size(time));
y1_vals = a .* sin(w .* time);
x2_vals = a .* sin(w .* time);
y2_vals = 5 .* ones(size(time));

figure('Name', 'Animation');
for i = 1:length(time)
    pause(time(2) * 0.55);
    subplot(1,3,1);
    plot(x1_vals(i), y1_vals(i), 'b*');
    xlim([0, 10]);
    ylim([-6, 6]);
    subplot(1,3,2);
    plot(x2_vals(i), y2_vals(i), 'b*');
    xlim([-6, 6]);
    ylim([0, 10]);
    subplot(1, 3, 3);
    plot(x1_vals(i), y1_vals(i), 'b*'); hold on;
    plot(x2_vals(i), y2_vals(i), 'b*'); hold off;
    xlim([-10, 10]);
    ylim([-10, 10]);
end
