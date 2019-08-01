% Anchored Neighborhood Search for Sketch Synthesis
% Example code
% Updated version: 
% Dec. 16, 2018. Sharon xu, NUPT
% 
clear;
close all;

% ===========================Configuration====================
% addpath
p = pwd;
addpath(fullfile(p, '/utils'));  % the functions utilized
addpath(fullfile(p, '/ksvdbox')) % K-SVD dictionary training algorithm
addpath(fullfile(p, '/ompbox')) % Orthogonal Matching Pursuit algorithm

input_dir = 'Data'; % Directory with input images
pattern = '*.jpg'; % Pattern to process

dict_sizes = [3 4 8 16 32 64 128 256 512 1024 2048 4096 5120 8192 16384 32768 65536];
block = 12;
overlap = 8;
dl=12;    %4096
dh = 9; % 512
%d = 8; %256
%d = 7; %128
%d = 6; % 64
%d = 5; % 32
%d=4;  %16
%d=3;  %8
%d=2; %4
%d=1; %2

conf.filters = {};
conf.window = [block block]; % window size
conf.border = [0 0]; % border of the image (to ignore)  
conf.overlap = [overlap overlap];


% ====================Load training images===================
% 1 load photos; 0 load sketches
photo_cell = load_images(glob('Data/CUHK Students/Training/photos', pattern),1);
sketch_cell = load_images(glob('Data/CUHK Students/Training/sketches', pattern),0);

conf_filename = ['conf_size_' num2str(block) '_overlap_' num2str(overlap) 'dict_' num2str(dict_sizes(dl)) '_' num2str(dict_sizes(dh))];
if  exist([conf_filename '.mat'],'file')
    load([conf_filename '.mat'], 'conf');
end
% PCA
if ~ isfield(conf,'V_pca')
    disp('pca...');
    % select 88 pairs randomly to calculate pca 
    photo_pca = photo_cell(randperm(length(photo_cell),88));
    % drop the background patches i.e. gray-vector all equals "1" 
    features_temp_gray = collect(conf,photo_pca ,'gray');
    sum_p = sum(features_temp_gray);
    bg_id = sum_p==size(features_temp_gray,1);
    features_temp = collect(conf,photo_pca ,'mul');
    features_temp(:,bg_id)=[];
    conf.V_pca = calpca(features_temp,0.75);
    clear features_temp;
    save(conf_filename,'conf');
end

%  which patches should be droped
bg_id=[];
pp_gray = collect(conf,photo_cell,'gray');
sum_p = sum(pp_gray);
bg_id = find(sum_p==size(pp_gray,1));

%  ==================Dictionary Learning in initial domain =========================
fname_l = ['patch_l_for_DL_siez' num2str(block) '_overlap_' num2str(overlap)];
if ~isfield(conf,'dict')
    disp('learn dictionary in the inter-domain...');
    % if the dict is not exist
    if exist([fname_l,'.mat'],'file')
        load(fname_l);
    else
        disp('collect...');
        pphoto = collect(conf,photo_cell,'mul');
        pphoto(:,bg_id)=[];
        save(fname_l,'pphoto');
    end
    conf.dict = learn_dict_PhSk(pphoto,dict_sizes(dl));
    save(conf_filename,'conf');
end

% =================Dictionary Learning in high-frequency domain========
fname_h = ['patch_h_siez' num2str(block) '_overlap_' num2str(overlap)];
if  ~isfield(conf,'dict_h')
    disp('learn dictionary in the intra-domain...');
    if exist([fname_h,'.mat'],'file')
        load(fname_h);
    else
        disp('collect...');
        pphoto_h = collect(conf,photo_cell,'hig');
        psketch_h = collect(conf, sketch_cell,'hig');
        pphoto_h(:,bg_id)=[];
        psketch_h(:,bg_id)=[];
        save(fname_h,'pphoto_h','psketch_h');
    end
    conf.dict_h = learn_dict_PhSk(pphoto_h,dict_sizes(dh));
    save(conf_filename,'conf');
end

%  =====================Clustering in initial domain========================
clustersz = 2048;
inter_ancho_filename = ['A_l_clustersz_' num2str(clustersz) '_dict_size' num2str(dict_sizes(dl)) 'patchsize' num2str(block) '_overlap_' num2str(overlap)];
if  exist([inter_ancho_filename '.mat'],'file')
    load(inter_ancho_filename);
else
    disp('Anchored neighborhood Clustering in the inter-domain...');
    % if the ancho is not exist
    if exist([fname_l,'.mat'],'file')
        load(fname_l);
    else
        pphoto = collect(conf, photo_cell,'mul');
        pphoto(:,bg_id)=[];
        save(fname_l,'pphoto');
    end
    % l2 normalize
    l2 = sum(pphoto.^2).^0.5+eps;
    l2n = repmat(l2,size(pphoto,1),1);
    pphotol2 = pphoto./l2n;
    for i = 1: size(conf.dict,2)
        D = abs(single(pphotol2)'*single(conf.dict(:,i)));
        [~, idx] = sort(D);
        % get the index
        ancho_idx{i} = idx(end-clustersz+1:end);
    end
    
    % change the feature space into SQI space
    fname_l_SQI = ['patch_l_for_ANS_siez' num2str(block) '_overlap_' num2str(overlap)];
    if  exist([fname_l_SQI '.mat'],'file')
        load(fname_l_SQI);
    else
        pphoto = collect(conf,photo_cell,'SQI');
        psketch = collect(conf,sketch_cell,'int');
        pphoto(:,bg_id)=[];
        psketch(:,bg_id)=[];
        l2 = sum(pphoto.^2).^0.5+eps;
        l2n = repmat(l2,size(pphoto,1),1);
        l2(l2<0.1) = 1;
        pphoto = pphoto./l2n;
        save(fname_l_SQI, 'pphoto','psketch');
    end   
    save(inter_ancho_filename, 'ancho_idx','pphoto','psketch');
end


% =======================Clustering in intra-domain=======================
clustersz = 2048;
intra_ancho_filename = ['A_h_clustersz_' num2str(clustersz) '_dict_size' num2str(dict_sizes(dh)) 'patchsize' num2str(block) '_overlap_' num2str(overlap)];
if  exist([intra_ancho_filename '.mat'],'file')
    load(intra_ancho_filename);
else
    disp('Anchored neighborhood Clustering in the intra-domain...');
    if exist([fname_h,'.mat'],'file')
        load(fname_h);
    else
        pphoto_h = collect(conf,photo_cell,'hig');
        psketch_h = collect(conf, sketch_cell,'hig');
        pphoto_h(:,bg_id)=[];
        psketch_h(:,bg_id)=[];
        save(fname_h,'pphoto_h','psketch_h');
    end
    l2 = sum(pphoto_h.^2).^0.5+eps;
    l2n = repmat(l2,size(pphoto_h,1),1);
    l2(l2<0.1) = 1;
    pphoto_hl2 = pphoto_h./l2n;    
    for i = 1: size(conf.dict_h,2)
        D = abs(single(pphoto_hl2)'*single(conf.dict_h(:,i)));
        [~, idx] = sort(D);
        ancho_idx_h{i} = idx(end-clustersz+1:end);
    end
    save(intra_ancho_filename, 'ancho_idx_h','pphoto_hl2','psketch_h');
end

% =============================Testing============================
% read the test filenames
conf.filenames = glob('Data/CUHK Students/Testing/photos', pattern); 

conf.results = {};
testOverlap=11;
conf.overlap=[testOverlap,testOverlap];
K=1;
conf.K = K;
conf.result_dir = qmkdir(['Results-Aplus-' datestr(now, 'YYYY-mm-dd_HH-MM-SS') '_overlap' num2str(testOverlap) '_K' num2str(K)]);
% get the Initial synthesized sketch
res =[];


for i = 1:numel(conf.filenames)
    
    f = conf.filenames{i};
    [p, n, x] = fileparts(f);
    f_cell = {f};
    img = load_images(f_cell,1);
    disp(['synthesis ' n '...']);
    img_size = [size(img{1},1),size(img{1},2)];
    grid = sampling_grid([size(img{1},1),size(img{1},2)], ...
        conf.window, conf.overlap, conf.border);
    
    % ===================initial-domain==========================
    disp('generate the initial sketch...')
    conf.ancho_idx = ancho_idx;
    conf.pp = pphoto;
    conf.ps = psketch;
    res_inter = p2s_initial_tmp(conf, img{1});
    res_inter_img = overlap_add(res_inter, img_size, grid);
%     figure,imshow(res_inter_img);
%    imwrite(res_inter_img,fullfile(conf.result_dir, [num2str(i) '.png']));

    
    % =================high-frequency domain======================
    disp('generate the high-frequency sketch...')
    conf.ancho_idx = ancho_idx_h;
    conf.pp = pphoto_hl2;
    conf.ps = psketch_h;
    res_intra = p2s_hig(conf,img{1});
    
    % ===================final-synthesis======================
    results = res_inter+0.2*(res_inter- mean(res_inter,1))+0.2*res_intra;  
    res{i} = overlap_add(results, img_size, grid);
%     figure,imshow(res{i});

    imwrite(res{i},fullfile(conf.result_dir, [n '.png']));
end
% remove path
rmpath(fullfile(p, '/utils'));
rmpath(fullfile(p, '/ksvdbox'));
rmpath(fullfile(p, '/ompbox'));
