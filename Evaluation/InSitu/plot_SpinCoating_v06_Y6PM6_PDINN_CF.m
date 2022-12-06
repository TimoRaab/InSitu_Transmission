%% Changelog
% v06
% - renewed time smoothing and time correction
% - read speed values from comments file
% - correct Time first removed due to new speed evaluation not making any
% sense any more
% v03
%   added time correction

%%
clc;
close all 
% clear all
%%
MeasCounter = 0;
basedir = 'C:\Measurements\Measurements\InSitu\SpinCoating\220825'; % Dateipfad zu ordner
fname = '20220825_160425_TR_Y6PM6_LB01_meas.spin';
cellName = 'LB01';
titleName = 'Y6PM6 1% CN';
fNameSaveStart = 'Y6PM6';
dirNameSave = 'E:\Eval\InSitu\211209';
savePic = 0;
wlRange = [420e-9 900e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-50 300]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605 740 790 810 840]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
cmapTimeColorbar = linspecer(120, 'sequential');

tempPos = regexp(fname,'_');
tempFname = fname(tempPos(2)+1:end);
fname = replaceBetween(fname, tempPos(end-1)+1, tempPos(end)-1, cellName);
titleName = [cellName ' - ' titleName];
% fNameSaveStart = [cellName '_' fNameSaveStart];

%% Correct for fname date
correctedPath = correctPathForDate(fullfile(basedir, fname));
splitter = regexp(correctedPath,filesep);

% basedir = pathstring(1:splitter(end));
fname = correctedPath(splitter(end)+1:end);
disp(['fname: ' fname])

%% 
smoothFFT = 1;
[spinCoatingMode, tempSpeedValues] = getSpeedValues(fullfile(basedir, fname));
speedValue = tempSpeedValues(:,1)'/60;
speedValueTimes = [0 tempSpeedValues(:,2)'];
for i=length(speedValueTimes):-1:1
    speedValueTimes(i) = sum(speedValueTimes(1:i));
end

% for override
% speedValue = [4000 3000]/60;
% speedValueTimes = [0 45 1000];

timeRangeFFT = [5 5 5]; % Defines area for FFT [TimeAreaStart+x, TimeAreaEnd-y, Length for FFT] 
wlDetectFFT = [450:100:850]*1e-9; %wavelength for fft
speedRangeValueDivider = 6; % 

%%
correctTime = 1;
timeDetectWavelength = 550e-9;
timeDetectLowerThreshold= [0.3 0.1];
timeDetectUpperThreshold = [0.9 0.2];
timeDetectSkipNSeconds = [speedValueTimes(1)+5 speedValueTimes(2)+2];

correctingTimeData = ...
    {correctTime, timeDetectLowerThreshold, timeDetectUpperThreshold,...
    timeDetectWavelength, timeDetectSkipNSeconds};


%%
createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
referenceTimeSector = 1;    % which speed area should be used
referenceTimeBefore = 2;    % Time before taking the reference
referenceTime = 3;          % Time for taking reference




%% Import Data
[spectra, time, wl, ref, dark, startTime] = readSpinCoater(fullfile(basedir,fname));  %liest die Spektren ein
spectra = squeeze(spectra); % entfernt eine Dimension
dark = squeeze(dark);
ref = squeeze(ref);
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes f�rs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
time = time-time(1);            % rechnet die Zeit um
time = time/1e5;                % rechnet die Zeit um
time = time-startTime;          % rechnet die Zeit um
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));

%% Saturation Detection
refMax = max(ref, [], 'all');
disp(['Reference Max: ' num2str(refMax)])
spectraMax = max(spectra, [], 'all');
disp(['Spectra Max: ' num2str(spectraMax)]);
disp('  ');

if (refMax < 2^16 && spectraMax < 2^16)
    disp('Saturation OK')
else
    disp('Saturation Problem!')
    disp('Check Data!');
end

%% Detect Speeds via FFT
if smoothFFT
    for i=1:length(speedValue)
        tempSpeedList = [];
        indCounter = 1;
        for j = wlDetectFFT
            [~,tempIWL] = min(abs(wl-j));
            for k=speedValueTimes(i)+timeRangeFFT(1):timeRangeFFT(3):speedValueTimes(i+1)-timeRangeFFT(2)
                [~,tempILow] = min(abs(time-k));
                [~,tempIHigh] = min(abs(time-(k+timeRangeFFT(3))));
                [f_FFT, p_FFT] = plotFFT(time(tempILow:tempIHigh), ...
                    spectra(tempIWL, tempILow:tempIHigh),1,1, 'plot', 'off');
                
                [~,indSpeedMin] = min(abs(f_FFT-(speedValue(i)-speedValue(i)/speedRangeValueDivider)));
                [~,indSpeedMax] = min(abs(f_FFT-(speedValue(i)+speedValue(i)/speedRangeValueDivider)));
                [~,ind] = max(p_FFT(indSpeedMin:indSpeedMax));
                ind = ind + indSpeedMin -1;
                tempSpeedList(indCounter) = f_FFT(ind);
                indCounter = indCounter+1;
            end
        end
        speedValue(i) = median(tempSpeedList);
    end
end

for i=1:length(speedValue)
    disp(['Section ' num2str(i) ': ' num2str(speedValue(i)*60) 'rpm'])
end


%%
if (createReferenceSpectrum)
    % if an to big speed section is giving, last section is used
    if referenceTimeSector > length(speedValueTimes)-1
        referenceTimeSector = length(speedValueTimes)-1;
        disp('ReferenceTimeSector changed due to non-existent sector')
    end

    time2Reference = speedValueTimes(referenceTimeSector) + referenceTimeBefore;

    [~, indTimeRefStart] = min(abs(time-time2Reference));
    [~, indTimeRefStop] = min(abs(time-(time2Reference+referenceTime)));

    %keep old reference for stuff
    refMeasured = ref;
    ref = spectra(:, indTimeRefStart:indTimeRefStop);
end

%%
trans = (spectra-mean(dark,2))./(mean(ref,2)-mean(dark,2)); % Berechnet die Transmission
%trans = trans(indWlMin:indWlMax, indTimeMin:indTimeMax);
% wl = wl(indWlMin:indWlMax);
% time = time(indTimeMin:indTimeMax);
clearvars spectra;

%% 
M = timeSmoothing(speedValue, speedValueTimes, trans, time);
timeStamps = timeCorrection(correctingTimeData, trans, wl, time);

%%
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes f�rs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));
%%
% figure(700+MeasCounter);
% set(gcf, 'Name', 'False Color Plot');
% imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), trans(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild
% c = colorbar(); % F�gt Colorbar ein
% caxis([0 1.2]) % Setzt die Grenzen der Colorbar
% xlabel('Time in s');
% ylabel('Wavelength in nm');
% ylabel(c, 'Transmitance');

%%
figure(800+MeasCounter)
set(gcf, 'Name', 'All Wavelength');
for indTimeLower = 1:length(wlPlot)
%     figure(800 + indTimeLower);
    [~,indWL] = min(abs(wl-wlPlot(indTimeLower)));
%     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
%     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
%     xlabel('Time in s')
%     ylabel('Transmittance')
    figure(800+MeasCounter)
    plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
    hold on
end

figure(800+ MeasCounter)
legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]))
xlabel('Time in s')
ylabel('Transmittance')

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


%% Hier wird ein moving average angewendet
R = smoothdata(M,1, 'sgolay', 20);
% R = M;
%%
figure(15000+MeasCounter)
imagesc(time(indTimeMin:indTimeMax), wl*1e9, R(:, indTimeMin:indTimeMax));
h = colorbar();
caxis([0 1.1]);
xlabel('Time in s');
ylabel('Wavelength in nm')
ylabel(h, 'Transmittance')

%%

for i=0:length(timeStamps)-1
    figure(13000+MeasCounter+i)
    set(gcf, 'Name', 'All Wavelength');
    for indTimeLower = 1:length(wlPlot)
    %     figure(800 + indTimeLower);
        [~,indWL] = min(abs(wl-wlPlot(indTimeLower)));
    %     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
    %     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
    %     xlabel('Time in s')
    %     ylabel('Transmittance')
        figure(13000+MeasCounter+i)
        plot(time(indTimeMin:indTimeMax)-timeStamps(i+1), R(indWL, indTimeMin:indTimeMax), 'Linewidth', 2);
        hold on
    end
    
    figure(13000+MeasCounter)
    legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]))
    xlabel('Time in s')
    ylabel('Transmittance')
end

%%
% figure(19002);
% mm = diff(R,1,2);
% mm = sign(mm).*log(abs(mm));
% mm2 = smoothdata(mm,2,'movmean', movTime);
% imagesc(time(1:end-1), wl*1e9, mm2)
% colormap(createColormap(-10,10))
% % % caxis([-10 10])

%%
% figure(19003);
% tempMax = max(R,[],1);
% tempMin = min(R,[],1);
% 
% Rnorm = (R-tempMin)./(tempMax-tempMin);
% imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), Rnorm(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild


%% Y6PM6
%%
fNameSave = [fNameSaveStart '_begin'];
timePlot = [-0.01:0.005:0, 0.11:0.005:0.3];
timePlot = [0.1:0.005:0.3];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(1)));
        plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
cTimePlot.Label.String = ('Time in s');
cTimePlot.Label.FontSize = 12;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end

%%
fNameSave = [fNameSaveStart '_crystal'];
timePlot = [0.5:0.005:0.75];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(1)));
        plot(wl*1e9, M(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
cTimePlot.Label.String = ('Time in s');
cTimePlot.Label.FontSize = 12;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end

%%
fNameSave = [fNameSaveStart '_inter'];
timePlot = [0.3:0.05:1.2];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(1)));
        plot(wl*1e9, M(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end
%%
fNameSave = [fNameSaveStart '_long'];
timePlot = [2:1:25];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(1)));
        plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
cTimePlot.Label.String = ('Time in s');
cTimePlot.Label.FontSize = 12;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end
%%












%%PDINN
%%
fNameSave = [fNameSaveStart '_begin'];
timePlot = [-1:0.1:-0.1, 0.2:0.05:0.3];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(2)));
        plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
cTimePlot.Label.String = ('Time in s');
cTimePlot.Label.FontSize = 12;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end

%%
fNameSave = [fNameSaveStart '_crystal'];
timePlot = [0.9:0.01:1.1];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(2)));
        plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
cTimePlot.Label.String = ('Time in s');
cTimePlot.Label.FontSize = 12;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end


%%
fNameSave = [fNameSaveStart '_inter'];
timePlot = [0.5:0.05:0.9];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(2)));
        plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
cTimePlot.Label.String = ('Time in s');
cTimePlot.Label.FontSize = 12;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end


%%
fNameSave = [fNameSaveStart '_jump'];
timePlot = [-2, -1, 3 4];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(2)));
        plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
cTimePlot.Label.String = ('Time in s');
cTimePlot.Label.FontSize = 12;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end

%%
fNameSave = [fNameSaveStart '_long'];
timePlot = [2:2:30];
fNameSave = [cellName '_' fNameSave];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(2)));
        plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([400 865])
ylabel('Transmission')
xlabel('Wavelength in nm')
set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
    'LineWidth', 2);

% cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% cTimePlot.Position = [0.2 0.78 0.4 0.05];
cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
caxis([min(timePlot), max(timePlot)])
colormap(cmapTimeColorbar)
cTimePlot.LineWidth = 2;
cTimePlot.Label.String = ('Time in s');
cTimePlot.Label.FontSize = 12;
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end