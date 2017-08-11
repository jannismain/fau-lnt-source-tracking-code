% Setup data

FORMAT_ANGLE = '%0.3f\x00B0 (expected %0.3f\x00B0)\n';
ROOM = [5 4 6];

R1 = [4, 0, 3];
S1 = [2, 2, 3];
S2 = [6, 2, 3];
S3 = [4, 3.5, 3];

R  = [3.85, 0.00, 3.00;      % Receiver 1 position [ x y z ] (m)
      4.15, 0.00, 3.00];     % Receiver 2 position [ x y z ] (m)
   %   R1];                   % Receiver 3 position [ x y z ] (m)

S  = [S1;                    % Source   1 position [ x y z ] (m)
      S2;                    % Source   2 position [ x y z ] (m)
      S3];                   % Source   3 position [ x y z ] (m)

fig = plot_room(ROOM, R, S);
counter = 1;


%% Test 1: 45 degree angles, single source, single receiver
DOA_expected = [-45, 45, 90];
for s = 1:size(S, 1)
   DOA = doa(S(s, :), R1);
   %fprintf(FORMAT_ANGLE, DOA, DOA_expected(s));
   assert(DOA == DOA_expected(s))
end

m = "PASSED (exact angles, single source, single receiver)"; counter = next_step(m, counter, 0, 0);

%% Test 2: 45 degree angles, single source, two receivers
DOA_expected = [-45, 45, 90];
for s = 1:size(S, 1)
   DOA = doa(S(s, :), R);
   %fprintf(FORMAT_ANGLE, DOA, DOA_expected(s));
   assert(DOA == DOA_expected(s))
end

m = "PASSED (exact angles, single source, two receivers)"; counter = next_step(m, counter, 0, 0);

%% Test 3: 45 degree angles, two sources, two receivers
DOA_expected = [-45, 45, 90];
DOA = doa(S, R);
assert(size(DOA, 1) == size(S, 1))
for s = 1:size(S, 1)
   %fprintf(FORMAT_ANGLE, DOA(s), DOA_expected(s));
   assert(DOA(s) == DOA_expected(s))
end

m = "PASSED (exact angles, two sources, two receivers)"; counter = next_step(m, counter, 0, 0);