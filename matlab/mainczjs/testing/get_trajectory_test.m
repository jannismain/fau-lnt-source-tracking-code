counter = 1;
samples = 101;

sweep_1_2 = linspace(1,2,101).';
sweep_5_3 = linspace(5,3,201).';

const_1_101 = ones(samples,1);

%% Test 1: [1 1 1], movement=[1 1 1]
samples = 101;
src_traj_exp = [sweep_1_2 sweep_1_2 sweep_1_2];
src_traj = get_trajectory(1,1,1,'',[1 1 1]);
is_equal = min(min(src_traj_exp==src_traj))==1;
assert(is_equal)

m = "PASSED ([1 1 1], movement=[1 1 1], samples='')"; counter = next_step(m, counter, 0, 0);

%% Test 2: [1 1 1], movement=[1 1 1], samples=400
samples=400;
src_traj_exp = [linspace(1,2,samples).' linspace(1,2,samples).' linspace(1,2,samples).'];
src_traj = get_trajectory(1,1,1,samples,[1 1 1]);
is_equal = min(min(src_traj_exp==src_traj))==1;
assert(is_equal)

m = "PASSED ([1 1 1], movement=[1 1 1], samples=400)"; counter = next_step(m, counter, 0, 0);

%% Test 3: [1 5 1], movement=[0 -2 0]
samples=201;
src_traj_exp = [ones(samples,1) linspace(5, 3, samples).' ones(samples,1)];
src_traj = get_trajectory(1,5,1,'',[0 -2 0]);
is_equal = min(min(src_traj_exp==src_traj))==1;
assert(is_equal)

m = "PASSED ([1 5 1], movement=[0 -2 0], samples='')"; counter = next_step(m, counter, 0, 0);
