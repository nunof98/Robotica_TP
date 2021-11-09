function [im_OUT] = ColorSegment(im_IN, H, S, V)

%Convert to HSV image
im_HSV = rgb2hsv(im_IN);
im_H = im_HSV(:,:,1);
im_S = im_HSV(:,:,2);
im_V = im_HSV(:,:,3);

%change data scale
if (H > 1)
    H = H/360;
end  
if (S > 1)
    S = S/100;
end  
if (V > 1)
    V = V/100;
end  

%calculate limits
h_inf = H - 30/360;
h_sup = H + 30/360;
s_inf = S - 0.35;
s_sup = 1;
v_inf = V - 0.35;
v_sup = V + 0.35;

%check if h_sup is higher than 1 (only happens if it's red)
if (h_sup > 1)
    h_sup = h_sup - 1;
    
    %create two binary images of H (two scales of red)
    im_H_BIN1 = roicolor(im_H, h_inf, 1);
    im_H_BIN2 = roicolor(im_H, 0.1/360, h_sup);
    
    %combine the two binary images
    im_H_BIN = im_H_BIN1 | im_H_BIN2;
else
    im_H_BIN = roicolor(im_H, h_inf, h_sup);
end

%segment image channels by colour
im_S_BIN = roicolor(im_S, s_inf, s_sup);
im_V_BIN = roicolor(im_V, v_inf, v_sup);

%join binary images into one with logical AND
im_BIN = im_H_BIN .* im_S_BIN .* im_V_BIN;

%mask operation
im_OUT = MaskOperation(im_IN, im_BIN);

end

