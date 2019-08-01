function [imgs] = load_images(paths,isPhoto)
% load images
% Input:  patchs  -- the load patchs
%         isPhoto -- '0' load sketches; '1' load photos
% Output: imgs   -- image cells
imgs = cell(size(paths));
for i = 1:numel(paths)
    X = imread(paths{i});
    if isPhoto  % if load images are photos
        X = im2single(X);
    else  % if load images are sketches
    if size(X, 3) == 3 % we extract our features from Y channel
        X = rgb2gray(X);
    end
    X = im2single(X); % to reduce memory usage
    end
    imgs{i} = X;   
end
