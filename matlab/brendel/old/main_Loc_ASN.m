
clear all

cfg.freq_range = (40:70)*2;
% cfg.freq_range = 16:48;
% cfg.freq_range = 5:30;

% set simulation parameters
cfg = set_params_ASN(cfg);

% create microphone signals
x = createMicSignals_ASN(cfg);

% Perform STFT-transform
fprintf('Compute phase differences...');
cfg.T = floor((size(x,1)-cfg.winpts)/cfg.steppts)+1;
X = zeros(cfg.n_bins,cfg.T,cfg.n_mic);
phi = zeros(cfg.K,cfg.T,cfg.n_pairs);
for idx_pair = 1:cfg.n_pairs
    for idx_mic = 1:cfg.n_mic
        X(:,:,idx_mic) = specgram(x(:,idx_mic,idx_pair),cfg.nfft,cfg.fs,cfg.window,cfg.n_overlap);
    end
    phi(:,:,idx_pair) = (X(cfg.freq_range,:,2)./X(cfg.freq_range,:,1)).*abs(X(cfg.freq_range,:,1)./X(cfg.freq_range,:,2));
end
% Improvements over implementation of schwartz_gannot
% - zuordnung von sprecher (s) und beitrag (psi) klappt nicht... -> s herausnehmen

clear x;
clear X;
fprintf(' done\n');

% Use the overal variance of the dataset as the initial variance for each cluster.
variance = 10;
% in paper: mean is fix, variance is estimated... here variance is fixed,
% as variance highly depends on grid layout, not on source position
% TODO: check this!

% Assign equal prior probabilities to each cluster.
psi = ones(cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1) * (1 /(cfg.X-2*cfg.N_margin)*(cfg.Y-2*cfg.N_margin));
% n_margin is border around mics

freq_mat = reshape(cfg.freq_range,cfg.K,1,1,1,1);
phi_mat = reshape(phi,cfg.K,cfg.T,1,1,cfg.n_pairs);
phi_mat = repmat(phi_mat,1,1,cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1);

fprintf('Compute distances...');
norm_differences = zeros(cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,cfg.n_pairs);
for idx_pairs = 1:cfg.n_pairs
    for idx_x = (cfg.N_margin+1):(cfg.X-cfg.N_margin)
        for idx_y = (cfg.N_margin+1):(cfg.Y-cfg.N_margin)
            norm_differences(idx_y-cfg.N_margin,idx_x-cfg.N_margin,idx_pairs) = norm([cfg.mesh_x(idx_x),cfg.mesh_y(idx_y)]-cfg.synth_room.mloc(2,1:2,idx_pairs),2) - norm([cfg.mesh_x(idx_x),cfg.mesh_y(idx_y)]-cfg.synth_room.mloc(1,1:2,idx_pairs),2);
        end
    end
end
norm_differences = reshape(norm_differences,1,1,size(norm_differences,1),size(norm_differences,2),size(norm_differences,3));
fprintf(' done\n');

fprintf('Compute Phi Tilde...');
phi_tilde_mat = exp(-1i*(bsxfun(@times,(2*pi*freq_mat)/(cfg.K), (norm_differences*cfg.fs)/(cfg.c)))); % K/T/Y/X
clear norm_differences;
fprintf(' done\n');

fprintf('Compute Angular Distances...');
ang_dist = bsxfun(@power,abs((bsxfun(@minus,phi_mat,phi_tilde_mat))),2);
% ang_dist is fixed, computed only once here
fprintf(' done\n');

clear phi_mat;
clear phi_tilde_mat;

psi_old = zeros(size(psi));

for iter = 1:10
    
    fprintf('  EM Iteration %d', iter);
    fprintf('  EM Iteration %1.5f\n', norm(psi(:)-psi_old(:)));
    
    psi_old = psi;
    
    
    %% Expectation
    pdf = bsxfun(@times,reshape(psi,1,1,cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1),prod((1 / (variance * pi))*exp(-ang_dist / (variance)),5));
    mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),cfg.K,cfg.T,1,1));
    % bsxfun does elementwise operations, faster than .\ or .*
    mu(isnan(mu)) = 0;
    
    %% Maximization
    psi = squeeze(sum(sum(mu,2),1)/(cfg.T*cfg.K));
    
    psi_plot = (-1)*ones(cfg.Y,cfg.X)*inf;
    psi_plot((cfg.N_margin+1):(cfg.Y-cfg.N_margin),(cfg.N_margin+1):(cfg.X-cfg.N_margin)) = psi;
    
%     figure(2)
%     clf
%     imagesc(cfg.mesh_x,cfg.mesh_y,psi_plot)
%     set(gca,'Ydir','Normal')
%     hold on
%     for idx_pair = 1:cfg.n_pairs
%         plot(cfg.synth_room.mloc(:, 1,idx_pair), cfg.synth_room.mloc(:, 2,idx_pair), 'x','MarkerSize', 12, 'Linewidth',2,'Color','g');
%         hold on;
%     end
%     plot(cfg.synth_room.sloc(:, 1), cfg.synth_room.sloc(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','w');
%     axis([0,cfg.synth_room.dim(1),0,cfg.synth_room.dim(2)])
%     colorbar
%     pause(0.01)
    
    cfg.conv_thres = 0.001;
    if(norm(psi_old(:) - psi(:)) < cfg.conv_thres)
        break;
    end
    
end
[loc_est1, loc_est2] = plot_results_MixtureModel_ASN_Gauss(cfg,psi,psi_plot);
