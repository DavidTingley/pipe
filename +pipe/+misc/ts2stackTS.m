function [ordered] = ts2stackTS(vid,levels)

ordered = zeros(size(vid,1),size(vid,2),levels,size(vid,3)/levels,'uint16');
for l = 1:levels
    vec = [1:levels:length(vid)-l+1] + l-1;    
    ordered(:,:,l,:) = vid(:,:,vec);
end
