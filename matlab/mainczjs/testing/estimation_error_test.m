%% Test 0: 
S =                [1.5 4.6;
                    1.2 2.0];
loc_est_assorted = [3.9 1.7;
                    3.0 4.0];
tic;
[loc_est,est_err] = estimation_error(S, loc_est_assorted);
assert(round(est_err(1), 2)==1.62)
assert(round(est_err(2), 2)==2.72)
%% Test 1: S(1) not in S_est
S =                [1.5 1.3;
                    1.8 4.4;
                    3.9 1.7;
                    3.0 4.0];
loc_est_assorted = [3.9 1.7;
                    3.0 4.0;
                    1.8 4.4;
                    1.1 3.9];
tic;
[~,est_err] = estimation_error(S, loc_est_assorted);
% Print Results
% for s=1:size(S, 1)
%     fprintf("  -> Source Location #%d = [x=%0.2f, y=%0.2f], Estimate = [x=%0.2f, y=%0.2f], err=%0.2f\n", s, S(s,1:2), loc_est(s, :), est_err(s));
% end
% fprintf("  -> Average Estimation Error = %0.2f (Elapsed time = %0.3f)\n", mean(est_err), toc');
assert(round(est_err(1), 2)==2.63)
assert(est_err(2)==0)
assert(est_err(3)==0)
assert(est_err(4)==0)

%% Test 2: S_est(1) not in S
S =                [1.1 3.9;
                    1.8 4.4;
                    3.9 1.7;
                    3.0 4.0];
loc_est_assorted = [3.9 4.0;
                    3.0 4.0;
                    1.8 4.4;
                    1.1 3.9];
tic;
[~,est_err] = estimation_error(S, loc_est_assorted);
assert(est_err(1)==0)
assert(est_err(2)==0)
assert(round(est_err(3), 2)==2.30)
assert(est_err(4)==0)

%% Test 3: S_est(1:2) not in S
S =                [1.1 3.9;
                    1.8 4.4;
                    3.9 1.7;
                    3.0 4.0];
loc_est_assorted = [3.9 4.0;
                    3.4 2.0;
                    1.8 4.4;
                    1.1 3.9];
tic;
[~,est_err] = estimation_error(S, loc_est_assorted);
assert(est_err(1)==0)
assert(est_err(2)==0)
assert(round(est_err(3), 2)==0.58)
assert(round(est_err(4), 2)==0.90)

%% Test 4: S_est(1:4) not in S, but close
S =                [1.1 3.9;
                    1.8 4.4;
                    3.9 1.7;
                    3.0 4.0];
loc_est_assorted = [2.8 4.0;
                    3.8 1.8;
                    2.0 4.4;
                    1.1 4.0];
tic;
[~,est_err] = estimation_error(S, loc_est_assorted);
assert(round(est_err(1), 2)==0.10)
assert(round(est_err(2), 2)==0.20)
assert(round(est_err(3), 2)==0.14)
assert(round(est_err(4), 2)==0.20)

%% Test 5: 4 wrong estimates, 10 random permutations
S =                [1.1 3.9;
                    1.8 4.4;
                    3.9 1.7;
                    3.0 4.0];
S_est =            [2.8 4.0;
                    3.8 1.8;
                    2.0 4.4;
                    1.1 4.0];
for n=1:10
    tic;
    S_est_perm = S_est(randperm(length(S_est)),:);
    [~,est_err] = estimation_error(S, S_est_perm);
    assert(round(mean(est_err), 2)==0.16);
end

%% Test 6: 2 wrong estimates close to same S, 10 random permutations
S =                [1.1 3.9;
                    1.8 4.4;
                    3.9 1.7;
                    3.0 4.0];
S_est =            [2.8 4.0;
                    3.9 1.7;
                    2.5 4.4;
                    1.1 3.9];
for n=1:10
    tic;
    S_est_perm = S_est(randperm(length(S_est)),:);
    [~,est_err] = estimation_error(S, S_est_perm);
    assert(round(mean(est_err), 2)==0.23);
end

%% Test 7: 4 random estimates, 10 random permutations
S =                [1.1 3.9;
                    1.8 4.4;
                    3.9 1.7;
                    3.0 4.0];
                
S_est = round(rand(4,2)*5, 1);
mean_err = zeros(10, 1);
for n=1:10
    tic;
    S_est_perm = S_est(randperm(length(S_est)),:);
    [~,est_err] = estimation_error(S, S_est_perm);
    mean_err(n) = mean(est_err);
end
assert(min(mean_err)==max(mean_err));

%% Test 8: 2-7 random sources, 2-7 random estimates, 25 random permutations
for s=2:7
    S = round(rand(s,2)*5, 1);        
    S_est = round(rand(s,2)*5, 1);
    mean_err = zeros(10, 1);
    for n=1:25
        tic;
        S_est_perm = S_est(randperm(length(S_est)),:);
        [~, est_err] = estimation_error(S, S_est_perm);
        mean_err(n) = mean(est_err);
    end
    assert(min(mean_err)==max(mean_err));
end

%% Test 9: 
S =     [4.7 1.2;
         1.5 2.9;
         1.7 4.5;
         2.3 2.7]
S_est = [1.5,2.9;
         2.3,2.7;
         2.2,4.9;
         1.1,3.9]
[loc_est,est_err] = estimation_error(S, S_est);
display(loc_est);
display(est_err);
% assert(round(mean(est_err), 2)==0.16);