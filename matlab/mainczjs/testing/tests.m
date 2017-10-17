%results_doa = runtests('doa_trig_test');
%results_src_traj = runtests('get_trajectory_test');
% results_random_sources = runtests('get_random_sources_test');
results_est_err = runtests('estimation_error_test');
display(results_est_err)