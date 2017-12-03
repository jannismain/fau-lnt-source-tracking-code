fprintf('------------------------- T E S T R U N -------------------------\n');
%% setting parameters
sources = 7;
md = 5;
wd = 12;
rand_sources = false;
rand_samples = false;
T60=0.6;
SNR=0;
em_iterations=10;
em_conv_threshold=0.0001;
guess_randomly=false;
reflect_order=3;
var_init=10;
var_fixed = false;
get_em_history = false;

%% init
tic;
fn_conf = config_update(sources,rand_sources, md,wd,rand_samples,T60,em_iterations, em_conv_threshold, reflect_order, SNR, var_init, var_fixed);
load(fn_conf);

%% Simulate Environment
x = simulate(fn_cfg, ROOM, R, sources, false);
x2 = x(:,2,1,1);
x3 = x(:,3,1,1);
x23 = sum(x(:,2:3,1,1),2);
x46 = sum(x(:,4:6,1,1),2);
n_sources = size(x,2);
figure;
for s=1:n_sources
    xtemp = x(:,s,1,1);
    subplot(2,n_sources,s);
    plot(xtemp);
    subplot(2,n_sources,n_sources+s);
    specgram(xtemp);
end

p12 = abs(imag(specgram(x2)).*imag(specgram(x3)));
figure;
subplot(1,2,1)
mesh(p12)
view([0 0])
title('X2*X3')
colormap('jet')

p2346 = abs(imag(specgram(x23)).*imag(specgram(x46)));
subplot(1,2,2)
mesh(p2346)
view([0 0])
title('(X2+X3)*(X4+X5+X6)')
colormap('jet')

delete(fn_cfg);