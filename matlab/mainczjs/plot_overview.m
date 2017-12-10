function [ fig ] = plot_overview( psi, variance, iterations, em, room, archive, save_to, save_to_matlab)
%PLOT_OVERVIEW Plots history of psi and var

if nargin<8, save_to_matlab = save_to; end

scr_size = get(0,'ScreenSize');
fig_size = [scr_size(3)/5 scr_size(4)];  % width x height
fig_xpos = ceil((scr_size(3)-fig_size(1))/2); % center the figure on the screen horizontally
fig_ypos = ceil((scr_size(4)-fig_size(2))/2); % center the figure on the screen vertically
fig = figure('Name','Overview of EM Algorithm Steps',...
              'NumberTitle','off',...
              'Color','white',...
              'Position', [fig_xpos fig_ypos fig_size(1) fig_size(2)]);%,...
              %'Visible','off');  TODO: Comment this back in for trial runs!

    %% Plotting history of psi and variance
    rows = iterations+1;
    psi_plot = zeros(iterations+1,em.S,em.Y,em.X);
    psi_plot(:,:,(room.N_margin+1):(em.Y_idxMax),(room.N_margin+1):(em.X_idxMax)) = psi;
    for r=1:rows
        for s=1:em.S
            subplot(rows,em.S,((r-1)*em.S)+s); hold on
            % if r<rows  % print psi
                axis([0,room.dimensions(1),0,room.dimensions(2)]);
                surf(room.grid_x,room.grid_y,squeeze(psi_plot(r,s,:,:)))
                % if r<rows-1  % comment this in to switch view of last psi plot
                    view([-45 45]);
                % else
                %     view([0 90]);
                % end
                shading interp
            % else  % print variance in last row
            %     plot(linspace(0,iterations,iterations+1), variance(:,s), '-x')
            %     axis([0,iterations,0,1.5])
            %     xticks(linspace(0,iterations,iterations+1))
            %     yticks(linspace(0,1.50,7))
            % end
        end
    end

    if strcmp(archive, 'tex') || strcmp(archive, 'both') || strcmp(archive, 'all')
        matlab2tikz(strcat(save_to, '.tex'), 'figurehandle', fig, 'imagesAsPng', true, 'checkForUpdates', false, 'externalData', false, 'dataPath', [getuserdir filesep 'thesis' filesep 'latex' filesep 'data' filesep 'plots' filesep 'tikz-data'], 'noSize', false, 'showInfo', false);
    end
    if strcmp(archive, 'fig') || strcmp(archive, 'both') || strcmp(archive, 'all')
        saveas(fig, strcat(save_to_matlab, '.fig'), 'fig');
    end
    if strcmp(archive, 'png') || strcmp(archive, 'all')
        print(fig, strcat(save_to, '.png'), '-dpng', '-noui','-r150')
    end
end
