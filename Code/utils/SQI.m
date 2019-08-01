function img_out = SQI(img_in)

% face illumination preprocessing using SQI method
% SQI: Self-quotient image
% Basic principle: Reflectance field estimation
% References: H.Wang, S.Z.Li, Y.Wang, Face recognition under varying lighting conditions
%             using self quotient image, in: Proceedings of the Automatic Face and Gesture
%             Recognition, 2004, pp.819¨C824.
%
% INPUT:
% img_in: the input image
%
% OUTPUT:
% img_out: the SQI image

%                 size  sigma
para_Guafilter = [  3,  0.5;  %1:  3x3
                    5,  1.0;  %2:  5x5
                    7,  2.0;  %3:  7x7
                    9,  2.0;  %4:  9x9
                   11,  3.0;  %5:  11x11
                   13,  3.8;  %6:  13x13
                   15,  4.2;  %7:  15x15
                   17,  4.8;  %8:  17x17
                   19,  5.0;  %9:  19x19
                   21,  6.0;  %10: 21x21
                   23,  8.0;  %11: 23x23
                   25,  9.0;  %12: 25x25
                   ];

img_out = zeros(size(img_in));
img_in = double(img_in);

[num_scale, num_para] = size(para_Guafilter);
scale_used = 0;
for inx_scale = 1 : num_scale

    scale_used = scale_used + 1;
    
    % get smoothed version
    hsize = para_Guafilter(inx_scale, 1);
    sigma = para_Guafilter(inx_scale, 2);
    H = fspecial('gaussian', hsize, sigma);
    img_smo = imfilter(img_in, H, 'replicate');
    
    % get self-quotient image
    QI_cur = img_in ./ img_smo;
    
    % nonlinear transform 2: sigmoid transform
    QI_cur = 1 ./ (1 + exp(-QI_cur));
    
    QI_cur = 255.0 * double( mat2gray(QI_cur) );
    QI_cur = double( uint8(QI_cur) );
    
    % nonlinear transform 1: logarithm transform
    %QI_cur = log(QI_cur + 1);
    %QI_cur = 255 * mat2gray(QI_cur);
    %QI_cur = double( uint8(QI_cur) );
    
    % cumulation
    img_out = img_out + QI_cur;
end
% get the final self-quotient image
img_out = img_out / scale_used;
img_out = uint8(img_out);
end
% eof