function v=randchoose(N,m)
% randomly choose m numbers N 
    if length(m) >1 
        error('m should be a number not a vector or matrix');
    end
    [row col]= size(N);
    len = row * col;
    if m > len
        m = len;
    end
    a = rand(1,len);
    [b c]=sort(a);
    d = c(1:m);
    v = N(d);
    
end

