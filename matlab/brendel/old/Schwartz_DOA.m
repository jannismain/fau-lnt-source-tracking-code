% author: Andreas Brendel (2017)
% edited by: Jannis Mainczyk

clear all

%% ################# SIMULATE.M #################
% microphone positions
mics = [3 4];
cfg.d_mic = 0.042*abs(diff(mics));
fprintf("Receiver Distance = %d\n", cfg.d_mic); 

% source positions
point= [3,6];
cfg.theta_vec= [0,20,45,90,135,160, 180];

% load speech signals and resample them to fs
s1 = audioread('audio/1.WAV');
s1 = resample(s1,4,5); %resample the original sound file from 20000Hz to 16000Hz
fprintf("Loaded S1 (length = %d)\n", length(s1)); 

s2 = audioread('audio/2.WAV');
s2 = resample(s2,4,5); %resample the original sound file from 20000Hz to 16000Hz
fprintf("Loaded S2 (length = %d)\n", length(s2)); 

% create two microphone signals from impulse responses

% load IRs corresponding to mic and source positions
load('audio/IR_HAR_circle_norm_16kHz');
IR = imp_resp(:,mics,point);

% filter speech signals
x1 = fftfilt(IR(:,:,1),s1);
x2 = fftfilt(IR(:,:,2),s2);

% assure same lengths
sig_len = min(size(x1,1),size(x2,1));
fprintf("Cut both signals to length %d\n", sig_len); 

% mix signals
x = x1(1:sig_len,:)+x2(1:sig_len,:);
fprintf("Mixed received signal (length=%d)\n", length(x)); 

%% ################### STFT.M ###################

% STFT Transformation
n_mic = 2;                                      % number of microphones
fs = 16000;                                     % sampling rate [Hz]
cfg.c = 342;                                    % speed of sound [m/s]
fft_window_time = 0.025;                        % window length [s]
fft_window_samples = round(fft_window_time*fs); % window length [samples]
fft_window = hanning(fft_window_samples)';      % hanning window

fft_step_time = 0.015;                          % frame shift [s]
fft_step_samples = round(fft_step_time*fs);     % frame shift [samples]

fft_overlap_samples = fft_window_samples - fft_step_samples;        % overlap of the windows [samples]
fft_bins = 2^(ceil(log(fft_window_samples)/log(2))); % number of fft bins for STFT
fft_bins_net = fft_bins/2+1;                 % number of non-redundant bins

freq = ((0:fft_bins/2)/fft_bins*fs).';
fprintf("Frequency Vector: %dx%d\n", size(freq, 1), size(freq, 2));

% Create the microphone signals by convolution and perform STFT-transform
y_hat(:,:,1) = spectrogram(x(:,1),fft_window,fft_overlap_samples,fft_bins,fs);
y_hat(:,:,2) = spectrogram(x(:,2),fft_window,fft_overlap_samples,fft_bins,fs);
fprintf("STFT Signal: Y=%dx%dx2\n", size(y_hat, 1), size(y_hat, 2)); 

% truncate signal
y_hat = y_hat(:,1:500,:);
fprintf("Truncated STFT Signal: Y1=%dx%dx2\n", size(y_hat, 1), size(y_hat, 2)); 

phi = (y_hat(:,:,2)./y_hat(:,:,1)).*abs(y_hat(:,:,1)./y_hat(:,:,2));


%% ############### DOA_FROM_STFT.M ###############

% compute DOAs (just for illustration)
coeff = repmat(1./(2*pi*freq),1,size(y_hat(:,:,1),2));
cconj = y_hat(:,:,1).*conj(y_hat(:,:,2));
fprintf("Coefficients: %dx%dx%d\n", size(coeff, 1), size(coeff, 2), size(coeff, 3)); 
fprintf("Complex Conjugates: %dx%dx%d\n", size(cconj, 1), size(cconj, 2), size(cconj, 3)); 
TDOA = coeff.*angle(cconj);
fprintf("TDOA: Y1=%dx%d\n", size(TDOA, 1), size(TDOA, 2)); 
hilf = TDOA * cfg.c /cfg.d_mic;
hilf(hilf>1) = 1;
hilf(hilf<-1) = -1;
DOA = acosd(hilf);
figure;
histogram(DOA);

%% ############### EM_ALGORITHM.M ###############

cfg.T = size(phi,2);
cfg.K = size(phi,1);
cfg.S = length(point); % Number of speakers
DOA_vec = 0:1:180; % vector of DOA candidates
cfg.D = length(DOA_vec); % Number of DOAs
fprintf("INPUT: K = %d, T = %d, S = %d, D = %d\n", cfg.K, cfg.T, cfg.S, cfg.D); 
fprintf("INPUT: phi = %dx%dx%d\n", size(phi, 1), size(phi, 2), size(phi, 3)); 

% Use the overal variance of the dataset as the initial variance for each cluster.
variance = ones(cfg.S,1) * sqrt(var(phi(:)));

% Assign equal prior probabilities to each cluster.
psi = ones(cfg.S,cfg.D) * (1 / (cfg.D*cfg.S));

% produce matrices of suitable sice for matrix multiplications
freq_mat = repmat((1:cfg.K).',1,cfg.T,cfg.S,length(DOA_vec));
phi_mat = repmat(phi,1,1,cfg.S,cfg.D);
DOA_mat = reshape(DOA_vec,1,1,1,length(DOA_vec));
DOA_mat = repmat(DOA_mat,cfg.K,cfg.T,cfg.S,1);

% phase hypothesis computed from DOAs
phi_tilde_mat = exp(-1i*(pi*freq_mat)/(cfg.K).*(cfg.d_mic*fs)/(cfg.c).*cosd(DOA_mat)); % K/T/S/D
fprintf("INPUT: freq_mat = %dx%dx%d\n", size(freq_mat, 1), size(freq_mat, 2), size(freq_mat, 3)); 
fprintf("INPUT: DOA_mat = %dx%dx%d\n", size(DOA_mat, 1), size(DOA_mat, 2), size(DOA_mat, 3)); 
fprintf("OUTPUT: dimensions of phi_tilde_mat = %dx%dx%d\n", size(phi_tilde_mat, 1), size(phi_tilde_mat, 2), size(phi_tilde_mat, 3)); 
fprintf("OUTPUT: dimensions of phi_mat = %dx%dx%d\n", size(phi_mat, 1), size(phi_mat, 2), size(phi_mat, 3)); 

ang_dist = abs(phi_mat-phi_tilde_mat).^2; % angular distances of observed phase differences and hypothesis

% EM-Algorithm Start
figure
for iter = 1:10
    
    fprintf('  EM Iteration %d\n', iter);
    
    %% Expectation Step
    psi_mat = reshape(psi,1,1,size(psi,1),size(psi,2));
    psi_mat = repmat(psi_mat,cfg.K,cfg.T,1,1);
    var_mat = ones(cfg.K,cfg.T,cfg.S,cfg.D);
    for S_idx = 1:cfg.S
        var_mat(:,:,S_idx,:) = var_mat(:,:,S_idx,:) * variance(S_idx);
    end
    pdf = psi_mat.*(1 ./ (var_mat * pi)) .* exp(-ang_dist ./ (var_mat));
    pdf_sum = repmat(sum(sum(pdf,4),3),1,1,cfg.S,cfg.D);
    mu = pdf./pdf_sum;
    mu(isnan(mu)) = 0; % avoid NaNs
    
    %% Maximization Step
    psi = squeeze(sum(sum(mu,2),1)/(cfg.T*cfg.K));
    psi = psi./sum(sum((psi))); % normalization due to weighting
    
    var_denominator = squeeze(sum(sum(sum(mu.*ang_dist,1),2),4));
    var_numerator = squeeze(sum(sum(sum(mu,1),2),4));
    variance = var_denominator./var_numerator;
    
    psi_smoothed = smooth(psi(1,:)); % smoothing for clear representation
    
    % plot result
    clf
    plot(DOA_vec,psi_smoothed)
    hold on
    line([cfg.theta_vec(point(1)),cfg.theta_vec(point(1))],[0,1.2*max(psi(1,:))],'Color','r')
    line([cfg.theta_vec(point(2)),cfg.theta_vec(point(2))],[0,1.2*max(psi(1,:))],'Color','r')
    xlabel('DOA \rightarrow')
    ylabel('p(DOA) \rightarrow')
    grid on
    axis tight
    pause(0.2)
    
end