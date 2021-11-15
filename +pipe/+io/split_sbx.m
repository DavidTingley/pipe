function [] = split_sbx(file,intervals)

meta = strsplit(file,'.');
info = pipe.io.read_sbxinfo([meta{1} '.mat']);
vid = pipe.io.read_sbx(file);

for f = 1:length(intervals)
    t = strsplit(meta{1},'_');
    animal = t{1};
    date = t{2};
    splitFile = [animal '_' date  '_split_' num2str(f,'%0.3d')];
    
    completeStacks = intervals(f,:); %1:completeStacks * info.otlevels
    if ndims(vid) == 3
        temp = vid(:,:,completeStacks(1):completeStacks(2));
    elseif ndims(vid) == 4
        temp = vid(:,:,:,completeStacks(1):completeStacks(2));
    end
    
    info.nframes = completeStacks(2) - completeStacks(1) + 1;
    rw = pipe.io.RegWriter([splitFile '.sbx'], info, 'sbx', true,'w');
    rw.write(temp);
    rw.close() 
    save([splitFile '.mat'],'info')
end