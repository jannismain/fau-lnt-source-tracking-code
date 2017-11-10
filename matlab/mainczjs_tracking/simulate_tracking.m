function [x] = simulate_tracking()
% SIMULATE Simulates a room with two audio sources and receivers and
% generates the received signal at both receivers
%
% NOTES:
%   - Time will always be given in seconds [s] unless otherwise noted
%     (e.g. [ms])
%
%

%% START
fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);
load('config.mat')

%% Load source data...
m = sprintf("Load source data... (t = %2.4f)", toc); counter = next_step(m, counter);
    
    S_data = zeros(source_length*fs, n_sources);
    for s = 1:n_sources
        [temp, fs_temp] = audioread(sources.samples(s, :));
        if fs_temp ~= fs
            temp = resample(temp, fs, fs_temp);
            if room.snr>0
                temp = awgn(temp, SNR, 'measured');
            end
        end
        S_data(1:source_length*fs, s) = temp(1:source_length*fs);
    end

%% Calculate RIR-bank
m = sprintf("Calculate RIR for each Source-Receiver combination... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NODEF>
    filename_rir_bank = ["", ""];
    for s = 1:n_sources
        config_shift_current_trajectory(s)
        fn = sprintf('ress/rir/RIRs_[%d,%d]_to_[%d,%d]_T60=%0.1f_s=%d.mat', sources.positions(s, 1), sources.positions(s, 2), sources.positions(s, 1)+sources.movement(s, 1), sources.positions(s, 2)+sources.movement(s, 2),rir.t_reverb, samples);
        filename_rir_bank(s) = fn;
        if exist(fn,'file')~=2
            fast_ISM_RIR_bank(custom_ISM_setup,fn);
        else
            fprintf("%s Will use existing RIR-Bank: '%s' (t=%2.2f)\n", FORMAT_PREFIX, filename_rir_bank(s), toc);
        end
    end

%% Create Received Signals
m = sprintf("Mixing Signals... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NASGU>
    for s=1:n_sources
        source_data = ISM_AudioData(filename_rir_bank(s),S_data(:, s));
        if s==1
            x = zeros(size(source_data, 1), n_sources,2, size(source_data, 2)/2);
        end
        % reshape data to fit [:,s,mic,mic_pair] structure
        for i=1:size(source_data, 2)
            mic = 2-mod(i,2);
            mic_pair = roundn(i/2,0);
            x(:,s,mic,mic_pair) = source_data(:,i);
        end
    end
    m = sprintf("Mixing Signals... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NASGU>
    x = squeeze(sum(x, 2));
end