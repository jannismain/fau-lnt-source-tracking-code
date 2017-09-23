load('config.mat', 'ROOM')
load('config.mat', 'R')

%% Test 1: Generating 10 sources with 0.5m required distance and plot them
n = 10;
S = get_random_sources(n,15,0);
assert(size(S, 1) == n)
assert(size(S, 2) == 3)
plot_room(ROOM, R, S);

%% Test 2: Generating 100 sources with 0.0m required distance and plot them
n = 100;
S = get_random_sources(n,15,0);
assert(size(S, 1) == n)
assert(size(S, 2) == 3)
plot_room(ROOM, R, S);