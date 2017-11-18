function [ psi_ret, iter, var_ret] = em_algorithm(fn_cfg, phi, iterations, conv_threshold, return_all_psi)
%EM_ALGORITHM Uses the em-algorithm to find parameters of a gaussian mixture model based
%on phi
%   Detailed explanation goes here
%   phi: matrix with gaussian components
%   iterations: max. number of em-iterations
%   conv_threshold: em-iterations stop early, when change in psi is lower than conv_threshold (provide -1 to prevent early stopping)

fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);
load(fn_cfg);
if nargin>2, em.iterations = iterations; fprintf('WARNING: Overriding EM-Iterations (%d)!\n', iterations); end
if nargin>3, em.conv_threshold = conv_threshold; fprintf('WARNING: Overriding EM convergence threshold (%d)!\n', conv_threshold); end
if nargin<5, return_all_psi = false; end

if ~(exist('ang_dist.mat', 'file') == 2)
if ~(exist('ang_dist.mat', 'file') == 2)
    % FREQ_MAT
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "fft_freq_range"); display(size(fft_freq_range)); end
    freq_mat = reshape(fft_freq_range,em.K,1,1,1,1);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "new freq mat"); display(size(freq_mat)); end

    % PHI_MAT
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "phi"); display(size(phi)); end
    %% extend phi_mat to sixth dimension for S and reshape into form!
    % phi_mat = phi;
    % for i=1:em.S-1
    %     phi_mat = cat(4,phi_mat, phi);
    % end
    % phi_mat = reshape(phi_mat,em.K,em.T,1,1,em.M, em.S);
    % if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "phi mat"); display(size(phi_mat)); end
    phi_mat = reshape(phi,em.K,em.T,1,1,em.M);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "phi mat"); display(size(phi_mat)); end
    phi_mat = repmat(phi_mat,1,1,em.Ynet,em.Xnet,1, 1);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "repmat phi mat"); display(size(phi_mat)); end

    m = 'Compute distances...'; counter = next_step(m, counter);
    norm_differences = zeros(em.Ynet,em.Xnet,em.M);
    for idx_pairs = 1:room.R_pairs
        for idx_x = (room.N_margin+1):(em.X-room.N_margin)
            for idx_y = (room.N_margin+1):(em.Y-room.N_margin)
                norm_differences(idx_y-room.N_margin,idx_x-room.N_margin,idx_pairs) = norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2,1:2),2) - norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2-1,1:2),2);
            end
        end
    end
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "norm_diff"); display(size(norm_differences)); end
    norm_differences = reshape(norm_differences,1,1,size(norm_differences,1),size(norm_differences,2),size(norm_differences,3));
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "new norm_diff"); display(size(norm_differences)); end
    fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);

    %% Phi Tilde
    m = 'Compute phi tilde...'; counter = next_step(m, counter);
    phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(room.c)))); % K/T/Y/X
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "phi tilde mat"); display(size(phi_tilde_mat)); end
    % TODO: Make algorithm dependent on number of sources, evaluate
    % performance (better, worse?)  --> additional dimension for phi and psi
    clear norm_differences;
    fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);

    %% Angular Distances
    m = 'Compute angular distances...'; counter = next_step(m, counter);
    phi_diff = bsxfun(@minus,phi_mat,phi_tilde_mat);

    ang_dist = bsxfun(@power,abs(phi_diff),2);  % slower by about 1 sec on MBP
    %   ang_dist = abs(phi_mat-phi_tilde_mat).^2;     % slightly slower (maybe 0.1 sec on MBP)
    %   ang_dist = bsxfun(@power,abs(phi_mat-phi_tilde_mat),2);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "ext. ang_dist"); display(size(ang_dist)); end

    %% extend ang_dist to sixth dimension for S
    ang_dist_temp = ang_dist;
%     ang_dist = reshape(ang_dist, 1,)
    for i=1:em.S-1
        ang_dist = cat(6,ang_dist, ang_dist_temp);
    end
    ang_dist = permute(ang_dist, [6,1,2,3,4,5]);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "ext. ang_dist"); display(size(ang_dist)); end

    fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);
    clear phi_mat; clear phi_tilde_mat; clear phi_diff; clear ang_dist_temp;
    save('ang_dist.mat', 'ang_dist', '-v7.3', '-nocompression');
else
    m = 'Load ang_dist from disk...'; counter = next_step(m, counter);
    load('ang_dist.mat')
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "ang_dist"); display(size(ang_dist)); end
    fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);
end

%% EM Algorithm
m = 'EM-Iterations...'; counter = next_step(m, counter);
% Assign equal prior probabilities to each cluster.
% IDEA: Initialisierung anders gestalten? Eventuell besseres Ergebnis?
psi = ones(em.S, em.Ynet,em.Xnet,1) * (1 /(em.Xnet)*(em.Ynet));
if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "psi"); display(size(psi)); end
% TODO: Ausweiten auf gesamten Bereich (em.X instead of em.Xnet), auswerten ob Sources auch außerhalb erkannt werden.
psi_old = zeros(size(psi));

variance = em.var;
var_ret = zeros(em.iterations+1, 1);
var_ret(1) = em.var;

if return_all_psi
    psi_ret = zeros(em.iterations, size(psi, 1), size(psi, 2));
end
for iter = 1:em.iterations

    fprintf('%s EM Iter. #%2d: ', FORMAT_PREFIX, iter);
    fprintf('\x0394\x03C8 = %2.4f (t = %2.4f)\n', norm(psi(:)-psi_old(:)), toc);  % \x0394\x03C8 = Delta Psi

    psi_old = psi;

%% Expectation
%                                                                                 
    prob = bsxfun(@times, reshape(psi,em.S,1,1,em.Ynet,em.Xnet,1), prod( (1/(variance*pi) ) *exp(-ang_dist/(variance)),6));
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "prob"); display(size(prob)); end
    
    mu = bsxfun(@rdivide,prob,reshape(sum(sum(prob,5),4),em.S,em.K,em.T));
    mu(isnan(mu)) = 0;
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "mu"); display(size(mu)); end

%% Maximization
    psi = squeeze(sum(sum(mu,3),2)/(em.T*em.K));
    psi(psi<=0) = eps;  % reset negative values to the smallest possible positive value
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "maxim. psi"); display(size(psi)); end
    
    if ~em.var_fixed  %Try to use fixed variance to improve results?
        var_denominator = squeeze(sum(sum(sum(sum(sum(bsxfun(@times,reshape(mu,size(mu,1),size(mu,2),size(mu,3),size(mu,4),1),ang_dist),5),4),3),2),1));
        var_numerator = room.R_pairs*squeeze(sum(sum(sum(sum(mu,4),3),2),1));
        variance = var_denominator./var_numerator;
    end
    var_ret(iter+1)=variance;
    if return_all_psi
        psi_ret(iter, :, :) = psi;
    else
        psi_ret = psi;
    end
    if em.conv_threshold > 0
        if(norm(psi_old(:) - psi(:)) < em.conv_threshold), break; end
    end
end

% %% Delete outer margin (around microphones) to eliminate false peaks
% if size(psi_ret, 3) == 1  % return_all_psi == false
%     psi_ret(1,:) = 0;
%     psi_ret(size(psi, 1),:) = 0;
%     psi_ret(:,1) = 0;
%     psi_ret(:,size(psi, 2)) = 0;
% else  % return_all_psi == true
%     psi_ret(:, 1,:) = 0;
%     psi_ret(:, size(psi, 1),:) = 0;
%     psi_ret(:, :, 1) = 0;
%     psi_ret(:, :,size(psi, 2)) = 0;
% end
% psi_ret(iter+1:em.iterations,:,:) = [];  % remove zero rows, so size(psi, 1) gives actual em-iterations
% var_ret(iter+1:em.iterations) = [];  % remove zero rows, so size(psi, 1) gives actual em-iterations
end
