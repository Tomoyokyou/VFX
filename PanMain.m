clear all;
%% parameter

% alignment
levelNum = 2;
ignoreThreshold = 5;
% HDR
sampleNum = 100;

shutterTime = [1/3200 1/1600 1/800 1/320 1/400 1/200 1/100 1/50 1/25 1/13 1/6 1/3 1/2 1];
lambda = 200;

path = 'C:\Users\Lifeislikeamelody\Pictures\Dahu\data_set_1';
list = dir([path '\*.JPG']);
imgNum = size(list,1);
imgSet = cell(1,imgNum);


for i=1:imgNum

        imgSet{1,i} = imread([path '\' list(i).name]);
        imgSet{1,i} = imresize(imgSet{1,i},0.2);

end
%% alignment

<<<<<<< HEAD

=======
>>>>>>> 872635aed890fefe94b6a5a16de22eee2f2597ea
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
%[ imgSet_aligned ] = MTBalign( imgSet, imgNum, levelNum, ignoreThreshold );
%imgSet = imgSet_aligned;
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

%Tone Mapping

%%Parameter Setting
a = 0.72;
%s = 8;
phi = 20;
episilon = 1;

for i = 1:size(HDR,1)
	for j = 1:size(HDR,2)
		if isnan(HDR(i,j,1))
			HDR(i,j,1)=0;
		end
		if isnan(HDR(i,j,2))
			HDR(i,j,2)=0;
		end
		if isnan(HDR(i,j,3))
			HDR(i,j,3)=0;
		end
	end
end
	
Lw = 0.2126.*HDR(:,:,1)+0.7152.*HDR(:,:,2)+0.0722.*HDR(:,:,3);
	%Log-average luminance
delta = 0.01;
LwBar = logaverage(Lw, delta);
	%Scaled Luminance
L = Lw*a./LwBar;

	%Automatic dodging-and-burning
	
	
	% 1 1.6 2.56 4.096 6.5536 10.485760 16.777216 26.843546  43

%standard = [ 15.9024 9.9395241,5.872026,3.670016,2.29376,1.4336,0.896,0.56,0.35];
%scale = [43, 27, 17, 10, 7, 4, 3, 2, 1];	
	%standard =[0.35, 0.56, 0.896, 1.4336, 2.29376, 3.670016, 5.872026, 9.9395241, 15.9024];
	standard = [];
	init = 1;
	for i = 1:30
		init= init*1.2;
		standard =[standard, init];
	end
	
	%scale = [1, 2, 3,4 ,7, 10, 17,27,43];
level = size(standard,2);	
V = {};
for s=1:level
    %H = fspecial('gaussian',31,s-1+eps);
	H = fspecial('gaussian',500,standard(s));
%	H = fspecial('gaussian',max(size(L,1), size(L,2)),standard(s));
    V{s}= imfilter(L,H,'symmetric');
end

scaleMat=zeros(size(L,1), size(L,2));
for i=1:size(L,1)
    for j=1: size(L,2)
        dis=1;
        for s=1:level-1
			%Center-surround function
            dis=(V{s}(i,j)-V{s+1}(i,j))/((2^phi)*a/s^2+V{s}(i,j));
            if abs(dis)>episilon
                scaleMat(i,j)=s;
                break;
            end
        end
        if scaleMat(i,j)==0
            scaleMat(i,j)=level;
        end
    end
end

%Local Operator
Ld=[];
for i=1:size(L,1)
    for j=1:size(L,2)
        Ld(i,j)=L(i,j)/(1+V{scaleMat(i,j)}(i,j));
    end
end
r=1;
HDR_tonemapping = zeros(size(L,1),size(L,2),3);
max1 = max(max(HDR(:,:,1))); max2 = max(max(HDR(:,:,2))); max3 = max(max(HDR(:,:,3)));
min1 = min(min(HDR(:,:,1))); min2 = min(min(HDR(:,:,2))); min3 = min(min(HDR(:,:,3)));

HDR_tonemapping(:,:,1)=HDR(:,:,1)./Lw.*Ld;
HDR_tonemapping(:,:,2)=HDR(:,:,2)./Lw.*Ld;
HDR_tonemapping(:,:,3)=HDR(:,:,3)./Lw.*Ld;


%HDR_tonemapping(:,:,1)=round((((HDR(:,:,1)-min1)./(max1-min1)./Lw).*Ld.*max1*255).^r);
%HDR_tonemapping(:,:,2)=round((((HDR(:,:,2)-min2)./(max2-min2)./Lw).*Ld.*max2*255).^r);
%HDR_tonemapping(:,:,3)=round((((HDR(:,:,3)-min3)./(max3-min3)./Lw).*Ld.*max3*255).^r);


imwrite(HDR_tonemapping,'HDR_tonemapping.jpg');
figure, %imshow(uint8(HDR_tonemapping));
imshow(HDR_tonemapping);