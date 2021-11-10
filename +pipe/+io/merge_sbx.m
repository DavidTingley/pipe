function [] = merge_sbx(fileList)

for f = 1:length(fileList)
       meta = strsplit(fileList(f).name,'.');
       info = pipe.io.read_sbxinfo([meta{1} '.mat']);
       temp = pipe.io.read_sbx(fileList(f).name);
       
       % hacky code that assumes file naming ANIMAL_DATE_RUN.sbx
       t = strsplit(meta{1},'_');
       animal = t{1};
       date = t{2};
       mergeFile = [animal '_' date '_merge'];
       
       %ensures you crop last/incomplete Z-stacks
       if ndims(temp) == 3
           completeStacks = floor(size(temp,3)/info.otlevels);
           temp = temp(:,:,1:completeStacks * info.otlevels);
       elseif ndims(temp) == 4
           completeStacks = floor(size(temp,4)/info.otlevels);
           temp = temp(:,:,:,1:completeStacks * info.otlevels);
       end
          
       disp(['writing file #' num2str(f) ' to merge file'])
       nFrames(f) = size(temp,ndims(temp));
       nstacks(f) = completeStacks;

       info.nframes = sum(nFrames); % needs to be updated for regWriter, dumb
       % write new if first file, otherwise append
       if f == 1
        rw = pipe.io.RegWriter([mergeFile '.sbx'], info, 'sbx', true,'w');      
       else
        rw = pipe.io.RegWriter([mergeFile '.sbx'], info, 'sbx', true,'a');
       end
       rw.write(temp);
       rw.close()  
end
     % save metadata file
     info.nframes = sum(nFrames);
     info.nstacks = nstacks;
     save([mergeFile '.mat'],'info')
end