
clear all

% specify microphone positions
mics = [3 4];
cfg.d_mic = 0.042*abs(diff(mics));

% specify source positions (-> "setup_circle_7pos_HAR.pdf")
point= [22,24];

cfg.theta_vec= -[0,0,80,60,40,20,0,-20,-40,-60,-80,90,80,70,60,50,40,30,20,10,0,-10,-20,-30,-40,-50,-60,-70,-80,-90,40,30,20,10,0,-10,-20,-30,-40,-50,-60] +90;
% cfg.theta_vec=[180,155,135,90,45,20,0];
%% load speech signals and resample them to fs
s1 = audioread('E205A.WAV');
s1 = resample(s1,4,5); %resample the original sound file from 20000Hz to 16000Hz

s2 = audioread('E202A.WAV');
s2 = resample(s2,4,5); %resample the original sound file from 20000Hz to 16000Hz

%% create two microphone signals from impulse responses

% load IRs corresponding to mic and source positions
load('IR_R517_circle_norm_16kHz');
% load('IR_HAR_circle_norm_16kHz');
IR = imp_resp(:,mics,point);

% filter speech signals
x1 = fftfilt(IR(:,:,1),s1);
x2 = fftfilt(IR(:,:,2),s2);

% assure same lengths
sig_len = min(size(x1,1),size(x2,1));

% mix signals
x = x1(1:sig_len,:)+x2(1:sig_len,:);

n1 = 0.01*rand(size(x(:,1)));
n2 = 0.01*rand(size(x(:,2)));

SNR1 = 10*log10(var(x(:,1))/var(n1));
SNR2 = 10*log10(var(x(:,2))/var(n2));
x(:,1) = x(:,1) + n1;
x(:,2) = x(:,2) + n2;

disp('-----------------------------------------------')
disp(' ')
disp(['used Microphones: ' num2str(mics)])
disp(['point: ' num2str(point)])
disp(['true angles: ' num2str(cfg.theta_vec(point))])
disp(' ')

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

X = X(:,1:500,:);

phi = (X(:,:,2)./X(:,:,1)).*abs(X(:,:,1)./X(:,:,2));

% TDOA = repmat(1./(2*pi*freq),1,size(X(:,:,1),2)).*angle(X(:,:,1).*conj(X(:,:,2)));
% hilf = TDOA * cfg.c /cfg.d_mic;
% hilf(hilf>1) = 1;
% hilf(hilf<-1) = -1;
% % phi = -acosd(hilf)+90;
% phi = acosd(hilf);
% phi(1,:) = 0;

%% CDR estimation

cfg.nr.lambda = 0.68; % smoothing factor for PSD estimation
cfg.estimator = @estimate_cdr_nodoa;              % DOA-independent estimator (CDRprop3)

%% Signal processing
fprintf('Performing signal enhancement... \n');tic;

% estimate PSD and coherence
Pxx = estimate_psd(X,cfg.nr.lambda);
Cxx = estimate_cpsd(X(:,:,1),X(:,:,2),cfg.nr.lambda)./sqrt(Pxx(:,:,1).*Pxx(:,:,2));

% define coherence models
Cnn = sinc(2 * freq * cfg.d_mic/cfg.c); % diffuse noise coherence; not required for estimate_cdr_nodiffuse

% apply CDR estimator (=SNR)
SNR = estimate_cdr_nodoa(Cxx, Cnn);
SNR = max(real(SNR),0);

Diffuseness = 1./(SNR + 1);

CDR_weighting = 1;
if(CDR_weighting)
    weight = (1-Diffuseness);
    weight(weight<0.7) = 0;
else
    weight = ones(size(Diffuseness));
end


% phi = phi(1:100,:);
% weight = weight(1:100,:);
cfg.T = size(phi,2);
cfg.K = size(phi,1);
DOA_vec = 0:1:180;
cfg.D = length(DOA_vec); % Number of DOAs

% Use the overal variance of the dataset as the initial variance for each cluster.
variance = sqrt(var(phi(:)));

% Assign equal prior probabilities to each cluster.
psi = ones(cfg.D,1) * (1 /cfg.D);


freq_mat = repmat((1:cfg.K).',1,cfg.T,length(DOA_vec));
phi_mat = repmat(phi,1,1,cfg.D);
DOA_mat = reshape(DOA_vec,1,1,length(DOA_vec));
DOA_mat = repmat(DOA_mat,cfg.K,cfg.T,1);
weight = repmat(weight,1,1,cfg.D);


phi_tilde_mat = exp(-1i*(pi*freq_mat)/(cfg.K).*(cfg.d_mic*cfg.fs)/(cfg.c).*cosd(DOA_mat)); % K/T/D
ang_dist = abs(phi_mat-phi_tilde_mat).^2;

figure
for iter = 1:50
    
    fprintf('  EM Iteration %d\n', iter);
    
    %% Expectation
    
    psi_mat = reshape(psi,1,1,size(psi,1),size(psi,2));
    psi_mat = repmat(psi_mat,cfg.K,cfg.T,1,1);
    var_mat = ones(cfg.K,cfg.T,cfg.D);

        var_mat = var_mat * variance;

    pdf = psi_mat.*(1 ./ (var_mat * pi)) .* exp(-ang_dist ./ (var_mat));
    pdf_sum = repmat(sum(sum(pdf,4),3),1,1,cfg.D);
    mu = weight.*pdf./pdf_sum;
    mu(isnan(mu)) = 0;
    
    %% Maximization
    flag_Dirichlet = 0;
    
    if(flag_Dirichlet)
        Dirichlet= 0.0001;
        psi = (squeeze(sum(sum(mu,2),1) + (Dirichlet - 1))/(cfg.T*cfg.K + cfg.D*(Dirichlet-1)));
        psi = psi./sum(sum((psi))); % normalization due to weighting
        psi(psi<0) = eps;
    else
        psi = squeeze(sum(sum(mu,2),1)/(cfg.T*cfg.K));
        psi = psi./sum(sum((psi))); % normalization due to weighting
    end
    
    
%     var_denominator = squeeze(sum(sum(sum(mu.*ang_dist,1),2),3));
%     var_numerator = squeeze(sum(sum(sum(mu,1),2),3));
%     variance = var_denominator./var_numerator;
    
variance = 1;

%     psi_smoothed = smooth(psi(:));
    psi_smoothed = psi(:);
    
    clf
    plot(DOA_vec,psi_smoothed)
    hold on
    line([cfg.theta_vec(point(1)),cfg.theta_vec(point(1))],[0,1.2*max(psi(:))],'Color','r')
    line([cfg.theta_vec(point(2)),cfg.theta_vec(point(2))],[0,1.2*max(psi(:))],'Color','r')
    grid on
    axis tight
    if CDR_weighting
        title('with CDR weighting')
    else
        title('without CDR weighting')
    end
    pause(0.01)
    
end

[~,peak_pos] = findpeaks(psi_smoothed,'SortStr','descend');

if(numel(peak_pos)>=2)
    if(abs(cfg.theta_vec(point(1)) - peak_pos(1))<abs(cfg.theta_vec(point(1)) - peak_pos(2)))
        error1 = abs(cfg.theta_vec(point(1)) - peak_pos(1));
        error2 = abs(cfg.theta_vec(point(2)) - peak_pos(2));
    elseif(abs(cfg.theta_vec(point(1)) - peak_pos(2))<abs(cfg.theta_vec(point(1)) - peak_pos(1)))
        error1 = abs(cfg.theta_vec(point(1)) - peak_pos(2));
        error2 = abs(cfg.theta_vec(point(2)) - peak_pos(1));
    end
end
if(numel(peak_pos)>=2)
    plot(DOA_vec(peak_pos(1:2)),psi_smoothed(peak_pos(1:2)),'+')
    %         title(['angular error 1: ', num2str(error1),'  angular error 2: ', num2str(error2)])
end
