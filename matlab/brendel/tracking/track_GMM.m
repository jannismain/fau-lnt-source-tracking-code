clear all;
tic;

cfg.freq_range = 40:65; % checked

% set simulation parameters
cfg = set_params_ASN_GMM_tracking(cfg);

% simulate moving sources
[cfg.src_path,cfg.mic_path] = generate_sourcePath(cfg);

% create microphone observations (either create them by simulating RIRs or by loading sound files)
x = createMicSignals_ASN_vonMises_tracking(cfg);
% load('linear_movement_vertLines')
% load('arc_movement_Rev03')

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
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % needed for stored sound files
%     if(idx_pair > 6)
%         phi(:,:,idx_pair) = (X(cfg.freq_range,:,1)./X(cfg.freq_range,:,2)).*abs(X(cfg.freq_range,:,2)./X(cfg.freq_range,:,1));
%     end
    %%%%%%%%%%%%%%%%%%%%%%
end
clear x;
clear X;
fprintf(' done\n');

% Assign equal prior probabilities to each cluster.
psi = ones(cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1) * (1 /(cfg.X-2*cfg.N_margin)*(cfg.Y-2*cfg.N_margin));

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
phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*cfg.freq(cfg.freq_range), (norm_differences)/(cfg.c)))); % K/T/Y/X
clear norm_differences;
fprintf(' done\n');

fprintf('Compute Angular Distances...');
ang_dist = bsxfun(@power,abs((bsxfun(@minus,phi_mat,phi_tilde_mat))),2);
fprintf(' done\n');

clear phi_mat;
clear phi_tilde_mat;

%% perform EM algorithm
psi_old = zeros(size(psi));
plot_est = zeros(size(psi));
loc_est = zeros(2,cfg.T);
gamma = 0.1;%0.1;
cfg.block_length = 1;
variance = 2;
num_iter_inner = 1;

for iter = 1:(cfg.T - cfg.block_length)
    
    fprintf('  EM Iteration %2d', iter);
    fprintf('  EM Iteration %1.5f\n', norm(psi(:)-psi_old(:)));
    psi_old = psi;
    
    for iter_inner = 1:num_iter_inner
        %% Expectation
        pdf = bsxfun(@times,reshape(psi,1,1,cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1),prod((1 / (variance * pi))*exp(-ang_dist(:,iter+cfg.block_length,:,:,:) / (variance)),5));
        mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),cfg.K,1,1,1));
        mu(isnan(mu)) = 0;
        
        %% Maximization
        psi = squeeze(sum(mu,1)/(cfg.K));
        psi(psi<=0) = eps;
        
    end
    
    % recursive update for psi
    psi = psi_old + gamma*(psi - psi_old);
    
    psi_plot = zeros(cfg.Y,cfg.X);
    psi_plot((cfg.N_margin+1):(cfg.Y-cfg.N_margin),(cfg.N_margin+1):(cfg.X-cfg.N_margin)) = psi;
    
    % compute the two highest local maxima with distance thres_max
    psi_computeMax = psi;
    [~,idx_maxX1] = max(max(psi_computeMax,[],1));
    [~,idx_maxY1] = max(max(psi_computeMax,[],2));
    loc_est1(:,iter) = [cfg.mesh_x(idx_maxX1),cfg.mesh_y(idx_maxY1)] + cfg.N_margin*cfg.mesh_res;
    
    psi_computeMax(idx_maxY1,idx_maxX1) = 0;
    [~,idx_maxX2] = max(max(psi_computeMax,[],1));
    [~,idx_maxY2] = max(max(psi_computeMax,[],2));
    loc_est2(:,iter) = [cfg.mesh_x(idx_maxX2),cfg.mesh_y(idx_maxY2)]+ cfg.N_margin*cfg.mesh_res;
    thres_max = 2;
    while(norm(loc_est1(:,iter)-loc_est2(:,iter)) < thres_max)
        psi_computeMax(idx_maxY2,idx_maxX2) = 0;
        if(sum(sum(psi_computeMax))<100*eps)
            break;
        end
        [~,idx_maxX2] = max(max(psi_computeMax,[],1));
        [~,idx_maxY2] = max(max(psi_computeMax,[],2));
        loc_est2(:,iter) = [cfg.mesh_x(idx_maxX2),cfg.mesh_y(idx_maxY2)]+ cfg.N_margin*cfg.mesh_res;
    end
end

%% plot results
figure
count1 = 1;
count2 = 1;
count3 = 1;
color_step = 50;
colorfactor = 2;
for idx_T = 1:size(loc_est1,2)
    if(idx_T < 0.33*size(loc_est1,2))
        plot(loc_est1(1,idx_T),loc_est1(2,idx_T),'x','MarkerSize', 6,'Linewidth',4,'Color',[0,0,color_step*count1*colorfactor/(size(loc_est1,2))])
        hold on
        plot(loc_est2(1,idx_T),loc_est2(2,idx_T),'x','MarkerSize', 6,'Linewidth',4,'Color',[0,0,color_step*count1*colorfactor/(size(loc_est1,2))])
        plot(cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),1,1),cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),2,1),'.','MarkerSize', 8,'Linewidth',4,'Color',[0,0,color_step*count1*colorfactor/(size(loc_est1,2))])
        plot(cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),1,2),cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),2,2),'.','MarkerSize', 8,'Linewidth',4,'Color',[0,0,color_step*count1*colorfactor/(size(loc_est1,2))])
        if(mod(idx_T,color_step)==0)
            count1 = count1 + 1;
        end
    elseif(idx_T < 0.66*size(loc_est1,2))
        plot(loc_est1(1,idx_T),loc_est1(2,idx_T),'x','MarkerSize', 6,'Linewidth',4,'Color',[0,color_step*(count2*colorfactor)/(size(loc_est1,2)),0])
        hold on
        plot(loc_est2(1,idx_T),loc_est2(2,idx_T),'x','MarkerSize', 6,'Linewidth',4,'Color',[0,color_step*(count2*colorfactor)/(size(loc_est1,2)),0])
        plot(cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),1,1),cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),2,1),'.','MarkerSize', 8,'Linewidth',4,'Color',[0,color_step*(count2*colorfactor)/(size(loc_est1,2)),0])
        plot(cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),1,2),cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),2,2),'.','MarkerSize', 8,'Linewidth',4,'Color',[0,color_step*(count2*colorfactor)/(size(loc_est1,2)),0])
        if(mod(idx_T,color_step)==0)
            count2 = count2 + 1;
        end
    else
        plot(loc_est1(1,idx_T),loc_est1(2,idx_T),'x','MarkerSize', 6,'Linewidth',4,'Color',[color_step*(count3*colorfactor)/(size(loc_est1,2)),0,0])
        hold on
        plot(loc_est2(1,idx_T),loc_est2(2,idx_T),'x','MarkerSize', 6,'Linewidth',4,'Color',[color_step*(count3*colorfactor)/(size(loc_est1,2)),0,0])
        plot(cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),1,1),cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),2,1),'.','MarkerSize', 8,'Linewidth',4,'Color',[color_step*(count3*colorfactor)/(size(loc_est1,2)),0,0])
        plot(cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),1,2),cfg.src_path(ceil(idx_T*(size(cfg.src_path,1))/(size(loc_est1,2))),2,2),'.','MarkerSize', 8,'Linewidth',4,'Color',[color_step*(count3*colorfactor)/(size(loc_est1,2)),0,0])
        if(mod(idx_T,color_step)==0)
            count3 = count3 + 1;
        end
    end
end
title('GMM')
xlabel('x-axis \rightarrow')
ylabel('y-axis \rightarrow')
axis([0,cfg.synth_room.dim(1),0,cfg.synth_room.dim(2)])
grid on
disp(['Elapsed Time = ', num2str(toc)])
