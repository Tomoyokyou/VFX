function [ HDR ] = constructHDR( Z, deltaT, W, g )
HDR = zeros(size(Z,1),1);
for i=1:size(Z,1)
    gZ = [];
    wZ = [];
    for j=1:size(Z,2)
        gZ = [gZ g(Z(i,j)+1)];
        wZ = [wZ W(Z(i,j)+1)];
    end
    HDR(i,1) = sum((gZ-deltaT(1,:)).*wZ)/sum(wZ);
end
HDR = exp(HDR);

