%% Changelog
% v03
%   added time correction

%%
clc;
close all
% clear all
%%
MeasCounter = 0;
basedir = 'E:\Measurements\InSitu\Emilia\210707'; % Dateipfad zu ordner
fname = '20210707_113623_ES-3cat7-2_meas.spin';
wlRange = [420e-9 900e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-50 50]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605 740 840]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
timePlot = [1:5:20];

timeRangeFFT = [-15 -5]; %Zeitbereich f�r die FFT (hier soll das Spektrum konstant sein)
wlDetectFFT = 550e-9; % Wellenl�nge, f�r welche die FFT bestimmt wird
speedRangeFFT = [3000 5000]/60; % Bereich der Rotationsgeschwindigkeit, in welcher gesucht wird


%%
timeCorrection = 0;
timeDetectLowerThreshold= 0.3;
timeDetectUpperThreshold = 0.95;
timeDetectWavelength = 550e-9;
timeDetectSkipNSeconds = 5;

%%
fftSmoothing = 0;
speedValue = [1000 6000];
speedValueTimes = [0 10 1000];

%% Correct for fname date
correctedPath = correctPathForDate(fullfile(basedir, fname));
splitter = regexp(correctedPath,filesep);

% basedir = pathstring(1:splitter(end));
fname = correctedPath(splitter(end)+1:end)

%%
createReferenceSpectrum = 0;% 1 create own reference, 0 use prerecoded spectrum
referenceTimeSector = 2;    % which speed area should be used
referenceTimeBefore = 1;    % Time before taking the reference
referenceTime = 3;          % Time for taking reference

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

%% timeDetect
[~,indTimeDetectWl] = min(abs(wl-timeDetectWavelength));
[~,indTimeDetect] = min(abs(time-(min(time)+timeDetectSkipNSeconds)));
for indTimeLower=indTimeDetect:length(time)
    if trans(indTimeDetectWl,indTimeLower) < timeDetectLowerThreshold
        break
    end
end
for indTimeUpper=indTimeLower:-1:1
    if (trans(indTimeDetectWl,indTimeUpper) > timeDetectUpperThreshold)
        break
    end
end
time = time - time(indTimeUpper);

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
legend(cellstr(num2str(wlPlot')))
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
if fftSmoothing
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
    disp(['RPM:' num2str(xDat(ind)*60)])
    movTime = round(1/xDat(ind)/mean(diff(time(indLowFFT:indHighFFT))));

else
    movTime = round(60/speedValue/mean(diff(time)));
end

%% Hier wird ein moving average angewendet
M = movmean(trans, movTime,2);
R = smoothdata(M,1, 'sgolay', 20);

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
% figure(19002);
% mm = diff(R,1,2);
% mm = sign(mm).*log(abs(mm));
% mm2 = smoothdata(mm,2,'movmean', movTime);
% imagesc(time(1:end-1), wl*1e9, mm2)
% colormap(createColormap(-10,10))
% % % caxis([-10 10])

%%
figure(19003);
tempMax = max(R,[],1);
tempMin = min(R,[],1);

Rnorm = (R-tempMin)./(tempMax-tempMin);
imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), Rnorm(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild
