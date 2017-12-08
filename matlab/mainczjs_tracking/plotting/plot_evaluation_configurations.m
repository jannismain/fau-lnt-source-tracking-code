% change into working directory, so temporary files are in one (and only one) place
oldpath = pwd;
PATH_SRC = [getuserdir filesep 'thesis' filesep 'src' filesep 'matlab' filesep 'temp'];
[~,~] = mkdir(PATH_SRC); cd(PATH_SRC);

fig = figure('Name', 'Tracking Evaluation Scenarios');

scenarios = [string('arc'), string('parallel'), string('crossing')];
for i=1:length(scenarios)
    tic;
    config_update_tracking(scenarios(i));
    load('config.mat');
    color = [c.lmsred; c.darkgray];
    
    subplot(1,length(scenarios),i); hold on;
    % plot room in blue
    ax_bg = surf(linspace(0,ROOM(1),ROOM(1)),linspace(0,ROOM(2), ROOM(2)), zeros(ROOM(1), ROOM(2)));
    colormap([61/255 38/255 168/255]);
    shading interp;
    
    ax = plot(sources.trajectories(:,:,1)', sources.trajectories(:,:,2)','-', 'LineWidth', 2);
    line2arrow(ax)
    for a=1:length(ax)
        set(ax(a),'color',color(a,:));
    end
    ax_r = plot(R(:, 1), R(:, 2),'O','MarkerSize', 5, 'Linewidth',1,'Color','g');    
    
    axis([0 ROOM(1) 0 ROOM(2)]);
    xlabel("x");
    ylabel("y");
    matlab2tikz([PATH_LATEX, 'evaluation-scenarios.tex'],...
                'figurehandle', fig,...
                'imagesAsPng', true,...
                'checkForUpdates', false,...
                'externalData', false,...
                'height', '\figureheight',...
                'width', '\figurewidth',...
                'noSize', false,...
                'showInfo', false,...
                'interpretTickLabelsAsTex',true,...
                'extraColors', {{'lms_red',c.lmsred}, {'darkgray',c.darkgray}});
end