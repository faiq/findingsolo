function [ O xf v ] = register( I, proto, mask, theta, scale, xshift, yshift, squish, squishlim) 
%registers prototype object finding image to image I by optimizing 
    % scaling/rotating tranformation matrix
    %I and mask must be of the same size

    [height, width, d] = size(I);
    
    %first blur image
    blurSize = 2*floor((height+width)/400) + 3;
    blur = ones(blurSize, blurSize)/(blurSize^2);
    Im(:,:,1) = conv2(I(:,:,1), blur, 'same');
    Im(:,:,2) = conv2(I(:,:,2), blur, 'same');
    Im(:,:,3) = conv2(I(:,:,3), blur, 'same');
    
    %wrap match funtion to facilitate easier optimization
    %init = [theta, scale, xshift, yshift, squish]
    
    calcmat = ones(height, width); %used to calculate out in match function - we prealloc memory here
    
    %calucate the brightness offset for our region and adjust the protoype
    %accordingly
    %the prototype is a simple image with pretty much universal brightness
    mask3(:,:,1) = mask;
    mask3(:,:,2) = mask;
    mask3(:,:,3) = mask;
    protogray = rgb2gray(proto);
    protoR(:,:,1) = ((protogray < .60) & (protogray > .20));
    protoR(:,:,2) = protoR(:,:,1);
    protoR(:,:,3) = protoR(:,:,1);
    protobrightness = sum(sum(sum(proto.*protoR))) / sum(sum(sum(protoR ~= 0)));
    regionbrightness = sum(sum(sum(Im.*mask3))) / sum(sum(sum(mask3 ~= 0)));
    offset = regionbrightness/protobrightness;
    
    %now we adjust the brightness of the prototype and proceed:
    protonew = proto.* (1+offset)/2;
    
        %now blur proto type same amount
    protonewb(:,:,1) = conv2(protonew(:,:,1), blur, 'same');
    protonewb(:,:,2) = conv2(protonew(:,:,2), blur, 'same');
    protonewb(:,:,3) = conv2(protonew(:,:,3), blur, 'same');

   
    function [ opt ] = matchOpt( x )
        protoT = tForm( protonewb, width, height, x(1), x(2), x(3), x(4), x(5), squishlim);

        %value to be optimized
        opt = match( Im, protoT, mask, calcmat) + 0*.04  + 0*.03/x(5) + x(2)*.03;
    end
    
    %perform optimization
    %run 4 seperate interations of fminunc to prevent termination at a
    %local minumum
    [ph, pw, pd] = size(protonew);
    x0 = [theta,scale,xshift,yshift, squish];
    LB = [pi, 0.1*scale, xshift-.25*pw*scale, yshift-.25*ph*scale, .2];
    UB = [3*pi, 1.6*scale, xshift+.25*pw*scale, yshift+.25*ph*scale, 1];
    options = optimset('Display','off');%, 'MaxIter',100);

    xf = fminsearchbnd3(@matchOpt,x0,LB,UB,options)
    %xf = fminsearchbnd3(@matchOpt,xf,LB,UB,options)
    %xf = fminsearchbnd3(@matchOpt,x0,LB,UB,options);
    Im = I;
    protonewb = protonew;
    v = matchOpt(xf);

   %return the actual transformed prototype
   O = tForm(proto, width, height, xf(1), xf(2), xf(3), xf(4), xf(5), squishlim );
   
   
    %we add punishment for surrounding red, which we didn't want to inlcude
    %in the optimization
    Ogray = rgb2gray(O);
    protoR = ((Ogray < .65) & (Ogray > .20));
    border = imdilate(protoR, strel('disk',10))-imdilate(protoR, strel('disk',2));

    calcmat = border.*3 .* ((Im(:,:,1) ./ ( .001 + Im(:,:,1) + Im(:,:,2) + Im(:,:,3) ) - O(:,:,1) ./ ( .001 + O(:,:,1) + O(:,:,2) + O(:,:,3) ) )).^3;
    calcmat = calcmat + (protoR) .* ((Im(:,:,1)-O(:,:,1)).^2 + abs(Im(:,:,2)-O(:,:,2)).^2 + abs(Im(:,:,3)-O(:,:,3)).^2);
   
    v = v + sum(sum(calcmat))/(sum(sum(border)) + sum(sum(protoR)))
    
end



