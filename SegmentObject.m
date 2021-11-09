function [im_OUT, x, y, numberObjects] = SegmentObject(im_IN, threshold)
%SEGMENTOBJECT Returns object image

%convert image to gray (single chanel)
im_IN_gray = rgb2gray(im_IN);

%check if user provided threshold value
if (nargin < 2)
    %calculate threshold value, via Otsu method
    thresh_value = graythresh(im_IN_gray);
else
    thresh_value = threshold;
end

%aply threshold segmentation 
im_BW = imbinarize(im_IN_gray, thresh_value); %imbinarize = im2bw

%show images
subplot(2,3,2); imshow(im_IN_gray); title('Gray image');
subplot(2,3,3); imshow(im_BW); title('Black and white image');

%determine all objects present in image
Objects = bwconncomp(im_BW, 8)
%create a black image with the same size as im_BW
im_object = false(size(im_BW));

%get object properties
%‘basic’ some object properties
%‘all’ all object properties
info = regionprops(Objects, 'Area', 'Centroid'); %basic gives: Area, Centroid and BoundingBox
numberObjects = Objects.NumObjects; 

%get object of interest
%get biggest object excluding the object bigger than 60k pixels    
area = 0;
for i = 1:Objects.NumObjects
    if (info(i).Area >= area && info(i).Area < 60000)
        area = info(i).Area;
        index = i;
    end
end

object_area = info(index).Area
%put pixels of selected object in white
im_object(Objects.PixelIdxList{index}) = true;

%get the pixel coordinates
x = info(index).Centroid(1);
y = info(index).Centroid(2);

%return image
im_OUT = im_object;

end

