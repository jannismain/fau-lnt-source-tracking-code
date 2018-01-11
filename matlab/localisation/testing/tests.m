%tests Run all available tests

%% Run all available tests
results_src_traj = runtests('get_trajectory_test');
results_random_sources = runtests('get_random_sources_test');
results_est_err = runtests('estimate_location_test');
results_est_err = runtests('estimation_error_test');
results_est_err = runtests('estimation_error_min_test');
results_est_err = runtests('estimation_error_rad_test');