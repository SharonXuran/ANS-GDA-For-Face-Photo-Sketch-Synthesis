function [featuresx] = extractfeatures(conf,X,flag)
% Current image features extraction
% Input:  conf  -- configuration
%         X     -- the current image 
%         flag  -- 'mul','SQI','int','hig'
% Output: featuresx -- the feature matrix
if strcmp(flag,'mul')
    % multi-features
    % 1.ycbcr 2.lbp % 3.xy
    assert(size(X,3)==3, 'the image is not a color image!');
    X_ycbcr = rgb2ycbcr(X);
    X_y_J = imadjust(X_ycbcr(:,:,1),[],[],0.5);
    features1 = extract(conf,X_y_J,{});
    features2 = extract(conf,X_ycbcr(:,:,2),{});
    features3 = extract(conf,X_ycbcr(:,:,3),{});
    features_lbp = extract(conf,rgb2gray(X),{1});  % extract 1 lbp
    if isfield(conf,'V_pca') %
        featuresx = conf.V_pca'*[features1;features2;features3;features_lbp];%
        featuresPxy = extract(conf,X,{3});  % extract  3 xy
        featuresx(end+1:end+size(featuresPxy),:) = featuresPxy;
    else
        % use ycbcr+lbp to get the PCA 
        featuresx = [features1;features2;features3;features_lbp];
    end  
elseif strcmp(flag,'SQI')
    % SQI
    if size(X,3)==3
        X_ycbcr = rgb2ycbcr(X);
        X = X_ycbcr(:,:,1);
    end
    X_y_J = SQI(X);
    featuresx = extract(conf,X_y_J,{});
elseif strcmp(flag,'int')
    % int
    featuresx = extract(conf,X,{});
elseif strcmp(flag,'hig')
    % submean
    featuresx = extract(conf,X,{});
    featuresx = featuresx - mean(featuresx,1);
    if size(X,3)==3
        featuresPxy = extract(conf,X,{3});  % extract  3 xy
        featuresx(end+1:end+size(featuresPxy),:) = featuresPxy;
    end
end
