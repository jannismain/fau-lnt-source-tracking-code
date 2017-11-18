tic;
fn_cfg = config_update(2, true, 10);
load(fn_cfg);

EXPORT = false;

PATH_SRC = [filesep 'Users' filesep 'jannismainczyk' filesep 'thesis' filesep 'latex' filesep];
PATH_LATEX_ABS = strcat(PATH_SRC, 'data/plots/setup/tikz-data/');
PATH_TIKZ_OUTPUT = strcat(PATH_SRC, 'data/plots/setup/setup.tex');
PATH_PDF_OUTPUT = strcat(PATH_SRC, 'data', filesep, 'plots', filesep, 'setup', filesep, 'setup.pdf');
PATH_PNG_OUTPUT = strcat(PATH_SRC, 'data', filesep, 'plots', filesep, 'setup', filesep, 'setup.png');
PATH_OUTPUT = strcat(PATH_SRC, 'data', filesep, 'plots', filesep, 'setup', filesep, 'setup');


fig = figure('Units', 'centimeters', 'InnerPosition', [0 0 12 12]);
[fig, ax_s, ax_r] = plot_room(ROOM, R, S, 1, 800, 800, fig);
hold on

% plot grid across whole room
step = room.grid_resolution;
[Xall,Yall] = meshgrid(step:step:room.dimensions(1)-step,step:step:room.dimensions(2)-step);
Zall = ones(length(Xall), length(Yall));
axd1 = plot3(Xall,Yall,Zall, 'k.', 'MarkerSize', 1);

% plot grid of possible source locations
xyMin = sources.wall_distance/10;
xMax = room.dimensions(1)-sources.wall_distance/10;
yMax = room.dimensions(2)-sources.wall_distance/10;
[X,Y] = meshgrid(xyMin:step:xMax,xyMin:step:yMax);
Z = ones(length(X), length(Y));
axd2 = plot3(X,Y,Z, 'w.', 'MarkerSize', 1);
legend off;
grid off;

if EXPORT
    % export to tikz
    matlab2tikz(PATH_TIKZ_OUTPUT,...
               'figurehandle', fig,...
               'imagesAsPng', true,...
               'checkForUpdates', false,...
               'externalData', false,...
               'relativeDataPath', 'data/plots/setup/tikz-data/',...
               'dataPath', PATH_LATEX_ABS,...
               'noSize', false,...
               'width', '0.5\textwidth',...
               'height', '0.5\textwidth',...
               'showInfo', false);

    % resize elements for non-tikz output
    for i=1:length(axd1)
        axd1(i).MarkerSize = 2;
    end
    for i=1:length(axd2)
        axd2(i).MarkerSize = 2;
    end
    for i=1:length(ax_s)
        ax_s(i).MarkerSize = 6;
    end
    for i=1:length(ax_r)
        ax_r(i).MarkerSize = 6;
    end

    % export as pdf
    print(fig, '-dpdf', PATH_PDF_OUTPUT, '-bestfit');
    %export as png/jpeg
    saveas(fig, [PATH_OUTPUT '.png']);
    saveas(fig, [PATH_OUTPUT '.jpg']);
end

delete(fn_cfg);
