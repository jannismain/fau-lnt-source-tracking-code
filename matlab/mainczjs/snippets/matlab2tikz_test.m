%% plot sine wave
% x = linspace(0,4*pi,100);
% plot(x, sin(x));
% % control x-axis
% xlim([0 2*pi])
% xticks([0 0.5*pi pi 3/2*pi 2*pi])
% xticklabels({'0','1/2 \pi', '\pi', '3/2 \pi', '2\pi'})
% % control y-axis
% ylim([-1.5 1.5])
% yticks([-1 0 1])
% % yticklabels({'min','y = 0','max'})
% %export
% % matlab2tikz('latex/plots/static/sin-tikz.tex', 'width', '0.5\textwidth', 'checkForUpdates', false);


%% plot cosine wave
% plot(x, cos(x));
% % control x-axis
% xlim([0 2*pi])
% xticks([0 0.5*pi pi 3/2*pi 2*pi])
% xticklabels({'0','1/2 \pi', '\pi', '3/2 \pi', '2\pi'})
% % control y-axis
% ylim([-1.5 1.5])
% yticks([-1 0 1])
% % yticklabels({'min','y = 0','max'})
% matlab2tikz('latex/plots/static/cos-tikz.tex', 'width', '0.5\textwidth', 'checkForUpdates', false);

%% plot multiple 3d gaussian curves and export to tikz and eps
fig = gaussian_plot();
view([-45 45])
axis tight;
cleanfigure();
matlab2tikz('latex/plots/static/gaussian-tikz.tex', 'figurehandle', fig, 'imagesAsPng', true, 'checkForUpdates', false, 'externalData', false, 'relativeDataPath', 'plots/static/tikz-data/', 'dataPath', 'latex/plots/static/tikz-data/', 'noSize', true, 'showInfo', false);%, 'maxChunkLength', 120);
% matlab2tikz('latex/plots/static/gaussian-tikz.tex');
% print -dpsc latex/plots/static/gaussian.eps