function [ psi ] = em_algorithm(phi, iterations)
%EM_ALGORITHM2 Summary of this function goes here
%   Detailed explanation goes here

fprintf('\n<%s.m>', mfilename);
fprintf(' (t = %2.4f)\n', toc);

load('config.mat');
if nargin>1, em.iterations = iterations; end

if ~(exist("em.T", 'var'))
    em.T = 296;
end

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
fprintf('%s done! (Elapsed Time = %s)\n', FORMAT_PREFIX, num2str(toc)');
    
%% Phi Tilde
    m = "Compute phi tilde..."; counter = next_step(m, counter);
    phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(room.c)))); % K/T/Y/X
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
    psi = ones(em.Y-2*room.N_margin,em.X-2*room.N_margin,1) * (1 /(em.X-2*room.N_margin)*(em.Y-2*room.N_margin));
    % N_margin: Berechnungen nur für Bereich innerhalb der Mikrofone. TODO:
    % Ausweiten auf gesamten Bereich, auswerten ob Sources auch außerhalb erkannt werden.
    psi_old = zeros(size(psi));
    
    variance = 0.1;%10; % Use the overal variance of the dataset as the initial variance for each cluster.
    for iter = 1:iterations
        
        fprintf('%s EM Iter. #%2d: ', FORMAT_PREFIX, iter);
        fprintf('\x0394\x03C8 = %2.4f (t = %02.4f)\n', norm(psi(:)-psi_old(:)), toc);  % \x0394\x03C8 = Delta Psi
        
        psi_old = psi;
        
    %% Expectation
        pdf = bsxfun(@times,reshape(psi,1,1,em.Y-2*room.N_margin,em.X-2*room.N_margin,1),prod((1 / (variance * pi))*exp(-ang_dist / (variance)),5));
        mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),em.K,em.T,1,1));
        mu(isnan(mu)) = 0;
        
    %% Maximization
        psi = squeeze(sum(sum(mu,2),1)/(em.T*em.K));
        psi(psi<=0) = eps;  % reset negative values to the smallest possible positive value
        % calculate variance
        % variance converges to a fixed value... TODO: Try to use fixed variance to
        % improve results?
        var_denominator = squeeze(sum(sum(sum(sum(sum(bsxfun(@times,reshape(mu,size(mu,1),size(mu,2),size(mu,3),size(mu,4),1),ang_dist),5),4),3),2),1));
        var_numerator = room.R_pairs*squeeze(sum(sum(sum(sum(mu,4),3),2),1));
        variance = var_denominator./var_numerator;
        
        if(norm(psi_old(:) - psi(:)) < em.conv_threshold), break; end
    end
    
%% Delete outer margin (around microphones) to eliminate false peaks
    psi(1,:) = 0;
    psi(size(psi, 1),:) = 0;
    psi(:,1) = 0;
    psi(:,size(psi, 2)) = 0;

end

