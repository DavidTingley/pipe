function [ordered] = stackTS2ts(vid,levels)

ordered = zeros(size(vid,1),size(vid,2),size(vid,3)*size(vid,4),'uint16');


for l = 1:size(vid,4)
    ordered(:,:,(l-1)*levels+1:(l-1)*levels+levels) = vid(:,:,:,l);
end
