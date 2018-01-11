# Source Localisation and Tracking Toolbox

Custom MATLAB Code Documentation

- _Documentation automatically created with `m2html` can be found [here](m2html/index.html)._
- _The documentation of the whole file structure of this thesis is located [here](../../../README_file_structure.html) ([source code](../../../README_file_structure.md))._

|                |                                                                                              |
|----------------|----------------------------------------------------------------------------------------------|
| **Topic**      | [Source Tracking in Acoustical Sensor Networks](https://lms.lnt.de/en/studies/theses/show.php?id=688)|
| **Type**       | Master Thesis                                                                                |
| **Author**     | Jannis Mainczyk                                                                              |
| **University** | [Friedrich-Alexander-University Erlangen-Nuremberg](https://www.fau.eu)                      |
| **Chair**      | [Multimedia Communications and Signal Processing](https://lms.lnt.de/en/)                    |
| **Professor**  | [Prof. Dr.-Ing. Walter Kellermann](https://lms.lnt.de/en/people/staff/walter-kellermann.php) |
| **Advisor**    | [M.Sc. Andreas Brendel](https://lms.lnt.de/en/people/staff/andreas-brendel.php)              |

## Summary

This MATLAB(R) toolbox is the result of the *Source Tracking in Acoustical Sensor Networks* Master Thesis by Jannis Mainczyk at the *Chair of Multimedia Communications and Signal Processing* of *Friedrich-Alexander-University (FAU) Erlangen-Nuremberg*

## About Package

### Codebase as MATLAB Toolbox

`LocTrackToolbox.prj` has been created to package the existing codebase as MATLAB Toolbox for easier use on different machines. However, the project as is produces a toolbox file of approximately 8GB, mostly due to the RIR banks being included. To create a Toolbox with a more appropriate file size, certain files would have to be removed and the paths for them adjusted accordingly.

### Documentation

The documentation of the functions and scripts outlined below have been published from inside MATLAB. To update the documentation, the `update_docs.m` script is provided, which re-publishes all well-documented scripts and functions.

**NOTE: It is recommended to view the documentation using MATLABs Help browser. If this is not possible, viewing the HTML files in a browser should also work.**

### `m2html` Documentation

For the curious reader, a documentation generated with `m2html` has also been included, that features a more complete set of documents and dependency graphs. The downside with this is that it is not a drop-in replacement for MATLABs own `publish` method and therefore some sections might not be rendered as nicely.

To update the `m2html` documentation, call the `m2html` function in MATLAB from the `matlab` directory like this:
```matlab
m2html('mfiles','localisation','htmldir','docs/m2html','recursive','on','global','on','save','on','todo','on','template','blue','graph','on');
```

## Contents

Listed below are the most important scripts and functions used while working on the thesis. Files not mentioned here have not been used in the final form of the evaluation trials.

**NOTE**: Clicking on a function or script name will open the corresponding documentation file! 

- Source Localisation and Tracking
    - [Acoustic Source Localisation](localisation)
        - [`em_algorithm`](localisation/em_algorithm.html)
        - [`estimate_location`](localisation/estimate_location.html)
        - [`estimation_error_rad`](localisation/estimation_error_rad.html)
        - [`simulate`](localisation/simulate.html)
        - [`stft`](localisation/stft.html)
        - `testrun` _(script to test localisation algorithm)_
        - Configuration
            - [`config_update`](localisation/config_update.html)
            - [`get_random_sources`](localisation/get_random_sources.html)
        - Evaluation
            - [`main`](localisation/main.html)
            - [`random_sources_eval`](localisation/random_sources_eval.html)
            - `single_example_eval`
            - [`evalrun_lnt`](localisation/evalrun_lnt.html)
            - [`evalrun_peng`](localisation/evalrun_peng.html)
            - [`evalrun_whacky`](localisation/evalrun_whacky.html)
        - Plotting
            - `plot_results` _(plot localisation results)_
            - `plot_room` _(plot simulated room)_
            - `plot_signals` _(plot signals in time- and STFT-domain representation)_
            - `plot_simulation_environment` _(plot entire simulation environment)_
        - Helpers
            - [`eliminate_neighbourhood`](localisation/eliminate_neighbourhood.html)
            - [`get_column_names_result`](localisation/get_column_names_result.html)
            - `rand_string`
        - Testing
            - [`tests`](localisation/tests.html)
    - [Acoustic Source Tracking](tracking)
        - [`assign_estimates_tracking`](tracking/assign_estimates_tracking.html)
        - [`rem_init`](tracking/rem_init.html)
        - [`rem_tracking`](tracking/rem_tracking.html)
        - [`simulate_tracking`](tracking/simulate_tracking.html)
        - `testrun_tracking` _(script to test tracking algorithm)_
        - Configuration
            - `config_update_tracking` _(similar to_ [`config_update`](localisation/config_update.html) _of localisation algorithm)_
            - `config_shift_current_trajectory` _(helper function to run fastISM with single_ `my_ISM_setup` _but multiple source trajectories)_
            - [`get_trajectory_from_source`](tracking/get_trajectory_from_source.html)
            - [`get_trajectory_arc`](tracking/get_trajectory_arc.html)
            - `my_ISM_setup` _(used by fastISM package)_
        - Evaluation
            - `crem_trem_comparison` _(script to produce tracking algorithm evaluation plots)_
            - `variance_comparison` _(script to produce variance estimation comparison plots)_
        - Plotting
            - `plot_loc_est_history_c` _(plot location estimates across time in room)_
            - `plot_results_tracking` _(plot tracking results)_
            - `plot_variance` _(plot variance estimates of tracking algorithms across time)_