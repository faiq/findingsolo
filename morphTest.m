%define the structuring element for the morphological operations
se = strel('disk',3);
imshow(manT);
figure();

%image opening
manTO = imopen(manT, se);
imshow(manTO);
figure();

%image closing
manTC = imclose(manT, se);
imshow(manTC);
figure();

%opening of closing
se2 = strel('disk',6);
manTCO = imopen(imclose(manT,se), se2);
imshow(manTCO);

