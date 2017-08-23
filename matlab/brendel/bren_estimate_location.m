function [ est_error1, est_error2 ] = bren_estimate_location( cfg, phi )
%BREN_ESTIMATE_LOCATION Summary of this function goes here
%   Detailed explanation goes here
    
    PLOT_ROOM_BORDER = 1;

    if ~(exist("cfg.T", 'var'))
        cfg.T = 296;
    end

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
    fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
    
    fprintf('Compute Phi Tilde...');
    phi_tilde_mat = exp(-1i*(bsxfun(@times,2*pi*cfg.freq(cfg.freq_range), (norm_differences)/(cfg.c)))); % K/T/Y/X
    
    clear norm_differences;
    fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
    
    fprintf('Compute Angular Distances...');
    ang_dist = bsxfun(@power,abs((bsxfun(@minus,phi_mat,phi_tilde_mat))),2);
    fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
    
    clear phi_mat;
    clear phi_tilde_mat;
    
    %% EM Algorithm
    % Assign equal prior probabilities to each cluster.
    psi = ones(cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1) * (1 /(cfg.X-2*cfg.N_margin)*(cfg.Y-2*cfg.N_margin));
    psi_old = zeros(size(psi));
    
    % Use the overal variance of the dataset as the initial variance for each cluster.
    variance = 0.1;%10;
    for iter = 1:10
        
        fprintf('  EM Iter. #%2d: ', iter);
        fprintf('\x0394\x03C8 = %2.4f (t = %2.4f)\n', norm(psi(:)-psi_old(:)), toc);  % \x0394\x03C8 = Delta Psi
        
        psi_old = psi;
        
        %% Expectation
        pdf = bsxfun(@times,reshape(psi,1,1,cfg.Y-2*cfg.N_margin,cfg.X-2*cfg.N_margin,1),prod((1 / (variance * pi))*exp(-ang_dist / (variance)),5));
        mu = bsxfun(@rdivide,pdf,reshape(sum(sum(pdf,4),3),cfg.K,cfg.T,1,1));
        mu(isnan(mu)) = 0;
        
        %% Maximization
        psi = squeeze(sum(sum(mu,2),1)/(cfg.T*cfg.K));
        psi(psi<=0) = eps;
        
        var_denominator = squeeze(sum(sum(sum(sum(sum(bsxfun(@times,reshape(mu,size(mu,1),size(mu,2),size(mu,3),size(mu,4),1),ang_dist),5),4),3),2),1));
        var_numerator = cfg.n_pairs*squeeze(sum(sum(sum(sum(mu,4),3),2),1));
        variance = var_denominator./var_numerator;
        
        psi_plot = zeros(cfg.Y,cfg.X);
        psi_plot((cfg.N_margin+1):(cfg.Y-cfg.N_margin),(cfg.N_margin+1):(cfg.X-cfg.N_margin)) = psi;
        
        cfg.conv_thres = 0.001;
        if(norm(psi_old(:) - psi(:)) < cfg.conv_thres)
            break;
        end
        
    end
    
    clear ang_dist;
    clear mu;
    clear pdf;
    
    thres_max = 0.5;
    fprintf('compute localization errors...\n')
    psi_complete = psi;
    psi_trunc = zeros(size(psi_complete));
    psi_trunc(psi_complete>0.001) = psi_complete(psi_complete>0.001);
    psi_trunc_complete = psi_trunc;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [~,idx_maxX1] = max(max(psi,[],1));
    [~,idx_maxY1] = max(max(psi,[],2));
    loc_est1 = [cfg.mesh_x(idx_maxX1),cfg.mesh_y(idx_maxY1)];
    loc_est1 = loc_est1 + cfg.N_margin*cfg.mesh_res;
    
    if((idx_maxY1>2)&&(idx_maxX1>2))
        for idx_Y = (idx_maxY1-2):(idx_maxY1+2)
            for idx_X = (idx_maxX1-2):(idx_maxX1+2)
                psi(idx_Y,idx_X) = 0;
            end
        end
    end
    
    [~,idx_maxX2] = max(max(psi,[],1));
    [~,idx_maxY2] = max(max(psi,[],2));
    loc_est2 = [cfg.mesh_x(idx_maxX2),cfg.mesh_y(idx_maxY2)]+ cfg.N_margin*cfg.mesh_res;
    
    if((idx_maxY2>2)&&(idx_maxX2>2))
        for idx_Y = (idx_maxY2-2):(idx_maxY2+2)
            for idx_X = (idx_maxX2-2):(idx_maxX2+2)
                psi(idx_Y,idx_X) = 0;
            end
        end
    end
    
    while(norm(loc_est1-loc_est2) < thres_max)
        psi(idx_maxY2,idx_maxX2) = 0;
        if(sum(sum(psi)) == 0)
            break
        end
        [~,idx_maxX2] = max(max(psi,[],1));
        [~,idx_maxY2] = max(max(psi,[],2));
        loc_est2 = [cfg.mesh_x(idx_maxX2),cfg.mesh_y(idx_maxY2)]+ cfg.N_margin*cfg.mesh_res;
    end
    
    diff1 = norm(cfg.synth_room.sloc(1,1:2)-loc_est1);
    diff2 = norm(cfg.synth_room.sloc(2,1:2)-loc_est1);
    [est_error1_complete,idx_est_error_1] = min([diff1,diff2]);
    est_error2_complete = norm(cfg.synth_room.sloc(3-idx_est_error_1,1:2)-loc_est2);
    fprintf('    -> Estimation errors: %1.2f m   %1.2f m\n', est_error1_complete,est_error2_complete);
    
    diff1_rev = norm(cfg.synth_room.sloc(1,1:2)-loc_est2);
    diff2_rev = norm(cfg.synth_room.sloc(2,1:2)-loc_est2);
    [est_error2_complete_rev,idx_est_error_2_rev] = min([diff1_rev,diff2_rev]);
    est_error1_complete_rev = norm(cfg.synth_room.sloc(3-idx_est_error_2_rev,1:2)-loc_est1);
    fprintf('    -> Estimation errors: %1.2f m   %1.2f m\n', est_error1_complete_rev,est_error2_complete_rev);
    
    [~,idx_error] = min([est_error1_complete,est_error2_complete,est_error1_complete_rev,est_error2_complete_rev]);
    if(idx_error<=2)
        est_error1 = est_error1_complete;
        est_error2 = est_error2_complete;
    else
        est_error1 = est_error1_complete_rev;
        est_error2 = est_error2_complete_rev;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    psi_plot((cfg.N_margin+1):(cfg.Y-cfg.N_margin),(cfg.N_margin+1):(cfg.X-cfg.N_margin)) = psi_complete;
    imagesc(cfg.mesh_x,cfg.mesh_y,psi_plot)
    set(gca,'Ydir','Normal')
    set(gca, 'box', 'off')
    hold on
    for idx_pair = 1:cfg.n_pairs
        plot(cfg.synth_room.mloc(:, 1,idx_pair), cfg.synth_room.mloc(:, 2,idx_pair), 'x','MarkerSize', 12, 'Linewidth',2,'Color','g');
        hold on;
    end
    plot(cfg.synth_room.sloc(:, 1), cfg.synth_room.sloc(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','w');
    plot(loc_est1(1), loc_est1(2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');
    plot(loc_est2(1), loc_est2(2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');
    axis([-PLOT_ROOM_BORDER,cfg.synth_room.dim(1)+PLOT_ROOM_BORDER,-PLOT_ROOM_BORDER,cfg.synth_room.dim(2)+PLOT_ROOM_BORDER]);
    colorbar('East', 'AxisLocation', 'out', 'Ticks', [0.01 0.02 0.03]);
%     colormap(flipud(gray));  % apply inverted b/w colormap
    title(sprintf('Location Estimate\n(Est. Err.: %1.2fm, %1.2fm, T60=%1.2fs)', est_error1,est_error2,cfg.synth_room.t60));
    pause(0.1)

end

