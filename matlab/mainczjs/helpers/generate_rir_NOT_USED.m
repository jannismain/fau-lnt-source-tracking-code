function h = generate_rir(ROOM, R, S)

%GENERATE_RIR Summary of this function goes here
load('config.mat');

% sanity checks
if (~ismatrix(R)) || (~ismatrix(S))
    error('Please provide 1- or 2-dimensional input parameters only!')
end
if (size(R, 2) == 2) || (size(S, 2) == 2)
    height = 1;
    ROOM = [ROOM height];
    zR = ones(size(R, 1), 1).*height/2; R = [R zR];
    zS = ones(size(S, 1), 1).*height/2; S = [S zS];
elseif (size(R, 2) ~= 3) || (size(S, 2) ~= 3)
    error('Please provide [ x y ] or [ x y z ] coordinates for all input parameters!')
end

n_receiver_pairs = size(R, 1)/2;
n_sources = size(S, 1);

h = zeros(rir.length, n_sources, 2, n_receiver_pairs);
for mic_pair = 1:n_receiver_pairs
    for mic = 1:2
        for s = 1:n_sources
            [h(:, s, mic, mic_pair),~] = rir_generator(...
                c, ...
                fs, ...
                R((mic_pair*2-1)+(mic-1),:), ...
                S(s,:), ...
                ROOM, ...
                rir.t_reverb, ...
                rir.length, ...
                mics.type, ...
                rir.reflect_order, ...
                room.dimension, ...
                mics.orientation, ...
                mics.hp_filter);
        end
    end
end

end

