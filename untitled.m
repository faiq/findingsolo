  %now convert to red hue masks
    
    proto = (solo(:,:,1)/(.01+solo(:,:,1)+solo(:,:,2)+solo(:,:,3)))^2;
    Im = (couple(:,:,1)./(.01+couple(:,:,1)+couple(:,:,2)+couple(:,:,3))).^2;
    
    
    c = normxcorr2(proto,couple);
`figure, surf(c), shading fl