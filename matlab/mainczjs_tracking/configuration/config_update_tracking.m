function config_update = config_update_tracking(n_sources, T60, reflect_order, SNR, samples, source_length, freq_range, sidx)

if nargin < 1, n_sources = 2; end
if nargin < 2, T60 = 0.3; fprintf("WARNING: Using default for T60 (0.3)\n"); end
if nargin < 3, reflect_order = -1; fprintf("WARNING: Using default for rir-reflect_order (3)\n"); end
if nargin < 4, SNR = 0; fprintf("WARNING: Using default for SNR (0)\n"); end
if nargin < 5, samples = 20; fprintf("WARNING: Using default for samples (20)\n"); end
if nargin < 6, source_length = 3; fprintf("WARNING: Using default for source_length (3s)\n"); end
if nargin < 7 || isempty(freq_range), freq_range = 40:65; fprintf("WARNING: Using default for freq_range (40Hz-65Hz)\n"); end
if nargin < 8, sidx = false; fprintf("WARNING: Using default for source_length (3s)\n"); end

try
    fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);
end

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
room.snr = SNR;

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
S    =              [4 2 1;
                     2 4 1;
                     1 1 1;
                     5 1 1];
% Source Movement
sources.movement = [ 0  2 0;
                     0 -2 0;
                     4  4 0;
                    -4  4 0];
if sidx
    S = S(sidx(1):sidx(2),:);
    sources.movement = sources.movement(sidx(1):sidx(2),:);
else
    S = S(1:n_sources,:);
end
room.S = S;
sources.positions = S;

for n=1:7
    sources.samples(n, :) = strcat(int2str(n),'.WAV');
end

sources.signal_length = source_length;  % length of source signals [s]


sources.trajectory_samples = samples;
sources.trajectories = zeros(size(S, 1), sources.trajectory_samples, size(S, 2));
for s=1:size(S, 1)
    sources.trajectories(s, :, :) = get_trajectory_from_source(squeeze(S(s,:)),squeeze(sources.movement(s,:)), sources.trajectory_samples);
end
current_trajectory = squeeze(sources.trajectories(1, :, :));

n_receivers = size(R, 1);
n_receiver_pairs = n_receivers/2;
n_sources = size(S, 1);
source_length = 3;  % length of source signals [s]
d_r = R(2, 1) - R(1, 1);

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

fft_freq_range = freq_range;  % TODO: Find reason for this range
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
em.K = length(fft_freq_range);
em.T = floor((source_length*fs-fft_window_samples)/fft_step_samples)+1;
em.X = length(room.grid_x);
em.Y = length(room.grid_y);
em.P = em.X*em.Y; % Number of Gridpoints
% em.conv_threshold = em_conv_threshold;
% em.iterations = em_iterations;

%% Location Estimation
elimination_radius = 0;

%% Logging
log_sim="";
log_stft="";
log_em="";
log_estloc="";
log_esterr="";

%% Store new values
save('config.mat')

end