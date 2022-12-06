function [spectra] = ReadSpectraSpinCoating_old(path)
%%Old version with no wavelength included

fid = fopen(path);
siz = [2^32 2^16 2^8 1]';

frames = sum(fread(fid,4).*siz);
y = sum(fread(fid,4).*siz);
x = sum(fread(fid,4).*siz);

spectraTemp = fread(fid, frames*y*x, 'uint16', 0, 'ieee-be');
spectra = reshape(spectraTemp, [x,y,frames]);

fclose(fid);
end
