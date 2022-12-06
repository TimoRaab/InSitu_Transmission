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
% close all 
if ishandle(800)
    clf(800) 
end
if ishandle(15000) 
    clf(15000)
end
if ishandle(13000) 
    clf(13000) 
end
% clear all

%%
MeasCounter = 0;
basedir = 'C:\Measurements\Measurements\InSitu\SpinCoating\220809'; % Dateipfad zu ordner
fname = '20220809_104229_TR_CB_Drying_A01_meas.spin';
% cellName = 'B01';
titleName = 'Y6PM6 1% CN';
fNameSaveStart = 'Y6PM6';
dirNameSave = 'E:\Eval\InSitu\211209';
savePic = 0;
wlRange = [420e-9 900e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-50 300]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
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
correctTime = 0;
timeDetectWavelength = 550e-9;
timeDetectLowerThreshold= [0.3];
timeDetectUpperThreshold = [0.9];
timeDetectSkipNSeconds = [speedValueTimes(1)+3];
timeSmoothOrder = 1;

correctingTimeData = ...
    {correctTime, timeDetectLowerThreshold, timeDetectUpperThreshold,...
    timeDetectWavelength, timeDetectSkipNSeconds};


%%
createReferenceSpectrum = 1;% 1 create own reference, 0 use prerecoded spectrum
referenceTimeSector = 1;    % which speed area should be used
referenceTimeBefore = 3;    % Time before taking the reference
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

if (refMax < 2^16-1 && spectraMax < 2^16-1)
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

figure(2000)
plot(wl*1e9, mean(ref, 2))
hold on

%%
trans = (spectra-mean(dark,2))./(mean(ref,2)-mean(dark,2)); % Berechnet die Transmission
%trans = trans(indWlMin:indWlMax, indTimeMin:indTimeMax);
% wl = wl(indWlMin:indWlMax);
% time = time(indTimeMin:indTimeMax);
clearvars spectra;

%% 
M = timeSmoothing(speedValue, speedValueTimes, trans, time, timeSmoothOrder);
timeStamps = timeCorrection(correctingTimeData, trans, wl, time);

%%
[~,indWlMin] = min(abs(wl-min(wlRange))); % findet die Indizes f�rs plotten
[~,indWlMax] = min(abs(wl-max(wlRange)));
[~,indTimeMin] = min(abs(time-min(timeRange))); 
[~,indTimeMax] = min(abs(time-max(timeRange)));
%%
% figure(700+MeasCounter);
% set(gcf, 'Name', 'False Color Plot');
% imagesc(time(indTimeMin:indTimeMax)-timeStamps, wl(indWlMin:indWlMax), trans(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild
% c = colorbar(); % F�gt Colorbar ein
% caxis([0 1.2]) % Setzt die Grenzen der Colorbar
% xlabel('Time in s');
% ylabel('Wavelength in nm');
% ylabel(c, 'Transmitance');
% caxis([0.93 1.08])

%%
% figure(800+MeasCounter)
% set(gcf, 'Name', 'All Wavelength');
% for indTimeLower = 1:length(wlPlot)
% %     figure(800 + indTimeLower);
%     [~,indWL] = min(abs(wl-wlPlot(indTimeLower)));
% %     set(gcf, 'Name', ['Wavelength' num2str(wl(indWL))]);
% %     plot(time(indTimeMin:indTimeMax), trans(indWL, indTimeMin:indTimeMax));
% %     xlabel('Time in s')
% %     ylabel('Transmittance')
%     figure(800+MeasCounter)
%     plot(time(indTimeMin:indTimeMax)-timeStamps, trans(indWL, indTimeMin:indTimeMax));
%     hold on
% end
% 
% figure(800+ MeasCounter)
% legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]))
% xlabel('Time in s')
% ylabel('Transmittance')

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
% figure(15000+MeasCounter)
% imagesc(time(indTimeMin:indTimeMax)-timeStamps(1), wl*1e9, R(:, indTimeMin:indTimeMax));
% h = colorbar();
% caxis([0 1.1]);
% xlabel('Time in s');
% ylabel('Wavelength in nm')
% ylabel(h, 'Transmittance')

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
% ss = mean(R);
% [~,indTimeEnd] = min(abs(time - (time(end)-5)));
% for kk=indTimeEnd:-1:1
%     if abs(ss(kk)-1) > 0.05
%         break;
%     end
% end
% 
% [~,ii1] = min(abs(time-(time(kk)+10)));
% [~,ii2] = min(abs(time-(time(kk)+12)));
% 
% for kk=ii1:-1:1
%     if (abs(ss(kk)-mean(ss(ii1:ii2))) > 0.003)
%         break
%     end
% end
% 
% disp(time(kk) - timeStamps(1))
% 
% figure(13000)
% plot(repmat(time(kk) - timeStamps(1), 2,1), get(gca, 'Ylim'), 'k')
% ylim([0.8 1.2])
% a(1,end+1) = time(kk)-timeStamps(1);


%%
% tt = diff(R, 2);
% [~,~,f, ~, ~, Y] = plotFFT(time, sum(abs(tt),1), 1, 1, 'Plot', 'off');
% [~,ii1] = min(abs(f-0.5));
% [~,ii2] = min(abs(f+0.5));
% Y = fftshift(Y);
% Y([1:ii2, ii1:end]) = 0;
% Y = ifftshift(Y);
% sss = ifft(Y);
% sss = (sss- mean(sss(indTimeRefStart:indTimeRefStop)));
% sss = sss./max(sss);
% 
% figure(2222)
% plot(time(1:end-1)-timeStamps, sss)
% 
% [~, indSpeedStart] = min(abs(time-(timeStamps+1)));
% for kk2 = indSpeedStart:1:length(time)
%     if sss(kk2) < 0.1
%         break
%     end
% end
% 
% disp(time(kk2) - timeStamps(1))
% 
% figure(2222)
% plot(time(1:end-1), sss./max(sss))
% 
% figure(13000)
% plot(repmat(time(kk2) - timeStamps(1), 2,1), get(gca, 'Ylim'), 'k')

%%
% tt = diff(R, 2);
% tt2 = sum(abs(tt), 1);
% tt2 = smoothdata(tt2, 2, 'movmedian', 100);
% [~, indSpeedStart] = min(abs(time-timeStamps));
% for kk = indSpeedStart:1:length(time)
%     if tt2(kk) < mean(tt2(indTimeRefStart:indTimeRefStop))*1.2
%         break
%     end
% end
% 
% disp(time(kk) - timeStamps(1))
% 
% figure(13000)
% plot(repmat(time(kk) - timeStamps(1), 2,1), get(gca, 'Ylim'), 'k')
% a(2,size(a,2)) = time(kk)-timeStamps(1);


%%
% ss = mean(R);
% ss2 = smoothdata(ss,2, 'movmedian', 10);
% [~,indTimeEnd] = min(abs(time - (time(end)-5)));
% for kk=indTimeEnd:-1:1
%     if abs(ss2(kk)-1) > 0.005
%         break;
%     end
% end
% disp(time(kk) - timeStamps(1))
% 
% figure(13000)
% plot(repmat(time(kk) - timeStamps(1), 2,1), get(gca, 'Ylim'), 'k')
% 
% figure(13000)
% xlim([(time(kk) - timeStamps)-1 (time(kk) - timeStamps)*1.3])
% ylim([0.8 1.2])
% a(3,size(a,2)) = time(kk)-timeStamps(1);

%%
% for jjj = [450 550 650 750]*1e-9
% [~,indTimeDetectionWL] = min(abs(wl-jjj));
% [~,indT1] = min(abs(time-timeStamps-(-5)));
% [~,indT2] = min(abs(time-timeStamps-(-2)));
% referenceStd = std(trans(i111, indT1:indT2));
% 
% counter = 1;
% for i=-0:0.1:time(end)
%     [~,indT1] = min(abs(time-timeStamps-(i-0.1/2)));
%     [~,indT2] = min(abs(time-timeStamps-(i+0.1/2)));
%     if std(trans(i111,indT1:indT2)) < 1.1*referenceStd
%         break;
%     end
% end
% 
% disp(i)
% end


%%
timeStamps = 15; %% Quick and Dirty Fix for evaluation
ss = mean(R); 
ssMean = mean(ss(indTimeRefStart:indTimeRefStop));
stdTrans = mean(std(trans(:,indTimeRefStart:indTimeRefStop), 0,1));
[~, i55] = min(abs(time-timeStamps));

for kkk = i55:50:length(time)-100
    if abs(mean(ss(kkk:kkk+100))./ssMean-1) < 0.15
        if abs(mean(std(trans(:,kkk:kkk+100), 0,1))./stdTrans-1) < 0.15
            break
        end
    end
end
disp(time(kkk)-timeStamps)
a(end+1) = time(kkk)-timeStamps;

%%
% figure(4000)
% plot(diff(time))
%%
% close all