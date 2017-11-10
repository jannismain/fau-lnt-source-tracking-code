function [x] = simulate(ROOM, R, sources)
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

%% Calculate RIRs
m = sprintf("Calculate RIR for each Source-Receiver combination... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NODEF>

    H = zeros(rir.length, n_sources, 2, n_receiver_pairs);
    for mic_pair = 1:n_receiver_pairs
        for s = 1:n_sources
            H(:, s, :,mic_pair) = rir_generator(...
            room.c, ...
            fs, ...
            R((mic_pair*2-1):(mic_pair*2),:,:), ...
            sources.positions(s, :), ...
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
m = sprintf("Load source data... (t = %2.4f)", toc); counter = next_step(m, counter);
    
    S_data = zeros(source_length*fs, n_sources);
    for s = 1:n_sources
        [temp, fs_temp] = audioread(sources.samples(s, :));
        if fs_temp ~= fs
            temp = resample(temp, fs, fs_temp);
            if SNR>0
                temp = awgn(temp, SNR, 'measured');
            end
        end
        S_data(1:source_length*fs, s) = temp(1:source_length*fs);
    end
%     sound(S_data(:, 1), fs)

%% Y x RIRs
m = sprintf("Convolute source data with room impulse response... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NASGU>
    
    n_samples_y = source_length*fs;

    Y = zeros(n_samples_y, n_sources, 2, n_receiver_pairs);
    for mic_pair = 1:n_receiver_pairs
        for mic = 1:2
            for s = 1:n_sources
                Y(:, s, mic, mic_pair) = fftfilt(squeeze(H(:, s, mic, mic_pair)), S_data(:, s));
            end
        end
    end
    % IMPROVE: There should be a way to use fftfilt without nested for loops using reshape on H and S_data
    % IMPROVE: Also, we go from time- to stft domain back to time domain (fftfilt)
    %          only to transform back into stft-domain in the next step.
    %          Better: Directly multiply signal in STFT-domain (without fftfilt)
    %          May bring additional work (e.g. reshaping to specified size)

%% $x = \sum(Y)$
m = sprintf("Mixing Signals... (t = %2.4f)", toc); counter = next_step(m, counter); %#ok<*NASGU>
    x = squeeze(sum(Y, 2));

end