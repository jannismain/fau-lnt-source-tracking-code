function [ psi_ret, iter, var_ret] = em_algorithm(fn_cfg, phi, iterations, conv_threshold, return_all_psi, verbose, prior)
%EM_ALGORITHM Uses the em-algorithm to find parameters of a gaussian mixture model based
%on phi
%   Detailed explanation goes here
%   ARG: fn_cfg: filename of config file (str; e.g. 'config_t3mv6.mat')
%   ARG: phi: matrix with gaussian components ()
%   ARG: iterations: max. number of em-iterations
%   ARG: conv_threshold: em-iterations stop early, when change in psi is lower than conv_threshold (provide -1 to prevent early stopping)
%   ARG: verbose: will print size of intermediary results (bool)
%   ARG: prior: prior initialisation of psi (str; 'rand', 'hv', 'hh', 'equal')

fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);
load(fn_cfg);
if nargin>2, em.iterations = iterations; fprintf('WARNING: Overriding EM-Iterations (%d)!\n', iterations); end
if nargin>3, em.conv_threshold = conv_threshold; fprintf('WARNING: Overriding EM convergence threshold (%d)!\n', conv_threshold); end
if nargin<5, return_all_psi = false; end
if nargin<6, verbose = false; end
if nargin>6, fprintf('WARNING: Overriding prior from config (%d, was: %d)!\n', prior, em.prior); em.prior = prior; end

if ~(exist('ang_dist.mat', 'file') == 2)
    % FREQ_MAT
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "fft_freq_range"); disp(size(fft_freq_range)); end
    freq_mat = reshape(fft_freq_range,em.K,1,1,1,1);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "new freq mat"); disp(size(freq_mat)); end

    % PHI_MAT
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "phi"); disp(size(phi)); end
    %% extend phi_mat to sixth dimension for S and reshape into form!
    % phi_mat = phi;
    % for i=1:em.S-1
    %     phi_mat = cat(4,phi_mat, phi);
    % end
    % phi_mat = reshape(phi_mat,em.K,em.T,1,1,em.M, em.S);
    % if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "phi mat"); display(size(phi_mat)); end
    phi_mat = reshape(phi,em.K,em.T,1,1,em.M);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "phi mat"); disp(size(phi_mat)); end
    phi_mat = repmat(phi_mat,1,1,em.Ynet,em.Xnet,1, 1);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "repmat phi mat"); disp(size(phi_mat)); end

    m = 'Compute distances...'; counter = next_step(m, counter);
    norm_differences = zeros(em.Ynet,em.Xnet,em.M);
    for idx_pairs = 1:room.R_pairs
        for idx_x = (room.N_margin+1):(em.X-room.N_margin)
            for idx_y = (room.N_margin+1):(em.Y-room.N_margin)
                norm_differences(idx_y-room.N_margin,idx_x-room.N_margin,idx_pairs) = norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2,1:2),2) - norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2-1,1:2),2);
            end
        end
    end
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "norm_diff"); disp(size(norm_differences)); end
    norm_differences = reshape(norm_differences,1,1,size(norm_differences,1),size(norm_differences,2),size(norm_differences,3));
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "new norm_diff"); disp(size(norm_differences)); end
    fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);

    %% Phi Tilde
    m = 'Compute phi tilde...'; counter = next_step(m, counter);
    phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(room.c)))); % K/T/Y/X
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "phi tilde mat"); disp(size(phi_tilde_mat)); end
    clear norm_differences;
    fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);

    %% Angular Distances
    m = 'Compute angular distances...'; counter = next_step(m, counter);
    ang_dist = abs(phi_mat-phi_tilde_mat).^2;  % slower by about 1 sec on MBP
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "ang_dist"); disp(size(ang_dist)); end

    m = 'Add additional dimension em.S to arg_dist...'; counter = next_step(m, counter);
    ang_dist = repmat(permute(ang_dist, [6,1,2,3,4,5]), em.S, 1);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "ext. ang_dist"); disp(size(ang_dist)); end

    fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);
    clear phi_mat; clear phi_tilde_mat;
    % for debugging purposes, ang_dist can be saved and loaded!
%     save('ang_dist.mat', 'ang_dist', '-v7.3');
else
    m = 'Load ang_dist from disk...'; counter = next_step(m, counter);
    load('ang_dist.mat')
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "ang_dist"); disp(size(ang_dist)); end
    fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);
end

%% EM Algorithm
m = 'EM Initialisation...'; counter = next_step(m, counter);

switch em.prior
    case 'equal'
        psi = ones(em.S, em.Ynet,em.Xnet,1) * (1 /(em.Xnet)*(em.Ynet));
    case 'rand'
        psi = psi_random(em.S, em.Xnet, em.Ynet); % Random prior
    case 'hv'  % half-half vertical
        psi = psi_half_half(em.S, em.Xnet, em.Ynet, true, 'vert');
    case 'hh'  % half-half horizontal
        psi = psi_half_half(em.S, em.Xnet, em.Ynet, true, 'horz');
end

if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "psi"); disp(size(psi)); end
% TODO: Ausweiten auf gesamten Bereich (em.X instead of em.Xnet), auswerten ob Sources auch außerhalb erkannt werden.
psi_old = zeros(size(psi));

variance = ones(em.S,1)*em.var;
var_ret = zeros(em.iterations+1, em.S);
var_ret(1, :) = variance;

if return_all_psi
    psi_ret = zeros(em.iterations+1,em.S, size(psi, 2), size(psi, 3));
    psi_ret(1,:,:,:) = psi;
end

m = 'EM Iterations...'; counter = next_step(m, counter);
for iter = 1:em.iterations

    fprintf('%s EM Iter. #%2d: ', FORMAT_PREFIX, iter);
    fprintf('\x0394\x03C8 = %2.4f (t = %2.4f)\n', norm(psi(:)-psi_old(:)), toc);  % \x0394\x03C8 = Delta Psi

    psi_old = psi;

%% Expectation       
    prob = permute(psi,[1,4,5,2,3,6]) .* prod( 1./(variance*pi) .* exp(-(ang_dist./variance)),6);
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "prob"); disp(size(prob)); end
    
    mu = prob./sum(sum(sum(prob,5),4),1);
    mu(isnan(mu)) = 0;
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "mu"); disp(size(mu)); end

%% Maximization
    psi = squeeze(sum(sum(mu,3),2)/(em.T*em.K));
    psi(psi<=0) = eps;  % reset negative values to the smallest possible positive value
    if verbose, fprintf("%s %15s: ", FORMAT_PREFIX, "maxim. psi"); disp(size(psi)); end
    
    if ~em.var_fixed
        var_denominator = squeeze(sum(sum(sum(sum(sum(mu.*ang_dist,6),5),4),3),2));
        var_numerator = em.M.*squeeze(sum(sum(sum(sum(mu,5),4),3),2));
        variance = var_denominator./var_numerator;
    end
    var_ret(iter+1,:)=variance;
    if return_all_psi
        psi_ret(iter+1,:, :, :) = psi;
    end
    if em.conv_threshold > 0
        if(norm(psi_old(:) - psi(:)) < em.conv_threshold), break; end
    end
end
if ~return_all_psi
    psi_ret = psi;
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
% below is only necessary, when convergence threshold is set
if conv_threshold > 0
    fprintf("You should probably add code to remove zero lines from return values, so the number of iterations is correct in subsequential functions!")
    % psi_ret(iter+1:em.iterations,:,:) = [];  % remove zero rows, so size(psi, 1) gives actual em-iterations
    % var_ret(iter+1:em.iterations) = [];  % remove zero rows, so size(psi, 1) gives actual em-iterations
end
