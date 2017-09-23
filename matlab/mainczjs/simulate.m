function [x, fig] = simulate(ROOM, R, S)
% SIMULATE Simulates a room with two audio sources and receivers and
% generates the received signal at both receivers
%
% NOTES:
%   - Time will always be given in seconds [s] unless otherwise noted
%     (e.g. [ms])
%
%

%% START
cprintf('*blue', '\n<%s.m>\n', mfilename);
fprintf(' (t = %2.4f)\n', toc);
load('config.mat')

%% Setting up the environment...
m = "Setting up the environment..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    fig = plot_room(ROOM, R, S);

%% Calculate RIRs
m = "Calculate RIR for each Source-Receiver combination..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);

    H = zeros(rir.length, n_sources, 2, n_receiver_pairs);
    for mic_pair = 1:n_receiver_pairs
        for s = 1:n_sources
            H(:, s, :,mic_pair) = rir_generator(...
            c, ...
            fs, ...
            R((mic_pair*2-1):(mic_pair*2),:,:), ...
            S(s, :), ...
            ROOM, ...
            rir.t_reverb, ...
            rir.length, ...
            mics.type, ...
            rir.reflect_order, ...
            3)';
        end
    end
    H = H/(max(max(max(max(H)))));
    fprintf("%s Generated RIR %dx%dx%dx%d\n", FORMAT_PREFIX, size(H, 1), size(H, 2), size(H, 3), size(H, 4));

%% Load source data...
m = "Load source data..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    S_data = zeros(source_length*fs, n_sources);
    for s = 1:n_sources
        [temp, fs_temp] = audioread(strcat(int2str(s),'.WAV'));
        if fs_temp ~= fs
            temp = resample(temp, fs, fs_temp);
        end
        S_data(1:source_length*fs, s) = temp(1:source_length*fs);
    end

%% Y x RIRs
m = "Convolute source data with room impulse response..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    n_samples_y = source_length*fs;

    Y = zeros(n_samples_y, n_sources, 2, n_receiver_pairs);
    for mic_pair = 1:n_receiver_pairs
        for mic = 1:2
            for s = 1:n_sources
                Y(:, s, mic, mic_pair) = fftfilt(squeeze(H(:, s, mic, mic_pair)), S_data(:, s));
%                 fprintf("%s Calculated RIR(R%d.%dxS%d)(length = %d)\n", FORMAT_PREFIX, mic_pair, mic, s, length(Y(:, s, mic, mic_pair))); 
            end
        end
    end
    fprintf('%s done! (Elapsed Time = %2.4f)\n', FORMAT_PREFIX, toc);
    
    fprintf("%s Mixing Signals... ", FORMAT_PREFIX);
    x = squeeze(sum(Y, 2));
    fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');

end