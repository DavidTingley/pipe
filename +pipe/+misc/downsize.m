function [out] = downsize(vid_fname,otlevels,window,newSize)

chunkSize = 10 * otlevels * window;
% newSize = 1/4;

parfor i=1:100
    try
        temp = pipe.io.read_sbx(vid_fname,1 + (i-1)*chunkSize,chunkSize,1,[]);
        temp = pipe.misc.ts2stackTS(temp,otlevels);
        temp2 = zeros(ceil(size(temp,1)*newSize),ceil(size(temp,2)*newSize),otlevels,floor((size(temp,4))/window),'single');

        for ts = 1:floor(size(temp,4)/window)
            idx = ts*window:ts*window+window;
            idx(idx>size(temp,4))=[];
            for plane = 1:otlevels
                temp2(:,:,plane,ts) = imresize(squeeze(nanmean(temp(:,:,plane,idx),4)),newSize,'bilinear');
            end
    %         c = 1+c;
        end
        if size(temp2,4) > 0    
            output{i} = temp2;
        end
        
        disp(['done with chunk ' num2str(i)])
%         if size(temp,4) * size(temp,3)<chunkSize
%             return
%         end
    catch
    end
end

out = [];
for i = 1:length(output) 
    out = cat(4,out,output{i});
end

end