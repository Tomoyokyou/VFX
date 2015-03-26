function [ imgSet_aligned ] = MTBalign( imgSet, imgNum, levelNum, ignoreThreshold )
% imgSet 768x1024x3
imgY = [];
imgMTB = [];
imgMTB_mask = [];
for i=1:imgNum
    imgY = [imgY reshape(0.299*imgSet{1,i}(:,:,1)+0.587*imgSet{1,i}(:,:,2)+0.144*imgSet{1,i}(:,:,3),size(imgSet{1,i},1)*size(imgSet{1,i},2),1)];
    threshold = median(imgY(:,i));
    imgMTB = [imgMTB (imgY(:,i)-threshold)>0];
    imgMTB_mask = [imgMTB_mask ((imgY(:,i)-threshold)>ignoreThreshold)|((threshold-imgY(:,i))>ignoreThreshold)];
end
% imshow(reshape(imgY(:,1),size(imgSet{1,i},1),size(imgSet{1,i},2)));
% imshow(reshape(imgMTB(:,1),size(imgSet{1,i},1),size(imgSet{1,i},2)));
% imshow(reshape(imgMTB_mask(:,1),size(imgSet{1,i},1),size(imgSet{1,i},2)));
cropCoordinate = zeros(4,imgNum);
for i=1:imgNum
    imgY1 = reshape(imgY(:,1),size(imgSet{1,i},1),size(imgSet{1,i},2));
    imgMTB1 = reshape(imgMTB(:,1),size(imgSet{1,i},1),size(imgSet{1,i},2));
    imgMTB_mask1 = reshape(imgMTB_mask(:,1),size(imgSet{1,i},1),size(imgSet{1,i},2));
    imgY2 = reshape(imgY(:,i),size(imgSet{1,i},1),size(imgSet{1,i},2));
    imgMTB2 = reshape(imgMTB(:,i),size(imgSet{1,i},1),size(imgSet{1,i},2));
    imgMTB_mask2 = reshape(imgMTB_mask(:,i),size(imgSet{1,i},1),size(imgSet{1,i},2));
    [ coordinate ] = MTBcrop( imgMTB1, imgMTB_mask1, imgMTB2, imgMTB_mask2, levelNum);
    cropCoordinate(:,i) = coordinate;
end
imgSet_aligned = cell(1,imgNum);
for i=1:imgNum
    imgSet_aligned{1,i} = imgSet{1,i}(cropCoordinate(1,i):cropCoordinate(2,i),cropCoordinate(3,i):cropCoordinate(4,i),:);
end

