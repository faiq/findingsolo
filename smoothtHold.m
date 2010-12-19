function [ O mask ] = smoothtHold( I )
%this function takes mask and smooths it
%this is important for reducing noise as well as making regions easier to
%identify
%first just compute the raw threshold
[h,w,~] = size(I);
%mask = tHoldOrig(I, .435);
%  mask = tHoldOrig(I, .4);
%end

mask = tHold(I);

%first just do basic opening and closing of noise
%small enough disk works for general image - don't base on image or region
%size
se = strel('disk',2);
se2 = strel('disk',4);
mask = imopen(imclose(mask,se), se2);

%now we split up into regions
[regions, numRegions] = bwlabel(mask);

%now we cut out weird shaped images and images with lines through them
for(i = 1:numRegions)
    %black mask with region i in white
    regioni = (regions == i);
    stats = regionprops(regioni, 'Perimeter', 'Area', 'Eccentricity');%, 'ConvexImage', 'BoundingBox');

    roundness = 4*pi*stats.Area/stats.Perimeter^2;
    stats.Eccentricity
    
    if(stats.Eccentricity > .85)
        regions = (regions~=i).*regions;
    end
    if(roundness < .4)
        regions = (regions~=i) .*regions;
    end
    %now fill in any holes
   % leftshift = stats.BoundingBox(1);
   % downshift = stats.BoundingBox(2);
   % width = stats.BoundingBox(3);
   % height = stats.BoundingBox(4);
   % regions((downshift+.5):(downshift+height-.5), (leftshift+.5):(leftshift+width-.5)) = stats.FilledImage.*i; 
end

%now limit the number of regions
if(numRegions > 5)
    scores = [1:numRegions];
    for i = 1:numRegions
        scores(i) = sum(sum(regions==i));
    end
    scoresSort = sort(scores);
    cutoff = scoresSort(numRegions-4);
    %now actually cut off values that are too low
    
    for i = 1:numRegions
        if(scores(i) < cutoff)
            %this operatino wipes out the ith region
            regions = (regions~=i).*regions;
        end
    end
end

%relable 5 largest regions
[regions, numRegions] = bwlabel(regions>0);

%the mask image we'll work with
%regionsBW = regions > 0;

   %{
    leftshift = stats.BoundingBox(1);
    downshift = stats.BoundingBox(2);
    width = stats.BoundingBox(3);
    height = stats.BoundingBox(4);
    
    if(sum(sum(regioni)) < h*w/1000)
        regionsBW((downshift+.5):(downshift+height-.5), (leftshift+.5):(leftshift+width-.5)) = stats.ConvexImage*0;
    else
    
    %modifiy regionsBW to have the convex hulls
    %size(regionsBW((downshift+.5):(downshift+height-.5), (leftshift+.5):(leftshift+width-.5)));
    regionsBW((downshift+.5):(downshift+height-.5), (leftshift+.5):(leftshift+width-.5)) = stats.ConvexImage;
    end

end

    mask=regionsBW;

    %}
    
mask = regions > 0;

O = im2double(I);
for i = 1:3
   O(:,:,i) = min(mask(:,:), O(:,:,i));
end

end

