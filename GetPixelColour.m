function [im_Pixel, H, S, V] = GetPixelColour(im_IN, x, y)
%GETPIXELCOLOUR Summary of this function goes here

%get pixel image
im_Pixel = im_IN(int16(y), int16(x), :);

%convert pixel to hsv
im_Pixel_HSV = rgb2hsv(im_Pixel);
%get H value
H = im_Pixel_HSV(:,:,1);
S = im_Pixel_HSV(:,:,2);
V = im_Pixel_HSV(:,:,3);

end

