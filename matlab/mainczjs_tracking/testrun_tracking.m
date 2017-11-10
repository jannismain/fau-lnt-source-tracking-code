%% Setup Environment
%% setting parameters
n_sources = 2;
T60=0.0;
SNR=0;
reflect_order=1;
samples=50;
source_length = 5; % seconds
freq_range=[];

%% init
tic;
config_update_tracking(n_sources,T60,reflect_order,SNR,samples,source_length,freq_range);
load('config.mat');
cprintf('err', '--------------------- S T A R T ---------------------\n');

%% SIMULATE
x = simulate_tracking();
[X, phi] = stft(x);

%% SOURCE TRACKING
[psi, loc_est] = rem_tracking(phi);

%% PLOTTING
% loc_est = zeros(2,size(loc_est1', 1), size(loc_est1', 2));
% loc_est(1,:,:) = loc_est1'; loc_est(2,:,:)=loc_est2';
plot_results_tracking(loc_est, sources, room)
% title(sprintf("Freq.Range %dHz - %dHz",freq_range(1), freq_range(21)))
fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
cprintf('err', '\n---------------------   E N D   ---------------------\n');