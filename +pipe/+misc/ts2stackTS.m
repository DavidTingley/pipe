function [ordered] = ts2stackTS(vid,levels)

ordered = zeros(size(vid,1),size(vid,2),levels,floor(size(vid,3)/levels),'uint16');
limit = floor(size(vid,3)/levels)*levels;
for l = 1:levels
    vec = [1:levels:limit-l+1] + l-1;   
    
    ordered(:,:,l,:) = vid(:,:,vec);
end
if floor(size(vid,3)/levels) ~= ceil(size(vid,3)/levels)
   warning('dropping frames...') 
end