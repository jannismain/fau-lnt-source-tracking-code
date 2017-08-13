%% save current workspace
save_env = 0;
if save_env == 1
    clear('save')
    tmpfile = join(['tmp_', datestr(now, 'yyyy-mm-dd_HH-MM-ss'), '.mat']);
    save(tmpfile);
    clearvars('-except', 'tmpfile save_env');
else
    clearvars('-except', 'save_env');
end

%% Plot
PLOT_BORDER = .06;
PLOT = [1 0 0 0 0 0 1 0 0]; % boolean plotting flag: [ all | step1 | step2 | ... | stepX ]

%% Method Configuration Default Values
STEP = 0;
STOP_AFTER_STEP = 0;
PLAY_AUDIO = 0;
FORMAT_PREFIX = '      ->'; % indents output of each step
counter = 1;

% Simulation
fs = 16000;                      % Sample frequency (samples/s)
c = 343;                         % Sound velocity (m/s)
rir.t_reverb = 0.3;              % Reverberationtime (s)
rir.length = 10*1024;            % Number of samples
mics.type = 'omnidirectional';   % Type of microphone
rir.reflect_order = 3;           % −1 equals maximum reflection order!
room.dimension = 3;              % Room dimension
mics.orientation = [pi/2 0];     % Microphone orientation [azimuth elevation] in radians
mics.hp_filter = 1;              % Enable high-pass filter

%% Testbed
% Room dimensions    [ x y ] (m)
ROOM = [6 6 6.1];
room.dimensions = [6 6 6.1];

% Receiver position  [ x y ] (m)
R    = [2.1, 1.0, 1.0;  % bottom       
        2.3, 1.0, 1.0;
        2.7, 1.0, 1.0;
        2.9, 1.0, 1.0;
        3.7, 1.0, 1.0;
        3.9, 1.0, 1.0;
        5.0, 2.2, 1.0;  % right
        5.0, 2.4, 1.0;
        5.0, 2.8, 1.0;
        5.0, 3.0, 1.0;
        5.0, 3.8, 1.0;
        5.0, 4.0, 1.0;
        2.2, 5.0, 1.0;  % top
        2.4, 5.0, 1.0;
        3.0, 5.0, 1.0;
        3.2, 5.0, 1.0;
        3.8, 5.0, 1.0;
        4.0, 5.0, 1.0;
        1.0, 2.1, 1.0;  % left
        1.0, 2.3, 1.0;
        1.0, 2.9, 1.0;
        1.0, 3.1, 1.0;
        1.0, 3.7, 1.0;
        1.0, 3.9, 1.0];
%         2.85, 0;
%         3.15, 0]; 
% Source position(s) [ x y ] (m)
S    = [3 2 1;
        4 4 1];
n_receivers = size(R, 1);
n_receiver_pairs = n_receivers/2;
n_sources = size(S, 1);
source_length = 3;  % length of source signals [s]
d_r = R(2, 1) - R(1, 1);
% doa_wanted = doa_trig(S,R);

%% STFT
fft_window_time = 0.05;
fft_window_samples = round(fft_window_time*fs);  % 500
fft_window = hanning(fft_window_samples);  % 500x1

fft_step_time =   0.01;
fft_step_samples = round(fft_step_time*fs);  % 300

fft_overlap_samples = fft_window_samples - fft_step_samples;  % 200 overlapping samples
fft_bins = 2^(ceil(log(fft_window_samples)/log(2)));  % 512 fft bins for STFT
fft_bins_net = fft_bins/2+1;
fft_trunc = 500;

fft_freq_range = 40:65;  % TODO: Find reason for this range
freq = ((0:fft_bins/2)/fft_bins*fs).'; % frequency vector [Hz]

%% GMM
room.grid_resolution = 0.1;
room.N_margin = 1/room.grid_resolution;
room.grid_x = (0:room.grid_resolution:room.dimensions(1));
room.grid_y = (0:room.grid_resolution:room.dimensions(2));
[room.pos_x, room.pos_y] = meshgrid(room.grid_x, room.grid_y);

room.X = length(room.grid_x);
room.Y = length(room.grid_y);

%% EM
room.n_pos = room.X * room.Y;  % Number of Gridpoints
em.K = length(fft_freq_range);
em.T = 296;  % # of time bins TODO: calculate

%% Store new values
save('config_new.mat', '-regexp', '^(?!(tmpfile)$).')
% opt = input('Do you want to overwrite "config.mat" with "config_new.mat" (y/n) [y]: ', 's');
opt = 'y';
if isequal(opt, 'y') || isequal(opt, 'Y') || isempty(opt)
    %delete('config.mat');
    movefile('config_new.mat','config.mat');
else
    delete('config_new.mat');
end

%% Restore workspace
if save_env == 1 
    clearvars('-except', 'tmpfile');
    load(tmpfile);
    delete(tmpfile);
    clear('tmpfile');
else
    clear all;
end