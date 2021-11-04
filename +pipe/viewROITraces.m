function [] = viewROITraces(vid)


figure(1)
imagesc(squeeze(nanmean(nanmean(vid(:,:,15:45,:),3),4)))
[x y]  = ginput();
figure(2)
for i = 1:length(x)
plot(squeeze(nanmean(vid(round(y(i)),round(x(i)),15:45,:),3)))
hold on
end
hold off

