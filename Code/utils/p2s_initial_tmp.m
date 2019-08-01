function psketch_syn = p2s_initial_tmp(conf,imgs)
grid = sampling_grid([size(imgs,1),size(imgs,2)], ...
    conf.window, conf.overlap, conf.border);
img_size = [size(imgs,1),size(imgs,2)];
features_gray = collect(conf,{imgs},'gray');
sum_t = sum(features_gray(1:size(features_gray,1),:));
bg_id = find(sum_t==(size(features_gray,1)));
% bg_id = find(sum_t==0);
id = ones(1,size(features_gray,2));
id(bg_id)=0;
features = collect(conf,{imgs},'mul');
features(:,bg_id)=[];

% find patches of the test sketch
D = abs(conf.dict'*features);
[~, idx] = max(D);
clear D;

% features = double(features);

% l2 = sum(features.^2).^0.5+eps;
% l2n = repmat(l2,size(features,1),1);
% featuresl2 = features./l2n;

features_SQI = collect(conf,{imgs},'SQI');
features_SQI(:,bg_id)=[];
features_SQI = double(features_SQI);

l2 = sum(features_SQI.^2).^0.5+eps;
l2n = repmat(l2,size(features_SQI,1),1);
features_SQI = features_SQI./l2n;


for l = 1:size(features_SQI,2) 
    ancho_P = conf.pp(:,conf.ancho_idx{idx(l)});
    D_pp = abs(ancho_P'*features_SQI(:,l));
    [~, idx_pp] = sort(D_pp);
    ancho_S = conf.ps(:,conf.ancho_idx{idx(l)});
    s_candidates = ancho_S(:,idx_pp(end-conf.K+1:end));
    Spatches(:,l) = mean(s_candidates,2);
end

psketch_syn = single(zeros(size(Spatches,1),size(grid,3)));
psketch_syn(:,id==1) = Spatches;
psketch_syn(:,id==0) = 1;
end

