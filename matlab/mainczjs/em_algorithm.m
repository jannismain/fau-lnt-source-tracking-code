function [ psi ] = em_algorithm2(cfg, phi, iterations)
%EM_ALGORITHM2 Summary of this function goes here
%   Detailed explanation goes here

cprintf('*blue', '\n<%s.m>', mfilename);
fprintf(' (t = %2.4f)\n', toc);

load('config.mat');
if nargin<3, iterations = 10; end

if ~(exist("cfg.T", 'var'))
    cfg.T = 296;
end

freq_mat = reshape(fft_freq_range,cfg.K,1,1,1,1);
phi_mat = reshape(phi,cfg.K,cfg.T,1,1,cfg.n_pairs);
phi_mat = repmat(phi_mat,1,1,cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1);

m = "Compute distances..."; counter = next_step(m, counter);
norm_differences = zeros(cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,cfg.n_pairs);
for idx_pairs = 1:cfg.n_pairs
    for idx_x = (cfg.N_margin+1):(cfg.X-cfg.N_margin)
        for idx_y = (cfg.N_margin+1):(cfg.Y-cfg.N_margin)
            norm_differences(idx_y-cfg.N_margin,idx_x-cfg.N_margin,idx_pairs) = norm([cfg.mesh_x(idx_x),cfg.mesh_y(idx_y)]-cfg.synth_room.mloc(2,1:2,idx_pairs),2) - norm([cfg.mesh_x(idx_x),cfg.mesh_y(idx_y)]-cfg.synth_room.mloc(1,1:2,idx_pairs),2);
        end
    end
end

norm_differences = reshape(norm_differences,1,1,size(norm_differences,1),size(norm_differences,2),size(norm_differences,3));
fprintf('%s done! (Elapsed Time = %s)\n', FORMAT_PREFIX, num2str(toc)');
    
%% Phi Tilde
    m = "Compute phi tilde..."; counter = next_step(m, counter);
    phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(cfg.c)))); % K/T/Y/X
    % TODO: Make algorithm dependent on number of sources, evaluate
    % performance (better, worse?)  --> additional dimension for phi and
    % psi
    clear norm_differences;
    fprintf('%s done! (Elapsed Time = %s)\n', FORMAT_PREFIX, num2str(toc)');

%% Angular Distances
    m = "Compute angular distances..."; counter = next_step(m, counter);
    
%   ang_dist = bsxfun(@power,abs((bsxfun(@minus,phi_mat,phi_tilde_mat))),2);  % slower by about 1 sec on MBP
%   ang_dist = abs(phi_mat-phi_tilde_mat).^2;                                 % slightly slower (maybe 0.1 sec on MBP)
    ang_dist = bsxfun(@power,abs(phi_mat-phi_tilde_mat),2);

    fprintf('%s done! (Elapsed Time = %s)\n', FORMAT_PREFIX, num2str(toc)');
    clear phi_mat;
    clear phi_tilde_mat;
    
%% EM Algorithm
    m = "EM-Iterations..."; counter = next_step(m, counter);
    % Assign equal prior probabilities to each cluster.
    % TODO: Initialisierung anders gestalten? Eventuell besseres Ergebnis?
    psi = ones(cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1) * (1 /(cfg.X-2*cfg.N_margin)*(cfg.Y-2*cfg.N_margin));
    % N_margin: Berechnungen nur für Bereich innerhalb der Mikrofone. TODO:
    % Ausweiten auf gesamten Bereich
    psi_old = zeros(size(psi));
    
    variance = 0.1;%10; % Use the overal variance of the dataset as the initial variance for each cluster.
    for iter = 1:10
        
        fprintf('%s EM Iter. #%2d: ', FORMAT_PREFIX, iter);
        fprintf('\x0394\x03C8 = %2.4f (t = %02.4f)\n', norm(psi(:)-psi_old(:)), toc);  % \x0394\x03C8 = Delta Psi
        
        psi_old = psi;
        
    %% Expectation
        pdf = bsxfun(@times,reshape(psi,1,1,cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1),prod((1 / (variance * pi))*exp(-ang_dist / (variance)),5));
        mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),cfg.K,cfg.T,1,1));
        mu(isnan(mu)) = 0;
        
    %% Maximization
        psi = squeeze(sum(sum(mu,2),1)/(cfg.T*cfg.K));
        psi(psi<=0) = eps;  % reset negative values to the smallest possible positive value
        % calculate variance
        % variance converges to a fixed value... TODO: Try to use fixed variance to
        % improve results?
        var_denominator = squeeze(sum(sum(sum(sum(sum(bsxfun(@times,reshape(mu,size(mu,1),size(mu,2),size(mu,3),size(mu,4),1),ang_dist),5),4),3),2),1));
        var_numerator = cfg.n_pairs*squeeze(sum(sum(sum(sum(mu,4),3),2),1));
        variance = var_denominator./var_numerator;
        
        if(norm(psi_old(:) - psi(:)) < cfg.conv_thres), break; end
        
    end

    % clear ang_dist; clear mu; clear pdf;  % takes 0.2s, not needed
        
    thres_max = 0.5;
    
    size(psi)
    psi(1,:) = 0;
    psi(size(psi, 1),:) = 0;
    psi(:,1) = 0;
    psi(:,size(psi, 2)) = 0;
    psi_complete = psi;

end

