function [ fig ] = plot_results( psi, loc_est, cfg )
%PLOT_RESULTS Plots location estimation results
%   Detailed explanation goes here

    scr_size = get(0,'ScreenSize');
    fig_size = [2*scr_size(3)/3 scr_size(4)/2];  % width x height
    fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
    fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically
    fig = figure('Name','Location Estimate Result',...
                  'NumberTitle','off',...
                  'Color','white',...
                  'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)]);
    subplot_tight(1,2,1);
    imagesc(cfg.mesh_x,cfg.mesh_y,psi)
    set(gca,'Ydir','Normal')
    set(gca, 'box', 'off')
    hold on
    for idx_pair = 1:cfg.n_pairs
        plot(cfg.synth_room.mloc(:, 1,idx_pair), cfg.synth_room.mloc(:, 2,idx_pair), 'x','MarkerSize', 12, 'Linewidth',2,'Color','g');
        hold on;
    end
    
    plot(cfg.synth_room.sloc(:, 1), cfg.synth_room.sloc(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','w');
    for i=1:size(loc_est, 1)
        plot(loc_est(i, 1), loc_est(i, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');
    end
    axis([0,cfg.synth_room.dim(1),0,cfg.synth_room.dim(2)]);
    % colorbar('East', 'AxisLocation', 'out', 'Ticks', [0.01 0.02 0.03]);
    % colormap(flipud(gray));  % apply inverted b/w colormap
    % title(sprintf('Location Estimate\n(Est. Err.: %1.2fm, %1.2fm, T60=%1.2fs)', est_error1,est_error2,cfg.synth_room.t60));
    subplot_tight(1,2,2);
    surf(cfg.mesh_x,cfg.mesh_y,psi)
    view([-65 25]);
    shading interp
    pause(0.1)

end

