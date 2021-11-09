function [shape] = GetShape(im_IN)
%GETSHAPE Finds shape of object within picture

%convert rgb to gray
im_IN_gray = rgb2gray(im_IN);

%binarize image
im_BW = imbinarize(im_IN_gray);

% Define o kernelde pesquisa
se =  strel('disk',5); 
% Aplica uma erosão à imagem
im_BW = imerode(im_BW, se);
%subplot(2, 3, 6);imshow(im_BW); title('Eroded object');

Objects = bwconncomp(im_BW, 8);
info = regionprops(Objects, 'Circularity');

if (info(1).Circularity >= 0.9)
    shape = 'circle';
elseif (info(1).Circularity >= 0.75)
    shape = 'square';
else
    shape = 'triangle';
end

disp('Circularity: ');
disp(info(1).Circularity);
disp('Shape: ');
disp(shape);

end

