[x, fs] = audioread('1.WAV');
x = x(1:fs*3);
v = rir_generator(343, fs, [2 2 3], [4 4 3], [8 6 6], 0.9, fs,...
                  'omnidirectional', -1, 3);

r_fft = fftfilt(x, v, 1024);
r_conv = conv(x,v);
r=r_conv;
r = r/(max(max(max(max(r)))));
subplot(1,3,1);
plot(x);
subplot(1,3,2);
plot(v);
subplot(1,3,3);
plot(r);
sound(r, fs)
