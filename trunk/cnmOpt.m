%an optimization function specificall designed to optimize the affine
%transform. Takes initial values and lower and upper bounds
function [theta, scale, xshift,yshift] = cnmOpt(fun, xL, xU)
    gran = 10
    %we try out theta values. If a 360 degree range is given, we divide
    %into 6 degree steps
    thetas = [1:gran] * (xU(1) - xL(1))/gran;
    
    %we also have a set of scales we want to try:
    scales = [1:gran] * (xU(2) - xL(2))/gran;
    
    %shifts
    xshifts = [1:gran] * (xU(3) - xL(3))/gran;
    yshifts = [1:gran] * (xU(4) - xL(4))/gran;
    
    g = [1:gran];