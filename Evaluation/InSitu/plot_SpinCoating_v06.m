%% Changelog
% v06
% - renewed time smoothing and time correction
% - read speed values from comments file
% - correct Time first removed due to new speed evaluation not making any
% sense any more
% v03
%   added time correction

%%
% clc;
close all
% clear all

% figs2keep = [13670 13671 13672 13680 13681 13682];
% all_figs = findobj(0, 'type', 'figure');
% delete(setdiff(all_figs, figs2keep))
%%
MeasCounter = 1;
basedir = 'D:\InSitu\SpinCoating\220926'; % Dateipfad zu ordner
fname = '20220926_151142_TR_Perovskite_SpeedTest_PC41_meas.spin';
% cellName = '';
titleNameStart = 'AntiSolvent_Ethanol';
fNameSaveStartTemp = 'AntiSolvent_Ethanol';
dirNameSave = basedir;
savePic = 0;
wlRange = [420e-9 900e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-50 300]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605 740 790 810 840]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
% wlPlot = [446 509 558 605 650 850]*1e-9;
% wlPlot = [650 660 670 680 690]*1e-9;
cmapTimeColorbar = linspecer(120, 'sequential');


perovskiteSetting = 1;
Y6PM6_PDINN_Setting = 0;
Y6PM6_CB_Setting = 0;
Y6PM6_CF_Setting = 0;
PDINN_Setting = 0;
PEDOT_Setting = 0;

longTime = 0;


% Do not Change this Part!_______________________________
tempPos = regexp(fname,'_');
tempFname = fname(tempPos(2)+1:end);
fname = replaceBetween(fname, tempPos(end-1)+1, tempPos(end)-1, cellName);
titleName = [cellName ' - ' titleNameStart];
fNameSaveStart = fNameSaveStartTemp;
fNameSaveStart = [cellName '_' fNameSaveStart];
% You can Change again.__________________________________




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

timeRangeFFT = [2 5 5]; % Defines area for FFT [TimeAreaStart+x, TimeAreaEnd-y, Length for FFT] 
wlDetectFFT = [450:100:850]*1e-9; %wavelength for fft
speedRangeValueDivider = 6; % 

%%
correctTime = 1;
timeDetectWavelength = 550e-9;
timeDetectLowerThreshold= [0.3];
timeDetectUpperThreshold = [0.9];
timeDetectSkipNSeconds = [speedValueTimes(1)+2];
if perovskiteSetting
    timeDetectLowerThreshold= [0.3 0.1];
    timeDetectUpperThreshold = [0.9 0.6];
    timeDetectSkipNSeconds = [speedValueTimes(1)+2 speedValueTimes(2)+2];
end
if Y6PM6_PDINN_Setting
    timeDetectWavelength = 420e-9;
    timeDetectLowerThreshold= [0.3 0.1];
    timeDetectUpperThreshold = [0.9 0.4];
    timeDetectSkipNSeconds = [speedValueTimes(1)+2 speedValueTimes(2)+2];
end
if Y6PM6_CB_Setting
    timeDetectWavelength = 420e-9;
    timeDetectLowerThreshold= [0.3];
    timeDetectUpperThreshold = [0.9];
    timeDetectSkipNSeconds = [speedValueTimes(1)+2];
end
if PDINN_Setting
    timeDetectWavelength = 420e-9;
    timeDetectLowerThreshold= [0.3];
    timeDetectUpperThreshold = [0.9];
    timeDetectSkipNSeconds = [speedValueTimes(1)+2];
end

timeSmoothOrder = 1;

correctingTimeData = ...
    {correctTime, timeDetectLowerThreshold, timeDetectUpperThreshold,...
    timeDetectWavelength, timeDetectSkipNSeconds};


%%
createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
referenceTimeSector = 1;    % which speed area should be used
referenceTimeBefore = 4.5;    % Time before taking the reference
referenceTime = 4;          % Time for taking reference




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
% clearvars spectra;

%% 
M = timeSmoothing(speedValue, speedValueTimes, trans, time, timeSmoothOrder);
timeStamps = timeCorrection(correctingTimeData, trans, wl, time);
% timeStamps = timeStamps+0.09;

%% Hier wird ein moving average angewendet
R = smoothdata(M,1, 'sgolay', 40);
% R = M;

%%
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes f�rs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));
%%
figure(700+MeasCounter);
set(gcf, 'Name', 'False Color Plot');
imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), trans(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild
c = colorbar(); % F�gt Colorbar ein
caxis([0 1.2]) % Setzt die Grenzen der Colorbar
xlabel('Time in s');
ylabel('Wavelength in nm');
ylabel(c, 'Transmitance');

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

%%
for i = 1:length(timeStamps)
    figure(15000+MeasCounter+i)
    mapSize = get(gcf, 'Position');
    % set(gcf, "Position", [mapSize(1:2) 669 489]);
    imagesc(time(indTimeMin:indTimeMax)-timeStamps(i), wl*1e9, R(:, indTimeMin:indTimeMax));
    h = colorbar();
    caxis([0 1.1]);
    
    xlabel('Time in s');
    ylabel('Wavelength in nm')
    ylabel(h, 'Transmittance')
    title([titleName ' - ' num2str(i) 'Drop'])
    
    fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_map'];
    fNameSave = [cellName '_' fNameSave];
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
end

%%

for i=1:length(timeStamps)
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
        plot(time(indTimeMin:indTimeMax)-timeStamps(i), R(indWL, indTimeMin:indTimeMax), 'Linewidth', 2);
        hold on
    end
    
    figure(13000+MeasCounter+i)
    legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]))
    xlabel('Time in s')
    ylabel('Transmittance')
    title([titleName ' - ' num2str(i) 'Drop'])
    
    fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_wlCut'];
    fNameSave = [cellName '_' fNameSave];
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
      savefig(gcf, fullfile(dirNameSave, fNameSave));
    end
end

%%
% for i=0:length(timeStamps)-1
%     figure(14000+MeasCounter+i)
%     set(gcf, 'Name', 'All Wavelength');
%     for indTimeLower = 1:length(wlPlot)
%     %     figure(800 + indTimeLower);
%         [~,indWL] = min(abs(wl-wlPlot(indTimeLower)));
%     %     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
%     %     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
%     %     xlabel('Time in s')
%     %     ylabel('Transmittance')
%         aa = mean(trans);
%         M2 = timeSmoothing(speedValue, speedValueTimes, aa, time, timeSmoothOrder);
%         bb = smoothdata(M2, 2, 'sgolay', 5000);
%         plot(time(indTimeMin:indTimeMax)-timeStamps(i+1), bb, 'Linewidth', 2);
%         hold on
%         xlim([2 18])
%     end
%     
%     figure(14000+MeasCounter)
%     legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]))
%     xlabel('Time in s')
%     ylabel('Transmittance')
% end
% 
% xlim([2 20])

% xlim([-2 15])
% ylim([0.9 1.1])
%
% figure(19002);
% mm = diff(R,1,2);
% mm = sign(mm).*log(abs(mm));
% mm2 = smoothdata(mm,2,'movmean', movTime);
% imagesc(time(1:end-1), wl*1e9, mm2)
% colormap(createColormap(-10,10))
% % % caxis([-10 10])
% 
% %
% figure(19003);
% tempMax = max(R,[],1);
% tempMin = min(R,[],1);
% 
% Rnorm = (R-tempMin)./(tempMax-tempMin);
% imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), Rnorm(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild

%%
% fNameSave = [fNameSaveStart '_begin'];
% % timePlot = [30];
% timePlot = [0.1:0.1:1];
% fNameSave = [cellName '_' fNameSave];
% figureCounter = 0;
% while ishandle(200000+figureCounter)
%     figureCounter = figureCounter+1;
% end
% figure(200000+figureCounter);
% 
% if length(timePlot) > 1
%     timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);
% else
%     timePlot2 = timePlot;
% end
% 
% cmapLine = linspecer(length(timePlot2), 'sequential');
% for i=1:length(timePlot2)
%     if any(abs(timePlot-timePlot2(i)) < 1e-5)
%         [~,indTimeTemp] = min(abs(time-timeStamps(1)-timePlot2(i)));
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
% fNameSave = [fNameSaveStart '_crystal'];
% timePlot = [26:0.1:27];
% fNameSave = [cellName '_' fNameSave];
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
%         [~,indTimeTemp] = min(abs((time-timeStamps(1))-timePlot2(i)));
%         plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
%         hold on
%     end
% end
% xlim([400 700])
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
% 
%%
% fNameSave = [fNameSaveStart '_inter'];
% timePlot = [12:1:70];
% fNameSave = [cellName '_' fNameSave];
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
%         [~,indTimeTemp] = min(abs(time-timeStamps-timePlot2(i)));
%         plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
%         hold on
%     end
% end
% xlim([400 700])
% ylabel('Transmission')
% xlabel('Wavelength in nm')
% set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
%     'LineWidth', 2);
% ylim([0.5 1])
% 
% % cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
% % cTimePlot.Position = [0.2 0.78 0.4 0.05];
% cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
% caxis([min(timePlot), max(timePlot)])
% colormap(cmapTimeColorbar);
% cTimePlot.LineWidth = 2;
% title(titleName)
% ylabel(cTimePlot, 'Time in s');
% 
% if savePic
%   saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
% end

%%
% fNameSave = [fNameSaveStart '_inter'];
% timePlot = [12:1:70];
% fNameSave = [cellName '_' fNameSave];
% figureCounter = 0;
% while ishandle(210000+figureCounter)
%     figureCounter = figureCounter+1;
% end
% figure(210000+figureCounter);
% 
% timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);
% [~,indTimeTemp] = min(abs(time-timeStamps-min(timePlot2)));
% refSpec = R(:,indTimeTemp);
% cmapLine = linspecer(length(timePlot2)-1, 'sequential');
% for i=2:length(timePlot2)
%     if any(abs(timePlot-timePlot2(i)) < 1e-5)
%         [~,indTimeTemp] = min(abs(time-timeStamps-timePlot2(i)));
%         plot(wl*1e9, (R(:, indTimeTemp)-refSpec)./refSpec, 'Color', cmapLine(i-1,:), 'LineWidth', 2)
%         hold on
%     end
% end
% xlim([400 700])
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
% title(cellName)
% 
% if savePic
%   saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
% end
%%
% fNameSave = [fNameSaveStart '_long'];
% timePlot = [60:1:75];
% fNameSave = [cellName '_' fNameSave];
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
%         [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps));
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


%%
% figure(12000)
% [~,indAAA] = min(abs(time-60));
% plot(wl*1e9, R(:, indAAA))
% hold on


%% Grosser Abstand fuer schnelle Scrollen













































%%__________________________________________________________________________

%% Y6PM6 Plus PDINN_______________________________________________________________
for codeFolding = 1
    if Y6PM6_PDINN_Setting
    %% Y6PM6
    titleName = ['Y6:PM6 ' titleNameStart];
    fNameSaveStart = ['Y6PM6_' fNameSaveStartTemp];
    titleName = [cellName ' - ' titleName];
    %%
    timePlot = [-0.01:0.005:0, 0.11:0.005:0.3];
    timePlot = [0.1:0.005:0.3];
    titleNameAdjustment = ' - begin';
    fNameSave = [fNameSaveStart '_begin'];
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
    xlim([400 900])
    ylim([0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    timePlot = [0.3:mean(diff(time)):0.6];
    titleNameAdjustment = ' - crystalClose';
    fNameSave = [fNameSaveStart '_crystalClose'];
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
    xlim([400 900])
    ylim([0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    timePlot = [0.3:0.05:1.2];
    titleNameAdjustment = ' - overall';
    fNameSave = [fNameSaveStart '_overall'];
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
    xlim([400 900])
    ylim([0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    %%
    timePlot = [2:1:30];
    titleNameAdjustment = ' - afterCrystal';
    fNameSave = [fNameSaveStart '_afterCrystal'];
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
    xlim([400 900])
    ylim([0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    %%
    
    %%  WL Cut
    i = 1;
    titleNameAdjustment = '';
    fNameSave = [fNameSaveStart ''];
    fNameSave = [cellName '_' fNameSave];
    figure(13000+MeasCounter+i)
    legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]), 'Location', 'best')
    xlabel('Time in s')
    ylabel('Transmittance')
    title([titleName ' - ' num2str(i) 'Drop'])
    
    fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_wlCut'];
    fNameSave = [cellName '_' fNameSave];
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'fig');
    end

    %% Map
    figure(15000+MeasCounter+i)
%         caxis([0.9 1.2]);
    
    xlabel('Time in s');
    ylabel('Wavelength in nm')
    ylabel(h, 'Transmittance')
    title([titleName ' - ' num2str(i) 'Drop'])
    
    fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_map'];
    fNameSave = [cellName '_' fNameSave];
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end

    
    
    
    %%PDINN__________________________________________________________________
    titleName = ['PDINN  ' titleNameStart];
    fNameSaveStart = ['PDINN_' fNameSaveStartTemp];
    titleName = [cellName ' - ' titleName];
    %%
    timePlot = [-1:0.1:-0.1, 0.2:0.05:0.3];
    titleNameAdjustment = ' - begin';
    fNameSave = [fNameSaveStart '_begin'];
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
    xlim([400 900])
    ylim([0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    timePlot = [0.85:0.01:1];
    titleNameAdjustment = ' - Crystal';
    fNameSave = [fNameSaveStart '_crystal'];
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
    xlim([400 900])
    ylim([0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    
    %%
    % fNameSave = [fNameSaveStart '_inter'];
    % timePlot = [0.5:0.05:0.9];
    % fNameSave = [cellName '_' fNameSave];
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
    %         [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(2)));
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
    % title([titleName titleNameAdjustment])
    % 
    % if savePic
    %   saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    % end
    
    
    %%
    timePlot = [-2, -1, 3 4];
    titleNameAdjustment = ' - DropJump';
    fNameSave = [fNameSaveStart '_jump'];
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
    xlim([400 900])
    ylim([0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    timePlot = [2:2:30];
    titleNameAdjustment = ' - after Crystal';
    fNameSave = [fNameSaveStart '_afterCrystal'];
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
    xlim([400 900])
    ylim([0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end

    %%  WL Cut
    i = 2;
    titleNameAdjustment = '';
    fNameSave = [fNameSaveStart ''];
    fNameSave = [cellName '_' fNameSave];
    figure(13000+MeasCounter+i)
    legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]), 'Location', 'best')
    xlabel('Time in s')
    ylabel('Transmittance')
    title([titleName ' - ' num2str(i) 'Drop'])
    
    fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_wlCut'];
    fNameSave = [cellName '_' fNameSave];
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'fig');
    end

    %% Map
    figure(15000+MeasCounter+i)
%         caxis([0.9 1.2]);
    
    xlabel('Time in s');
    ylabel('Wavelength in nm')
    ylabel(h, 'Transmittance')
    title([titleName ' - ' num2str(i) 'Drop'])
    
    fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_map'];
    fNameSave = [cellName '_' fNameSave];
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    end
end


%% Y6PM6 CF
for codeFolding = 1
    if Y6PM6_CF_Setting
    %% Y6PM6
    titleName = ['Y6:PM6 ' titleNameStart];
    fNameSaveStart = ['Y6PM6_' fNameSaveStartTemp];
    titleName = [cellName ' - ' titleName];
    %%
    timePlot = [-0.01:0.005:0, 0.11:0.005:0.3];
    timePlot = [0.1:0.005:0.3];
    titleNameAdjustment = ' - begin';
    fNameSave = [fNameSaveStart '_begin'];
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
    xlim([400 900])
    ylim([0.1 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    timePlot = [0.3:0.007:0.36];
    titleNameAdjustment = ' - crystalClose';
    fNameSave = [fNameSaveStart '_crystalClose'];
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
    xlim([400 900])
    ylim([0.0 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    timePlot = [0.3:0.05:1.2];
    titleNameAdjustment = ' - overall';
    fNameSave = [fNameSaveStart '_overall'];
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
    xlim([400 900])
    ylim([0.1 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end

    %%
    timePlot = [2:1:28];
    titleNameAdjustment = ' - afterCrystal';
    fNameSave = [fNameSaveStart '_afterCrystal'];
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
    xlim([400 900])
    ylim([0.1 1])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
%     %%
%     timePlot = [0.05:0.01:0.6];
%     titleNameAdjustment = ' - begin2End';
%     fNameSave = [fNameSaveStart '_begin2End'];
%     fNameSave = [cellName '_' fNameSave];
%     figureCounter = 0;
%     while ishandle(200000+figureCounter)
%         figureCounter = figureCounter+1;
%     end
%     figure(200000+figureCounter);
%     
%     timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);
%     
%     cmapLine = linspecer(length(timePlot2), 'sequential');
%     for i=1:length(timePlot2)
%         if any(abs(timePlot-timePlot2(i)) < 1e-5)
%             [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(1)));
%             plot(wl*1e9, M(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
%             hold on
%         end
%     end
%     xlim([400 900])
%     ylim([0.0 1])
%     ylabel('Transmission')
%     xlabel('Wavelength in nm')
%     set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
%         'LineWidth', 2);
%     
%     % cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
%     % cTimePlot.Position = [0.2 0.78 0.4 0.05];
%     cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
%     caxis([min(timePlot), max(timePlot)])
%     colormap(cmapTimeColorbar)
%     cTimePlot.LineWidth = 2;
%     cTimePlot.Label.String = ('Time in s');
%     cTimePlot.Label.FontSize = 12;
%     title([titleName titleNameAdjustment])
%     
%     if savePic
%       saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
%     end

    %%  WL Cut
        i = 1;
        titleNameAdjustment = '';
        fNameSave = [fNameSaveStart ''];
        fNameSave = [cellName '_' fNameSave];
        figure(13000+MeasCounter+i)
        legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]), 'Location', 'best')
        xlabel('Time in s')
        ylabel('Transmittance')
        title([titleName ' - ' num2str(i) 'Drop'])
        
        fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_wlCut'];
        fNameSave = [cellName '_' fNameSave];
        
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'fig');
        end

        %% Map
        figure(15000+MeasCounter+i)
%         caxis([0.9 1.2]);
        
        xlabel('Time in s');
        ylabel('Wavelength in nm')
        ylabel(h, 'Transmittance')
        title([titleName ' - ' num2str(i) 'Drop'])
        
        fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_map'];
        fNameSave = [cellName '_' fNameSave];
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        end

    end
end



%% Y6PM6 CB
for codeFolding = 1
    if Y6PM6_CB_Setting
    %% Y6PM6
    titleName = ['Y6:PM6 ' titleNameStart];
    fNameSaveStart = ['Y6PM6_' fNameSaveStartTemp];
    titleName = [cellName ' - ' titleName];
    %%
    timePlot = [-0.01:0.005:0, 0.11:0.005:0.3];
    timePlot = [0.1:0.05:0.3];
    titleNameAdjustment = ' - begin';
    fNameSave = [fNameSaveStart '_begin'];
    fNameSave = [cellName '_' fNameSave];
    figureCounter = 0;
    while ishandle(200000+figureCounter)
        figureCounter = figureCounter+1;
    end
    figure(200000+figureCounter);
    
    timePlot2 = min(timePlot):min(diff(timePlot)):max(timePlot);
%     timePlot2 = flip(timePlot2);
    
    cmapLine = linspecer(length(timePlot2), 'sequential');
    for i=1:length(timePlot2)
        if any(abs(timePlot-timePlot2(i)) < 1e-5)
            [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps(1)));
            plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
            hold on
        end
    end
    xlim([400 900])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    timePlot = [7:0.5:12];
    titleNameAdjustment = ' - crystalClose';
    fNameSave = [fNameSaveStart '_crystalClose'];
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
    xlim([400 900])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    timePlot = [2:1:12];
    titleNameAdjustment = ' - overall';
    fNameSave = [fNameSaveStart '_overall'];
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
    xlim([400 900])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    %%
    timePlot = [16:1:24];
    titleNameAdjustment = ' - afterCrystal';
    fNameSave = [fNameSaveStart '_afterCrystal'];
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
    xlim([400 900])
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
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    

    %%  WL Cut
        i = 1;
        titleNameAdjustment = '';
        fNameSave = [fNameSaveStart ''];
        fNameSave = [cellName '_' fNameSave];
        figure(13000+MeasCounter+i)
        legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]), 'Location', 'best')
        xlabel('Time in s')
        ylabel('Transmittance')
        title([titleName ' - ' num2str(i) 'Drop'])
        
        fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_wlCut'];
        fNameSave = [cellName '_' fNameSave];
        
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'fig');
        end

        %% Map
        figure(15000+MeasCounter+i)
%         caxis([0.9 1.2]);
        
        xlabel('Time in s');
        ylabel('Wavelength in nm')
        ylabel(h, 'Transmittance')
        title([titleName ' - ' num2str(i) 'Drop'])
        
        fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_map'];
        fNameSave = [cellName '_' fNameSave];
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        end

    end 
end


%% PDINN Alone
for codeFolding = 1
    if PDINN_Setting
        titleName = ['PDINN ' titleNameStart];
        fNameSaveStart = ['PDINN_' fNameSaveStartTemp];
        titleName = [cellName ' - ' titleName];
        %%
        timePlot = [0.2:0.05:0.5];
        titleNameAdjustment = ' - begin';
        fNameSave = [fNameSaveStart '_begin'];
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
                [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps));
                plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
                hold on
            end
        end
        xlim([400 900])
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
        title([titleName titleNameAdjustment])
        
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        end
        
        %%
        timePlot = [0.85:0.01:1.2];
        titleNameAdjustment = ' - Crystal';
        fNameSave = [fNameSaveStart '_crystal'];
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
                [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps));
                plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
                hold on
            end
        end
        xlim([400 900])
%         ylim([0.8 1.2])
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
        title([titleName titleNameAdjustment])
        
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        end    

        %%
        timePlot = [1.5:1:30];
        titleNameAdjustment = ' - after';
        fNameSave = [fNameSaveStart '_after'];
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
                [~,indTimeTemp] = min(abs(time-timePlot2(i)-timeStamps));
                plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
                hold on
            end
        end
        xlim([400 900])
%         ylim([0.8 1.2])
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
        title([titleName titleNameAdjustment])
        
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        end

        %%  WL Cut
        i = 1;
        titleNameAdjustment = '';
        fNameSave = [fNameSaveStart ''];
        fNameSave = [cellName '_' fNameSave];
        figure(13000+MeasCounter+i)
        legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]), 'Location', 'best')
        xlabel('Time in s')
        ylabel('Transmittance')
        title([titleName ' - ' num2str(i) 'Drop'])
        
        fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_wlCut'];
        fNameSave = [cellName '_' fNameSave];
        
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'fig');
        end

        %% Map
        figure(15000+MeasCounter+i)
%         caxis([0.9 1.2]);
        
        xlabel('Time in s');
        ylabel('Wavelength in nm')
        ylabel(h, 'Transmittance')
        title([titleName ' - ' num2str(i) 'Drop'])
        
        fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_map'];
        fNameSave = [cellName '_' fNameSave];
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        end
   
    end
end


%% PEROVSKITE______________________________________________________________
for codeFolding = 1
    if perovskiteSetting
   %% Thickness
    
    wlTemp = wl*1e9;
    n_DMF = 1.4764-6.2707e4./wlTemp.^2 + 1.3755e10./wlTemp.^4;
    n_DMSO = sqrt(1+0.04419*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.046390067309) + 1.09101*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.01221543949));
    n_Ethanol = sqrt(1+0.0165*(wlTemp/1000).^2./((wlTemp/1000).^2 - 9.08) + 0.8268*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.01039));
    n_nitrobenzene = sqrt(1+1.30628*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.02268) + 0.00502*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.18487));
    
    n = (4*n_DMF + n_DMSO)/5;
    % n = n_Ethanol;
    % n = n_nitrobenzene;
    
    
    cropWl = [450 700];
    [~,indCropMin] = min(abs(wlTemp - min(cropWl)));
    [~,indCropMax] = min(abs(wlTemp - max(cropWl)));
    
%     wl2 = wlTemp(indCropMin:indCropMax);
%     
%     
%     timeRangeDetectionThickness = (speedValueTimes(2)-8):0.05:(timeStamps(2)-1);
%     thicknessDetection = NaN(size(timeRangeDetectionThickness));
%     counter = 1;
%     for ttt = timeRangeDetectionThickness
% %         disp(ttt)
%         [~,indTimeTemp] = min(abs(time-ttt));
%         bbb3 = smoothdata(R(indCropMin:indCropMax, indTimeTemp), 1, 'sgolay', 60);
% %         bbb = (aaa-0.9)./0.01;
% %         bbb2 = smoothdata(bbb, 1, 'sgolay', 60);
% %     %     bbb2 = bbb;
% %         bbb3 = bbb2(indCropMin:indCropMax);
%         [~,lambdaList, ~, p] = findpeaks(bbb3, wl2, 'MinPeakDistance', 0);
%     %     [~, lambdaList] = findpeaks(bbb3, wl2*1e9, 'NPeaks', numberPeaks, 'MinPeakDistance', 8, 'Threshold', 0.3);
% 
%         divisor = 8;
% %         disp(nnz(p<max(p)/divisor))
%         while (nnz(p>max(p)/divisor) < 2)
%             divisor = divisor+1;
% %             disp(nnz(p<max(p)/divisor))
%         end
%         lambdaList(p < max(p)/divisor) = [];
%         p(p < max(p)/divisor) = [];
%     
%         [p, pIndex] = sort(p, 'descend');
%         lambdaList = lambdaList(pIndex);
%     %     p = ones(size(lambdaList));
%     
%         if length(lambdaList) > 8
%             lambdaList = lambdaList(1:8);
%         end
%     % 
%         for iii = 1:length(lambdaList)
%             [~,indTempWL] = min(abs(wl2-lambdaList(iii)));
%             lambdaList(iii) = lambdaList(iii)./n(indTempWL);
%         end
%         if (~isempty(lambdaList))
%             thicknessDetection(counter) = thicknessCalculationV3(lambdaList, p);
%         end
%         counter = counter+1;
%     end
%     
%     median(thicknessDetection(end-5:end))

    freq = flip(299792458./(wl(indCropMin:indCropMax)./n(indCropMin:indCropMax)));
    
%     timeRangeDetectionThickness = (speedValueTimes(2)-8):0.05:(timeStamps(2)-1);
    timeRangeDetectionThickness = timeStamps(1)+1:0.05:(timeStamps(2)-1);
    thicknessDetection = NaN(size(timeRangeDetectionThickness));
    counter = 1;
    
    for ttt = timeRangeDetectionThickness
        [~,indTimeTemp] = min(abs(time-ttt));
        aaa = flip(R(indCropMin:indCropMax, indTimeTemp));
        [~,freqList, ~, p] = findpeaks(aaa, freq);
        freqList(p<max(p)/8) = [];
        p(p<max(p)/8) = [];
    
        thicknessDetection(counter) =  299792458./median(diff(freqList))/2*1e9;
        counter = counter+1;
    end
    
    
%     disp(thicknessDetection(end))
    figure(224+MeasCounter)
    ax1 = axes;
    plot(timeRangeDetectionThickness-timeStamps(1), thicknessDetection, 'o')
    ax1.XLabel.String = 'Time after Precursor Drop';
    % ax2 = axes;
    % plot(timeRangeDetectionThickness-timeStamps(2), thicknessDetection, 'o')
    
    % ax2.XAxisLocation = 'top';
    ylabel('Thickness in nm');
    ax1.XLabel.String = 'Time after precursor drop in s';
    set(ax1, 'FontSize', 12, 'LabelFontSizeMultiplier', 1)
    posBottom = get(gca, 'Position');
    ax1.XAxisLocation = 'top';
    posTop = get(gca, 'Position');
    ax1.XAxisLocation = 'bottom';
    tempPosition = [posBottom(1) posBottom(2) posBottom(3) posTop(4)+posTop(2)-posBottom(2)];
    ax1.Position = tempPosition;
    
    ax1.XLim = [ax1.XLim(1) timeStamps(2)-timeStamps(1)];
    set(gca, 'LineWidth', 2)
    box off
    
    ax2=axes('Position',ax1.Position, ...
              'XAxisLocation','top', ...
              'YAxisLocation','right', ...
              'Color','none', ...
              'YTickLabel',[]);
    % plot(timeRangeDetectionThickness-timeStamps(2), thicknessDetection, 'o')
    set(ax2, 'FontSize', 12, 'LabelFontSizeMultiplier', 1)
    ax2.XLim = ax1.XLim -(timeStamps(2)-timeStamps(1));
    ax2.YLim = ax1.YLim;
    ax2.YTick = ax1.YTick;
    set(gca, 'LineWidth', 2)
    ax2.XLabel.String = 'Time before antisovlent drop in s';
    annotation('textbox', 'Position', [0.7 0.7 0.1 0.1], 'String', cellName, 'FitBoxToText', 'on', 'FontSize', 12, 'FontWeight', 'bold')
    
    
    fNameSave = [fNameSaveStart '_FilmThickness'];
    fNameSave = [cellName '_' fNameSave];
    
    if savePic
        saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        savefig(gcf, fullfile(dirNameSave, fNameSave));
    end

%     figure(220)
%     plot(timeRangeDetectionThickness-timeStamps(1), thicknessDetection, 'o')
%     hold on

    %%
    fNameSave = [fNameSaveStart '_Antisolvent_Crystal'];
    timePlot = [1:0.1:2.2,  2.22:0.02:3];
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
            [~,indTimeTemp] = min(abs(time-timeStamps(2)-timePlot2(i)));
            plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
            hold on
        end
    end
    xlim([400 900])
    ylabel('Transmission')
    xlabel('Wavelength in nm')
    set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
        'LineWidth', 2);
    ylim([0 1])
    
    % cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
    % cTimePlot.Position = [0.2 0.78 0.4 0.05];
    cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
    caxis([min(timePlot), max(timePlot)])
    colormap(cmapTimeColorbar);
    cTimePlot.LineWidth = 2;
    title([titleName ' after Antisolvent'])
    ylabel(cTimePlot, 'Time in s');
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    %%
    fNameSave = [fNameSaveStart '_AfterCrystal'];
    timePlot = [3:1:floor(max(time)-timeStamps(2))];
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
            [~,indTimeTemp] = min(abs(time-timeStamps(2)-timePlot2(i)));
            plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
            hold on
        end
    end
    xlim([400 900])
    ylabel('Transmission')
    xlabel('Wavelength in nm')
    set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
        'LineWidth', 2);
    ylim([0 1])
    
    % cTimePlot = colorbar('Location', 'north', 'AxisLocation', 'out');
    % cTimePlot.Position = [0.2 0.78 0.4 0.05];
    cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
    caxis([min(timePlot), max(timePlot)])
    colormap(cmapTimeColorbar);
    cTimePlot.LineWidth = 2;
    title([titleName ' after Antisolvent'])
    ylabel(cTimePlot, 'Time in s');
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
    
    
    
    
    end
end


%% PEDOT___________________________________________________________________
for codeFolding = 1
    if PEDOT_Setting
    %% Y6PM6
    titleName = ['Pedot ' titleNameStart];
    fNameSaveStart = ['Pedot_' fNameSaveStartTemp];
    titleName = [cellName ' - ' titleName];

        %% Thickness
    
    wlTemp = wl*1e9;
    n_DMF = 1.4764-6.2707e4./wlTemp.^2 + 1.3755e10./wlTemp.^4;
    n_DMSO = sqrt(1+0.04419*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.046390067309) + 1.09101*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.01221543949));
    n_Ethanol = sqrt(1+0.0165*(wlTemp/1000).^2./((wlTemp/1000).^2 - 9.08) + 0.8268*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.01039));
    n_nitrobenzene = sqrt(1+1.30628*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.02268) + 0.00502*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.18487));
    n_Water_21 = sqrt(1 + 5.689093832e-1*(wlTemp/1000).^2./((wlTemp/1000).^2 - 5.110301794e-3) + ...
        1.719708856e-1*(wlTemp/1000).^2./((wlTemp/1000).^2 - 1.825180155e-2) + ...
        2.062501582e-2*(wlTemp/1000).^2./((wlTemp/1000).^2 - 2.624158904e-2) + ...
        1.123965424e-1*(wlTemp/1000).^2./((wlTemp/1000).^2 - 1.067505178e1) );

    n = n_Water_21;
    
    
    cropWl = [450 850];
    [~,indCropMin] = min(abs(wlTemp - min(cropWl)));
    [~,indCropMax] = min(abs(wlTemp - max(cropWl)));
%     wlTemp = wlTemp./n;
    wl2 = wlTemp(indCropMin:indCropMax);
%     freq2 = 299792458./wl2*1e-14;
    
    
    timeRangeDetectionThickness = (timeStamps(1)+2):0.05:(time(end)-3);
    thicknessDetection = NaN(size(timeRangeDetectionThickness));
    counter = 1;

%     for ttt = timeRangeDetectionThickness
%         disp(ttt)
%         [~,indTimeTemp] = min(abs(time-ttt));
%         aaa = R(indCropMin:indCropMax, indTimeTemp);        
% 
% 
%         [f1, p1] = plotNFFT(freq2, aaa, 1,1, 'plot', 'off');
%         [~,i1] = max(p1);
%         ab = diff(aaa);
%         [~, i2] = min(abs(ab));
%         f = fit(freq2, aaa, 'sin1', 'StartPoint', [0.1 2*pi*f1(i1) freq2(i2)]);
%         thicknessDetection(counter) = 299792458./(2*1e14*(2*pi./f.b1));
%         counter = counter+1;
% 
% %         [~, ii1] = max(p1);
% %         thicknessDetection(counter) = 299792458./(2*ff1(ii1)*1e14)*1e9;
% %         counter = counter+1;
%     end
        
    for ttt = timeRangeDetectionThickness
    %     disp(ttt)
        [~,indTimeTemp] = min(abs(time-ttt));
        aaa = R(:, indTimeTemp);
        bbb = (aaa-0.9)./0.01;
        bbb2 = smoothdata(bbb, 1, 'sgolay', 60);
    %     bbb2 = bbb;
        bbb3 = bbb2(indCropMin:indCropMax);
        [~,lambdaList, ~, p] = findpeaks(bbb3, wl2, 'MinPeakDistance', 8);
    %     [~, lambdaList] = findpeaks(bbb3, wl2*1e9, 'NPeaks', numberPeaks, 'MinPeakDistance', 8, 'Threshold', 0.3);
%         lambdaList(p < 1) = [];
%         p(p < 1) = [];

        lambdaList(p < max(p)/8) = [];
        p(p < max(p)/8) = [];
    
        [p, pIndex] = sort(p, 'descend');
        lambdaList = lambdaList(pIndex);
    %     p = ones(size(lambdaList));
    
        if length(lambdaList) > 8
            lambdaList = lambdaList(1:8);
        end
    % 
        for iii = 1:length(lambdaList)
            [~,indTempWL] = min(abs(wl2-lambdaList(iii)));
            lambdaList(iii) = lambdaList(iii)./n(indTempWL);
        end
        if length(lambdaList) > 1
            thicknessDetection(counter) = thicknessCalculationV3(lambdaList, p);
        end
        counter = counter+1;
    end
    
    median(thicknessDetection(end-5:end))
    
    
    figure(224)
    ax1 = axes;
    plot(timeRangeDetectionThickness-timeStamps(1), thicknessDetection, 'o')
    ylim([0 4000])
    
    ylabel('Thickness in nm');
    xlabel('Time after Drop');
    set(ax1, 'FontSize', 12, 'LabelFontSizeMultiplier', 1)
    
    set(gca, 'LineWidth', 2)
    
    annotation('textbox', 'Position', [0.3 0.7 0.1 0.1], 'String', cellName, 'FitBoxToText', 'on', 'FontSize', 12, 'FontWeight', 'bold')
    
    
    fNameSave = [fNameSaveStart '_FilmThickness'];
    fNameSave = [cellName '_' fNameSave];
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end

%%
        timePlot = [25:0.1:30];
        titleNameAdjustment = ' - end';
        fNameSave = [fNameSaveStart '_end'];
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
                [~,indTimeTemp] = min(abs((time-timeStamps(1))-timePlot2(i)));
                plot(wl*1e9, R(:, indTimeTemp), 'Color', cmapLine(i,:), 'LineWidth', 2)
                hold on
            end
        end
        xlim([400 900])
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

       
        %%  WL Cut
        i = 1;
        titleNameAdjustment = '';
        fNameSave = [fNameSaveStart ''];
        fNameSave = [cellName '_' fNameSave];
        figure(13000+MeasCounter+i)
        legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]), 'Location', 'best')
        xlabel('Time in s')
        ylabel('Transmittance')
        title([titleName ' - ' num2str(i) 'Drop'])
        
        fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_wlCut'];
        fNameSave = [cellName '_' fNameSave];
        
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        end

        %% MaP
        figure(15000+MeasCounter+i)
        caxis([0.9 1.2]);
        
        xlabel('Time in s');
        ylabel('Wavelength in nm')
        ylabel(h, 'Transmittance')
        title([titleName ' - ' num2str(i) 'Drop'])
        
        fNameSave = [fNameSaveStart '_' num2str(i) 'Drop' '_map'];
        fNameSave = [cellName '_' fNameSave];
        if savePic
          saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
        end
    end

end



%% LongTime
%%
for codeFolding = 1
if (longTime)
    tempPos = regexp(fname,'_');
    d = dir(basedir);
    T = struct2table(d);
    T = sortrows(T, 'date');
    d = table2struct(T);
    clearvars T
    
    
    fList = cell(0);
    for i=1:length(d)
        if ~isempty(regexp(d(i).name, fname(1:tempPos(end-1))))
            if ~isempty(regexp(d(i).name, '.spectra'))
                fList{end+1} = d(i).name;
            end
        end
    end
    
    
    specAfter = [];
    for i=1:length(fList)
        disp([num2str(i) ' from ' num2str(length(fList))])
        [s,w] = ReadSpectraSpinCoating(fullfile(basedir, fList{i}));
        s = squeeze(s);
        s = mean(s,2);
        [~,indW1] = min(abs(w-wl(1)));
        [~,indW2] = min(abs(w-wl(end)));
        specAfter(i,:) = s(indW1:indW2);   
    end
    
    transAfter = (specAfter'-mean(dark,2))./(mean(ref,2)-mean(dark,2));
    transAfter = smoothdata(transAfter, 1, 'sgolay', 40);
    
    %%
    fname_settings = [fname(1:end-9) 'comments.txt'];
    
    settingsFileID = fopen(fullfile(basedir, fname_settings));
    lineTemp = fgetl(settingsFileID);
    while isempty(regexp(lineTemp, 'Periodic Time:', 'once'))
        lineTemp = fgetl(settingsFileID);
    end
    fclose(settingsFileID);
    lineTemp = lineTemp(16:end-1);
    
    timeDifferenceAfter = str2double(lineTemp);
    
    %%
    titleNameAdjustment = ' - Long Investigation';
    fNameSave = [fNameSaveStart '_afterLong'];
    fNameSave = [cellName '_' fNameSave];
    figureCounter = 0;
    cmapLine = linspecer(size(transAfter,2), 'sequential');

    while ishandle(200000+figureCounter)
        figureCounter = figureCounter+1;
    end
    figure(200000+figureCounter);

    for i=1:size(transAfter,2)
        plot(wl*1e9, transAfter(:,i), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
    xlim([400 900])
    ylim([0.1 1])
    ylabel('Transmission')
    xlabel('Wavelength in nm')
    set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
        'LineWidth', 2);
    cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
    caxis([timeDifferenceAfter, timeDifferenceAfter*size(transAfter,2)]/60);
    colormap(cmapTimeColorbar)
    cTimePlot.LineWidth = 2;
    cTimePlot.Label.String = ('Time in min');
    cTimePlot.Label.FontSize = 12;
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end

    %%
    titleNameAdjustment = ' - Long Investigation 5min';
    fNameSave = [fNameSaveStart '_afterLong_5min'];
    fNameSave = [cellName '_' fNameSave];
    figureCounter = 0;
    FiveMinValue = ceil(300/timeDifferenceAfter);
    cmapLine = linspecer(FiveMinValue, 'sequential');

    while ishandle(200000+figureCounter)
        figureCounter = figureCounter+1;
    end
    figure(200000+figureCounter);

    for i=1:FiveMinValue
        plot(wl*1e9, transAfter(:,i), 'Color', cmapLine(i,:), 'LineWidth', 2)
        hold on
    end
    xlim([400 900])
    ylim([0.1 1])
    ylabel('Transmission')
    xlabel('Wavelength in nm')
    set(gca, 'FontSize', 12, 'LabelFontSizeMultiplier', 1, 'Layer', 'top', ...
        'LineWidth', 2);
    cTimePlot = colorbar('Location', 'eastoutside', 'AxisLocation', 'out');
    caxis([timeDifferenceAfter, timeDifferenceAfter*FiveMinValue]/60);
    colormap(cmapTimeColorbar)
    cTimePlot.LineWidth = 2;
    cTimePlot.Label.String = ('Time in min');
    cTimePlot.Label.FontSize = 12;
    title([titleName titleNameAdjustment])
    
    if savePic
      saveas(gcf, fullfile(dirNameSave, fNameSave), 'png');
    end
end
end


%% EOF