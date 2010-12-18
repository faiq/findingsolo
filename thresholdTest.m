manT = man;
[height, width] = size(manT(:,:,1));
%desired percentage of red in pixel
threshold = .35;
%loop though image pixels
for i = 1:height
    for j = 1:width
            %calculate proportion of red in pixel
            scl = manT(i,j,1)^(3)/sum(manT(i,j,1:3));
            if(scl > threshold)     
                %remove green and blue
                manT(i,j,2:3) = 0;
            else
                %set pixel to white
                manT(i,j,1:3) = 1;
            end
    end
end
%display image
imshow(manT);