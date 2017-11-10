function [ psi, loc_est, loc_est1, loc_est2 ] = rem_tracking( phi )
%REM_TRACKING Summary of this function goes here
%   Detailed explanation goes here
load('config.mat')

%% init
psi = ones(em.Y-2*room.N_margin,em.X-2*room.N_margin,1) * (1 /(em.X-2*room.N_margin)*(em.Y-2*room.N_margin));
freq_mat = reshape(fft_freq_range,em.K,1,1,1,1);
phi_mat = reshape(phi,em.K,em.T,1,1,room.R_pairs);
phi_mat = repmat(phi_mat,1,1,em.Y-2*room.N_margin,em.X-2*room.N_margin,1);


m = "Compute distances..."; counter = next_step(m, counter);
norm_differences = zeros(em.Y-2*room.N_margin,em.X-2*room.N_margin,room.R_pairs);
for idx_pairs = 1:room.R_pairs
    for idx_x = (room.N_margin+1):(em.X-room.N_margin)
        for idx_y = (room.N_margin+1):(em.Y-room.N_margin)
            norm_differences(idx_y-room.N_margin,idx_x-room.N_margin,idx_pairs) = norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2,1:2),2) - norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2-1,1:2),2);
        end
    end
end
norm_differences = reshape(norm_differences,1,1,size(norm_differences,1),size(norm_differences,2),size(norm_differences,3));
fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);


m = "Compute phi tilde..."; counter = next_step(m, counter);
phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(room.c)))); % K/T/Y/X
clear norm_differences;
fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);


m = "Compute angular distances..."; counter = next_step(m, counter);
phi_diff = bsxfun(@minus,phi_mat,phi_tilde_mat);
ang_dist = bsxfun(@power,abs((phi_diff)),2);  % slower by about 1 sec on MBP
fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);

clear phi_mat; clear phi_tilde_mat; clear phi_diff;

%% EM algorithm
m = "EM-Iterations..."; counter = next_step(m, counter);
psi_old = zeros(size(psi));
plot_est = zeros(size(psi));
loc_est = zeros(n_sources, em.T, 2);
em_gamma = 0.1;%0.1;
em_block_length = 1;
em_variance = 0.1;
em_num_iter_inner = 1;

for iter = 1:(em.T - em_block_length)
    
    fprintf('%s EM Iter. #%2d: ', FORMAT_PREFIX, iter);
    fprintf('\x0394\x03C8 = %2.4f (t = %2.4f)\n', norm(psi(:)-psi_old(:)), toc);  % \x0394\x03C8 = Delta Psi
    psi_old = psi;
    
    for iter_inner = 1:em_num_iter_inner
        %% Expectation
        pdf = bsxfun(@times,reshape(psi,1,1,em.Y-2*room.N_margin,em.X-2*room.N_margin,1),prod((1 / (em_variance * pi))*exp(-ang_dist(:,iter+em_block_length,:,:,:) / (em_variance)),5));
        mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),em.K,1,1,1));
        mu(isnan(mu)) = 0;
        
        %% Maximization
        psi = squeeze(sum(mu,1)/(em.K));
        psi(psi<=0) = eps;
        
    end
    
    % recursive update for psi
    psi = psi_old + em_gamma*(psi - psi_old);
    
    psi_plot = zeros(em.Y,em.X);
    psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
    
    % compute the two highest local maxima with distance thres_max
    psi_computeMax = psi;
    
    %% Delete outer margin (around microphones) to eliminate false peaks
    b=0;
    if size(psi_computeMax, 3) == 1 
        psi_computeMax(1:b,:) = 0;
        psi_computeMax(size(psi, 1)-b:size(psi, 1),:) = 0;
        psi_computeMax(:,1:b) = 0;
        psi_computeMax(:,size(psi, 2)-b:size(psi, 2)) = 0;
    end
    
    %% Find Location
    evalc('loc_est(:,iter,:) = estimate_location(psi_computeMax,n_sources,1,5,room);');
end

end

