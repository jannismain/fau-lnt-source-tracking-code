%% Setup Environment
clear all;
cprintf('err', '--------------------- S T A R T ---------------------\n');
tic;
config_update(2, true, 10);
load('config.mat');

%% Simulate Environment
% try
%     load('x.mat');
%     fig = plot_room(ROOM, R, S);
% catch err
    [x, fig] = simulate(ROOM, R, S);
%     save('x.mat', 'x');
% end

%% Calculate STFT
[X, phi] = stft(x);
cfg = set_params_evaluate_Gauss();
% phi = bren_stft(cfg, x);

%% Estimate Location (GMM+EM-Algorithmus)
subplot_tight(2,2,[2 4], PLOT_BORDER);
[est_error1, est_error2] = bren_estimate_location(cfg, phi);

%% End
cprintf('err', '\n---------------------   E N D   ---------------------\n');