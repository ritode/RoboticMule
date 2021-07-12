%%DATA_VIZ Data Visualizer for Serial Protocol 1
% Run using ./data_viz
% Open the file and change the items in <user configuration area:begin>
% (upto <user configuration area:end>)
% See also DATA_TX_RX_DATA_SYNC

%% Setup
clc;clearvars;close all;
% <user configuration area:begin>
RX_File = 'RX_19_FEB_2020_14_53_28_049969458.txt';
TX_File = 'TX_19_FEB_2020_14_53_28_049969458.txt';
% <user configuration area:end>

%% Main program
% Get data from files
RX_data = load(RX_File);
TX_data = load(TX_File);
% Get time and value
rx_data_t = RX_data(:, 1);
rx_data_val = RX_data(:, 3);
tx_data_t = TX_data(:, 1);
tx_data_val = TX_data(:, 3);
% < Edit area: begin >
% Remove the 2326 index from file
rx_data_t(2326) = [];
rx_data_val(2326) = [];
% < Edit area: end >
% Get synchronous data for TX from the time stamps of RX
sync_tx_data = data_tx_rx_data_sync(rx_data_t, rx_data_val, ...
                                    tx_data_t, tx_data_val);
sync_tx_time = sync_tx_data(:, 1);
sync_tx_val = sync_tx_data(:, 2);
% - Plot data -
figure('Name', 'RAW Data', 'NumberTitle', 'off');
% Transmitted data
subplot(2,2,1);
plot(tx_data_t, tx_data_val, 'r*');
ax = gca;
ax.XGrid = 'on';
ax.YGrid = ax.XGrid;
ax.XMinorGrid = 'on';
ax.YMinorGrid = ax.XMinorGrid;
title('Transmitted');
% Received data
subplot(2,2,2);
plot(rx_data_t, rx_data_val, 'b.');
ax = gca;
ax.XGrid = 'on';
ax.YGrid = ax.XGrid;
ax.XMinorGrid = 'on';
ax.YMinorGrid = ax.XMinorGrid;
title('Received');
% Combination of both on the same plot
% subplot(2,2,[3,4]);
% plot(tx_data_t, tx_data_val, 'r+'); 
% hold on;
% plot(sync_tx_time, sync_tx_val, 'r--');
% hold on;
% plot(rx_data_t, rx_data_val, 'b.');
% ax = gca;
% ax.XGrid = 'on';
% ax.YGrid = ax.XGrid;
% ax.XMinorGrid = 'on';
% ax.YMinorGrid = ax.XMinorGrid;
% legend('TX', 'TX (sync)', 'RX');
% title('Combined');
subplot(2,2,[3,4]);
plot(tx_data_t, tx_data_val, 'r.'); 
hold on;
plot(rx_data_t, rx_data_val, 'b.');
ax = gca;
ax.XGrid = 'on';
ax.YGrid = ax.XGrid;
ax.XMinorGrid = 'on';
ax.YMinorGrid = ax.XMinorGrid;
legend('TX', 'RX');
title('Combined');
