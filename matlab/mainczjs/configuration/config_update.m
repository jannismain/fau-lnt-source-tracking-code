function fn_cfg = config_update(n_sources, random_sources, min_distance, distance_wall, randomize_samples, T60, em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed)

if nargin < 1, n_sources = 2; end
if nargin < 2, random_sources = true; end
if nargin < 3, min_distance = 5; end
if nargin < 4, distance_wall = 12; end
if nargin < 5, randomize_samples = true; end
if nargin < 6, T60 = 0.3; fprintf('WARNING: Using default for T60 (0.3)\n'); end
if nargin < 7, em_iterations = 10; fprintf('WARNING: Using default for em_iterations (10)\n'); end
if nargin < 8, em_conv_threshold = -1; fprintf('WARNING: Using default for em_conv_threshold (-1)\n'); end
if nargin < 9, reflect_order = -1; fprintf('WARNING: Using default for rir-reflect_order (3)\n'); end
if nargin < 10, SNR = 0; fprintf('WARNING: Using default for SNR (0)\n'); end
if nargin < 11, var_init = 0.1; end
if nargin < 12, var_fixed = false; end

fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);

%% Plot
PLOT_BORDER = .06;

%% Method Configuration Default Values
FORMAT_PREFIX = '      ->'; % indents output of each step
counter = 1;

% Simulation
fs = 16000;                         % Sample frequency (samples/s)
room.c = 343;                       % Sound velocity (m/s)
rir.t_reverb = T60;                 % Reverberationtime (s)
rir.length = 10*1024;               % Number of samples
mics.type = 'omnidirectional';      % Type of microphone
rir.reflect_order = reflect_order;  % −1 equals maximum reflection order!
room.dimension = 3;                 % Room dimension
mics.orientation = [pi/2 0];        % Microphone orientation [azimuth elevation] in radians
mics.hp_filter = 1;                 % Enable high-pass filter
mics.distance_wall = 1;

%% Testbed
% Room dimensions    [ x y ] (m)
ROOM = [6 6 6.1];
room.dimensions = [6 6 6.1];

% Receiver position  [ x y ] (m)
RminX = mics.distance_wall;
RminY = mics.distance_wall;
RmaxX = room.dimensions(1)-mics.distance_wall;
RmaxY = room.dimensions(2)-mics.distance_wall;
R    = [2.1, RminY, 1.0;  % bottom
        2.3, RminY, 1.0;
        2.7, RminY, 1.0;
        2.9, RminY, 1.0;
        3.7, RminY, 1.0;
        3.9, RminY, 1.0;
        RmaxX, 2.2, 1.0;  % right
        RmaxX, 2.4, 1.0;
        RmaxX, 2.8, 1.0;
        RmaxX, 3.0, 1.0;
        RmaxX, 3.8, 1.0;
        RmaxX, 4.0, 1.0;
        2.2, RmaxY, 1.0;  % top
        2.4, RmaxY, 1.0;
        3.0, RmaxY, 1.0;
        3.2, RmaxY, 1.0;
        3.8, RmaxY, 1.0;
        4.0, RmaxY, 1.0;
        RminX, 2.1, 1.0;  % left
        RminX, 2.3, 1.0;
        RminX, 2.9, 1.0;
        RminX, 3.1, 1.0;
        RminX, 3.7, 1.0;
        RminX, 3.9, 1.0];
room.R = R;
room.R_pairs = size(R, 1)/2;

% Source position(s) [ x y ] (m)
if random_sources == false
    S    = [4 2];
    S = S(1:n_sources,:);
else
    S = get_random_sources(n_sources, distance_wall, min_distance, ROOM);
end
room.S = S;
sources.positions = S;
for n=1:7
%     if n>9  % this is necessary when more than 9 sources need to be supported!
%         fname = split('A,B,C,D,E,F,G,H,I,J,K,L',',');
%         fname = fname(n-9);
    sources.samples(n, :) = strcat(int2str(n),'.WAV');
end

if randomize_samples, sources.samples = sources.samples(randperm(length(sources.samples), n_sources), :); end

sources.signal_length = 3;  % length of source signals [s]

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
room.n_pos = room.X * room.Y;  % Number of Gridpoints

%% EM
em.var = var_init;
em.var_fixed = var_fixed;

em.K = length(fft_freq_range);
em.T = 296;  % # of time bins TODO: calculate
em.X = length(room.grid_x);
em.Y = length(room.grid_y);
em.P = em.X*em.Y; % Number of Gridpoints
em.conv_threshold = em_conv_threshold;
em.iterations = em_iterations;

%% Location Estimation
elimination_radius = 0;

%% Logging
LOGGING = false;
log_sim='';
log_stft='';
log_em='';
log_estloc='';
log_esterr='';

%% Store new values
fn_cfg = sprintf('config_%s.mat', rand_string(5));
save(fn_cfg);

end
