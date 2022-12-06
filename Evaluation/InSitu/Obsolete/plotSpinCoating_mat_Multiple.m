clc;
close all
clear all
%%

basedirList = cell(0);
basedirList{end+1} = 'F:\Measurements\InSitu\SpinCoater\190626';


% basedir = 'F:\Measurements\InSitu\SpinCoater\190701'; %
% fname = '20190701_143236_190624_JZ_P3HTPC70BM_CB_B_R1_meas';
wlRange = [420e-9 700e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-5 130]; % gibt den Zeitbereich zum plotten an
wlPlot = [446 509 558 605]*1e-9; % für den plot einer Wellenlänge über die Zeit
timePlot = [1:5:20];

timeRangeFFTStart = [30 100];
wlDetectFFT = 550e-9;
speedRangeFFT = [700 1000]/60;
%%
for listCounter = 1:length(basedirList)
    dirTemp = dir(basedirList{listCounter});
    fname = cell(0);
    for i=1:length(dirTemp)
        if ~isempty(regexp(dirTemp(i).name, 'meas.mat'))
            fname{end+1} = dirTemp(i).name;
        end
    end
end
values = NaN(length(fname), 4*length(wlPlot));
valuesRef = NaN(length(fname), 4*length(wlPlot));
% fname = fname(end);
for listCounter = 1:length(fname)
%%
load(fullfile(basedirList{1}, fname{listCounter}));

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

% figure(15743)
% imagesc(time, wl, movedSpectra);
% colorbar();
% caxis([0 1.1]);

%%
figure(1300+listCounter)
set(gcf, 'Name', 'All Wavelength');
for i = 1:length(wlPlot)
%     figure(800 + i);
    [~,indWL] = min(abs(wl-wlPlot(i)));
%     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
%     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
%     figure(13001)
    plot(time(indTimeMin:indTimeMax), movedSpectra(indWL, indTimeMin:indTimeMax), 'Linewidth', 2);
    hold on
end


pause(0.1)
%% find timing of spin coating
disp([num2str(listCounter) ': ' (fname{listCounter})]);
for i= 1:length(wlPlot)
    [~,indWL] = min(abs(wl-wlPlot(i)));
    values(listCounter, (i-1)*4 + 1) = wl(indWL);
    
    averagingTime = ceil(1/rotFrequency/mean(diff(time)));
    diffMoved = diff(movedSpectra(indWL,:));

    % start applying
    diffMoved_temp = diffMoved./abs(min(diffMoved));
    [~,indDiffTemp] = min(diffMoved_temp);
    while diffMoved_temp(indDiffTemp) < (-0.1) 
        indDiffTemp = indDiffTemp -1;
    end
    indStartApp = indDiffTemp+1;

    % "start" drying
    diffMoved_temp = diffMoved./max(diffMoved(indStartApp:end));
    [~,indDiffTemp] = max(diffMoved_temp);
    [~,indStartDry] = min(abs(diffMoved_temp(1:indDiffTemp) - (0.1)));

    % end drying

    deviation = NaN(1,length(time)-3*averagingTime);
    for j=1:length(deviation)
        deviation(j) = mean(diff(movedSpectra(indWL,j:(j+3*averagingTime))));
    end

    tempDeviation = deviation - mean(deviation(indLowFFT:indHighFFT));
    tempDeviation = tempDeviation./max(abs(tempDeviation));
    tempDeviation = abs(tempDeviation(1:end-10000)) > 0.01;
    tempDevPos = find(tempDeviation);
    indEndDry = max(tempDevPos)+1;
    disp([num2str(wlPlot(i)) ':     ' num2str(mean(diff(time))*(indEndDry-indStartApp)) ' ------- ' num2str(indEndDry) '  /  ' num2str(indStartApp)])
    values(listCounter, (i-1)*4 + 2) = mean(diff(time))*(indEndDry-indStartApp);
    values(listCounter, (i-1)*4 + 3) = mean(movedSpectra(indWL,indEndDry+1:indEndDry+1+5*averagingTime));
    values(listCounter, (i-1)*4 + 4) = mean(movedSpectra(indWL,end-10000-5*averagingTime:end-10000));
end


%% Reference Values

averagingTime = ceil(1/rotFrequency/mean(diff(time)));
diffMoved = diff(movedSpectra(end,:));

% start applying
diffMoved_temp = diffMoved./abs(min(diffMoved));
[~,indDiffTemp] = min(diffMoved_temp);
while diffMoved_temp(indDiffTemp) < (-0.1) 
    indDiffTemp = indDiffTemp -1;
end
indStartApp = indDiffTemp+1;

% "start" drying
diffMoved_temp = diffMoved./max(diffMoved(indStartApp:end));
[~,indDiffTemp] = max(diffMoved_temp);
[~,indStartDry] = min(abs(diffMoved_temp(1:indDiffTemp) - (0.1)));

% end drying

deviation = NaN(1,length(time)-3*averagingTime);
for j=1:length(deviation)
    deviation(j) = mean(diff(movedSpectra(end,j:(j+3*averagingTime))));
end

tempDeviation = deviation - mean(deviation(indLowFFT:indHighFFT));
tempDeviation = tempDeviation./max(abs(tempDeviation));
tempDeviation = abs(tempDeviation(1:end-10000)) > 0.01;
tempDevPos = find(tempDeviation);
indEndDry = max(tempDevPos)+1;

for i= 1:length(wlPlot)
    [~,indWL] = min(abs(wl-wlPlot(i)));
    valuesRef(listCounter, (i-1)*4 + 1) = wl(indWL);
    
    valuesRef(listCounter, (i-1)*4 + 2) = mean(diff(time))*(indEndDry-indStartApp);
    valuesRef(listCounter, (i-1)*4 + 3) = mean(movedSpectra(indWL,indEndDry+1:indEndDry+1+5*averagingTime));
    valuesRef(listCounter, (i-1)*4 + 4) = mean(movedSpectra(indWL,end-10000-5*averagingTime:end-10000));
end

end

