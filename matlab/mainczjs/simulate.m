function [y, fig] = simulate(ROOM, R, S)
% SIMULATE Simulates a room with two audio sources and receivers and
% generates the received signal at both receivers
%
% NOTES:
%   - Time will always be given in seconds [s] unless otherwise noted
%     (e.g. [ms])
%
%

%% This snippet allows to call testbed without switching editor window
if ~(exist('ROOM','var'))
    testbed;
    return;
end

%% START
cprintf('*blue', '\n<simulate.m>\n');
load('config.mat')
PLOT = [1 1 0 0 0 0 0]; % boolean plotting flag: [ all | step1 | step2 | ... | stepX ]

%% Setting up the environment...
m = "Setting up the environment..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    if PLOT(1) && PLOT(counter)
        fig = plot_room(ROOM, R, S);
    end

%% DoA Calculation...
m = "Actual DoA Calculation..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    DOA = doa_trig(S,R);
    for s=1:n_sources
        fprintf('%s Actual DOA(S_{%d}): %0.2f\x03C0 (%0.1f\x00B0)\n', FORMAT_PREFIX, s, deg2rad(DOA(s)/pi), DOA(s));
    end

%% Calculate RIRs
m = "Calculate RIR for each Source-Receiver combination..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    H = generate_rir(ROOM, R, S);
    n_samples_h = length(squeeze(H(1,1,:)));
    fprintf("%s Generated RIR %dx%dx%d\n", FORMAT_PREFIX, size(H, 1), size(H, 2), size(H, 3));
    if PLOT(1) && PLOT(counter)
        figure; plot_count = 1;
        for r = 1:size(H, 1)
            for s = 1:size(H, 2)
                subplot(size(H, 1), size(H, 2), plot_count);
                plot(squeeze(H(r,s,:)));
                title(strcat("RIR(R_{", int2str(r), "}, S_{", int2str(s), "})"))
                plot_count = plot_count + 1;
            end
        end
    end

%% Load source data...
m = "Load source data..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    S_data = zeros(n_sources);
    n_samples_s = 0;
    for s = 1:n_sources
        [temp, fs] = audioread(strcat('audio/',int2str(s),'.WAV'));
        fprintf("%s Loaded S%d (fs = %d, length = %d)\n", FORMAT_PREFIX, s, fs, length(temp)); 
        S_data(s,1:length(temp)) = temp;
        if (n_samples_s == 0) || ( n_samples_s > length(temp))
            fprintf("%s New minimal sample length: %6.0d (was %d)\n", FORMAT_PREFIX, length(temp), n_samples_s); 
            n_samples_s = length(temp);
        end
    end
    S_data = S_data(:,1:n_samples_s);
    fprintf("%s Truncated S to 2x%d\n", FORMAT_PREFIX, size(S_data, 2));

%% Y x RIRs
m = "Convolute source data with room impulse response..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    n_samples_y = n_samples_s + n_samples_h - 1; % max length of conv return values

    Y = zeros(n_receivers, n_sources, n_samples_y);
    for r = 1:n_receivers
        for s = 1:n_sources
            Y(r,s,:) = conv(squeeze(S_data(s, 1:n_samples_s)), squeeze(H(r,s,:)));
            fprintf("%s Calculated RIR(R%dxS%d)(length = %d)\n", FORMAT_PREFIX, r, s, length(Y(r,s,:))); 
        end
    end

%     %% Andreas
%     x1 = fftfilt(H(:,:,1),S_data(1,:));
%     x2 = fftfilt(H(:,:,2),S_data(2,:));
    
    if PLOT(1) && PLOT(counter)
        figure; plot_count = 1;
        for r = 1:n_receivers
            for s = 1:n_sources
                subplot(size(Y, 1), size(Y, 2), plot_count);
                plot(squeeze(Y(r,s,:)));
                title(strcat("S_{", int2str(s), "} x RIR(R_{", int2str(r), "}, S_{", int2str(s), "})"))
                plot_count = plot_count + 1;
            end
        end
    end
    
%% Calculate received signal...  
m = "Calculate received signal..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);

    % mixing / addition of received signals
    Y_m = zeros(n_receivers, n_samples_y);
    for r = 1:n_receivers
        for s = 1:n_sources
            Y_m(r, :) = Y_m(r, :) + squeeze(Y(r,s,:))';
        end
        fprintf("%s R%d (length = %d)\n", FORMAT_PREFIX, r, length(Y_m(r,:))); 
    end
    
    y = Y_m;
    
    if PLOT(1) && PLOT(counter)
        figure;
        for r = 1:n_receivers
            subplot(n_receivers, 1,r);
            plot(Y_m(1,:));
            title(strcat("R_{", int2str(r), "}"))
        end
    end
    
    if PLAY_AUDIO > 0 && PLAY_AUDIO <= n_receivers
        sound(Y_m(PLAY_AUDIO, :), fs);
    end

end