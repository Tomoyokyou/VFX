clear all;
%% parameter
imgNum = 9;
% alignment
levelNum = 5;
ignoreThreshold = 5;
% HDR
sampleNum = 100;
shutterTime = [13 10 7 3.2 1 0.8 1/3 1/4 1/60];
lambda = 20;

%% alignment
imgSet = cell(1,imgNum);
for i=1:imgNum
    imgSet{1,i} = imread(['C:\Users\acer\Documents\NTUEE\¤j¥|¤U\DVE\hw1\testimages\exposures\img0' num2str(i) '.jpg']);
end
% imgSet 768x1024x3

% % misalign
%     shift = 7;
%     misalignImg = zeros(768,1024,3);
%     misalignImg(1+shift:768,1+shift:1024,:) = imgSet{1,2}(1:768-shift,1:1024-shift,:);
%     imgSet{1,2} = misalignImg;
% %test no align
% for i=1:9
%     figure(i);
%     imshow(imgSet{1,i});
% end

% align
[ imgSet_aligned ] = MTBalign( imgSet, imgNum, levelNum, ignoreThreshold );
imgSet = imgSet_aligned;
imgHeight = size(imgSet{1,1},1);
imgWidth = size(imgSet{1,1},2);
% %test yes align
% for i=1:9
%     figure(i);
%     imshow(imgSet{1,i});
% end
%% HDR
imgR = [];
imgG = [];
imgB = [];
for i=1:imgNum
    imgR = [imgR reshape(imgSet{1,i}(:,:,1), imgHeight*imgWidth, 1)];
    imgG = [imgG reshape(imgSet{1,i}(:,:,2), imgHeight*imgWidth, 1)];
    imgB = [imgB reshape(imgSet{1,i}(:,:,3), imgHeight*imgWidth, 1)];
end
sampleIndex = randomchoose(1:size(imgR,1),sampleNum);
Z_R = imgR(sampleIndex,:);
Z_G = imgG(sampleIndex,:);
Z_B = imgB(sampleIndex,:);
deltaT = ones(sampleNum,imgNum);
for i=1:imgNum
    deltaT(:,i) = deltaT(:,i)*log(shutterTime(1,i));
end
W = zeros(1,256);
for i=2:256
    if i<=128
        W(1,i) = W(1,i-1)+1;
    elseif i==129
        W(1,i) = W(1,i-1);
    else
        W(1,i) = W(1,i-1)-1;
    end
end
[g_R,lE_R]=gsolve(Z_R,deltaT,lambda,W);
[g_G,lE_G]=gsolve(Z_G,deltaT,lambda,W);
[g_B,lE_B]=gsolve(Z_B,deltaT,lambda,W);
% plot(g_R,1:256);
% plot(g_G,1:256);
% plot(g_B,1:256);
[ HDR_R ] = constructHDR( imgR, deltaT, W, g_R );
[ HDR_G ] = constructHDR( imgG, deltaT, W, g_G );
[ HDR_B ] = constructHDR( imgB, deltaT, W, g_B );
HDR = zeros(imgHeight,imgWidth,3);
HDR(:,:,1) = reshape(HDR_R,imgHeight,imgWidth);
HDR(:,:,2) = reshape(HDR_G,imgHeight,imgWidth);
HDR(:,:,3) = reshape(HDR_B,imgHeight,imgWidth);
RGB = tonemap(HDR);
imshow(RGB);