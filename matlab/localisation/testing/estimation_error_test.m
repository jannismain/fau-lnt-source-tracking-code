%% Test 0: Constructed Example with S=2
S =                [1.5 4.6;
                    1.2 2.0];
loc_est_assorted = [3.9 1.7;
                    3.0 4.0];
tic;
[~,~,est_err] = evalc('estimation_error(S, loc_est_assorted);');
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
[~,~,est_err] = evalc('estimation_error(S, loc_est_assorted);');
[~,loc_est_min,est_err_min] = evalc('estimation_error_min(S, loc_est_assorted);');
assert(round(est_err(1), 2)==2.63)
assert(est_err(2)==0)
assert(est_err(3)==0)
assert(est_err(4)==0)
assert(sum(est_err==est_err_min)==4)

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
[~,~,est_err] = evalc('estimation_error(S, loc_est_assorted);');
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
[~,~,est_err] = evalc('estimation_error(S, loc_est_assorted);');
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
[~,~,est_err] = evalc('estimation_error(S, loc_est_assorted);');
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
    [~,~,est_err] = evalc('estimation_error(S, S_est_perm);');
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
    [~,~,est_err] = evalc('estimation_error(S, S_est_perm);');
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
    [~,~,est_err] = evalc('estimation_error(S, S_est_perm);');
    mean_err(n) = mean(est_err);
end
assert(min(mean_err)==max(mean_err));

%% Test 8: 2-5 random sources, 2-5 random estimates, all permutations of S_est
for m=1:50
    for n=2:5
        S = round(rand(n,2)*5, 1);        
        S_est = round(rand(n,2)*5, 1);

        all_perm_S = perms(1:size(S,1));
        loc_err = zeros(size(all_perm_S,1), n);
        for i=1:size(all_perm_S, 1)
            [~, ~, loc_err(i,:)] = evalc('estimation_error(S,S_est(all_perm_S(i,:),:));');
        end
        mean_err = mean(loc_err, 2);
        assert(round(min(mean_err),2)==round(max(mean_err),2));
    end
end

%% Test 9: 2-5 random sources, 2-5 random estimates, all permutations of S
for m=1:50
    for n=2:5
        S = round(rand(n,2)*5, 1);        
        S_est = round(rand(n,2)*5, 1);

        all_perm_S = perms(1:size(S,1));
        loc_err = zeros(size(all_perm_S,1), n);
        for i=1:size(all_perm_S, 1)
            [~, ~, loc_err(i,:)] = evalc('estimation_error(S(all_perm_S(i,:),:),S_est);');
        end
        mean_err = mean(loc_err, 2);
        assert(round(min(mean_err),2)==round(max(mean_err),2));
    end
end

%% Test 10: Constructed Example with S=4
S =     [4.7 1.2;
         1.5 2.9;
         1.7 4.5;
         2.3 2.7];
S_est = [1.5,2.9;
         2.3,2.7;
         2.2,4.9;
         1.1,3.9];
[~,loc_est,est_err] = evalc('estimation_error(S, S_est);');
assert(round(mean(est_err), 2)==1.29);