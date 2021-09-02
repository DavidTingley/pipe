function [out] = downsize(vid_fname,otlevels,window)


cc=1;
chunkSize = 100 * otlevels;
out = [];
for i=1:chunkSize:10000000

    temp = pipe.io.read_sbx(vid_fname,i,chunkSize,1,[]);

    temp = pipe.misc.ts2stackTS(temp,otlevels);
%     c = 1;

    temp2 = zeros(ceil(size(temp,1)/3),ceil(size(temp,2)/3),otlevels,floor((size(temp,4))/window));
    
    parfor ts = 1:floor(size(temp,4)/window)
        idx = ts*window:ts*window+window;
        idx(idx>size(temp,4))=[];
        for plane = 1:otlevels
            temp2(:,:,plane,ts) = imresize(squeeze(nanmean(temp(:,:,plane,idx),4)),1/3,'bilinear');
        end
%         c = 1+c;
    end
    if size(temp2,4) > 0
        out = cat(4,out,temp2);
    end
    cc=1+cc;
    disp(['done with chunk ' num2str(i)])
    if size(temp,4) * size(temp,3)<chunkSize
        return
    end
end


end