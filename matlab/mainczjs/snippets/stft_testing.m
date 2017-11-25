[x,Fs]=audioread('1.WAV');
subplot(4,1,1)
plot(x)

load('config_9ewjb.mat')
x_temp = x + 0.01*(rand(size(x))-0.5);
subplot(4,1,2)
plot(x_temp)

X = specgram(x_temp,fft_bins,fs,fft_window,fft_overlap_samples);
subplot(4,1,3)
imagesc(abs(X))

Nx = length(x);
nsc = floor(Nx/4.5);
nov = floor(nsc/2);
nff = max(256,2^nextpow2(nsc));

X2 = spectrogram(x,hamming(nsc),nov,nff);
subplot(4,1,4)
imagesc(abs(X2))


