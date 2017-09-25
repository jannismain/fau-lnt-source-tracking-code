function [X, phi] = stft(x)
% STFT calculates the short-time fourier transformation of y using specific
% parameters that allow for later DOA estimation

%% START
load('config.mat')

PLOT = [0 0];

cprintf('*blue', '\n<stft.m>');
fprintf(' (t = %2.4f)\n', toc);
m = "Calculate STFT of received signal..."; counter = next_step(m, counter);
    
    X = zeros(fft_bins_net, 296, 2, n_receiver_pairs);  % TODO: Find out how to calculate 296
    phi = zeros(em.K,em.T,n_receiver_pairs);
    %% actual stft calculation
    for mic_pair = 1:n_receiver_pairs
        for mic = 1:2
            x_temp = x(:,mic,mic_pair) + 0.01*(rand(size(x(:,1,mic_pair)))-0.5);
            X(:,:,mic,mic_pair) = specgram(x_temp,fft_bins,fs,fft_window,fft_overlap_samples);
%             fprintf('%s STFT Signal X%d: %dx%dx%dx%d\n', FORMAT_PREFIX, r, size(X, 1), size(X, 2), size(X, 3), size(X, 4));
        end
        phi(:,:,mic_pair) = (X(fft_freq_range,:,2,mic_pair)./X(fft_freq_range,:,1,mic_pair)).*abs(X(fft_freq_range,:,1,mic_pair)./X(fft_freq_range,:,2,mic_pair));
    end
    fprintf('    -> size(x) = %dx%dx%d\n', size(x_temp, 1), size(x_temp, 2), size(x_temp, 3));
    fprintf('    -> size(X) = %dx%dx%d\n', size(X, 1), size(X, 2), size(X, 3));
    fprintf('    -> size(phi) = %dx%dx%d\n', size(phi, 1), size(phi, 2), size(phi, 3));
%     fprintf('%s Truncated STFT Signal to %dx%dx%d\n', FORMAT_PREFIX, size(X, 1), size(X, 2), size(X, 3));
%     fprintf('%s size(phi) = %dx%dx%d', FORMAT_PREFIX, size(phi, 1), size(phi, 2), size(phi, 3));    
    fprintf('%s done! (Elapsed Time = %s)\n', FORMAT_PREFIX, num2str(toc)');
    
    if PLOT(1) && PLOT(counter)
        subplot_tight(1,5,5, 0.06);
        % plotting code
    end
end