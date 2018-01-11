function [ psi_ret, iter, var_ret] = em_algorithm(fn_cfg, phi, iterations, conv_threshold, return_all_psi)
%% EM_ALGORITHM Estimate parameters of GMM from PRPs
% TEST
%% Arguments
% * *fn_cfg (str)*: _filename of configuration file (i.e. |config_5x8d0.mat|)_
% * *phi (mat)*: _matrix with PRP value for each combination_
% * *iterations (int)*: _number of maximum em iterations_
% * *conv_threshold (int)*: _convergence threshold for em algorithm (-1 equals no threshold)_
% * *return_all_psi (bool)*: _return psi with additional dimension to provide psi values across em iterations (default: *false*)_

fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);
load(fn_cfg);
if nargin>2, em.iterations = iterations; fprintf('WARNING: Overriding EM-Iterations (%d)!\n', iterations); end
if nargin>3, em.conv_threshold = conv_threshold; fprintf('WARNING: Overriding EM convergence threshold (%d)!\n', conv_threshold); end
if nargin<5, return_all_psi = false; end

%% Initialisation
freq_mat = reshape(fft_freq_range,em.K,1,1,1,1);
phi_mat = reshape(phi,em.K,em.T,1,1,room.R_pairs);
phi_mat = repmat(phi_mat,1,1,em.Y-2*room.N_margin,em.X-2*room.N_margin,1);

%% Compute Distances
m = 'Compute distances...'; counter = next_step(m, counter);
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

%% Compute Phi Tilde
m = 'Compute phi tilde...'; counter = next_step(m, counter);
phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(room.c)))); % K/T/Y/X
% TODO: Make algorithm dependent on number of sources, evaluate
% performance (better, worse?)  --> additional dimension for phi and psi
clear norm_differences;
fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);

%% Compute Angular Distances
m = 'Compute angular distances...'; counter = next_step(m, counter);
phi_diff = bsxfun(@minus,phi_mat,phi_tilde_mat);
ang_dist = bsxfun(@power,abs((phi_diff)),2);  % slower by about 1 sec on MBP
%   ang_dist = abs(phi_mat-phi_tilde_mat).^2;     % slightly slower (maybe 0.1 sec on MBP)
%   ang_dist = bsxfun(@power,abs(phi_mat-phi_tilde_mat),2);
fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);
clear phi_mat; clear phi_tilde_mat; clear phi_diff;

%% EM Algorithm Init
m = 'EM-Iterations...'; counter = next_step(m, counter);
psi = ones(em.Y-2*room.N_margin,em.X-2*room.N_margin,1) * (1 /(em.X-2*room.N_margin)*(em.Y-2*room.N_margin));
psi_old = zeros(size(psi));

variance = em.var;
var_ret = zeros(em.iterations+1, 1);
var_ret(1) = em.var;

if return_all_psi
    psi_ret = zeros(em.iterations, size(psi, 1), size(psi, 2));
end
%% EM Algorithm Iterations
for iter = 1:em.iterations
    fprintf('%s EM Iter. #%2d: ', FORMAT_PREFIX, iter);
    fprintf('\x0394\x03C8 = %2.4f (t = %2.4f)\n', norm(psi(:)-psi_old(:)), toc);  % \x0394\x03C8 = Delta Psi
    psi_old = psi;
%% Expectation
    e_start = toc;
    pdf = bsxfun(@times,reshape(psi,1,1,em.Y-2*room.N_margin,em.X-2*room.N_margin,1),prod((1 / (variance * pi))*exp(-ang_dist / (variance)),5));
    mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),em.K,em.T,1,1));
    mu(isnan(mu)) = 0;

%% Maximization
    m_start = toc;
    psi = squeeze(sum(sum(mu,2),1)/(em.T*em.K));
    psi(psi<=0) = eps;  % reset negative values to the smallest possible positive value
    m_var_start = toc;
    if ~em.var_fixed
        var_denominator = squeeze(sum(sum(sum(sum(sum(bsxfun(@times,reshape(mu,size(mu,1),size(mu,2),size(mu,3),size(mu,4),1),ang_dist),5),4),3),2),1));
        var_numerator = room.R_pairs*squeeze(sum(sum(sum(sum(mu,4),3),2),1));
        variance = var_denominator./var_numerator;
    end
    m_stop = toc;
%% Profile Algorithm
    em_duration = m_stop-e_start;
    e_duration = m_start-e_start;
    m_psi_duration = m_var_start-m_start;
    m_var_duration = m_stop-m_var_start;
    fprintf("%s Iteration took %2.4f (100), E took %2.4f (%2.2f), M-Psi took %2.4f (%2.2f), M-Var took %2.4f (%2.2f)\n", FORMAT_PREFIX, em_duration, e_duration, e_duration/em_duration, m_psi_duration, m_psi_duration/em_duration, m_var_duration, m_var_duration/em_duration);
%% Update Return Values
    var_ret(iter+1)=variance;
    if return_all_psi
        psi_ret(iter, :, :) = psi;
    else
        psi_ret = psi;
    end
%% Convergence Check
    if em.conv_threshold > 0
        if(norm(psi_old(:) - psi(:)) < em.conv_threshold), break; end
    end
end

%% Delete outer margin (around microphones) to eliminate false peaks
if size(psi_ret, 3) == 1  % return_all_psi == false
    psi_ret(1,:) = 0;
    psi_ret(size(psi, 1),:) = 0;
    psi_ret(:,1) = 0;
    psi_ret(:,size(psi, 2)) = 0;
else  % return_all_psi == true
    psi_ret(:, 1,:) = 0;
    psi_ret(:, size(psi, 1),:) = 0;
    psi_ret(:, :, 1) = 0;
    psi_ret(:, :,size(psi, 2)) = 0;
end

%% Shorten Return Variables to only include actual iterations
% Otherwise, when convergence is determined before max |em_iterations| is reached, the
% return value would be zero for the iterations not executed.
psi_ret(iter+1:em.iterations,:,:) = [];  % remove zero rows, so size(psi, 1) gives actual em-iterations
var_ret(iter+1:em.iterations) = [];  % remove zero rows, so size(psi, 1) gives actual em-iterations
end
