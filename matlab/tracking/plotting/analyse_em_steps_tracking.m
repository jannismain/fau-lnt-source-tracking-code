function analyse_em_steps_tracking(psi, var, room, sources)
%PLOT_EM_STEPS A helper to visualise the incremental changes in between em iterations
%
%   PARAMETERS:
%   psi: a history of estimates psi-matrices size(psi) = (trials x n_sources x coordinate)
%        Example: size(psi)=7x5x2 for 7 trials with 5 sources (and 2 coordinates)

if size(psi, 3) == 1, error("psi needs to be in the following shape: psi(trial, source, coordinate)"); end

iterations = size(psi, 1);
n_sources = size(room.S, 1);
% x_vals = linspace(0,em_iterations,em_iterations+1);
loc_est_sorted = zeros(iterations, n_sources, 2);
est_err = zeros(iterations, n_sources);

scr_size = get(0,'ScreenSize');
fig_size = [5*scr_size(3)/6 scr_size(4)/2];  % width x height
fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically
fig1 = figure('Name','EM Algorithm: Estimation Error Overview',...
              'NumberTitle','off',...
              'Color','white',...
              'Position', [fig_xpos scr_size(4)-fig_size(2)/1.5-50 fig_size(1) fig_size(2)/1.5],...
              'Visible','on',...
              'MenuBar','none');
fig2 = figure('Name',sprintf('EM Algorithm: \x03C8 across Iterations'),...
              'NumberTitle','off',...
              'Color','white',...
              'Position', [fig_xpos scr_size(4)-fig_size(2)-scr_size(4)/2 fig_size(1) fig_size(2)],...
              'Visible','on');

for i=1:iterations
    loc_est = estimate_location(squeeze(psi(i, :, :)), n_sources, 0, 1, room);
%     [loc_est_sorted(i,:,:), est_err(i,:)] = estimation_error(room.S, loc_est);
    % plot
    for s=1:n_sources+1
        figure(fig1);
        subplot_tight(1,n_sources+1,s)
        if s~=n_sources+1
            plot(loc_est(:, s), 'LineWidth',2,'Color',[0.4 0.4 0.4], 'Marker', 'x', 'MarkerSize', 12);
            title(sprintf("S%d Estimation Error", s));
        else  % last iteration, plot mean
            plot(mean(est_err, 2), 'LineWidth',2,'Color',[204/255 53/255 56/255], 'Marker', 'x', 'MarkerSize', 12);
            title("Average Estimation Error");
        end
        ylim([-0.1 4.0])
        yticks(linspace(0, 4, 21))
        grid on
    end

    %% PLOT PSI
    figure(fig2);
    subplot_tight(3,iterations,i)
    
    psi_plot = zeros(room.Y,room.X);
    psi_plot((room.N_margin+1):(room.Y-room.N_margin),(room.N_margin+1):(room.X-room.N_margin)) = squeeze(psi(i,:,:));
    
    imagesc(room.grid_x,room.grid_y,psi_plot)
    set(gca,'Ydir','Normal')
    set(gca, 'box', 'off')
    hold on

    plot(room.R(:, 1), room.R(:, 2),'x','MarkerSize', 12, 'Linewidth',2,'Color','g');    
    plot(room.S(:, 1), room.S(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','w');
    plot(loc_est(:, 1), loc_est(:, 2),'x','MarkerSize', 16, 'Linewidth',2,'Color','r');

    axis([0,room.dimensions(1),0,room.dimensions(2)]);
    subplot_tight(3,iterations,i+iterations)
    surf(room.grid_x,room.grid_y,psi_plot)
    view([45 25]);
    if i==1  % first iteration
        z = zlim;
        zMax = z(2);
    end
    zlim([0 zMax*3])
    shading interp
    
    %% PLOT DELTA PSI
    subplot_tight(3,iterations,i+2*iterations)
    if i>1
        psi_diff = squeeze(psi(i,:,:)-psi(i-1,:,:));
    else
        psi_diff = squeeze(psi(i,:,:));
    end
    psi_diff_plot = zeros(room.Y,room.X);
    psi_diff_plot((room.N_margin+1):(room.Y-room.N_margin),(room.N_margin+1):(room.X-room.N_margin)) = psi_diff(:,:);
    mesh(room.grid_x,room.grid_y,psi_diff_plot)
    view([45 10]);
    zlim([-zMax/3 zMax/3])
%     set(gca,'PlotBoxAspectRatio',[1 1 0.3])

    end

    figure('Name','EM Algorithm: Variance');
    plot(var, 'rx-', 'LineWidth', 1, 'MarkerSize', 6);
    ylim([0,1]);
    
end