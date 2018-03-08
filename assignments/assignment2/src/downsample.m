% Assignment 2: Scale-space blob detection
% Zhenye Na (zna2)
% 3/6/2018

% img filename: butterfly.jpg, einstein.jpg, fishes.jpg, Florist.jpg
% frog.jpg, gta5.jpg, sunflowers.jpg, tnj.jpg, music.jpg


clear all
% Read in image and convert to double and then grayscale
img = imread('../data/butterfly.jpg');
img = rgb2gray(img);
img = im2double(img);


% Image size
[h, w] = size(img);
% Define threshold
threshold = 0.35;
% Increasing factor of k
k = 1.2;
% Define number of iterations
levels = 5;
% Define parameters for LoG
initial_sigma = 2;
sigma = 2;
% hsize = 2 * ceil(2 * sigma) + 1;


tic
% Perform LoG filter to image for several levels
% [h,w] - dimensions of image, n - number of levels in scale space
scale_space = zeros(h, w, levels); 
for i = 1:levels
    % Generate a Laplacian of Gaussian filter and scale normalization
    LoG = fspecial('log', 2 * ceil(3*sigma) + 1, sigma);
    if i == 1
        % Filter the img with LoG
        scale_space(:,:,i) = imfilter(img, LoG, 'same', 'replicate') .* (sigma^2);
    else
        % Filter the img with LoG
        response = imfilter(img_copy, LoG, 'same', 'replicate') .* (sigma^2);
        scale_space(:,:,i) = imresize(response, [h, w]);
    end
    % Increase scale by a factor k
    sigma = sigma * k;
    % hsize = 2 * ceil(sigma) + 1;
    % Downsample the img
    img_copy = imresize(img, 1/k);
end
toc




% Perform nonmaximum suppression in each 2D slice
% nonmax_space = zeros(h, w, levels);
suppressed_space = zeros(h,w,levels);
suppress_order = 3;
for num = 1:levels
    % nonmax_space(:,:,num) = scale_space(:,:,num) .* imregionalmax(scale_space(:,:,num));
    % nonmax_space(:,:,num) = scale_space(:,:,num) .* (maxima_space(:,:,num) >= threshold);
    suppressed_space(:,:,num) = ordfilt2(scale_space(:,:,num),suppress_order^2, ones(suppress_order)); 
    % suppressed_space(:,:,num) = suppressed_space(:,:,num) .* (suppressed_space(:,:,num) == nonmax_space(:,:,num));
end



maxima_space = max(suppressed_space, [], 3);
survive_space = zeros(h, w, levels);
for num = 1:levels
    survive_space(:,:,num) = (maxima_space == scale_space(:,:,num));
    survive_space(:,:,num) = survive_space(:,:,num) .* img;
end


% Find all the coordinates and corresponding sigma
[row, col] = size(survive_space(:,:,num));
idx = 1;
for num = 1:levels
    for i = 1:row
        for j = 1:col
            if(survive_space(i,j,num) >= threshold) 
                cx(idx) = i;
                cy(idx) = j;
                rad(idx) = sqrt(2) * initial_sigma^num; 
                idx = idx + 1;
            end
        end
    end
end







show_all_circles(img, cy', cx', rad');