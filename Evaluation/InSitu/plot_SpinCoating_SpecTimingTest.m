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
basedir = 'C:\Measurements\Measurements\InSitu\SpinCoating\220404'; % Dateipfad zu ordner
fname = '20220404_110607_TR_CBTest_ClosedLid_A01_meas.spin';
% cellName = 'B03';
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
fname = [fname(1:end-9) 'time.spin'];
fid = fopen(fullfile(basedir,fname));
siz = [2^32 2^16 2^8 1]';
frames = sum(fread(fid,4).*siz);
time = fread(fid, frames, 'uint32', 0, 'ieee-be');
fclose(fid);

%% Import Data
time = time-time(1);            % rechnet die Zeit um
time = time*10;                % rechnet die Zeit um

td = diff(time);
a = abs(diff(time)-min(diff(time))) < 50;
length(a)-sum(a)

td2 = td;
td2(a) = [];
histogram(td2-(min(diff(time)) + 10e-6)/2, 'BinWidth', (min(diff(time)) + 10e-6))







