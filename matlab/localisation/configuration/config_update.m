function fn_cfg = config_update(n_sources, random_sources, min_distance, distance_wall, randomise_samples, T60, em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed)
%% CONFIG_UPDATE Creates config-file and returns its filename.
% 
% The filename that is returned can be used by other functions to load the parameter set
% defined here.
%
%% Arguments
% 
% * *n_sources (int)*: _number of sources to be simulated (default: *2*)_
% * *random_sources (bool)*: _chose random source locations (default: *true*)_
% * *min_distance (int)*: _minimum required distance between sources (in decimetre, default: *5*)_
% * *distance_wall (int)*: _minimum required distance of sources from wall (in decimetre, default: *12*)_
% * *randomise_samples (bool)*: _randomise speech sample order (default: *true*)_
% * *T60 (double)*: _reverberation time (in seconds, default: *0.3*)_
% * *em_iterations (int)*: _number of maximum em iterations (default: *5*)_
% * *em_conv_threshold (int)*: _convergence threshold for em algorithm (-1 equals no threshold, default: *-1*)_
% * *reflect_order (int)*: _maximum reflection order for image-method simulation (-1 equals max, default: *3*)_
% * *SNR (int)*: _amount of noise added to received signal (in dB, 0 equals no noise, default: *0*)_
% * *var_init (double)*: _initial value for variance (default: *0.1*)_
% * *var_fixed (bool)*: _do not estimate variance for each em iteration (default: *false*)_

%% Returns
% * *fn_cfg (str)*: _filename of configuration file (i.e. |config_5x8d0.mat|)_

if nargin < 1, n_sources = 2; end
if nargin < 2, random_sources = true; end
if nargin < 3, min_distance = 5; end
if nargin < 4, distance_wall = 12; end
if nargin < 5, randomise_samples = true; end
if nargin < 6, T60 = 0.3; fprintf('WARNING: Using default for T60 (0.3)\n'); end
if nargin < 7, em_iterations = 5; fprintf('WARNING: Using default for em_iterations (5)\n'); end
if nargin < 8, em_conv_threshold = -1; fprintf('WARNING: Using default for em_conv_threshold (-1)\n'); end
if nargin < 9, reflect_order = 3; fprintf('WARNING: Using default for rir-reflect_order (3)\n'); end
if nargin < 10, SNR = 0; fprintf('WARNING: Using default for SNR (0)\n'); end
if nargin < 11, var_init = 0.1; fprintf('WARNING: Using default initial variance (0.1)\n'); end
if nargin < 12, var_fixed = false; fprintf('WARNING: Using default for var_fixed (false)\n'); end

try fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc); end

%% Output Variables
PLOT_BORDER = .06;
FORMAT_PREFIX = '      ->'; % indents output of each step
counter = 1;

%% Simulation Variables
fs = 16000;                         % Sample frequency (samples/s)
room.c = 343;                       % Sound velocity (m/s)
rir.t_reverb = T60;                % Reverberationtime (s)
if T60>0.3
    rir.length = fs*T60;           % Number of samples
else
    rir.length = fs*0.5;
end
mics.type = 'omnidirectional';      % Type of microphone
rir.reflect_order = reflect_order;  % −1 equals maximum reflection order!
room.dimension = 3;                 % Room dimension
mics.orientation = [pi/2 0];        % Microphone orientation [azimuth elevation] in radians
mics.hp_filter = 1;                 % Enable high-pass filter
mics.distance_wall = 1;

%% Environment Variables
% Room dimensions |[ x y z ]| in metre
ROOM = [6 6 6.1];
room.dimensions = [6 6 6.1];

%% Blub
% <../matlab/addpath_recurse.m Test>

%% Receiver Positions
% Cartesian coordinates of receiver |[x y z]| in metre
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

%% Source position(s)
% Cartesian coordinates of sources |[x y z]| in metre
if random_sources == false
    S    = [3.3 3 1;
            2.7 3 1;
            4 4.5 1;
            3.3 3 1;
            2.7 3 1;
            4 4.5 1;
            5 5 1];
    S = S(1:n_sources,:);
else
    S = get_random_sources(n_sources, distance_wall, min_distance, ROOM);
end
room.S = S;
sources.positions = S;
for n=1:7
    if n>9  % this is necessary when more than 9 sources need to be supported!
        fname = 'ABCDEFGHIJKLMNOPQRST';
        n_str = fname(n-9);
    else
        n_str = int2str(n);
    end
    sources.samples(n, :) = strcat(n_str,'.WAV');
end
if n_sources>8
    fprintf('WARN: only 7 audio samples available at the moment!');
end

if randomise_samples, sources.samples = sources.samples(randperm(length(sources.samples), n_sources), :); end

sources.signal_length = 3;  % length of source signals [s]
sources.wall_distance = distance_wall;  % enforced distance from outer wall

n_receivers = size(R, 1);
n_receiver_pairs = n_receivers/2;
n_sources = size(S, 1);  % REDUNDANT
sources.n = size(S, 1);
source_length = sources.signal_length;  % REDUNDANT
sources.length = sources.signal_length;  % length of source signals [s]
d_r = R(2, 1) - R(1, 1);

%% STFT Variables
% Variables necessary for the short time Fourier transformation (STFT)
fft_window_time = 0.05;
fft_window_samples = round(fft_window_time*fs);  % 500
fft_window = hanning(fft_window_samples);  % 500x1

fft_step_time =   0.01;
fft_step_samples = round(fft_step_time*fs);  % 300

fft_overlap_samples = fft_window_samples - fft_step_samples;  % 200 overlapping samples
fft_bins = 2^(ceil(log(fft_window_samples)/log(2)));  % 512 fft bins for STFT
fft_bins_net = fft_bins/2+1;
fft_trunc = 500;

fft_freq_range = 40:65;  % NOTE: Empirically chosen
freq = ((0:fft_bins/2)/fft_bins*fs).'; % frequency vector [Hz]

%% GMM Variables
% Variables of the Gaussian mixture model (GMM)
room.grid_resolution = 0.1;
room.N_margin = 1/room.grid_resolution;
room.grid_x = (0:room.grid_resolution:room.dimensions(1));
room.grid_y = (0:room.grid_resolution:room.dimensions(2));
[room.pos_x, room.pos_y] = meshgrid(room.grid_x, room.grid_y);
room.X = length(room.grid_x);
room.Y = length(room.grid_y);
room.n_pos = room.X * room.Y;  % Number of Gridpoints

%% EM Variables
% Variables used by |em_algorithm.m|
em.var = var_init;
em.var_fixed = var_fixed;

em.S = sources.n;
em.K = length(fft_freq_range);
em.T = 296;  % # of time bins, NOTE: not needed anymore, as now recalculated in |em_algorithm.m| when wrong
em.X = length(room.grid_x);  % all possible gridpoints for X and Y
em.Y = length(room.grid_y);
em.Xnet = em.X-2*room.N_margin;  % all gridpoints used in estimation
em.Ynet = em.Y-2*room.N_margin;
em.P = em.X*em.Y; % Number of Gridpoints
em.M = room.R_pairs;
em.conv_threshold = em_conv_threshold;
em.iterations = em_iterations;

%% Location Estimation Variables
% used in |estimate_location.m|
elimination_radius = 0;  

%% Logging Variables
% used in evaluation scripts to redirect output to log-files.
verbose = true;
LOGGING = false;
LOGGING_FIG = true;
log_sim='';
log_stft='';
log_em='';
log_estloc='';
log_esterr='';

%% Save config_xxx.mat
% When saving the configuration to the file system, a random suffix is added to the filename,
% to allow for parallel trials within the same directory (otherwise, |config.mat| could be
% overwritten by other instances)
%
% Filename Example: |config_ygnw2.mat|
fn_cfg = sprintf('config_%s.mat', rand_string(5));
save(fn_cfg);

end
