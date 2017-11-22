fprintf('------------------------- T E S T R U N -------------------------\n'); tic;

USE_SAVED_DATA = false;

%% setting parameters
sources = 4;
md = 5;
wd = 12;
rand_samples = true;
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
prior = 'hh';  % initial distribution for psi ('rand', 'hh', 'hv', 'equal')

if ~USE_SAVED_DATA, delete('ang_dist.mat'); end  % so em doesn't load old values

saved_data = false;
if USE_SAVED_DATA
    w = what(); w = w.mat;
    for i=1:length(w)
        fname = cell2mat(w(i));
        if sum(fname(1:6)=='config')==6
            fn_cfg = fname;
            load(fn_cfg);
            saved_data = true;
        end
    end
    if saved_data
        fprintf("Will analyze saved data\n");
    else
        fprintf("No saved data found! Will generate new!\n")
    end
end
%% Create Simulation Environment
if ~saved_data
    %% init
    tic;
    fn_conf = config_update(sources, rand_samples, md,wd,rand_samples,T60,em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed, prior);
    load(fn_conf);

    %% Simulate Environment
    x = simulate(fn_cfg, ROOM, R, sources);

    %% Calculate STFT
    [X, phi] = stft(fn_cfg, x);
end

%% Estimate Location (GMM+EM-Algorithmus)
[psi, iterations, variance] = em_algorithm(fn_cfg, phi, em_iterations, em_conv_threshold, get_em_history, verbose);
% loc_est = estimate_location(squeeze(psi(size(psi, 1), :, :)), n_sources, 0, 5, room);
% [loc_est_sorted, est_err] = estimation_error(S, loc_est);

%% Plotting results
figure; 
for i=1:iterations
    for s=1:em.S
        psi_plot = zeros(em.S,em.Y,em.X);
        psi_plot(:,(room.N_margin+1):(em.Y_idxMax),(room.N_margin+1):(em.X_idxMax)) = psi;
        subplot_tight(iterations,em.S,iterations*s); hold on
        axis([0,room.dimensions(1),0,room.dimensions(2)]);
        surf(room.grid_x,room.grid_y,squeeze(psi_plot(s,:,:)))
        view([-10 35]);
        shading interp
    end
end
save(fn_cfg);  % save all temp results to config

%% End
fprintf('\n---------------------   E N D   ---------------------\n');
