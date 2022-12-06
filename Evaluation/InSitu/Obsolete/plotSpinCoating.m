clc;
close all
clear all
%%
basedir = 'F:\Measurements\InSitu\SpinCoater\200820'; %
fname = '20200820_140014_Test_inSitu_NewSetup_TestBefore_meas.spin';
wlRange = [420e-9 700e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-5 130]; % gibt den Zeitbereich zum plotten an
wlPlot = [446 509 558 605]*1e-9; % für den plot einer Wellenlänge über die Zeit
timePlot = [1:5:20];

timeRangeFFT = [30 90];
wlDetectFFT = 550e-9;
speedRangeFFT = [700 1000]/60;
%%
[spectra, time, wl, ref, dark, startTime] = readSpinCoater(fullfile(basedir,fname));  %liest die Spektren ein
spectra = squeeze(spectra); % entfernt eine Dimension
dark = squeeze(dark);
ref = squeeze(ref);
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes fürs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
time = time-time(1);            % rechnet die Zeit um
time = time/1e5;                % rechnet die Zeit um
time = time-startTime;          % rechnet die Zeit um
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));

trans = (spectra-mean(dark,2))./(mean(ref,2)-mean(dark,2)); % Berechnet die Transmission
%trans = trans(indWlMin:indWlMax, indTimeMin:indTimeMax);
% wl = wl(indWlMin:indWlMax);
% time = time(indTimeMin:indTimeMax);
clearvars spectra;
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes fürs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));
%%
figure(700);
set(gcf, 'Name', 'False Color Plot');
imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), trans(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild
colorbar(); % Fügt Colorbar ein
caxis([0 1.2]) % Setzt die Grenzen der Colorbar

%%
figure(800)
set(gcf, 'Name', 'All Wavelength');
for i = 1:length(wlPlot)
%     figure(800 + i);
    [~,indWL] = min(abs(wl-wlPlot(i)));
%     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
%     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
    figure(800)
    plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
    hold on
end

figure(800)
legend(cellstr(num2str(wlPlot')))

%%
% figure(900)
% set(gcf, 'Name', 'All TimeCut');
% for i = 1:length(timePlot)
%     figure(900 + i);
%     [~,indTime] = min(abs(time-timePlot(i)));
%     set(gcf, 'Name', ['Time' num2str(time(indTime))]);
%     plot(wl(indWlMin:indWlMax), trans(indWlMin:indWlMax,indTime));
%     figure(900)
%     plot(wl(indWlMin:indWlMax), trans(indWlMin:indWlMax,indTime));
%     hold on
% end
% 
% 
% legend(cellstr(num2str(timePlot')))

%% 
% figure(1000)
% set(gcf, 'Name', 'Reference')
% [~,indForReference] = min(abs(wl-550e-9));
% for i=1:100:size(ref,2)
%     plot(wl, ref(:,i))
%     hold on
% end
% disp('Reference max min')
% max(ref(indForReference,:)) - min(ref(indForReference,:))
% std(ref(indForReference,:))
% 
% figure(1001)
% set(gcf, 'Name', 'dark')
% [~,indForReference] = min(abs(wl-550e-9));
% for i=1:100:size(dark,2)
%     plot(wl, dark(:,i))
%     hold on
% end
% disp('dark max min')
% max(dark(indForReference,:)) - min(dark(indForReference,:))
% std(dark(indForReference,:))

%%
[~,indLowFFT] = min(abs(time-min(timeRangeFFT)));
[~,indHighFFT] = min(abs(time-max(timeRangeFFT)));          
[~,indWlFFT] = min(abs(wl-wlDetectFFT));
plotFFT(time(indLowFFT:indHighFFT), trans(indWlFFT,indLowFFT:indHighFFT), 1,1)

f = figure(5002);
xDat = f.Children(1).Children(1).XData;
yDat = f.Children(1).Children(1).YData;
figure(5000);
close
figure(5001);
close
figure(5002);
close

[~,indSpeedMin] = min(abs(xDat-min(speedRangeFFT)));
[~,indSpeedMax] = min(abs(xDat-max(speedRangeFFT)));

[~,ind] = max(yDat(indSpeedMin:indSpeedMax));
ind = ind + indSpeedMin -1;

%%
movTime = round(1/xDat(ind)/mean(diff(time(indLowFFT:indHighFFT))));
M = movmean(trans, movTime,2);
R = movmean(M, 5);

figure(15743)
imagesc(time, wl, R);
colorbar();
caxis([0 1.1]);

%%
figure(13001)
set(gcf, 'Name', 'All Wavelength');
for i = 1:length(wlPlot)
%     figure(800 + i);
    [~,indWL] = min(abs(wl-wlPlot(i)));
%     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
%     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
    figure(13001)
    plot(time(indTimeMin:indTimeMax), R(indWL, indTimeMin:indTimeMax), 'Linewidth', 2);
    hold on
end

figure(13000)
legend(cellstr(num2str(wlPlot')))