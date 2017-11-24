fprintf('------------------------- T E S T R U N -------------------------\n'); tic;

sources = 2;
md = 5;
wd = 12;
rand_samples = 'left';
T60=0.3;
SNR=0;
em_iterations=5;
em_conv_threshold=-1;
guess_randomly=false;
reflect_order=3;
var_init=1;
var_fixed = false;
get_em_history = true;
verbose=true;
prior = 'schwartz2014';  % initial distribution for psi ('rand', 'hh', 'hv', 'equal', 'quart')

PATH = [getuserdir filesep 'thesis' filesep 'src' filesep 'matlab' filesep 'mainczjs' filesep 'evaluation' filesep 'testruns' filesep];
PATH_LATEX = [getuserdir filesep 'thesis' filesep 'latex' filesep 'data' filesep 'plots' filesep 'testruns' filesep];
oldpath = pwd;
cd(PATH);

tic;
fn_conf = config_update(sources, rand_samples, md,wd,rand_samples,T60,em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed, prior);
load(fn_conf);

%% Simulate Environment
x = simulate(fn_cfg, ROOM, R, sources);

%% Calculate STFT
[X, phi] = stft(fn_cfg, x);

%% Estimate Location (GMM+EM-Algorithmus)
[psi, iterations, variance] = em_algorithm(fn_cfg, phi, em_iterations, em_conv_threshold, get_em_history, verbose, prior);

%% Plotting results
plot_overview(psi,variance,iterations,em,room,'all',PATH,'testrun_s=2_prior=schwartz2014_overview');

psi_mixed = squeeze(sum(psi(end,:,:,:),2));
loc_est = estimate_location(psi_mixed, n_sources, 0, md, room);
[loc_est_sorted, est_err] = estimation_error(S, loc_est);

psi_plot = zeros(em.Y,em.X);
psi_plot((room.N_margin+1):(em.Y-room.N_margin),(room.N_margin+1):(em.X-room.N_margin)) = psi_mixed;

fig = plot_results(psi_plot,loc_est_sorted,room);
saveas(fig, strcat(PATH_LATEX,'results'))
saveas(fig, strcat(PATH,'results.fig'))
matlab2tikz('results.tex', 'figurehandle', fig, 'showInfo', false);
close all
close all hidden
clear fig;
save(fn_cfg);  % save all temp results to config

%% End
fprintf('\n---------------------   E N D   ---------------------\n');
