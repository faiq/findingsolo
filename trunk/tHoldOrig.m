function [ mask ] = tHoldOrig( I, level)

%generalizing and improving threshold function

I = im2double(I);


%first split image into red,green,and blue layers
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);


%basic mask for red
mask = (R./(R+B+G)).^2;


mask = (level < mask);

%send to black where there wasn't enough red
    % T = thresholded image
%O = I;
%for i = 1:3
%   O(:,:,i) = min(mask(:,:), O(:,:,i));
%end

end
