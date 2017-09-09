%% Setup Environment
clear all;
tic;
config_update;
load('config.mat');
cprintf('err', '--------------------- S T A R T ---------------------\n');

%% Simulate Environment
% [temp, fs_temp] = audioread('1.WAV');
% fast_ISM_RIR_bank(my_ISM_setup,'RIRs.mat');
% source_data = ISM_AudioData('RIRs.mat',temp);

temp = load('RIRs.mat');
sound(temp, 16000);

%% Calculate STFT
% [X, phi] = stft(x);
% cfg = set_params_evaluate_Gauss();
% phi = bren_stft(cfg, x);

%% Estimate Location (GMM+EM-Algorithmus)
% subplot_tight(2,2,[2 4], PLOT_BORDER);
% [est_error1, est_error2] = bren_estimate_location(cfg, phi);

%% End
fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
cprintf('err', '\n---------------------   E N D   ---------------------\n');