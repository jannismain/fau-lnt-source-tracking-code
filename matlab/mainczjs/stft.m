function y_hat = stft(y)
% STFT calculates the short-time fourier transformation of y using specific
% parameters that allow for later DOA estimation


%% This snippet allows to call testbed without switching editor window
if ~(exist('y','var'))
    testbed;
    return;
end

%% START
load('config.mat')

PLOT = [0 1];

cprintf('*blue', '\n<stft.m>\n');
m = "Calculate STFT of received signal..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    %% set fft properties
    fft_window_samples = round(fft_window_time*fs);  % 500
    fft_window = hanning(fft_window_samples);  % 500x1

    fft_step_time = 0.015;
    fft_step_samples = round(fft_step_time*fs);  % 300

    fft_overlap_samples = fft_window_samples - fft_step_samples;  % 200 overlapping samples
    fft_bins = 2^(ceil(log(fft_window_samples)/log(2)));  % 512 fft bins for STFT
    fft_bins_net = fft_bins/2+1;  % 257 non-redundant bins
    
    %% preallocate result matrix by running test stft on first (longest)
    % input
    test=spectrogram(y(1,:),fft_window,fft_overlap_samples,fft_bins,fs); % determine dimensions of stft-output for proper allocation below
    [n_bins, n_samples_y_hat] = size(test);
    fprintf('%s n_bins = %d (should be %d)\n', FORMAT_PREFIX, n_bins, fft_bins);
    fprintf('%s n_samples_y_hat = %d\n', FORMAT_PREFIX, n_samples_y_hat);
    y_hat = zeros(n_receivers, n_bins, n_samples_y_hat);
    
    %% actual stft calculation
    for r = 1:n_receivers
        y_hat(r,:,:) = spectrogram(y(r,:),fft_window,fft_overlap_samples,fft_bins,fs);  % 2x257x1401
        fprintf('%s STFT Signal Y%d: %dx%dx%d\n', FORMAT_PREFIX, r, size(y_hat, 1), size(y_hat, 2), size(y_hat, 3));
    end
    % truncate signal
    y_hat = y_hat(:,:,1:fft_trunc);  % 2x257x500
    fprintf('%s Truncated STFT Signal to %dx%dx%d\n', FORMAT_PREFIX, size(y_hat, 1), size(y_hat, 2), size(y_hat, 3));
    
    if PLOT(1) && PLOT(counter)
        figure;
        for r = 1:n_receivers
            subplot(n_receivers, 2,r*2-1);
            plot(angle(squeeze(y_hat(r,1:10, 1:10))));
            title(strcat("STFT(R_{", num2str(r), "})"))
            subplot(n_receivers, 2,r*2);
            spectrogram(y(r,:),fft_window,fft_overlap_samples,fft_bins,fs,'yaxis');
        end
    end
end