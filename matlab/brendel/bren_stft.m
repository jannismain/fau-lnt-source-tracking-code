function [ phi ] = bren_stft(cfg, x)
%CALCULATE_PHI Summary of this function goes here
%   Detailed explanation goes here
    
    fprintf('Compute phase differences...\n');
    if ~(exist("cfg.T", 'var'))
        cfg.T = floor((size(x,1)-cfg.winpts)/cfg.steppts)+1;
    end
    phi = zeros(cfg.K,cfg.T,cfg.n_pairs);
    for idx_pair = 1:cfg.n_pairs
        x1 = x(:,1,idx_pair) + 0.01*(rand(size(x(:,1,idx_pair)))-0.5);
        x2 = x(:,2,idx_pair) + 0.01*(rand(size(x(:,2,idx_pair)))-0.5);
        X1 = specgram(x1,cfg.nfft,cfg.fs,cfg.window,cfg.n_overlap);
        X2 = specgram(x2,cfg.nfft,cfg.fs,cfg.window,cfg.n_overlap);
        phi(:,:,idx_pair) = (X2(cfg.freq_range,:)./X1(cfg.freq_range,:)).*abs(X1(cfg.freq_range,:)./X2(cfg.freq_range,:));
    end
    fprintf('    -> size(x) = %dx%dx%d\n', size(x1, 1), size(x1, 2), size(x1, 3));
    fprintf('    -> size(X) = %dx%dx%d\n', size(X1, 1), size(X1, 2), size(X1, 3));
    fprintf('    -> size(phi) = %dx%dx%d\n', size(phi, 1), size(phi, 2), size(phi, 3));


end

