function [ loc_est ] = estimate_location( psi, n_sources, elimination_radius, min_distance, room)
%ESTIMATE_LOCATION Finds the n_sources most probable locations of audio sources
%   Input Arguments:
%   - psi: output of prior EM-Iterations
%   - [n_sources]: number of locations to be found
%   Output Arguments:
%   - loc_est: array of x/y coordinates of estimated locations
%

fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);

if nargin<1, error('input argument "psi" is required!'); end
if nargin<2, n_sources=2; end
if nargin<3, elimination_radius=0; end
if nargin<4, min_distance=5; end

loc_est = zeros(n_sources, 2);

for n=1:n_sources
    %% determine maximum
    valid_loc = false;
    while ~valid_loc
        [~,idx_Xmax] = max(max(psi,[],1));  % ~ = max. value of psi at identified index
        [~,idx_Ymax] = max(max(psi,[],2));
        loc_est(n, 1:2) = [room.grid_x(idx_Xmax),room.grid_y(idx_Ymax)] + room.N_margin*room.grid_resolution;
        fprintf('      -> Estimate #%d at x=%0.2f, y=%0.2f\n', n, loc_est(n, :));
        valid_loc = true;
        if n>1  % is this is not the first estimate, make comparison to other estimates
            for m=1:n-1
                if(norm(loc_est(n, :)-loc_est(m, :)) < min_distance/10)  % est. too close
                    psi = eliminate_neighbourhood(psi, idx_Xmax, idx_Ymax, elimination_radius);
                    fprintf('      -> Estimate #%d is within %0.2fm of #%d. Will skip this one!\n', n, min_distance/10, m);
                    valid_loc = false;
                    break;
                end
            end
        else
            psi = eliminate_neighbourhood(psi, idx_Xmax, idx_Ymax, elimination_radius);
        end
    end
end

