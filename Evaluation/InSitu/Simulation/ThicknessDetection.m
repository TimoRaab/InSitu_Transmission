wl = [400:1000]*1e-9;
wlTemp = wl*1e9;


n_DMF = 1.4764-6.2707e4./wlTemp.^2 + 1.3755e10./wlTemp.^4;
n_DMSO = sqrt(1+0.04419*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.046390067309) + 1.09101*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.01221543949));
n_Ethanol = sqrt(1+0.0165*(wlTemp/1000).^2./((wlTemp/1000).^2 - 9.08) + 0.8268*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.01039));
n_nitrobenzene = sqrt(1+1.30628*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.02268) + 0.00502*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.18487));
n_Methanol = 1.294611 + 12706.403e-6*(wlTemp/1000).^(-2);

n = (4*n_DMF + n_DMSO)/5;
% n = n_Ethanol;
n = n_Methanol;

% d = 1500*1e-9;
% f = 1+0.3*exp(-1i*2*d./(wl./n)*2*pi + 1i*pi);
% 
% figure(1)
% plot(wlTemp, abs(f))
% figure(2)
% plot(299792458./wl * 1e-14, abs(f))
% 
% 
% wl2 = wl./n;
% figure(3)
% plot(wl2, abs(f))
% figure(4)
% plot(299792458./wl2, abs(f))



t = 0:0.1:50;
d = (1000*exp(-0.1*t)+1000)*1e-9;
counter = 1;
calcThickness = NaN(size(d));
freq2 = 299792458./(wl./n);

for ttt = t
    disp(ttt)
    f = 1+0.1*exp(-1i*2*d(counter)./(wl./n)*2*pi + 1i*pi);
%     [f1, p1] = plotNFFT(freq2*1e-14, abs(f), 1,1, 'plot', 'off');
%     [~,i1] = max(p1);
%     calcThickness(counter) = 299792458./(2*(1/f1(i1)*1e14));

    freq22 = freq2*1e-14;
    ff = abs(f)-1;

    [f1, p1] = plotNFFT(freq22, ff, 1,1, 'plot', 'off');
    [~,i1] = max(p1);
    ab = diff(ff);
    [~, i2] = min(abs(ab));
    f = fit(freq22', ff', 'sin1', 'StartPoint', [0.1 2*pi*f1(i1) freq22(i2)]);
    calcThickness(counter) = 299792458./(2*1e14*(2*pi./f.b1));
    counter = counter+1;
end