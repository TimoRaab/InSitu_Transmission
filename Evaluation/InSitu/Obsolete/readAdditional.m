function [dark, ref, wl] = readAdditional(pathstring)

splitter = regexp(pathstring,filesep);

basedir = pathstring(1:splitter(end));
fname = pathstring(splitter(end)+1:end);

fid = fopen(fullfile(basedir,fname));
siz = [2^32 2^16 2^8 1]';

%%
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
disp('additional values read');
disp('Reading finished');

end