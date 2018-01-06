function [ ang_dist ] = rem_init( phi )
%REM_TRACKING Summary of this function goes here
%   Detailed explanation goes here

load('config.mat')

%% EM algorithm
m = "Initialize EM Algorithm"; counter = next_step(m, counter);

freq_mat = reshape(fft_freq_range,em.K,1,1,1,1);
phi_mat = reshape(phi,em.K,em.T,1,1,room.R_pairs);
phi_mat = repmat(phi_mat,1,1,em.Ynet,em.Xnet,1);

m = "Compute distances..."; counter = next_step(m, counter);
norm_differences = zeros(em.Ynet,em.Xnet,em.M);
for idx_pairs = 1:em.M
    for idx_x = (room.N_margin+1):(em.X_idxmax)
        for idx_y = (room.N_margin+1):(em.Y_idxmax)
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
ang_dist = bsxfun(@power,abs((phi_diff)),2);  % 26 x 296 x 41 x 41 x 12
fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);
end
