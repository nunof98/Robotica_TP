function [im_RGB_mask] = MaskOperation(im_RGB, im_segmented)
%MASKOPERATION creates a mask of the original image on top of the
%segmented image

%split RGB channels
im_R = im_RGB(:,:,1);
im_G = im_RGB(:,:,2);
im_B = im_RGB(:,:,3);

%multiply every channel with the segmented image
im_R_mask = im_R .* uint8(im_segmented);  
im_G_mask = im_G .* uint8(im_segmented);
im_B_mask = im_B .* uint8(im_segmented);

%join channels
im_RGB_mask = cat(3 , im_R_mask, im_G_mask, im_B_mask);

end

