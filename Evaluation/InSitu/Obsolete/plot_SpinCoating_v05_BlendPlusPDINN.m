%% Changelog
% v03
%   added time correction

%%
clc;
close all
clear all
%%
MeasCounter = 0;
basedir = 'C:\Measurements\Measurements\InSitu\SpinCoating\220303'; % Dateipfad zu ordner
fname = '20220303_111606_TR_Y6PM6_PDINN_G01_meas.spin';
cellName = 'G06';
titleNameDescription = '- 5%CN - FullPower';
fNameSaveStart = 'FullPower';
dirNameSave = 'C:\Measurements\Eval\InSitu\220215';
savePic = 0;
savePic2 = 0;
wlRange = [420e-9 900e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-50 100]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605 740 790 810 840 430]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
cmapTimeColorbar = linspecer(120, 'sequential');

tempPos = regexp(fname,'_');
tempFname = fname(tempPos(2)+1:end);
fname = replaceBetween(fname, tempPos(end-1)+1, tempPos(end)-1, cellName);

%%
correctTimeFirst = 0;
%%
correctTime = 1;
timeDetectLowerThreshold= 0.3;
timeDetectUpperThreshold = 0.4;
timeDetectWavelength = 430e-9;
timeDetectSkipNSeconds = 5;

correctingTimeDataBlend = ...
    {correctTime, timeDetectLowerThreshold, timeDetectUpperThreshold,...
    timeDetectWavelength, timeDetectSkipNSeconds};

%%
smoothFFT = 0;
speedValue = [4000 3000]/60;
speedValueTimes = [0 45 1000];
timeRangeFFT = [-15 -5]; %Zeitbereich f�r die FFT (hier soll das Spektrum konstant sein)
wlDetectFFT = 550e-9; % Wellenl�nge, f�r welche die FFT bestimmt wird
speedRangeFFT = [3800 4200]/60; % Bereich der Rotationsgeschwindigkeit, in welcher gesucht wird

smoothingTimeData = ...
    {smoothFFT, speedValue, speedValueTimes, timeRangeFFT, wlDetectFFT, speedRangeFFT};

%%
createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
referenceTimeSector = 1;    % which speed area should be used
referenceTimeBefore = 1;    % Time before taking the reference
referenceTime = 3;          % Time for taking reference

%% Correct for fname date
correctedPath = correctPathForDate(fullfile(basedir, fname));
splitter = regexp(correctedPath,filesep);

% basedir = pathstring(1:splitter(end));
fname = correctedPath(splitter(end)+1:end)



%%
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

%%
if (createReferenceSpectrum)
    tempPos = regexp(fname, '_');
    fname_set = [fname(1:tempPos(end)) 'comments.txt'];
    temp_fid = fopen(fullfile(basedir, fname_set));
    temp_set = fscanf(temp_fid, '%c');
    fclose(temp_fid);
    temp_set = strsplit(temp_set, '\n')';

    %check for correct lines to read
    indTimeLower = 1;
    while (isempty(regexp(temp_set{indTimeLower}, 'Speed', 'once'))...
            || isempty(regexp(temp_set{indTimeLower}, 'Time', 'once'))...
            || isempty(regexp(temp_set{indTimeLower}, 'Acceleration', 'once')))
        indTimeLower = indTimeLower+1;
    end

    lowerLimit = indTimeLower+1;

    while (regexp(temp_set{indTimeLower}, '\r') ~= 1)
        indTimeLower = indTimeLower+1;
    end
    upperLimit = indTimeLower-1;

    % if an to big speed section is giving, last section is used
    line4Reference = lowerLimit+referenceTimeSector-1;
    if line4Reference > upperLimit
        line4Reference = upperLimit;
    end

    % get starting time for reference
    time2Reference = 0;
    indTimeLower = 0;
    while (lowerLimit+indTimeLower < line4Reference)
        temp = strsplit(temp_set{lowerLimit+indTimeLower}, '\t');
        time2Reference = time2Reference + str2double(temp{2});
        indTimeLower = indTimeLower+1;
    end

    time2Reference = time2Reference + referenceTimeBefore;

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
if correctTimeFirst
    time = timeCorrection(correctingTimeDataBlend, trans, wl, time);
    M = timeSmoothing(smoothingTimeData, trans, wl, time);
else
    M = timeSmoothing(smoothingTimeData, trans, wl, time);
    time = timeCorrection(correctingTimeDataBlend, trans, wl, time);
end

%%
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes f�rs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));

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
figure(13000+MeasCounter)
set(gcf, 'Name', 'All Wavelength');
for indTimeLower = 1:length(wlPlot)
%     figure(800 + indTimeLower);
    [~,indWL] = min(abs(wl-wlPlot(indTimeLower)));
%     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
%     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
%     xlabel('Time in s')
%     ylabel('Transmittance')
    figure(13000+MeasCounter)
    plot(time(indTimeMin:indTimeMax), R(indWL, indTimeMin:indTimeMax), 'Linewidth', 2);
    hold on
end

figure(13000+MeasCounter)
legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]))
xlabel('Time in s')
ylabel('Transmittance')


%%
% fNameSave = [fNameSaveStart 'Y6PM6_begin'];
% timePlot = [-0.01:0.005:0, 0.11:0.005:0.3];
% fNameSave = [cellName '_' fNameSave];
% titleName = [cellName ' - Y6PM6 ' titleNameDescription];
% figureCounter = 0;
% while ishandle(200000+figureCounter)
%     figureCounter = figureCounter+1;
% end
% figure(200000+figureCounter);
% 
% timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);
% 
% cmapLine = linspecer(length(timePlot2), 'sequential');
% for i=1:length(timePlot2)
%     if any(abs(timePlot-timePlot2(i)) < 1e-5)
%         [~,indTimeTemp] = min(abs(time-timePlot2(i)));
%         plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
%         hold on
%     end
% end
% xlim([400 865])
% ylabel('Transmission')
% xlabel('Wavelength in nm')
% set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
%     'LineWidth', 2);
% 
% % cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% % cTimePlot.Position = [0.2 0.78 0.4 0.05];
% cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
% caxis([min(timePlot), max(timePlot)])
% colormap(cmapTimeColorbar)
% cTimePlot.LineWidth = 2;
% cTimePlot.Label.String = ('Time in s');
% cTimePlot.Label.FontSize = 12;
% title(titleName)
% 
% if savePic
% %   saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
% end

%%
fNameSave = [fNameSaveStart 'Y6PM6_crystal'];
timePlot = [0.5:0.005:0.75];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName ' - Y6PM6 ' titleNameDescription ' - Crystalization'];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)));
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
fNameSave = [fNameSaveStart 'Y6PM6_afterCrystal'];
timePlot = [0.3:0.05:1];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName ' - Y6PM6 ' titleNameDescription ' - after Crys'];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)));
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
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end
%%
fNameSave = [fNameSaveStart 'Y6PM6_long'];
timePlot = [1:2:20];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName ' - Y6PM6 ' titleNameDescription ' - long'];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)));
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
% fNameSave = [fNameSaveStart 'Y6PM6_Extralong'];
% timePlot = [-200:15:-10];
% fNameSave = [cellName '_' fNameSave];
% titleName = [cellName ' - Y6PM6 ' titleNameDescription ' - long'];
% figureCounter = 0;
% while ishandle(200000+figureCounter)
%     figureCounter = figureCounter+1;
% end
% figure(200000+figureCounter);
% 
% timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);
% 
% cmapLine = linspecer(length(timePlot2), 'sequential');
% for i=1:length(timePlot2)
%     if any(abs(timePlot-timePlot2(i)) < 1e-5)
%         [~,indTimeTemp] = min(abs(time-timePlot2(i)));
%         plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
%         hold on
%     end
% end
% xlim([400 865])
% ylabel('Transmission')
% xlabel('Wavelength in nm')
% set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
%     'LineWidth', 2);
% 
% % cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% % cTimePlot.Position = [0.2 0.78 0.4 0.05];
% cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
% caxis([min(timePlot), max(timePlot)])
% colormap(cmapTimeColorbar)
% cTimePlot.LineWidth = 2;
% cTimePlot.Label.String = ('Time in s');
% cTimePlot.Label.FontSize = 12;
% title(titleName)
% 
% if savePic
%   saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
% end















%%
correctTime = 1;
timeDetectLowerThreshold= 0.1;
timeDetectUpperThreshold = 0.2;
timeDetectWavelength = 430e-9;
timeDetectSkipNSeconds = 30;

correctingTimeDataPDINN = ...
    {correctTime, timeDetectLowerThreshold, timeDetectUpperThreshold,...
    timeDetectWavelength, timeDetectSkipNSeconds};
time = timeCorrection(correctingTimeDataPDINN, trans, wl, time);

%%
figure(850+MeasCounter)
set(gcf, 'Name', 'All Wavelength');
for indTimeLower = 1:length(wlPlot)
%     figure(800 + indTimeLower);
    [~,indWL] = min(abs(wl-wlPlot(indTimeLower)));
%     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
%     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
%     xlabel('Time in s')
%     ylabel('Transmittance')
    figure(850+MeasCounter)
    plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
    hold on
end

figure(850+ MeasCounter)
legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]))
xlabel('Time in s')
% ylabel('Transmittance')

%%
fNameSave = [fNameSaveStart 'PDINN_begin'];
timePlot = [-0.03:0.005:0.01, 0.15:0.005:0.3];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName ' - PDINN ' titleNameDescription ' - drop'];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)));
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
fNameSave = [fNameSaveStart 'PDINN_crystal'];
timePlot = [0.85:0.01:1.1];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName ' - PDINN ' titleNameDescription ' - Crystalization'];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)));
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
fNameSave = [fNameSaveStart 'PDINN_afterCrystal'];
timePlot = [1:0.05:3];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName ' - PDINN ' titleNameDescription ' - after Crys'];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)));
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
title(titleName)

if savePic
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end
%%
fNameSave = [fNameSaveStart 'PDINN_long'];
timePlot = [2:2:55];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName ' - PDINN ' titleNameDescription ' - long'];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)));
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
fNameSave = [fNameSaveStart 'PDINN_overDrop'];
timePlot = [-1 -0.5 0.5 1 1.5];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName ' - PDINN' titleNameDescription ' - drop'];
figureCounter = 0;
while ishandle(200000+figureCounter)
    figureCounter = figureCounter+1;
end
figure(200000+figureCounter);

timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);

cmapLine = linspecer(length(timePlot2), 'sequential');
for i=1:length(timePlot2)
    if any(abs(timePlot-timePlot2(i)) < 1e-5)
        [~,indTimeTemp] = min(abs(time-timePlot2(i)));
        plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
end
xlim([700 850])
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

if or(savePic, savePic2)
  saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
end