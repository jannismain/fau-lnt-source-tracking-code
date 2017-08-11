
clear all

% specify microphone positions
mics = [3 4];
cfg.d_mic = 0.042*abs(diff(mics));

% specify source positions
point= [3,1];

cfg.theta_vec= [0,20,45,90,135,160,180];
%% load speech signals and resample them to fs
s1 = audioread('E205A.WAV');
s1 = resample(s1,4,5); %resample the original sound file from 20000Hz to 16000Hz

s2 = audioread('E202A.WAV');
s2 = resample(s2,4,5); %resample the original sound file from 20000Hz to 16000Hz

%% create two microphone signals from impulse responses

% load IRs corresponding to mic and source positions
load('IR_HAR_circle_norm_16kHz');
IR = imp_resp(:,mics,point);

% filter speech signals
x1 = fftfilt(IR(:,:,1),s1);
x2 = fftfilt(IR(:,:,2),s2);

% assure same lengths
sig_len = min(size(x1,1),size(x2,1));

% mix signals
x = x1(1:sig_len,:)+x2(1:sig_len,:);

n_mic = 2;                           % number of microphones
cfg.fs = 16000;                          % sampling rate [Hz]
cfg.c = 342;                             % speed of sound [m/s]
wintime = 0.025;                     % window length [s]
steptime = 0.010;                    % frame shift [s]
winpts = round(wintime*cfg.fs);          % window length [samples]
window = hanning(winpts)';           % hanning window
steppts = round(steptime*cfg.fs);        % frame shift [samples]
n_overlap = winpts - steppts;        % overlap of the windows [samples]
nfft = 2^(ceil(log(winpts)/log(2))); % number of fft bins for STFT
n_bins = nfft/2+1;                 % number of non-redundant bins
freq = ((0:nfft/2)/nfft*cfg.fs).';           % frequency vector [Hz]

% Create the microphone signals by convolution and perform STFT-transform
X(:,:,1) = specgram(x(:,1),nfft,cfg.fs,window,n_overlap);
X(:,:,2) = specgram(x(:,2),nfft,cfg.fs,window,n_overlap);

% truncate signal
X = X(:,1:500,:);

phi = (X(:,:,2)./X(:,:,1)).*abs(X(:,:,1)./X(:,:,2));

% compute DOAs (just for illustration)
TDOA = repmat(1./(2*pi*freq),1,size(X(:,:,1),2)).*angle(X(:,:,1).*conj(X(:,:,2)));
hilf = TDOA * cfg.c /cfg.d_mic;
hilf(hilf>1) = 1;
hilf(hilf<-1) = -1;
DOA = acosd(hilf);

cfg.T = size(phi,2);
cfg.K = size(phi,1);
cfg.S = length(point); % Number of speakers
DOA_vec = 0:1:180; % vector of DOA candidates
cfg.D = length(DOA_vec); % Number of DOAs

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
phi_tilde_mat = exp(-1i*(pi*freq_mat)/(cfg.K).*(cfg.d_mic*cfg.fs)/(cfg.c).*cosd(DOA_mat)); % K/T/S/D
ang_dist = abs(phi_mat-phi_tilde_mat).^2; % angular distances of observed phase differences and hypothesis

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
    pause(0.5)
    
end