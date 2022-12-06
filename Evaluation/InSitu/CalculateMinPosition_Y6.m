%%
% clc;
close all
% clear all

% figs2keep = [13670 13671 13672 13680 13681 13682];
% all_figs = findobj(0, 'type', 'figure');
% delete(setdiff(all_figs, figs2keep))
%%
MeasCounter = 0;
basedir = 'D:\InSitu\SpinCoating\210510'; % Dateipfad zu ordner
fname = '20210510_115950_Y6PM6_CB_K05_meas.spin';
cellName = 'O16';
titleNameStart = 'Y6:PM6 CB HotSolution';
fNameSaveStartTemp = 'CB_HotSolution';
dirNameSave = basedir;
savePic = 0;
wlRange = [420e-9 900e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-50 300]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605 740 790 810 840]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
% wlPlot = [446 509 558 605 650 850]*1e-9;
% wlPlot = [650 660 670 680 690]*1e-9;
cmapTimeColorbar = linspecer(120, 'sequential');


perovskiteSetting = 0;
Y6PM6_PDINN_Setting = 0;
Y6PM6_CB_Setting = 0;
Y6PM6_CF_Setting = 1;
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
clearvars spectra;

%% 
M = timeSmoothing(speedValue, speedValueTimes, trans, time, timeSmoothOrder);
timeStamps = timeCorrection(correctingTimeData, trans, wl, time);
clearvars trans;

%% Hier wird ein moving average angewendet
R = smoothdata(M,1, 'sgolay', 40);



%% Prepare Struct
minStruct = struct;
%% Get MinimumPos all
[~,indTimeMin] = min(abs(time-timeStamps(1)-0.15));
[~,wlStart] = min(abs(wl-700e-9));
[~,minSpecPosition] = min(R(wlStart:end, indTimeMin:end));

minStruct.time = time(indTimeMin:end)-timeStamps(1);
minStruct.minPosition = wl(wlStart-1+minSpecPosition);

%% Get MinimumPos Fit
timeInterval = [0.1:0.005:0.3 0.3001:0.001:0.7 0.8:0.1:55];
timeInterval = [0.1:0.01:3 3.001:0.001:4 4.1:0.1:30];

[~,indTimeFit] = min(abs(time-timeStamps(1)-min(timeInterval)));
[~,wlStart] = min(abs(wl-700e-9));
aa = R(wlStart:end, indTimeFit:end);
timeMin = time(indTimeFit:end)-timeStamps(1);
ww = wl(wlStart:end)*1e9;



minPos = NaN(length(timeInterval), 1);
thres = 5;
counter = 1;
for i=timeInterval
    if (counter/(length(timeInterval))*100 > thres)
        disp([num2str(thres) '% done'])
        thres = thres+5;
    end
%     if (i > 3.5679)
%         pause
%     end
    [~,timeIndex] = min(abs(timeMin-i));
    timeInterval(counter) = timeMin(timeIndex);
    [~, cc]= min(aa(:,timeIndex));
    if ww(cc)-10 > 700
        [~, lowLim] = min(abs(ww-(ww(cc)-10)));
    else
        [~, lowLim] = min(abs(ww-700));
    end
    if (ww(cc) +10) < 890
        [~, upLim] = min(abs(ww-(ww(cc)+10)));
    else
        [~, upLim] = min(abs(ww-890));
    end
    f = fit(ww(lowLim:upLim), abs(1-aa(lowLim:upLim, timeIndex)), 'gauss1');
%     f = fit(ww, abs(1-aa(:, timeIndex)), 'gauss1');
    minPos(counter) = f.b1;
    counter = counter+1;
end
minStruct.timeInterval = timeInterval;
minStruct.fitMin = minPos;

% save(fullfile(cd, [cellName '.mat']), 'minStruct')