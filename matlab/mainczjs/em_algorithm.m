function [ psi_ret, iter, var_ret] = em_algorithm(fn_cfg, phi, iterations, conv_threshold, verbose, prior)
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
if nargin<5, verbose = false; end
if nargin>5, fprintf('WARNING: Overriding prior from config (%s, was: %s)!\n', prior, em.prior); em.prior = prior; end

% PHI_MAT
if verbose, fprintf('%s %15s: ', FORMAT_PREFIX, 'phi'); disp(size(phi)); end
phi_mat = permute(phi,[1 2 4 5 3]);
if verbose, fprintf('%s %15s: ', FORMAT_PREFIX, 'phi mat'); disp(size(phi_mat)); end

% clever indexing...
emXidx = ones(em.Xnet, 1);  
emYidx = ones(em.Ynet, 1);
% ...instead of dumb replicating =)
% phi_mat = repmat(phi_mat,1,1,em.Ynet,em.Xnet,1, 1);
% if verbose, fprintf('%s %15s: ', 'FORMAT_PREFIX, 'repmat phi mat'); disp(size(phi_mat)); end

m = 'Compute distances...'; counter = next_step(m, counter);
norm_differences = zeros(1, 1, em.Ynet,em.Xnet,em.M);
for idx_pairs = 1:room.R_pairs
    for idx_x = (room.N_margin+1):(em.X-room.N_margin)
        for idx_y = (room.N_margin+1):(em.Y-room.N_margin)
            norm_differences(1, 1, idx_y-room.N_margin,idx_x-room.N_margin,idx_pairs) = ...
                norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2,1:2),2) - ...
                norm([room.grid_x(idx_x),room.grid_y(idx_y)]-room.R(idx_pairs*2-1,1:2),2);
        end
    end
end
if verbose, fprintf('%s %15s: ', FORMAT_PREFIX, 'norm_diff'); disp(size(norm_differences)); end
fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);

%% Phi Tilde
m = 'Compute phi tilde...'; counter = next_step(m, counter);
phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(room.c)))); % K/T/Y/X
if verbose, fprintf('%s %15s: ', FORMAT_PREFIX, 'phi tilde mat'); disp(size(phi_tilde_mat)); end
clear norm_differences; clear phi; 
fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);

%% Angular Distances
m = 'Compute angular distances...'; counter = next_step(m, counter);
ang_dist = abs(phi_mat(:,:,emXidx, emYidx, :)-phi_tilde_mat).^2;  % slower by about 1 sec on MBP
if verbose, fprintf('%s %15s: ', FORMAT_PREFIX, 'ang_dist'); disp(size(ang_dist)); end

m = 'Add additional dimension em.S to arg_dist...'; counter = next_step(m, counter);
ang_dist = permute(ang_dist, [6,1,2,3,4,5]);
emSidx = ones(em.S, 1);
if verbose, fprintf('%s %15s: ', FORMAT_PREFIX, 'ext. ang_dist'); disp(size(ang_dist)); end

fprintf('%s done! (t = %2.4f)\n', FORMAT_PREFIX, toc);
clear phi_mat; clear phi_tilde_mat;
% for debugging purposes, ang_dist can be saved and loaded!
%     save('ang_dist.mat', 'ang_dist', '-v7.3');

%% EM Algorithm
m = 'EM Initialisation...'; counter = next_step(m, counter);

switch em.prior
    case 'equal'
        psi = ones(em.S, em.Ynet,em.Xnet,1) * (1 /(em.Xnet)*(em.Ynet));
    case 'rand'
        psi = psi_random(em.S, em.Xnet, em.Ynet); % Random prior
    case 'hv'  % half-half vertical (random)
        psi = psi_half_half(em.S, em.Xnet, em.Ynet, true, 'vert');
    case 'hh'  % half-half horizontal (random)
        psi = psi_half_half(em.S, em.Xnet, em.Ynet, true, 'horz');
    case 'quart'  % quarter initialisation (random)
        psi = psi_quart(em.S, em.Xnet, em.Ynet, true, true);
    case 'schwartz2014'  % half-half vertical (equal)
        psi = psi_schwartz2014(em.S, em.Xnet, em.Ynet);
    case 'schwartz2014-unlucky'  % half-half horizontal (equal)
        psi = psi_schwartz2014(em.S, em.Xnet, em.Ynet, 'h');
    case 'quart-equal'  % half-half horizontal (equal)
        psi = psi_quart(em.S, em.Xnet, em.Ynet, true, false);
end

if verbose, fprintf('%s %15s: ', FORMAT_PREFIX, 'psi'); disp(size(psi)); end
% TODO: Ausweiten auf gesamten Bereich (em.X instead of em.Xnet), auswerten ob Sources auch außerhalb erkannt werden.
psi_old = zeros(size(psi));

variance = ones(em.S,1)*em.var;
var_ret = zeros(em.iterations+1, em.S);
var_ret(1, :) = variance;

psi_ret = zeros(em.iterations+1,em.S, size(psi, 2), size(psi, 3));
psi_ret(1,:,:,:) = psi;

m = 'EM Iterations...'; counter = next_step(m, counter); %#ok<*NASGU>
for iter = 1:em.iterations

    fprintf('%s EM Iter. #%2d: ', FORMAT_PREFIX, iter);
    fprintf('\x0394\x03C8 = %2.4f (t = %2.4f)\n', norm(psi(:)-psi_old(:)), toc);  % \x0394\x03C8 = Delta Psi

    psi_old = psi;

%% Expectation
    
    prob = permute(psi,[1,4,5,2,3,6]) .* prod( 1./(variance*pi) .* exp(-(ang_dist(emSidx,:,:,:,:,:)./variance)),6);  % fully vectorized
    
    if verbose&&iter==1, fprintf('%s %15s: ', FORMAT_PREFIX, 'prob'); disp(size(prob)); end

    mu = prob./sum(sum(sum(prob,5),4),1);
    mu(isnan(mu)) = 0;
    if verbose&&iter==1, fprintf('%s %15s: ', FORMAT_PREFIX, 'mu'); disp(size(mu)); end

%% Maximization
    psi = squeeze(sum(sum(mu,3),2)/(em.T*em.K));
    psi(psi<=0) = eps;  % reset negative values to the smallest possible positive value
    if verbose&&iter==1, fprintf('%s %15s: ', FORMAT_PREFIX, 'maxim. psi'); disp(size(psi)); end

    if ~em.var_fixed
        var_denominator = squeeze(sum(sum(sum(sum(sum(mu.*ang_dist,6),5),4),3),2));
        var_numerator = em.M.*squeeze(sum(sum(sum(sum(mu,5),4),3),2));
        variance = var_denominator./var_numerator;
    end
    
    var_ret(iter+1,:)=variance;
    psi_ret(iter+1,:, :, :) = psi;
    if em.conv_threshold > 0
        if(norm(psi_old(:) - psi(:)) < em.conv_threshold), break; end
    end
end

% below is only necessary, when convergence threshold is set
if conv_threshold > 0
    fprintf('You should probably add code to remove zero lines from return values, so the number of iterations is correct in subsequential functions!')
    % psi_ret(iter+1:em.iterations,:,:) = [];  % remove zero rows, so size(psi, 1) gives actual em-iterations
    % var_ret(iter+1:em.iterations) = [];  % remove zero rows, so size(psi, 1) gives actual em-iterations
end
