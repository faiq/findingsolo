function [ O ] = regFind( I, option, sensitivity )

%perform color equalization
%[X,map] = rgb2ind(I,256);
%map = histeq(X,map);
%I = im2double(ind2rgb(X,map));

%first shrink down the image to a reasonable size:
%{
while(sum(size(I)) > 1000)
        I = imresize(I, .75);
end
%}

%threshold image to find potential search areas
%[mask, T] = tHold(I);
[T, mask] = smoothtHold(I);

%determine candidate search areas
[regions, numRegions] = bwlabel(mask);
%if(numRegions > 5)
%    scores = [1:numRegions];
%    for i = 1:numRegions
    %    scores(i) = sum(sum(regions==i));
    %end
%    scoresAs = sort(scores);
  %  cutoff = scoresAs(numRegions-4);
    %now actuall cut off values that are too low
 %   scores = (scores >= cutoff);
%else
    scores = ones(1,numRegions);
%end

%first calculate width and height of entire image
[h, w] = size(mask);

%illustrated record of process
ill = mask;
final = I;

%prototype solocups
load('solo.mat');  %im2double(imread('solo.jpg'));
proto = solo;
squishlim = 37; %hard coded for the prototype image

%create array of prototypes: 
%load('solomask.mat');
%protomaskW = imopen( (rgb2gray(proto) > .65), strel('disk',3));
%protomaskR = imopen( ((rgb2gray(proto) > .2)-protomaskW), strel('disk',3));

[ph, pw, pd] = size(proto);
[ih, iw, id] = size(I);

%for each region we identify a border, then search for our cup
for i = 1:numRegions
    if(scores(i) == 0) 
        continue;
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    %IDENITFY SEARCH AREAS%
    %%%%%%%%%%%%%%%%%%%%%%%
    
    %black mask with region i in white
    regioni = (regions == i);
    
    %move left boundary to leftmost part of region
    left = 1;
    while(sum(regioni(:,left)) == 0)
        left = left + 1;
    end
    %move right boundary to rightmost part of region
    right = w;
    while(sum(regioni(:,right)) == 0)
        right = right - 1;
    end
    %move bottom boundary to bottommost part of region
    bot = h;
    while(sum(regioni(bot,:)) == 0)
        bot = bot - 1;
    end
    %move top boundary to topmmost part of region
    top = 1;
    while(sum(regioni(top,:)) == 0)
        top = top + 1;
    end
    
    %expand search regions by a certain amount
    b = 2;
    borderW = round((right-left)/b);
    
    %now find edges of search reginos
    leftOrig = left-borderW;
    left = max(leftOrig, 1);
    rightOrig = right+borderW;
    right = min(rightOrig, w);
    
    borderH = round((bot-top)/b);
    
    topOrig = top-borderH;
    top = max(topOrig, 1);
    botOrig = bot + borderH;
    bot = min(botOrig, h);
 
    %{
    %draw boundary rectangle (for illustrations)
    ill(top,left:right,:) = 1;
    ill(bot,left:right,:) = 1;
    ill(top:bot,left,:) = 1;
    ill(top:bot, right,:) = 1;
    %}
    

    %now do actual search:
    scale = min(((botOrig-topOrig)/ph), ((rightOrig-leftOrig)/pw))/2;
    %xshift = leftOrig + round((rightOrig-leftOrig)/2) - pw*scale/2;
    %yshift = topOrig + round((botOrig-topOrig)/2) - ph*scale/2;
    xshift = (leftOrig - left) + round((rightOrig-leftOrig)/2) - pw*scale/2;
    yshift = (topOrig - top) + round((botOrig-topOrig)/2) - ph*scale/2;
    
    %stats = regionprops(regioni, 'Orientation');
    %theta = stats.Orientation * 2*pi/180+2*pi;
 
    %old code for matching to small section of image
    [O, xf, v] = register(I(top:bot,left:right,:), proto, regioni(top:bot, left:right), 2*pi, scale, xshift, yshift, .5, squishlim);
    %code for full image match
    %[O, xf,  v ] = register(I, proto, protomaskW, protomaskR, regioni, 2*pi, scale, xshift, yshift);
    %O = tForm(proto, right+1-left, bot+1-top, theta, scale, xshift, yshift, .7, squishlim);
    %P = tForm(proto, right+1-left, bot+1-top, 2*pi, scale, xshift, yshift, .7, squishlim);
    %Q = tForm(proto, right+1-left, bot+1-top, 2*pi, scale, 0, 0, .7, squishlim);
    %R = tForm(proto, right+1-left, bot+1-top, pi, scale, 0, 0, .7, squishlim);
    %imshow(O+P+Q+R);
    %v = .05;
    %visualize by putting blue match on top of image
    
    overlay = final(top:bot, left:right, :);
    load 'moet.mat';
    load 'juice.mat';
    load 'grenade.mat';
    
    O1 = rgb2gray(O);
    if(option == 1)  %hightlight cups
        if(v < -2.6)
            overlay(:,:,3) = (O1~=0).*.5 + overlay(:,:,3);
        elseif (v < -2.3)
            overlay(:,:,2) = (O1~=0).*.5 + overlay(:,:,2);
        else
            overlay(:,:,2) = (O1~=0).*.25 + overlay(:,:,2); 
            overlay(:,:,3) = (O1~=0).*.25 + overlay(:,:,3); 
        end
        final(top:bot, left:right, :) = overlay;
    end
  
    %{
    if(option == 3 && v < sensitivity) % classy
       top = min(0, top - 100*xf(2));
       overlay = tForm(moet, iw, ih, xf(1), 1.9*xf(2), xf(3)+leftOrig-.3*xf(2)*pw, xf(4)+topOrig-1*xf(2)*ph, xf(5), 1);
       O2 = rgb2gray(overlay);
       final(:,:,1) = (O2~=0) .* overlay(:,:,1) + (O2==0) .* final(:,:,1);
       final(:,:,2) = (O2~=0) .* overlay(:,:,2) + (O2==0) .* final(:,:,2);
       final(:,:,3) = (O2~=0) .* overlay(:,:,3) + (O2==0) .* final(:,:,3);
    end
%}
    if(option == 3 && v < sensitivity) % defame
       top = min(0, top - 100*xf(2));
       overlay = tForm(grenade, iw, ih, xf(1), 1.4*xf(2), xf(3)+leftOrig-.3*xf(2)*pw, xf(4)+topOrig-.5*xf(2)*ph, xf(5), 1);
       O2 = rgb2gray(overlay);
       final(:,:,1) = (O2~=0) .* overlay(:,:,1) + (O2==0) .* final(:,:,1);
       final(:,:,2) = (O2~=0) .* overlay(:,:,2) + (O2==0) .* final(:,:,2);
       final(:,:,3) = (O2~=0) .* overlay(:,:,3) + (O2==0) .* final(:,:,3);
    end
    
    if(option == 2 && v < sensitivity) % mom proof
       overlay = tForm(juice, iw, ih, xf(1), 1.4*xf(2), xf(3)+leftOrig+xf(2)*.1, xf(4)+topOrig-.5*xf(2)*ph, xf(5), 1);
       O2 = rgb2gray(overlay);
       final(:,:,1) = (O2~=0) .* overlay(:,:,1) + (O2==0) .* final(:,:,1);
       final(:,:,2) = (O2~=0) .* overlay(:,:,2) + (O2==0) .* final(:,:,2);
       final(:,:,3) = (O2~=0) .* overlay(:,:,3) + (O2==0) .* final(:,:,3);
    end
    
%check out if it worked
%imshow(ill);
O = final;
end

O = final;
end
