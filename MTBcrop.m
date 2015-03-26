function [ coordinate ] = MTBcrop( imgMTB1, imgMTB_mask1, imgMTB2, imgMTB_mask2, levelNum)
coordinate_1 = [2; round(size(imgMTB1,1)/(2^(levelNum-1)))-1; 2; round(size(imgMTB1,2)/(2^(levelNum-1)))-1];
coordinate_2 = [2; round(size(imgMTB1,1)/(2^(levelNum-1)))-1; 2; round(size(imgMTB1,2)/(2^(levelNum-1)))-1];
for i=1:levelNum
% 9 directions
    coordinate_set_1 = coordinate_1;
    coordinate_set_2 = [];
    for j=1:9
        coordinate_set_2 = [coordinate_set_2 coordinate_2];
    end
    %1_1
    coordinate_set_2(:,1) = coordinate_set_2(:,1)-1;
    %1_2
    coordinate_set_2(1:2,2) = coordinate_set_2(1:2,2)-1;
    %1_3
    coordinate_set_2(1:2,3) = coordinate_set_2(1:2,3)-1;
    coordinate_set_2(3:4,3) = coordinate_set_2(3:4,3)+1;
    %2_1
    coordinate_set_2(3:4,4) = coordinate_set_2(3:4,4)-1;
    %2_2
    %2_3
    coordinate_set_2(3:4,6) = coordinate_set_2(3:4,6)+1;
    %3_1
    coordinate_set_2(1:2,7) = coordinate_set_2(1:2,7)+1;    
    coordinate_set_2(3:4,7) = coordinate_set_2(3:4,7)-1;
    %3_2
    coordinate_set_2(1:2,8) = coordinate_set_2(1:2,8)+1;
    %3_3
    coordinate_set_2(:,8) = coordinate_set_2(:,8)+1;
%downsample
    imgMTB1_d = imresize(imgMTB1,0.5^(levelNum-i),'nearest');
    imgMTB_mask1_d = imresize(imgMTB_mask1,0.5^(levelNum-i),'nearest');
    imgMTB2_d = imresize(imgMTB2,0.5^(levelNum-i),'nearest');
    imgMTB_mask2_d = imresize(imgMTB_mask2,0.5^(levelNum-i),'nearest');
%comparison
    error = ones(1,9)*100000;
    for j=1:9
        a_1 = coordinate_set_1(1,1);
        b_1 = coordinate_set_1(2,1);
        c_1 = coordinate_set_1(3,1);
        d_1 = coordinate_set_1(4,1);
        a_2 = coordinate_set_2(1,j);
        b_2 = coordinate_set_2(2,j);
        c_2 = coordinate_set_2(3,j);
        d_2 = coordinate_set_2(4,j);
        if( a_2>=1 && b_2<=(size(imgMTB2_d,1)) && c_2>=1 && d_2<=(size(imgMTB2_d,2)) )
            error(1,j) = norm((imgMTB1_d(a_1:b_1,c_1:d_1)-imgMTB2_d(a_2:b_2,c_2:d_2)).*(imgMTB_mask1_d(a_1:b_1,c_1:d_1)).*(imgMTB_mask2_d(a_2:b_2,c_2:d_2)),2);
        end
    end
    [temp,index] = min(error);
    coordinate_2 = coordinate_set_2(:,index);
    if(i~=levelNum)
        coordinate_1 = coordinate_1*2;
        coordinate_2 = coordinate_2*2;
    end        
end
coordinate = coordinate_2;

