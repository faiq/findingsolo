function [ Inew, O ] = brighteq( I, proto)

O = I(:,:,1) + I(:,:,2) + I(:,:,3);
Inew = I;
%first we use the prototype to get a brightness level we want to set to
%the prototype is a simple image with pretty much universal brightness
bright = sum(sum(sum(proto)));

%denomentator of the fraction to get average brightness
denom = sum(sum(sum(proto ~= 0)));

bright = bright/denom;

%a sub function to equalize brightness of a section of the image
function [ xb ] = eq( x )
    % we move through our image adjusting local brightness
    [h,w] = size(x);
    brightx = sum(sum(x))/(h*w);
    xb = bright/brightx;
end

%now we apply this function on blocks of the image
[ih, iw] = size(O);
bh = round(ih/20);
bw = round(iw/20);

O = nlfilter(O, [bh bw], @eq); %this holds the actualy brightness fraction at each point

%now actually adjuct image brightness:
Inew(:,:,1) = Inew(:,:,1) .* O;
Inew(:,:,2) = Inew(:,:,2) .* O;
Inew(:,:,3) = Inew(:,:,3) .* O;



end
%{
r = dark(:,:,1);
g = dark(:,:,2);
b = dark(:,:,3);

r= histeq(r, 10);
g= histeq(g, 10);
b= histeq(b, 10);

darkeq(:,:,1) = r;
darkeq(:,:,2) = g;
darkeq(:,:,3) = b;


[X,map] = rgb2ind(dark,256);
map = histeq(X,map);
darkeq = im2double(ind2rgb(X,map));
%}


