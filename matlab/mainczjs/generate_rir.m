function h = generate_rir(room, R, S)

%% This snippet allows to call testbed without switching editor window
if ~(exist('room','var'))
    testbed;
    return;
end

%GENERATE_RIR Summary of this function goes here
load('config.mat');
% c = 342;                     % Sound velocity (m/s)
% fs = 16000;                  % Sample frequency (samples/s)
%R = [ 4 0 3 ];              % Receiver position [ x y z ] (m)
%S = [ 1.5 1.5 3 ];          % Source position [ x y z ] (m)
%room = [ 5 4 6 ];           % Room dimensions [ x y z ] (m)
beta = 0.0;                  % Reverberationtime (s)
nsample = 4096;              % Number of samples
mtype = 'omnidirectional';   % Type of microphone
order = 4;                   % -1 equals maximum reflection order!
dim = 2;                     % Room dimension
orientation = [pi/2 0];      % Microphone orientation [azimuth elevation] in radians
hp_filter = 0;               % Enable high-pass filter

% sanity checks
if (~ismatrix(R)) || (~ismatrix(S))
    error('Please provide 1- or 2-dimensional input parameters only!')
end
if (size(R, 2) == 2) || (size(S, 2) == 2)
    height = 6;
    room = [room height];
    zR = ones(size(R, 1), 1).*height/2; R = [R zR];
    zS = ones(size(S, 1), 1).*height/2; S = [S zS];
elseif (size(R, 2) ~= 3) || (size(S, 2) ~= 3)
    error('Please provide [ x y ] or [ x y z ] coordinates for all input parameters!')
end

n_receivers = size(R, 1);
n_sources = size(S, 1);

h = zeros(n_receivers, n_sources, nsample);

addpath('./rir_generator');

for r = 1:n_receivers
    for s = 1:n_sources
        [h(r, s, :),~] = rir_generator(c, fs, R(r,:), S(s,:), room, beta, nsample, mtype, order, dim, orientation, hp_filter);
    end
end

end

