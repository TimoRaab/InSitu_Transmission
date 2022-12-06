%% Changelog
% v03
%   added time correction

%%
clc;
% close all
% clear all
%%
MeasCounter = 0;
basedir = 'E:\Measurements\InSitu\SpinCoater\211123'; % Dateipfad zu ordner
fname = '20211123_120349_TR_Y6PM6_5_0CN_Blend_E23_meas.spin';
wlRange = [420e-9 900e-9]; % gibt den Wellenbereich zum plotten an
timeRange = [-50 50]; % gibt den Zeitbereich zum plotten an
wlPlot = [510 580 605 740 840]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
% wlPlot = [405 420 500 605 740]*1e-9; % f�r den plot einer Wellenl�nge �ber die Zeit
timePlot = [1:5:20];


%%
correctTimeFirst = 1;
%%
correctTime = 1;
timeDetectLowerThreshold= 0.3;
timeDetectUpperThreshold = 0.95;
timeDetectWavelength = 550e-9;
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
speedRangeFFT = [3000 5000]/60; % Bereich der Rotationsgeschwindigkeit, in welcher gesucht wird

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
% figure(19002);
% mm = diff(R,1,2);
% mm = sign(mm).*log(abs(mm));
% mm2 = smoothdata(mm,2,'movmean', movTime);
% imagesc(time(1:end-1), wl*1e9, mm2)
% colormap(createColormap(-10,10))
% % % caxis([-10 10])

% %%
% figure(19003);
% tempMax = max(R,[],1);
% tempMin = min(R,[],1);
% 
% Rnorm = (R-tempMin)./(tempMax-tempMin);
% imagesc(time(indTimeMin:indTimeMax), wl(indWlMin:indWlMax), Rnorm(indWlMin:indWlMax,indTimeMin:indTimeMax)); % Plottet das Falschfarbenbild


%%
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
    [s,w] = ReadSpectraSpinCoating(fullfile(basedir, fList{i}));
    s = squeeze(s);
    s = mean(s,2);
    [~,indW1] = min(abs(w-wl(1)));
    [~,indW2] = min(abs(w-wl(end)));
    specAfter(i,:) = s(indW1:indW2);   
end

transAfter = (specAfter'-mean(dark,2))./(mean(ref,2)-mean(dark,2));
transAfter = smoothdata(transAfter, 1, 'sgolay', 20);

%%
figure(11111)
imagesc(10:10:length(fList)*10, wl, transAfter)
title('Transmission relative to Spin Coating')

figure(11112)
set(gcf, 'Name', 'All Wavelength');
for indTimeLower = 1:length(wlPlot)
    [~,indWL] = min(abs(wl-wlPlot(indTimeLower)));
    figure(11112)
    plot(10:10:length(fList)*10, transAfter(indWL, :));
    hold on
end

figure(11112)
legend(cellstr(num2str(wlPlot'*1e9)))
xlabel('Time in s')
ylabel('Transmittance')
title('Transmission relative to Spin Coating')

figure(11113)
for i = 10:10:length(fList)
    figure(11113)
    plot(wl*1e9, transAfter(:,i));
    hold on
end

%%
figure(11121)
imagesc(10:10:length(fList)*10, wl*1e9, transAfter./(transAfter(:,1)))
title('Transmission relative to Spin Stop')
xlabel('Time in s')
ylabel('Wavlenght in nm')
colormap(createColormap(0.9,1.10,1))
caxis([0.9 1.1])
c = colorbar();
ylabel(c, 'Transmitance');

figure(11122)
for indTimeLower = 1:length(wlPlot)
    [~,indWL] = min(abs(wl-wlPlot(indTimeLower)));
    figure(11122)
    plot(10:10:length(fList)*10, transAfter(indWL,:)./transAfter(indWL,1));
    hold on
end

figure(11122)
legend(cellstr([num2str(wlPlot'*1e9) repmat('nm', size(wlPlot'))]))
xlabel('Time in s')
ylabel('Transmittance')
title('Transmission relative to Spin Stop')

figure(11123)
for i = 10:10:length(fList)
    figure(11123)
    plot(wl*1e9, transAfter(:,i)./transAfter(:,1));
    hold on
end

legend(cellstr([num2str([100 200 300 400 500 600]'), repmat('s', 6,1)]))
xlabel('Wavelength in nm')
ylabel('Transmittance')
title('Transmission relative to Spin Stop')