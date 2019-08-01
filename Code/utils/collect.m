function [features_p] = collect(conf, imgs,flag,verbose)

if nargin < 5
    verbose = 0;
end

num_of_imgs = numel(imgs);
feature_p_cell = cell(num_of_imgs, 1); % contains photos' features
% feature_s_cell = cell(num_of_imgs, 1); %contains sketches' features
num_of_features = 0;

if verbose
    fprintf('Collecting features from %d image(s) ', num_of_imgs)
end
feature_size = [];

h = [];
for i = 1:num_of_imgs
    h = progress(h, i / num_of_imgs, verbose);
    sz = size(imgs{i});
    if verbose
        fprintf(' [%d x %d]', sz(1), sz(2));
    end
    if size(imgs{i},3)==3
        if strcmp(flag,'gray')
            [F_p] = extractfeatures(conf,rgb2gray(imgs{i}),'int');
        else
            [F_p] = extractfeatures(conf,imgs{i},flag);
        end
    else
        [F_p] = extractfeatures(conf,imgs{i},flag);
    end
    num_of_features = num_of_features + size(F_p, 2);
    feature_p_cell{i} = F_p;    

    assert(isempty(feature_size) || feature_size == size(F_p, 1), ...
        'Inconsistent feature size!')
    feature_size = size(F_p, 1);
end
if verbose
    fprintf('\nExtracted %d features (size: %d)\n', num_of_features, feature_size);
end
clear imgs % to save memory
features_p = zeros([feature_size num_of_features], 'single');

offset = 0;
for i = 1:num_of_imgs
    F_p = feature_p_cell{i};

    N = size(F_p, 2); % number of features in current cell
    features_p(:, (1:N) + offset) = F_p;

    offset = offset + N;
end
