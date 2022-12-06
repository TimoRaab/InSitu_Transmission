clc;
close all
clear all
%%
basedir = 'F:\Measurements\InSitu\SpinCoater\190701'; %
fname = '20190701_143236_190624_JZ_P3HTPC70BM_CB_B_R1_meas';
wlRange = [420e-9 700e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-5 130]; % gibt den Zeitbereich zum plotten an
wlPlot = [446 509 558 605]*1e-9; % für den plot einer Wellenlänge über die Zeit
timePlot = [1:5:20];

timeRangeFFTStart = [50 100];
wlDetectFFT = 550e-9;
speedRangeFFT = [700 1000]/60;
%%
load(fullfile(basedir, fname));

%%

[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes fürs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));


%%
[~,indLowFFT] = min(abs(time-min(timeRangeFFTStart)));
[~,indHighFFT] = min(abs(time-max(timeRangeFFTStart)));          
[~,indWlFFT] = min(abs(wl-wlDetectFFT));
plotFFT(time(indLowFFT:indHighFFT), trans(indWlFFT,indLowFFT:indHighFFT), 1,1)

f = figure(5002);
frequencyAxis = f.Children(1).Children(1).XData;
frequqncyIntensity = f.Children(1).Children(1).YData;
figure(5000);
close
figure(5001);
close
figure(5002);
close

[~,indSpeedMin] = min(abs(frequencyAxis-min(speedRangeFFT)));
[~,indSpeedMax] = min(abs(frequencyAxis-max(speedRangeFFT)));

[~,ind] = max(frequqncyIntensity(indSpeedMin:indSpeedMax));
ind = ind + indSpeedMin -1;
rotFrequency = frequencyAxis(ind);

%%
movTime = round(1/rotFrequency/mean(diff(time(indLowFFT:indHighFFT))));
movedTime = movmean(trans, movTime,2);
movedSpectra = movmean(movedTime, 5);

figure(15743)
imagesc(time, wl, movedSpectra);
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
    plot(time(indTimeMin:indTimeMax), movedSpectra(indWL, indTimeMin:indTimeMax), 'Linewidth', 2);
    hold on
end



%% find timing of spin coating
for i= 1:length(wlPlot)
    [~,indWL] = min(abs(wl-wlPlot(i)));
    diffMoved = diff(movedSpectra(indWL,:));

    % start applying
    diffMoved_temp = diffMoved./abs(min(diffMoved));
    [~,indDiffTemp] = min(diffMoved_temp);
    [~,indStartApp] = min(abs(diffMoved_temp(1:indDiffTemp) - (-0.1)));

    % "start" drying
    diffMoved_temp = diffMoved./max(diffMoved);
    [~,indDiffTemp] = max(diffMoved_temp);
    [~,indStartDry] = min(abs(diffMoved_temp(1:indDiffTemp) - (0.1)));

    % end drying
    averagingTime = ceil(3/rotFrequency/mean(diff(time)));

    deviation = NaN(1,length(time)-averagingTime);
    for j=1:length(deviation)
        deviation(j) = mean(diff(movedSpectra(indWL,j:(j+averagingTime))));
    end

    tempDeviation = deviation - mean(deviation(indLowFFT:indHighFFT));
    tempDeviation = tempDeviation./max(abs(tempDeviation));
    tempDeviation = abs(tempDeviation(1:end-10000)) > 0.01;
    tempDevPos = find(tempDeviation);
    indEndDry = max(tempDevPos)+1;
    disp(num2str(wlPlot(i)))
    disp(num2str(mean(diff(time)*(indEndDry-indStartApp))));
end




