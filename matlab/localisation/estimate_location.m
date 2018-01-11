function [ loc_est ] = estimate_location( psi, n_sources, elimination_area, min_distance, room)
%% ESTIMATE_LOCATION Finds the n_sources most probable locations of sources

%% Arguments
% * *psi (mat)*: _Output of |<em_algorithm.html em_iterations.m>|_
% * *n_sources (int)*: _number of locations to be found_
% * *elimination_area (int)*: _size of area around found location estimate to eliminate_
% * *room (struct)*: _room setup structure from configuration file_

%% Returns
% * *loc_est (mat)*: _|2xN| matrix of |[x y]| coordinates of estimated locations (i.e. |[2.4, 3.0; 1.2, 4.9]| for |n=2|)_

fprintf('\n<%s.m> (t = %2.4f)\n', mfilename, toc);

if nargin<1, error('input argument "psi" is required!'); end
if nargin<2, n_sources=2; end
if nargin<3, elimination_area=0; end
if nargin<4, min_distance=5; end

loc_est = zeros(n_sources, 2);

for n=1:n_sources
    %% determine maximum
    valid_loc = false;
    while ~valid_loc
        [~,idx_Xmax] = max(max(psi,[],1));  % ~ = max. value of psi at identified index
        [~,idx_Ymax] = max(max(psi,[],2));
        loc_est(n, 1:2) = [room.grid_x(idx_Xmax),room.grid_y(idx_Ymax)] + room.N_margin*room.grid_resolution;
        valid_loc = true;
        if n>1  % is this is not the first estimate, make comparison to other estimates
            for m=1:n-1
                if(norm(loc_est(n, :)-loc_est(m, :)) < min_distance/10)  % est. too close
                    psi = eliminate_neighbourhood(psi, idx_Xmax, idx_Ymax, elimination_area);
                    %fprintf('      -> Estimate #%d is within %0.2fm of #%d. Will skip this one!\n', n, min_distance/10, m);
                    valid_loc = false;
                    break;
                end
            end
        else
            psi = eliminate_neighbourhood(psi, idx_Xmax, idx_Ymax, elimination_area);
        end
        if valid_loc, fprintf('      -> Estimate #%d at x=%0.2f, y=%0.2f\n', n, loc_est(n, :)); end
        if sum(sum(psi))==0, break; end
    end
end

