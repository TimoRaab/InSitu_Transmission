clc;
close all
% clear all
%%
basedir = 'F:\Measurements\InSitu\SpinCoater\190911'; %
fname = '20190911_092726_TR_P3HTPCBM_OLD_TestHumidity_S02_meas.mat';
wlRange = [420e-9 700e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-10 200]; % gibt den Zeitbereich zum plotten an
wlPlot = [446 509 558 605]*1e-9; % für den plot einer Wellenlänge über die Zeit
timePlot = [1:5:20];

timeRangeFFT = [20 80];
wlDetectFFT = 550e-9;

speedRangeFFT = [700 1000]/60;
%%
load(fullfile(basedir, fname));
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes fürs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));

%%
% figure(700);
% set(gcf, 'Name', 'False Color Plot');
% imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), trans(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild
% colorbar(); % Fügt Colorbar ein
% caxis([0 1.2]) % Setzt die Grenzen der Colorbar

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
% figure(1200)
% t = trans./trans(:,end);
% imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), t(indWlMin:indWlMax,indTimeMin:indTimeMax));
% 
% figure(1201)
% for i = 1:length(wlPlot)
%     [~,indWL] = min(abs(wl-wlPlot(i)));
%     plot(time(indTimeMin:indTimeMax), t(indWL, indTimeMin:indTimeMax));
%     hold on
% end
% legend(cellstr(num2str(wlPlot')))


%% FFT
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

% fftTrans = fft2(trans);
% dt = mean(diff(time));
% fx = linspace(-1/(2*dt),1/(2*dt),length(time)+1);fx = fx(1:end-1);
% dwl = mean(diff(wl));
% fy = linspace(-1/(2*dwl),1/(2*dwl),length(wl)+1);fy = fy(1:end-1);
% 
% fftTrans(:,abs(fftshift(fx))>1.1*xDat(ind))= 0;
% % transFT11 = ifft2(fftTrans);
% 
% % figure(1400);
% % imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), abs(transFT11(indWlMin:indWlMax,indTimeMin:indTimeMax)));
% 
% % figure(1401)
% % for i = 1:length(wlPlot)
% %     [~,indWL] = min(abs(wl-wlPlot(i)));
% %     plot(time(indTimeMin:indTimeMax), abs(transFT11(indWL, indTimeMin:indTimeMax)));
% %     hold on
% % end
% % legend(cellstr(num2str(wlPlot')))
% 
% fftTrans(:,abs(fftshift(fx))>xDat(ind)/1.1)= 0;
% transFT09 = ifft2(fftTrans);
% figure(1402)
% for i = 1:length(wlPlot)
%     [~,indWL] = min(abs(wl-wlPlot(i)));
%     plot(time(indTimeMin:indTimeMax), abs(transFT09(indWL, indTimeMin:indTimeMax)));
%     hold on
% end
% legend(cellstr(num2str(wlPlot')))
% 
% fftTrans(:,abs(fftshift(fx))>5)= 0;
% transFT5 = ifft2(fftTrans);
% figure(1403)
% for i = 1:length(wlPlot)
%     [~,indWL] = min(abs(wl-wlPlot(i)));
%     plot(time(indTimeMin:indTimeMax), abs(transFT5(indWL, indTimeMin:indTimeMax)));
%     hold on
% end
% legend(cellstr(num2str(wlPlot')))
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