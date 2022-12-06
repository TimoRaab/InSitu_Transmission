function [timeRangeDetectionThickness, thicknessDetection] = automatedThicknessCalculation_Perovskite(timeStampsTemp, speedValueTimesTemp, wl, time)

wlTemp = wl*1e9;
n_DMF = 1.4764-6.2707e4./wlTemp.^2 + 1.3755e10./wlTemp.^4;
n_DMSO = sqrt(1+0.04419*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.046390067309) + 1.09101*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.01221543949));
n_Ethanol = sqrt(1+0.0165*(wlTemp/1000).^2./((wlTemp/1000).^2 - 9.08) + 0.8268*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.01039));
n_nitrobenzene = sqrt(1+1.30628*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.02268) + 0.00502*(wlTemp/1000).^2./((wlTemp/1000).^2 - 0.18487));

n = (4*n_DMF + n_DMSO)/5;
% n = n_Ethanol;
% n = n_nitrobenzene;


cropWl = [450 850];
[~,indCropMin] = min(abs(wlTemp - min(cropWl)));
[~,indCropMax] = min(abs(wlTemp - max(cropWl)));

wl2 = wlTemp(indCropMin:indCropMax);


timeRangeDetectionThickness = (speedValueTimesTemp(2)+1):0.05:timeStampsTemp(2)-1;
thicknessDetection = NaN(size(timeRangeDetectionThickness));
counter = 1;
for ttt = timeRangeDetectionThickness
    disp(ttt)
    [~,indTimeTemp] = min(abs(time-ttt-timeStamps));
    aaa = R(:, indTimeTemp);
    bbb = (aaa-0.9)./0.01;
    bbb2 = smoothdata(bbb, 1, 'sgolay', 60);
%     bbb2 = bbb;
    bbb3 = bbb2(indCropMin:indCropMax);
    [~,lambdaList, ~, p] = findpeaks(bbb3, wl2, 'MinPeakDistance', 8);
%     [~, lambdaList] = findpeaks(bbb3, wl2*1e9, 'NPeaks', numberPeaks, 'MinPeakDistance', 8, 'Threshold', 0.3);
    lambdaList(p < 1) = [];
    p(p < 1) = [];

    [p, pIndex] = sort(p, 'descend');
    lambdaList = lambdaList(pIndex);
%     p = ones(size(lambdaList));

    if length(lambdaList) > 8
        lambdaList = lambdaList(1:8);
    end
% 
    for iii = 1:length(lambdaList)
        [~,indTempWL] = min(abs(wl2-lambdaList(iii)));
        lambdaList(iii) = lambdaList(iii)./n(indTempWL);
    end
    thicknessDetection(counter) = thicknessCalculationV3(lambdaList, p);
    counter = counter+1;
end

figure(224)
plot(timeRangeDetectionThickness, thicknessDetection, 'o')

end