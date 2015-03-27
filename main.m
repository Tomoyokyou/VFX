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

%align
[ imgSet_aligned ] = MTBalign( imgSet, imgNum, levelNum, ignoreThreshold );
% test yes align
imgSet = imgSet_aligned;
for i=1:9
    figure(i);
    imshow(imgSet{1,i});
end
%% HDR
imgR = [];
imgG = [];
imgB = [];
for i=1:imgNum
    imgR = [imgR reshape(imgSet{1,i}(:,:,1), size(imgSet{1,i}(:,:,1),1)*size(imgSet{1,i}(:,:,1),2), 1)];
    imgG = [imgG reshape(imgSet{1,i}(:,:,2), size(imgSet{1,i}(:,:,2),1)*size(imgSet{1,i}(:,:,2),2), 1)];
    imgB = [imgB reshape(imgSet{1,i}(:,:,3), size(imgSet{1,i}(:,:,3),1)*size(imgSet{1,i}(:,:,3),2), 1)];
end
sampleIndex = randomchoose(1:size(imgR,1),sampleNum);
ZR = imgR(sampleIndex,:);
ZG = imgG(sampleIndex,:);
ZB = imgB(sampleIndex,:);
deltaT = ones(sampleNum,imgNum);
for i=1:imgNum
    deltaT(:,i) = deltaT(:,i)*log10(shutterTime(1,i));
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
[gR,lE_R]=gsolve(ZR,deltaT,lambda,W);
[gG,lE_G]=gsolve(ZG,deltaT,lambda,W);
[gB,lE_B]=gsolve(ZB,deltaT,lambda,W);
plot(gR,1:256);