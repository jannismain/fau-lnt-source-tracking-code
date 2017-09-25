%% Setup Environment
tic;
config_update;
load('config.mat');
cprintf('err', '--------------------- S T A R T ---------------------\n');

%% Calculate RIRs for 
% fast_ISM_RIR_bank(custom_ISM_setup,'ress/rir/RIRs_x=4_y=[2 4]_10.mat');

%% Create Received Signals
[source, fs_source] = audioread('1.WAV');
source = resample(source, 16000, fs_source);
source_duration = length(source)/fs;
source_data = ISM_AudioData('ress/rir/RIRs_x=4_y=[2 4]_10.mat',source);

% reshape data to fit [:,mic,mic_pair] structure
x = zeros(size(source_data, 1), 2, size(source_data, 2)/2);
for i=1:size(source_data, 2)
    mic = 2-mod(i,2);
    mic_pair = roundn(i/2,0);
    x(:,mic,mic_pair) = source_data(:,i);
end

x_first_3_seconds = x(1:48000,:,:);
x_last_3_seconds = x((size(x,1)-48000)+1:size(x,1),:,:);

sound(x_first_3_seconds(1,4), 16000)

%% Calculate STFT
[X, phi] = stft(x_first_3_seconds+x_last_3_seconds);
cfg = set_params_evaluate_Gauss();

% try
%     phi = load('bren_phi.mat', 'phi');
% catch err
%     phi = bren_stft(cfg, x_first_3_seconds);
%     save('bren_phi.mat', 'phi');
% end

%% Estimate Location (GMM+EM-Algorithmus)
subplot_tight(2,1,2, PLOT_BORDER);
[psi, est_error1, est_error2] = bren_estimate_location(cfg, phi);

%% End
fprintf(' done! (Elapsed Time = %s)\n', num2str(toc)');
cprintf('err', '\n---------------------   E N D   ---------------------\n');