function [featuresx] = extract(conf,X,filters)

% Compute one grid for all filters
grid = sampling_grid(size(X), ...
    conf.window, conf.overlap, conf.border);
% feature_size = prod(conf.window) * numel(conf.filters);

% Current image features extraction [feature x index]
if isempty(filters)
    fx = X(grid);
    featuresx = reshape(fx, [size(fx, 1) * size(fx, 2) size(fx, 3)]);
elseif filters{1}==2
    X_ = padarray(X,conf.window,'replicate','both');
    grid_ = sampling_grid(size(X_), ...
    conf.window+24, conf.overlap+24, conf.border);
    f_ = X_(grid_);
    for np = 1:size(f_, 3)
        fc = [36/2;36/2;36/2;0];
        [~,sift(:,np)]=vl_sift(f_(:,:,np),'frames',fc);
    end
    featuresx(1:size(sift,1),:)=sift;
elseif filters{1}==1
    fx = X(grid);
    for np = 1:size(fx, 3)
        lbp(:,np) = extractLBPFeatures(fx(:,:,np));
    end
    featuresx(1:size(lbp,1),:)=lbp;
elseif filters{1}==3
    skip = conf.window(1)-conf.overlap(1);
    xnum = floor((size(X,1)-conf.overlap(1))/skip);
    for num =1:size(grid,3)
        fx = skip*mod(num-1,xnum)+conf.window(1)/2;
        fy = skip*floor((num-1)/xnum)+conf.window(1)/2;
        xy(:,num)=[fx/size(X,1);fy/size(X,2)];
    end
    featuresx(1:size(xy,1),:)=xy;
end
