
%% Adquire image
close all;
cam = ipcam('http://192.168.137.176:8080/video','mia3', '1234');
im_RGB = snapshot(cam);
%%
%convert image to gray (single chanel)
im_RGB_gray = rgb2gray(im_RGB);

%calculate threshold value, via Otsu method
thresh_value = 120/255; %graythresh(im_RGB_gray);

%aply threshold segmentation 
im_BW = imbinarize(im_RGB_gray, thresh_value); %imbinarize = im2bw

%determine all objects present in image
Objects = bwconncomp(im_BW, 8)
%create a black image with the same size as im_BW
im_object = false(size(im_BW));

%get object properties
%‘basic’ some object properties
%‘all’ all object properties
info = regionprops(Objects, 'basic'); %basic gives: Area, Centroid and BoundingBox
numberObjects = Objects.NumObjects; 

figure, imshow(im_RGB);%desenha a imagem
hold on

for i = 1:Objects.NumObjects
    contorno = bwboundaries(im_BW);
    b = contorno{i};            
    plot(b(:,2),b(:,1),'g','LineWidth',2); %desenha contorno
    %text('position',int32([info(i).Centroid(1) info(i).Centroid(2)]),'fontsize',10,'string',info(i).Area,'color', 'black');
    text('position',int32([info(i).Centroid(1)-10 info(i).Centroid(2)]),'fontsize',10,'string',i,'color', 'r');
    %plot(info(i).Centroid(1), info(i).Centroid(2), 'g*', 'MarkerSize', 5, 'LineWidth', 2);
end
hold off;
