function DOA = phi_from_stft(y_hat, fig)
% DOA_FROM_STFT calculates the direction of arrival of components of the STFT
% spectrum Y

%% Start
cprintf('*keywords', '\n<%s>\n', mfilename);
load('config.mat')

%% DOA Calculation
m = "Calculate Degree of Arrival (DOA) of received signals"; counter = next_step(m, counter);
    
    fft_bins = 512;
    freq = ((0:fft_bins/2)/fft_bins*fs).';
%     freq(freq==0) = 0.0001;
    % select frequencies (spatial aliasing d/lambda...)!
    % filter possible freqs to achieve better DOA estimate
    fprintf("%s Input: y_hat = %dx%dx%d\n", FORMAT_PREFIX, size(y_hat, 1), size(y_hat, 2), size(y_hat, 3)); 
    fprintf("%s Input: freq_vector = %dx%d\n", FORMAT_PREFIX, size(freq, 1), size(freq, 2)); 
    fprintf("%s Input: distance between receivers = %0.2fm\n", FORMAT_PREFIX, d_r); 
    
    coeff = repmat(1./(2*pi*freq),1,size(y_hat(1,:,:),3));
    % freq begins at 0, divide by 0 gives NaN... TODO: not do this
    cconj = squeeze(y_hat(1,:,:).*conj(y_hat(2,:,:)));
    fprintf("%s Coefficients: %dx%dx%d\n", FORMAT_PREFIX, size(coeff, 1), size(coeff, 2), size(coeff, 3)); 
    fprintf("%s Conjugated Signal: %dx%dx%d\n", FORMAT_PREFIX, size(cconj, 1), size(cconj, 2), size(cconj, 3)); 
    % fix for peaks at 0 and 180 degrees: modulo 2*pi...
    TDOA = coeff.*angle(cconj);
    hilf = TDOA * c/d_r;
    hilf(hilf>1) = 1;
    hilf(hilf<-1) = -1;
    hold on;
    DOA = acosd(hilf);

%% Output
    subplot_tight(2,2,3,PLOT_BORDER);
    histogram(DOA);
    title('DOA Estimation')
    for b = 1:fft_bins
        fprintf('%s DOA(b%d) = %2.4f\x03C0 (%2.3f\x00B0)\n', FORMAT_PREFIX , b, deg2rad(DOA(b)), DOA(b));
    end
    fprintf('   %s Average DOA: %2.4f\x03C0 (%2.3f\x00B0)\n', FORMAT_PREFIX, sum(DOA)/length(DOA), deg2rad(sum(DOA)/length(DOA)));
end