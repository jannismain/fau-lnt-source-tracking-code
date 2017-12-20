fprintf('------------------------- T E S T R U N -------------------------\n');
%% setting parameters
sources = 5;
md = 5;
wd = 12;
rand_samples = true;
T60=0.6;
SNR=0;
em_iterations=20;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
var_init=1;
var_fixed = false;
get_em_history = false;

%% init
tic;
fn_conf = config_update(sources, true, md,wd,rand_samples,T60,em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed);
load(fn_conf);

%% Simulate Environment
x = simulate(fn_cfg, ROOM, R, sources);

%% Calculate STFT
[X, phi] = stft(fn_cfg, x);

%% Estimate Location (GMM+EM-Algorithmus)
[psi, iterations, variance] = em_algorithm(fn_cfg, phi, em_iterations, em_conv_threshold, get_em_history);
loc_est = estimate_location(squeeze(psi(size(psi, 1), :, :)), n_sources, 0, 5, room);
[loc_est_sorted, est_err] = estimation_error(S, loc_est);

%% Plotting results
if get_em_history
    loc_est = estimate_location(squeeze(psi(size(psi, 1), :, :)), n_sources, 0, 5, room);
    [loc_est_sorted, est_err] = estimation_error(S, loc_est);
    psi_plot = zeros(iterations,em.Y,em.X);
    psi_plot(:,(room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
else
    loc_est = estimate_location(psi, n_sources, 0, 5, room);
    [loc_est_sorted, est_err] = estimation_error(S, loc_est);
    psi_plot = zeros(em.Y,em.X);
    psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi;
end
fig = plot_results(psi_plot, loc_est, room);
% saveas(fig, 'fig.fig', 'mfig');
% matlab2tikz(strcat(PATH_SRC, '/latex/data/plots/static/', fname_trial, 'fig.tex'), 'figurehandle', fig, 'imagesAsPng', true, 'checkForUpdates', false, 'externalData', false, 'relativeDataPath', 'data/plots/static/tikz-data/', 'dataPath', PATH_LATEX_ABS, 'noSize', false, 'showInfo', false);
close(fig);

%% End
fprintf('\n---------------------   E N D   ---------------------\n');
