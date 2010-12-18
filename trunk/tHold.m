function [ mask maskR ] = tHold( I )

%generalizing and improving threshold function

I = im2double(I);
%bw = histeq(rgb2gray(I), 5);

%first split image into red,green,and blue layers
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);


%basic mask for red
mask = (R./(.0001+R+B+G)).^2;

[h, w] = size(mask);
blurSize = 2*floor((h+w)/400) + 3;
blur = ones(blurSize, blurSize)/(blurSize^2);
mask = conv2(mask, blur, 'same');
disc = histeq(mask, 100);
mask = (.55 < mask);

%make sure the mask fills some important constaints
low = tHoldOrig(I, .3);
high = tHoldOrig(I,.5);
mask = (mask & low) | high;

se = strel('disk', blurSize);
mask = imerode(mask,se);


%se2 = strel('disk',4);
%mask = imopen(imclose(mask,se), se2);
%level = .5 + m/2;
%level = graythresh(mask);
%this is 1 where acceptable, 0 where not accepatable for regioning

mask = ((mask | (disc == 1)));
for k = 1:10
%mask2 = mask;
for i = 2:h-1
    for j = 2:w-1
        if ((disc(i,j) >= .90) && low(i,j)) || high(i,j)%| (.7 < cont(i,j))
            disc(i,j) = max(disc(i,j), max(max(mask(i-1:i+1, j-1:j+1))));
        end
    end
end
mask = ((mask | (disc == 1))); %& low) | high;
%mask = mask | (disc == 1);
end
%mask = im2bw(mask, level);
%mask = (level < mask);

%now what we're going to do is get rid of anything in the mask that is too
%low red, and add back anything that is very red that might have been
%ignored.



%lap = [-1 -1 -1; -1 8 -1; -1 -1 -1];
%mask = conv2(mask, lap, 'same');

maskR(:,:,1) = mask(:,:).*I(:,:,1);
maskR(:,:,2) = mask(:,:).*I(:,:,2);
maskR(:,:,3) = mask(:,:).*I(:,:,3);
end
