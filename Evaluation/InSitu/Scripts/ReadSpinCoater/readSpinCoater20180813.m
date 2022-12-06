function [spectra, time, wl, ref, dark, startTime, timeDiff] = readSpinCoater20180813(pathstring, varargin)

if nargin > 0
    printout = 0;
end

splitter = regexp(pathstring,filesep);

basedir = pathstring(1:splitter(end));
fname = pathstring(splitter(end)+1:end);

fid = fopen(fullfile(basedir,fname));
siz = [2^32 2^16 2^8 1]';

%% Get Dimensions
frames = sum(fread(fid,4).*siz);
y = sum(fread(fid,4).*siz);
x = sum(fread(fid,4).*siz);

%% Read spectra data
if printout disp('Read spectra'); end
spectraTemp = fread(fid, frames*y*x, 'uint16', 0, 'ieee-be');
if printout disp('spectra read, reshaping now'); end
spectra = reshape(spectraTemp, [x,y,frames]);
fclose(fid);
clearvars spectraTemp;
if printout disp('Finished Read spectra'); end

%% Read Time Array
if printout disp('Read time array'); end
fname = [fname(1:end-9) 'time.spin'];
fid = fopen(fullfile(basedir,fname));
fread(fid, 4);
time = fread(fid, frames, 'uint32', 0, 'ieee-be');
fclose(fid);
if printout disp('Finished "Read time array"'); end


%% Read additional values like dark, ref and timing values
if printout disp('read additional values'); end
fname = [fname(1:end-9) 'add.spin'];
fid = fopen(fullfile(basedir,fname));
dim1 = sum(fread(fid,4).*siz);
dim2 = 1;
dim3 = sum(fread(fid,4).*siz);
dark = fread(fid,dim1*dim2*dim3,'uint16',0,'ieee-be');
dark = reshape(dark, [dim3, dim2, dim1]);
dim1 = sum(fread(fid,4).*siz);
dim2 = 1;
dim3 = sum(fread(fid,4).*siz);
ref = fread(fid,dim1*dim2*dim3,'uint16',0,'ieee-be');
ref = reshape(ref, [dim3, dim2, dim1]);
dim1 = sum(fread(fid,4).*siz);
wl = fread(fid,dim1,'double',0,'ieee-be');
startTime = fread(fid,1,'double',0,'ieee-be');
timeDiff = fread(fid,1,'double',0,'ieee-be');
fclose(fid);
if printout disp('additional values read'); end
if printout disp('Reading finished'); end

end