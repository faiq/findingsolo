function [ match ] = match( I, proto, mask, calcmat)
%match returns the match metric between image I and the object seeking 
    %prototype image, proto
    %I, proto, and mask must be of the same size
%0 values in proto will no be factored into the metric unless they 
    %correspond to non-zero pixels in mask

[height, width, d] = size(I);
%compute match metric using mean squared difference method
%metric = 0;
%n = 0; %number of pixels factored into metric
maskweight = 1; %weight for non-zero pixels mask
redweight = 5;

%{
for x=1:width 
for y=1:height
    metric = metric + protomaskW(y,x) *sum((I(y,x,1:3) - proto(y,x,1:3)))^2;
    metric = metric + redweight*(mask(y,x) + protomaskR(y,x)) * (I(y,x,1)/(.0001+sum(I(y,x,1:3))) - proto(y,x,1)/(.0001+sum(proto(y,x,1:3))) )^2;
    n = n + protomaskW(y,x) + mask(y,x) + protomaskR(y,x);
end
end
%}
protogray = rgb2gray(proto);
protoR = ((protogray < .65) & (protogray > .20));
protoW = (protogray > .70);

%border = imdilate(protoR, strel('disk',10))-imdilate(protoR, strel('disk',2));

%calcmat = (3*protoW+protoR) .* (1- 1./(1+((I(:,:,1)-proto(:,:,1)).^2 + (I(:,:,2)-proto(:,:,2)).^2 + (I(:,:,3)-proto(:,:,3)).^2)));
%want as white as possible
calcmat = (protoW) .* (-(I(:,:,1)-proto(:,:,1)) - (I(:,:,2)-proto(:,:,2)) - (I(:,:,3)-proto(:,:,3))).^3;

%want to compare squared difference
%calcmat = calcmat + (protoR) .* ((I(:,:,1)-proto(:,:,1)).^2 + abs(I(:,:,2)-proto(:,:,2)).^2 + abs(I(:,:,3)-proto(:,:,3)).^2);
%here we compare red hues
%calcmat = calcmat + redweight*(mask + protoR) .* (1-1 ./(1+((I(:,:,1) ./ ( .001 + I(:,:,1) + I(:,:,2) + I(:,:,3) ) - proto(:,:,1) ./ ( .00001 + proto(:,:,1) + proto(:,:,2) + proto(:,:,3) ) )).^2));
%calcmat = calcmat + redweight*(mask + protoR) .* abs((I(:,:,1) ./ ( .001 + I(:,:,1) + I(:,:,2) + I(:,:,3) ) - proto(:,:,1) ./ ( .00001 + proto(:,:,1) + proto(:,:,2) + proto(:,:,3) ) ));

%want as red as possible
calcmat = calcmat + redweight*(mask + protoR) .* (-(I(:,:,1) ./ ( .001 + I(:,:,1) + I(:,:,2) + I(:,:,3) ) + proto(:,:,1) ./ ( .00001 + proto(:,:,1) + proto(:,:,2) + proto(:,:,3) ) )).^3;

%now we want to punish red just outside the image
%calcmat = calcmat + 5*border .* ((I(:,:,1) ./ ( .001 + I(:,:,1) + I(:,:,2) + I(:,:,3) ) - proto(:,:,1) ./ ( .00001 + proto(:,:,1) + proto(:,:,2) + proto(:,:,3) ) )).^3;


n = (redweight*maskweight)* sum(sum(mask))+3*sum(sum(protoW)) + (1+redweight)*sum(sum(protoR));% + 5*sum(sum(border));

            
match = ( sum(sum(calcmat)) ) / n;


end

