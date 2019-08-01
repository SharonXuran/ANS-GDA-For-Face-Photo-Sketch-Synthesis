function dict_fine = learn_dict_PhSk(patch, dictsize)
% Sample patches (from high-res. images) and extract features (from low-res.)
% for the Super Resolution algorithm training phase, using specified scale 
% factor between high-res. and low-res.

% Load training high-res. image set and resample it

% featuresS = collect(conf, sketch,{});
% featuresP = collect(conf, photo, conf.filters);
featuresP = patch;

% Set KSVD configuration
%ksvd_conf.iternum = 20; % TBD
ksvd_conf.iternum = 20; % TBD
ksvd_conf.memusage = 'normal'; % higher usage doesn't fit...
%ksvd_conf.dictsize = 5000; % TBD
ksvd_conf.dictsize = dictsize; % TBD
ksvd_conf.Tdata = 3; % maximal sparsity: TBD
ksvd_conf.samples = size(featuresP,2);

% % PCA dimensionality reduction
% C = double(featuresP * featuresP');
% [V, D] = eig(C);
% D = diag(D); % perform PCA on features matrix 
% D = cumsum(D) / sum(D);
% k = find(D >= 1e-3, 1); % ignore 0.1% energy
% conf.V_pca = V(:, k:end); % choose the largest eigenvectors' projection
% conf.ksvd_conf = ksvd_conf;
% features_pca = conf.V_pca' * featuresP;
% % Combine into one large training set
% clear C D V

features_pca = featuresP;
ksvd_conf.data = double(features_pca);
clear features_pca
% Training process (will take a while)
tic;
fprintf('Training [%d x %d] dictionary on %d vectors using K-SVD\n', ...
    size(ksvd_conf.data, 1), ksvd_conf.dictsize, size(ksvd_conf.data, 2))
[dict_fine, gamma] = ksvd(ksvd_conf); 
toc;
% X_lores = dict_lores * gamma
% X_hires = dict_hires * gamma {hopefully}

fprintf('Computing high-res. dictionary from low-res. dictionary\n');
% dict_hires = patches / full(gamma); % Takes too much memory...
% featuresS = double(featuresS); % Since it is saved in single-precision.
% dict_hires = (featuresS * gamma') * inv(full(gamma * gamma'));
% 
% conf.dict_hires = double(dict_hires); 

