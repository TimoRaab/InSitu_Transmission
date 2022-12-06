function [spectra, wl] = ReadSpectraSpinCoating(pathstring)
%reads single spectra files from in-situ program
%new versions include wavelenght data
%multiple versions needed for backward compatibilty

splitter = regexp(pathstring,filesep);

% basedir = pathstring(1:splitter(end));
fname = pathstring(splitter(end)+1:end);
dateValue = str2double(fname(1:8));

wl = 0;

if dateValue >= 20200601 %v13
    addpath(genpath(pwd))
    [spectra, wl] = ReadSpectraSpinCoating_210601(pathstring);
    return
end
if dateValue >= 20180813 %vo5
    addpath(genpath(pwd))
    [spectra] = ReadSpectraSpinCoating_old(pathstring);
    return
end

error('ERROR! File not in supported time range')
end