%%DATA_TX_RX_DATA_SYNC Synchronise transmission data to reception time
% stamps
% Takes tx_val and synchronises it to the time stamps of rx_t. It follows
% the trailing point synchronization, that is, till the time of the next
% value in TX, the previous value is retained. The beginning is assumed to
% be 0 and end is the last value in tx_val.
% See also DATA_VIZ

function sync_tx_data = data_tx_rx_data_sync(rx_t, rx_val, tx_t, tx_val)
    sync_tx_data = zeros(size(rx_t, 1), 1+size(rx_val, 2));
    tx_ptr = 0;
    % Traverse entire RX data
    for i = 1:length(rx_t)
        val_tx = 0;
        if tx_ptr >= 1
            val_tx = tx_val(tx_ptr);
        end
        row = [rx_t(i), val_tx];
        sync_tx_data(i, :) = row;
        if tx_ptr < length(tx_t)
            if rx_t(i) > tx_t(tx_ptr + 1)
                tx_ptr = tx_ptr + 1;
            end
        else
            % Reached the length, do nothing
        end
    end
end