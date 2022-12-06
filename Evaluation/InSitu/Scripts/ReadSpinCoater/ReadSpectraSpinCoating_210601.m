function [spectra,wl] = ReadSpectraSpinCoating_210601(path)
%READSPECTRASPINCOATING_210601 Read spectra from in-situ programm since
%01.06.2021
%To use since version 13 of in-situ program

fid = fopen(path);
siz = [2^32 2^16 2^8 1]';

xAxis = sum(fread(fid,4).*siz);
wl = fread(fid,xAxis, 'double', 0, 'ieee-be');

frames = sum(fread(fid,4).*siz);
y = sum(fread(fid,4).*siz);
x = sum(fread(fid,4).*siz);

spectraTemp = fread(fid, frames*y*x, 'uint16', 0, 'ieee-be');
spectra = reshape(spectraTemp, [x,y,frames]);

fclose(fid);

end

