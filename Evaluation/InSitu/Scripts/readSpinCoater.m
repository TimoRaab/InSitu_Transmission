function [spectra, time, wl, ref, dark, startTime, timeDiff] = readSpinCoater(pathstring, varargin)
%% readSpinCoater_v02
% This method reads all the data coming from the in-situ spin coating.
% To overcome the problem of different versions of programming the correct
% script is chosen by the date the file was created.  

if nargin==1
    printReading = 1;
else
    if varargin{1} == 0
        printReading = 1;
    else
        printReading = 0;
    end
end

splitter = regexp(pathstring,filesep);

% basedir = pathstring(1:splitter(end));
fname = pathstring(splitter(end)+1:end);
dateValue = str2double(fname(1:8));
if ~strcmp(fname(end-8:end), 'meas.spin')
    tempPos = regexp(pathstring, '_');
    pathstring = [pathstring(1:tempPos(end)) 'meas.spin'];
end

if dateValue >= 20180831 %v09
    addpath(genpath(pwd))
    [spectra, time, wl, ref, dark, startTime, timeDiff] = readSpinCoater20180831(pathstring, printReading);
    return
end
if dateValue >= 20180813 %vo5
    addpath(genpath(pwd))
    [spectra, time, wl, ref, dark, startTime, timeDiff] = readSpinCoater20180813(pathstring, printReading);
    return
end

error('ERROR! File not in supported time range')
end
