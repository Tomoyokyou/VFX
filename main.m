clear all;
%% parameter
imgNum = 9;
% alignment
levelNum = 5;
ignoreThreshold = 5;
% HDR
sampleNum = 60;
longestShutter = 1;
lambda = 10;

%% alignment
imgSet = cell(1,imgNum);
for i=1:imgNum
    imgSet{1,i} = imread(['C:\Users\acer\Documents\NTUEE\¤j¥|¤U\DVE\hw1\testimages\exposures\img0' num2str(i) '.jpg']);
end
% imgSet 768x1024x3
% misalign
    shift = 7;
    misalignImg = zeros(768,1024,3);
    misalignImg(1+shift:768,1+shift:1024,:) = imgSet{1,2}(1:768-shift,1:1024-shift,:);
    imgSet{1,2} = misalignImg;
%test no align
imgY = [];
imgU = [];
imgV = [];
for i=1:imgNum
    imgY = [imgY reshape(0.299*imgSet{1,i}(:,:,1)+0.587*imgSet{1,i}(:,:,2)+0.144*imgSet{1,i}(:,:,3), size(imgSet{1,i}(:,:,1),1)*size(imgSet{1,i}(:,:,1),2), 1)];
    imgU = [imgU reshape(-0.169*imgSet{1,i}(:,:,1)-0.331*imgSet{1,i}(:,:,2)+0.5*imgSet{1,i}(:,:,3)+128, size(imgSet{1,i}(:,:,1),1)*size(imgSet{1,i}(:,:,1),2), 1)];
    imgV = [imgV reshape(0.5*imgSet{1,i}(:,:,1)-0.419*imgSet{1,i}(:,:,2)-0.081*imgSet{1,i}(:,:,3)+128, size(imgSet{1,i}(:,:,1),1)*size(imgSet{1,i}(:,:,1),2), 1)];
end
for i=1:9
    figure(i);
    imshow(reshape(imgY(:,i),size(imgSet{1,i},1),size(imgSet{1,i},2)));
end
%align
[ imgSet_aligned ] = MTBalign( imgSet, imgNum, levelNum, ignoreThreshold );
% test yes align
imgSet = imgSet_aligned;
imgY = [];
imgU = [];
imgV = [];
for i=1:imgNum
    imgY = [imgY reshape(0.299*imgSet{1,i}(:,:,1)+0.587*imgSet{1,i}(:,:,2)+0.144*imgSet{1,i}(:,:,3), size(imgSet{1,i}(:,:,1),1)*size(imgSet{1,i}(:,:,1),2), 1)];
    imgU = [imgU reshape(-0.169*imgSet{1,i}(:,:,1)-0.331*imgSet{1,i}(:,:,2)+0.5*imgSet{1,i}(:,:,3)+128, size(imgSet{1,i}(:,:,1),1)*size(imgSet{1,i}(:,:,1),2), 1)];
    imgV = [imgV reshape(0.5*imgSet{1,i}(:,:,1)-0.419*imgSet{1,i}(:,:,2)-0.081*imgSet{1,i}(:,:,3)+128, size(imgSet{1,i}(:,:,1),1)*size(imgSet{1,i}(:,:,1),2), 1)];
end
for i=1:9
    figure(i);
    imshow(reshape(imgY(:,i),size(imgSet{1,i},1),size(imgSet{1,i},2)));
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
shutterSet = [];
shutter = longestShutter*ones(size(imgR,1),1);
for i=1:imgNum
    shutterSet = [shutterSet log10(shutter)];
    shutter = shutter/2;
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
[gR,lE_R]=gsolve(ZR,shutterSet,lambda,W);
[gG,lE_G]=gsolve(ZG,shutterSet,lambda,W);
[gB,lE_B]=gsolve(ZB,shutterSet,lambda,W);
plot(1:256,gR);