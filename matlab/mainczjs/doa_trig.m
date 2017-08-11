function [ DOA ] = doa_trig(S, R)
%DOA Summary of this function goes here
%   R can be of the size [n_receivers x n_dimensions], whereas
%       n_receivers  ->  1 | 2
%       n_dimensions ->  2 | 3
%   S can be of the size [n_sources x n_dimensions], whereas
%       n_sources    ->  1 | 2
%   If 2 receivers are provided, a virtual receiver is calculated
%   in between the two actual ones.

n_receivers = size(R, 1);
n_sources = size(S, 1);

DOA = zeros(n_sources, 1);

if n_receivers > 2  % sanity check, only two receivers are supported
    error('A maximum of 2 receivers is allowed for this DOA calculation');
elseif n_receivers == 2
    r = sum(R)./n_receivers;  % determine virtual mean receiver
elseif n_receivers == 1
    r = R;
else
    error('Insufficient number of receivers provided!');
end
    
d_rs = S - r;  % determine distance between source(s) and receiver

for s = 1:n_sources
    DOA(s) = atand(d_rs(s, 2)/d_rs(s, 1))+90;
end

end

