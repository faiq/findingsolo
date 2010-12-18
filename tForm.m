function [ O ] = tForm( I, width, height, theta, scale, xshift, yshift, squish, squishlim)

%transforms an image I by rotating, scaling, and shifting, and squishing
%the top
%pads with black to produce a final image of size height x width

%produce homogenous transform matrix
    %note that the transform matrix will be multiplied on the right of a 
    %vector so the final row contains the shift components instead of 
    %the final column
[h,w,d] = size(I);

%first do squish of top part of image
dif = max(round(squish*squishlim), 1);
%O = vertcat( imresize(I(1:squishlim, :,:), [dif, w]), I(squishlim+1:h,:,:));
%we try to save time by keeping a single array, no vert cat
O = I;

O((squishlim-dif +1):squishlim,:,:) = imresize(I(1:squishlim, :,:), [dif, w]);

hnew = h + dif - squishlim;

mat = eye(3);
c = cos(theta);
s = sin(theta);
mat(1,1:2) = scale*[c, s];
mat(2,1:2) = scale*[-s, c];
%this is more complicated than a typical transform since we have to rotate in place
mat(3,1:2) = [xshift + (w*scale/2) - (w*scale/2)*c+ (hnew*scale/2)*s, yshift + (hnew*scale/2)-(w*scale/2)*s - (hnew*scale/2)*c];
    
%compute transformation of I
%force dimensions of transformed image to HxW
%-> imtransform will automatically pad with zero pixels
%XData = [1, width];
%YData = [1, height];
%tform = maketform('affine', mat);
O = imtransform(O((squishlim-dif+1):h,:,:), maketform('affine', mat), 'XData', [1, width], 'YData', [1, height], 'Size', [height,width]);

end