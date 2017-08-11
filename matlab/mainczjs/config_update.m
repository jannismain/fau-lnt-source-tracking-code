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

%% Method Configuration Default Values
STEP = 0;
STOP_AFTER_STEP = 0;
PLOT = [1 0 0 0 0 0 1 0 0]; % boolean plotting flag: [ all | step1 | step2 | ... | stepX ]
PLAY_AUDIO = 0;
FORMAT_PREFIX = '      ->'; % indents output of each step
counter = 1;

% Simulation
fs = 20000;                 % Sample frequency (samples/s)
c = 342;                    % Sound velocity (m/s)

% values below are set in 'generate_rir.m' for now!
% beta = 0.0;                 % Reverberationtime (s)
% nsample = 4096;             % Number of samples
% mtype = 'omnidirectional';    % Type of microphone
% order = 5;                  % −1 equals maximum reflection order!
% dim = 2;                    % Room dimension
% orientation = [pi/2 0];     % Microphone orientation [azimuth elevation] in radians
% hp_filter = 1;              % Enable high-pass filter

%% Testbed
% Room dimensions    [ x y ] (m)
ROOM = [7 5]; 
% Receiver position  [ x y ] (m)
R    = [3.85, 1;        
        4.15, 1];
%         2.85, 0;
%         3.15, 0]; 
% Source position(s) [ x y ] (m)
% S    = [2 2];
S = [3 2; 5 3];
%       4, 2;
%       6, 2];        
%     4.5, 0.5];
%     2.5, 3.5];
n_receivers = size(R, 1);
n_sources = size(S, 1);
d_r = R(2, 1) - R(1, 1);
doa_wanted = doa_trig(S,R);

%% STFT
fft_window_time = 0.025;
fft_step_time = 0.01;
fft_trunc = 500;

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