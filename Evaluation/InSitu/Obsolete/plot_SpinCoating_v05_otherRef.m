%% Changelog
% v03
%   added time correction

%%
clc;
close all
% clear all
%%
MeasCounter = 0;
basedir = 'C:\Measurements\Measurements\InSitu\SpinCoating\210706'; % Dateipfad zu ordner
% basedir = '';
fname1 = '20210706_150317_TR_Y6PM6_Y6First_B23_Y6_meas.spin';
fname2 = '20210706_150422_TR_Y6PM6_Y6First_B23_PM6_meas.spin';
cellName = 'B23';
titleNameDescription = 'PDINN - BlendRef - 5%CN - direct';
fNameSaveStart = 'PDINN_BlendRef';
dirNameSave = 'E:\Eval\InSitu\211123';
savePic = 0;
savePic2 = 1;
wlRange = [420e-9 900e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-50 50]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605 740 790 810 840]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
% wlPlot = [405 420 500 605 740]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
% fNameSave = 'Y6PM6_begin';
% timePlot = [0.1:0.01:0.3];
% fNameSave = 'Y6PM6_crystal';
% timePlot = [0.45:0.01:0.56];
% fNameSave = 'Y6PM6_long';
% timePlot = [1 2 3 5 10 15 20 25];
cmapTimeColorbar = linspecer(120, 'sequential');

tempPos = regexp(fname1,'_');
tempFname = fname1(tempPos(2)+1:end);
% fname1 = replaceBetween(fname1, tempPos(end-1)+1, tempPos(end)-1, cellName);
tempPos = regexp(fname2,'_');
tempFname = fname2(tempPos(2)+1:end);
% fname2 = replaceBetween(fname2, tempPos(end-1)+1, tempPos(end)-1, cellName);
titleName = [cellName ' - ' titleName];
% fNameSave = [cellName '_' fNameSave];
fname = fname1;

%%
correctTimeFirst = 1;
%%
correctTime = 1;
timeDetectLowerThreshold= 0.1;
timeDetectUpperThreshold = 0.3;
timeDetectWavelength = 900e-9;
timeDetectSkipNSeconds = 5;

correctingTimeData = ...
    {correctTime, timeDetectLowerThreshold, timeDetectUpperThreshold,...
    timeDetectWavelength, timeDetectSkipNSeconds};

%%
smoothFFT = 1;
speedValue = [1000 6000]/60;
speedValueTimes = [0 10 1000];
timeRangeFFT = [-15 -5]; %Zeitbereich f�r die FFT (hier soll das Spektrum konstant sein)
wlDetectFFT = 550e-9; % Wellenl�nge, f�r welche die FFT bestimmt wird
speedRangeFFT = [2800 4200]/60; % Bereich der Rotationsgeschwindigkeit, in welcher gesucht wird

smoothingTimeData = ...
    {smoothFFT, speedValue, speedValueTimes, timeRangeFFT, wlDetectFFT, speedRangeFFT};

%%
createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
referenceTimeSector = 2;    % which speed area should be used
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


%% Correct for fname date
fname = fname2;
correctedPath = correctPathForDate(fullfile(basedir, fname));
splitter = regexp(correctedPath,filesep);

% basedir = pathstring(1:splitter(end));
fname = correctedPath(splitter(end)+1:end)
[spectra, time, wl, ~, ~, startTime] = readSpinCoater(fullfile(basedir,fname));  %liest die Spektren ein
spectra = squeeze(spectra); % entfernt eine Dimension
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
trans = (spectra-mean(dark,2))./(mean(ref,2)-mean(dark,2)); % Berechnet die Transmission
%trans = trans(indWlMin:indWlMax, indTimeMin:indTimeMax);
% wl = wl(indWlMin:indWlMax);
% time = time(indTimeMin:indTimeMax);
clearvars spectra;

%% 
if correctTimeFirst
    time = timeCorrection(correctingTimeData, trans, wl, time);
    M = timeSmoothing(smoothingTimeData, trans, wl, time);
else
    M = timeSmoothing(smoothingTimeData, trans, wl, time);
    time = timeCorrection(correctingTimeData, trans, wl, time);
end

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
fNameSave = [fNameSaveStart 'PDINN_begin'];
timePlot = [-0.01:0.005:0, 0.08:0.005:0.3];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName titleNameDescription ' - drop'];
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
timePlot = [0.8:0.005:1.2];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName titleNameDescription ' - Crystalization'];
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
timePlot = [1:0.05:2];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName titleNameDescription ' - after Crys'];
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
timePlot = [2:2:25];
fNameSave = [cellName '_' fNameSave];
titleName = [cellName titleNameDescription ' - long'];
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
titleName = [cellName titleNameDescription ' - drop'];
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