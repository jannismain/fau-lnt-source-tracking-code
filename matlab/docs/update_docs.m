%% Define List of Documented Source Files
files_localisation = strcat(...
    'tests.m,',...
    'config_update.m,',...
    'eliminate_neighbourhood.m,',...
    'evalrun_lnt.m,',...
    'evalrun_peng.m,',...
    'evalrun_whacky.m,',...
    'get_random_sources.m,',...
    'main.m,',...
    'random_sources_eval.m,',...
    'single_example_eval.m,',...
    'get_column_names_result.m,',...
    'em_algorithm.m,',...
    'estimate_location.m,',...
    'estimation_error.m,',...
    'estimation_error_rad.m,',...
    'estimation_error_min.m,',...
    'simulate.m,',...
    'stft.m');

files_tracking = strcat(...
    'simulate_tracking.m,',...
    'rem_tracking.m,',...
    'rem_init.m,',...
    'assign_estimates_tracking.m,',...
    'get_trajectory_from_source.m');

files_localisation_list = split(files_localisation, ',');
files_tracking_list = split(files_tracking, ',');

%% Output Configuration
options_localisation = struct('format', 'html', 'outputDir', strcat('docs', filesep, 'localisation'), 'showCode', true, 'maxWidth', 800, 'evalCode', false, 'maxOutputLines', 10);
options_tracking = struct('format', 'html', 'outputDir', strcat('docs', filesep, 'tracking'), 'showCode', true, 'maxWidth', 800, 'evalCode', false, 'maxOutputLines', 10);

%% Publish Documentation
for i=1:length(files_localisation_list)
    publish(char(files_localisation_list(i)), options_localisation);
end

for i=1:length(files_tracking_list)
    publish(char(files_tracking_list(i)), options_tracking);
end

%% Open Index
web('docs/index.html')