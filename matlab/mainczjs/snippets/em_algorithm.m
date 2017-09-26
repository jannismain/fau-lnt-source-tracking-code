function [DOA_vec, psi] = em_algorithm(y_hat, fig)
% EM_ALGORITHM takes an stft signal and calculates the DOA of n speakers
%
% NOTES:
%   - None

load('config.mat')
cprintf('*blue', '\n<em_algorithm.m>\n');
fprintf("%s INPUT: y_hat = %dx%dx%d\n", FORMAT_PREFIX, size(y_hat, 1), size(y_hat, 2), size(y_hat, 3)); 
m = "Estimate DOA using the an EM Algorithm..."; counter = next_step(m, counter);

phi = squeeze((y_hat(1,:,:)./y_hat(2,:,:)).*abs(y_hat(1,:,:)./y_hat(2,:,:)));
fprintf("%s INPUT: phi = %dx%dx%d\n", FORMAT_PREFIX, size(phi, 1), size(phi, 2), size(phi, 3)); 
DOA_vec = 0:1:180; % vector of DOA candidates

cfg.S = n_sources;
cfg.T = size(phi,2);
cfg.K = size(phi,1);
cfg.D = length(DOA_vec); % Number of DOAs
fprintf("%s INPUT: K = %d, T = %d, S = %d, D = %d\n", FORMAT_PREFIX, cfg.K, cfg.T, cfg.S, cfg.D); 

% Use the overal variance of the dataset as the initial variance for each cluster.
variance = ones(cfg.S,1) * sqrt(var(phi(:)));

% Assign equal prior probabilities to each cluster.
psi = ones(cfg.S,cfg.D) * (1 / (cfg.D*cfg.S));

% produce matrices of suitable sice for matrix multiplications
freq_mat = repmat((1:cfg.K).',1,cfg.T,cfg.S,length(DOA_vec));
phi_mat = repmat(phi,1,1,cfg.S,cfg.D);
DOA_mat = reshape(DOA_vec,1,1,1,length(DOA_vec));
DOA_mat = repmat(DOA_mat,cfg.K,cfg.T,cfg.S,1);

% phase hypothesis computed from DOAs
phi_tilde_mat = exp(-1i*(pi*freq_mat)/(cfg.K).*(d_r*fs)/(c).*cosd(DOA_mat)); % K/T/S/D
fprintf("%s INPUT: freq_mat = %dx%dx%d\n", FORMAT_PREFIX, size(freq_mat, 1), size(freq_mat, 2), size(freq_mat, 3)); 
fprintf("%s INPUT: DOA_mat = %dx%dx%d\n", FORMAT_PREFIX, size(DOA_mat, 1), size(DOA_mat, 2), size(DOA_mat, 3)); 
fprintf("%s OUTPUT: dimensions of phi_tilde_mat = %dx%dx%d\n", FORMAT_PREFIX, size(phi_tilde_mat, 1), size(phi_tilde_mat, 2), size(phi_tilde_mat, 3)); 
fprintf("%s OUTPUT: dimensions of phi_mat = %dx%dx%d\n", FORMAT_PREFIX, size(phi_mat, 1), size(phi_mat, 2), size(phi_mat, 3)); 
ang_dist = abs(phi_mat-phi_tilde_mat).^2; % angular distances of observed phase differences and hypothesis

% setup plot
subplot_tight(2,2,4, PLOT_BORDER);
hold on;
box off;
title('DOA Estimation (EM-Algorithm)')

for iter = 1:10
    
    fprintf('%s EM Iteration %d\n', FORMAT_PREFIX, iter);
    
    %% Expectation Step
    psi_mat = reshape(psi,1,1,size(psi,1),size(psi,2));
    psi_mat = repmat(psi_mat,cfg.K,cfg.T,1,1);
    var_mat = ones(cfg.K,cfg.T,n_sources,cfg.D);
    for S_idx = 1:n_sources
        var_mat(:,:,S_idx,:) = var_mat(:,:,S_idx,:) * variance(S_idx);
    end
    pdf = psi_mat.*(1 ./ (var_mat * pi)) .* exp(-ang_dist ./ (var_mat));
    pdf_sum = repmat(sum(sum(pdf,4),3),1,1,n_sources,cfg.D);
    mu = pdf./pdf_sum;
    mu(isnan(mu)) = 0; % avoid NaNs
    
    %% Maximization Step
    psi = squeeze(sum(sum(mu,2),1)/(cfg.T*cfg.K));
    psi = psi./sum(sum((psi))); % normalization due to weighting
    
    var_denominator = squeeze(sum(sum(sum(mu.*ang_dist,1),2),4));
    var_numerator = squeeze(sum(sum(sum(mu,1),2),4));
    variance = var_denominator./var_numerator;
    
    psi_smoothed = smooth(psi(1,:)); % smoothing for clear representation
    
    % plot result
    plot(DOA_vec,psi_smoothed)
    xlabel('DOA \rightarrow')
    ylabel('p(DOA) \rightarrow')
    grid on
    axis tight
    pause(0.2)
    
end