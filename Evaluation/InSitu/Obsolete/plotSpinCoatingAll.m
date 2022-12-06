clc;
close all
clear all
%%
basedir = 'F:\Measurements\InSitu\SpinCoater\190522';
fname = '20190522_164335_P3HTPC70BM_30_24mg_S05_meas.spin';
wlRange = [400e-9 700e-9];
timeRange = [-10 50];
wlPlot = 605e-9;
listDir = dir(basedir);
counter = 0;
figure(100);
%%
for i=1:length(listDir)
    if ~isempty(regexp(listDir(i).name, 'meas.spin'))
        counter = counter+1;
        fname = listDir(i).name;
[spectra, time, wl, ref, dark, startTime] = readSpinCoater(fullfile(basedir,fname));
spectra = squeeze(spectra);
dark = squeeze(dark);
ref = squeeze(ref);
[~,indWlMin] = min(abs(wl-min(wlRange)));
[~,indWlMax] = min(abs(wl-max(wlRange)));
time = time-time(1);
time = time/1e5;
time = time-startTime;
[~,indTimeMin] = min(abs(time-min(timeRange)));
[~,indTimeMax] = min(abs(time-max(timeRange)));

%%
% figure(890);
% set(gcf, 'Name', 'Counts only');
% imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), spectra(indWlMin:indWlMax,indTimeMin:indTimeMax));
% colorbar();

%%
figure(800 + counter);
set(gcf, 'Name', listDir(i).name);
trans = (spectra-mean(dark,2))./(mean(ref,2)-mean(dark,2));
imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), trans(indWlMin:indWlMax,indTimeMin:indTimeMax));
colorbar();
caxis([0 1.2])

%%
figure(900 + counter);
[~,indWL] = min(abs(wl-wlPlot));
plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));

%%
figure(100)
plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
hold on
    end
end