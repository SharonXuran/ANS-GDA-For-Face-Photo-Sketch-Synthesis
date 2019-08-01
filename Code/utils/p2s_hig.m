function psketch_syn = p2s_hig(conf,imgs)
grid = sampling_grid([size(imgs,1),size(imgs,2)], ...
    conf.window, conf.overlap, conf.border);
img_size = [size(imgs,1),size(imgs,2)];
features_gray = collect(conf,{imgs},'gray');
sum_t = sum(features_gray(1:size(features_gray,1),:));
bg_id = find(sum_t==size(features_gray,1));
id = ones(1,size(features_gray,2));
id(bg_id)=0;
features = collect(conf,{imgs},'hig');
features(:,bg_id)=[];

% find patches of the test sketch
D = abs(conf.dict_h'*features);
[~, idx] = max(D);
clear D;

features = double(features);

l2 = sum(features.^2).^0.5+eps;
l2n = repmat(l2,size(features,1),1);
featuresl2 = features./l2n;


for l = 1: size(features,2) 
    ancho_P = conf.pp(:,conf.ancho_idx{idx(l)});
    D_pp = abs(ancho_P'*featuresl2(:,l));
    [~, idx_pp] = sort(D_pp);
    ancho_S = conf.ps(:,conf.ancho_idx{idx(l)});
    s_candidates = ancho_S(:,idx_pp(end-conf.K+1:end));
    Spatches(:,l) = mean(s_candidates,2);
end

psketch_syn = single(zeros(size(Spatches,1),size(grid,3)));
psketch_syn(:,id==1) = Spatches;
psketch_syn(:,id==0) = 0;
end

