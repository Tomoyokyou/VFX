function Lbar= logaverage(L, delta)

[x y] = size(L);
N = x*y;
total = log(L+delta);
Lbar = exp(nansum(total(:))/N);