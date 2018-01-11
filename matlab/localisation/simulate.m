function [x] = simulate(fn_cfg, ROOM, R, sources, mix)
% SIMULATE Simulates received signals in a room with audio sources and receivers.

%% Description
% Simulates received signals in a room with audio sources and receivers. For the
% simulation, the <https://github.com/ehabets/RIR-Generator RIR-Generator> by Emanuel
% Habets is used. If |SNR~=0| in |fn_cfg|, AWGN is added with the corresponding |dB|
% value.

%% Arguments
% * *fn_cfg (str)*: _filename of configuration file (e.g. |'config_5x8d0.mat'|)_
% * *ROOM (mat)*: room dimensions _(3x1 matrix, e.g. |[6, 6, 6.1]|)_
% * *R (mat)*: receiver position matrix _(3x2*M matrix)_
% * *sources (mat)*: sources parameter struct that contains the following two attributes
% *     *sources.positions (mat)*: matrix of source positions _(3xS matrix)_
% *     *sources.samples (mat)*: matrix of speech sample file names _(5xS matrix, e.g. |['1.WAV', '3.WAV', '2.WAV']| for |S=3|)_
% * *mix (bool)*: mix simulated signals together per microphone pair _(default: *true*)_

%% Caveats
% * |SNR=0| in |fn_cfg| means no noise, _not_ noise with |0dB|

%% Ideas for Improvement
% * There should be a way to use fftfilt without nested for loops using reshape on H and S_data
% * Also, we go from time- to stft domain back to time domain (fftfilt) only to transform 
% back into stft-domain in the next step. Better: Directly multiply signal in STFT-domain (without fftfilt). 
% *Note*: This may bring additional work (e.g. reshaping to specified size)

%% Initialisation
try fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc); end
load(fn_cfg)
if nargin<5, mix=true;end

%% Calculate RIRs
m = sprintf('Calculate RIR for each Source-Receiver combination... (t = %2.4f)', toc); counter = next_step(m, counter); %#ok<*NODEF>

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
fprintf('%s Generated RIR %dx%dx%dx%d\n', FORMAT_PREFIX, size(H, 1), size(H, 2), size(H, 3), size(H, 4));

%% Load Source Data
% Load speech samples, trim signal to the length specified in |fn_cfg| and add AWGN, if
% |SNR~=0|. 
m = sprintf('Load source data... (t = %2.4f)', toc); counter = next_step(m, counter);

    S_data = zeros(source_length*fs, n_sources);
    for s = 1:n_sources
        [temp, fs_temp] = audioread(sources.samples(s, :));
        if fs_temp ~= fs
            temp = resample(temp, fs, fs_temp);
            if SNR>0
                temp = awgn(temp, SNR, 'measured');
            end
        end

        if length(temp)>source_length*fs
            S_data(1:source_length*fs, s) = temp(1:source_length*fs);
        else
            S_data(1:length(temp), s) = temp;
        end
    end

%% Y x RIRs
% Convolute source data with RIR to compute received signal
m = sprintf('Convolute source data with room impulse response... (t = %2.4f)', toc); counter = next_step(m, counter); %#ok<*NASGU>

    n_samples_y = source_length*fs;

    Y = zeros(n_samples_y, n_sources, 2, n_receiver_pairs);
    for mic_pair = 1:n_receiver_pairs
        for mic = 1:2
            for s = 1:n_sources
                Y(:, s, mic, mic_pair) = fftfilt(squeeze(H(:, s, mic, mic_pair)), S_data(:, s));
            end
        end
    end

%% Mix Signals at Receiver Pairs
% _Optional:_ Mix signals for receiver pairs.
if mix
    m = sprintf('Mixing Signals... (t = %2.4f)', toc); counter = next_step(m, counter); %#ok<*NASGU>
        x = squeeze(sum(Y, 2));
else
    x = Y;
end
end
