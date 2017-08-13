function [ S_est ] = estimate_location(phi)
%ESTIMATE_LOCATION Estimates source locations
%   A Gaussian-Mixture-Model (GMM) is used together with the EM-Algorithm
%   to estimate the location of multiple sources inside a simulated
%   environment, based on the phase differences observed in various
%   microphone pairs around that environment.

%% START
cprintf('*blue', '\n<estimate_location.m>');
fprintf(' (t = %2.4f)\n', toc);
load('config.mat')
PLOT = [0 0 0 0 0 0 0]; % boolean plotting flag: [ all | step1 | step2 | ... | stepX ]

%% Stuff
m = "Initializing EM-Algorithm..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);

    freq_mat = reshape(fft_freq_range,em.K,1,1,1,1);
    phi_mat = reshape(phi,em.K,em.T,1,1,n_receiver_pairs);
    phi_mat = repmat(phi_mat,1,1,room.Y-2*room.N_margin,room.X-2*room.N_margin,1);
    
    fprintf('%s Compute distances...', FORMAT_PREFIX);
    norm_differences = zeros(room.Y-2*room.N_margin,room.X-2*room.N_margin,n_receiver_pairs);
    for mic_pair = 1:n_receiver_pairs
        for idx_x = (room.N_margin+1):(room.X-room.N_margin)
            for idx_y = (room.N_margin+1):(room.Y-room.N_margin)
                norm_differences(idx_y-room.N_margin,idx_x-room.N_margin,mic_pair) = norm([room.grid_x(idx_x),room.grid_y(idx_y)]-R(mic_pair*2),2) - norm([room.grid_x(idx_x),room.grid_y(idx_y)]-R(mic_pair*2-1),2);
            end
        end
    end
    
    norm_differences = reshape(norm_differences,1,1,size(norm_differences,1),size(norm_differences,2),size(norm_differences,3));
    fprintf(' done! (t = %2.4f)\n', toc);
    
    fprintf('%s Compute Phi Tilde...', FORMAT_PREFIX);
    phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*freq(fft_freq_range), (norm_differences)/(c)))); % K/T/Y/X
    
    clear norm_differences;
    fprintf(' done! (t = %s)\n', num2str(toc)');
    
    fprintf('%s Compute Angular Distances...', FORMAT_PREFIX);
    ang_dist = bsxfun(@power,abs((bsxfun(@minus,phi_mat,phi_tilde_mat))),2);
    fprintf(' done! (t = %s)\n', num2str(toc)');
    
    clear phi_mat;
    clear phi_tilde_mat;
    
    %% EM Algorithm
    % Assign equal prior probabilities to each cluster.
    psi = ones(room.Y-2*room.N_margin,room.X-2*room.N_margin,1) * (1 /(room.X-2*room.N_margin)*(room.Y-2*room.N_margin));
    psi_old = zeros(size(psi));
    
    % Use the overal variance of the dataset as the initial variance for each cluster.
    variance = 0.1;%10;
    
m = "Running EM-Algorithm..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    for iter = 1:10
        
        fprintf('%s Iteration #%2d: ', FORMAT_PREFIX, iter);
        fprintf('\x0394\x03C8 = %2.4f (t = %2.4f)\n', norm(psi(:)-psi_old(:)), toc);
        
        psi_old = psi;
        
        %% Expectation
        pdf = bsxfun(@times,reshape(psi,1,1,room.Y-2*room.N_margin,room.X-2*room.N_margin,1),prod((1 / (variance * pi))*exp(-ang_dist / (variance)),5));
        mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),em.K,em.T,1,1));
        mu(isnan(mu)) = 0;
        
        %% Maximization
        psi = squeeze(sum(sum(mu,2),1)/(em.T*em.K));
        psi(psi<=0) = eps;
        
        var_denominator = squeeze(sum(sum(sum(sum(sum(bsxfun(@times,reshape(mu,size(mu,1),size(mu,2),size(mu,3),size(mu,4),1),ang_dist),5),4),3),2),1));
        var_numerator = n_receiver_pairs*squeeze(sum(sum(sum(sum(mu,4),3),2),1));
        variance = var_denominator./var_numerator;
        
        
        psi_plot = zeros(room.Y,room.X);
        psi_plot((room.N_margin+1):(room.Y-room.N_margin),(room.N_margin+1):(room.X-room.N_margin)) = psi;
        
        cfg.conv_thres = 0.001;
        if(norm(psi_old(:) - psi(:)) < cfg.conv_thres)
            break;
        end
        
    end
    
    clear ang_dist;
    clear mu;
    clear pdf;
    
    thres_max = 0.5;
    
m = "Computing Localization Error..."; counter = next_step(m, counter, STEP, STOP_AFTER_STEP);
    
    psi_complete = psi;
    psi_trunc = zeros(size(psi_complete));
    psi_trunc(psi_complete>0.001) = psi_complete(psi_complete>0.001);
    psi_trunc_complete = psi_trunc;
    
    [maxX1,idx_maxX1] = max(max(psi,[],1));
    [maxY1,idx_maxY1] = max(max(psi,[],2));
    S_est1 = [room.grid_x(idx_maxX1),room.grid_y(idx_maxY1)];
    S_est1 = S_est1 + room.N_margin * room.grid_resolution;
    
    if((idx_maxY1>2)&&(idx_maxX1>2))
        for idx_Y = (idx_maxY1-2):(idx_maxY1+2)
            for idx_X = (idx_maxX1-2):(idx_maxX1+2)
                psi(idx_Y,idx_X) = 0;
            end
        end
    end
    
    [maxX2,idx_maxX2] = max(max(psi,[],1));
    [maxY2,idx_maxY2] = max(max(psi,[],2));
    S_est2 = [room.grid_x(idx_maxX2),room.grid_y(idx_maxY2)];
    S_est2 = S_est2 + room.N_margin * room.grid_resolution;
    
    if((idx_maxY2>2)&&(idx_maxX2>2))
        for idx_Y = (idx_maxY2-2):(idx_maxY2+2)
            for idx_X = (idx_maxX2-2):(idx_maxX2+2)
                psi(idx_Y,idx_X) = 0;
            end
        end
    end
    
    while(norm(S_est1-S_est2) < thres_max)
        psi(idx_maxY2,idx_maxX2) = 0;
        if(sum(sum(psi)) == 0)
            break
        end
        [~,idx_maxX2] = max(max(psi,[],1));
        [~,idx_maxY2] = max(max(psi,[],2));
        S_est2 = [room.grid_x(idx_maxX2),room.grid_y(idx_maxY2)];
        S_est2 = S_est2 + room.N_margin*room.grid_resolution;
    end
    
    for s = 1:1  % TODO 1:n_sources, when errors are vectorized
        S_est_diff1 = norm(S(1,:)-S_est1);
        S_est_diff2 = norm(S(2,:)-S_est2);
    end
    
    [est_error1_complete,idx_est_error_1] = min([S_est_diff1,S_est_diff2]);
    est_error2_complete = norm(S(3-idx_est_error_1,:)-S_est2);
    fprintf('    -> Estimation errors: %1.2f m   %1.2f m\n', est_error1_complete,est_error2_complete);
    
    diff1_rev = norm(S(1,:)-S_est2);
    S_est_diff2_rev = norm(S(2,:)-S_est2);
    [est_error2_complete_rev,idx_est_error_2_rev] = min([diff1_rev,S_est_diff2_rev]);
    est_error1_complete_rev = norm(S(3-idx_est_error_2_rev,:)-S_est1);
    fprintf('    -> Estimation errors: %1.2f m   %1.2f m\n', est_error1_complete_rev,est_error2_complete_rev);
    
    [~,idx_error] = min([est_error1_complete,est_error2_complete,est_error1_complete_rev,est_error2_complete_rev]);
    if(idx_error<=2)
        est_error1 = est_error1_complete;
        est_error2 = est_error2_complete;
    else
        est_error1 = est_error1_complete_rev;
        est_error2 = est_error2_complete_rev;
    end
    
    if PLOT(1) && PLOT(counter)
        figure(11)
        clf
        psi_plot((room.N_margin+1):(room.Y-room.N_margin),(room.N_margin+1):(room.X-room.N_margin)) = psi_complete;
        imagesc(room.grid_x,room.grid_y,psi_plot)
        set(gca,'Ydir','Normal')
        hold on
        
        for r = 1:n_receivers
            plot(R(r, 1), R(r, 2), 'x','MarkerSize', 12, 'Linewidth',2,'Color','g');
            hold on;
        end
        
        plot(S(:, 1), S(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','w');
        plot(S_est1(1), S_est1(2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');
        plot(S_est2(1), S_est2(2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');
        axis([0,room.dimensions(1),0,room.dimensions(2)])
        colorbar
        title(sprintf('GMM - Est. Err.: %1.2f m  %1.2f m  T60 = %1.2f sec', est_error1,est_error2,rir.t_reverb));
        xlabel('x-Axis \rightarrow')
        ylabel('y-Axis \rightarrow')
        pause(0.1)
    end
end

