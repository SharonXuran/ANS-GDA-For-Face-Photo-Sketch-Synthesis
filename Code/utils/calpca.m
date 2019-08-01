function [V_pca] = calpca( features,th )
%calpca 
%   
C = double(features * features');
[V, D] = eig(C);
D = diag(D); % perform PCA on features matrix
D = cumsum(D) / sum(D);
k = floor(length(D)*th); % ignore th ,eg£º0.75
V_pca = V(:, k:end);
end

