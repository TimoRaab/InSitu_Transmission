k = 1:40;

lambda = 400:850;
n_DMF = 1.4764-6.2707e4./lambda.^2 + 1.3755e10./lambda.^4;
n_DMSO = sqrt(1+0.04419*(lambda/1000).^2./((lambda/1000).^2 - 0.046390067309) + 1.09101*(lambda/1000).^2./((lambda/1000).^2 - 0.01221543949));
n = (4*n_DMF + n_DMSO)/5;

cropWl = [450 850]*1e-9;
[~,indCropMin] = min(abs(wl - min(cropWl)));
[~,indCropMax] = min(abs(wl - max(cropWl)));

wl2 = wl(indCropMin:indCropMax);
% wl3 = wl2*1e9;
% 
% n_DMF_real = 1.4764-6.2707e4./wl3.^2 + 1.3755e10./wl3.^4;
% n_DMSO_real = sqrt(1+0.04419*(wl3/1000).^2./((wl3/1000).^2 - 0.046390067309) + 1.09101*(wl3/1000).^2./((wl3/1000).^2 - 0.01221543949));
% n_real = (4*n_DMF_real + n_DMSO_real)/5;
numberPeaks = 4;

timeRangeDetectionThickness = 5:0.2:8;
thicknessDetection = NaN(size(timeRangeDetectionThickness));
counter = 1;
for ttt = timeRangeDetectionThickness
    [~,indTimeTemp] = min(abs(time-ttt-timeStamps));
    aaa = R(:, indTimeTemp);
    bbb = (aaa-0.9)./0.1;
    bbb2 = smoothdata(bbb, 1, 'sgolay', 60);
    bbb3 = bbb2(indCropMin:indCropMax);
    [~,lambdaList, w, p] = findpeaks(bbb3, wl2*1e9, 'MinPeakDistance', 8);
%     [~, lambdaList] = findpeaks(bbb3, wl2*1e9, 'NPeaks', numberPeaks, 'MinPeakDistance', 8, 'Threshold', 0.3);
    lambdaList(p < 0.1) = [];
% 
    tempValues = NaN(length(lambdaList), length(k)+length(lambdaList));
    
    lambdaIndex = [];
    for i=1:length(lambdaList)
        [~,lambdaIndex(i)] = min(abs(lambda-lambdaList(i)));
    end
    
    scrt = [];
    for i=1:length(lambdaList)
        wlS = lambdaIndex(i);
        scrt(i,:) = (k*lambda(wlS))./(2*n(wlS));
    end


    %Brute Force
    for ik1 = 2:length(lambdaList)
        

%     for i=1:length(lambdaList)
%         tempValues(i,i:length(k)+(i-1)) = scrt(i,:);
%     end
% 
%     [~, tempPosition] = min(std(tempValues));
%     thicknessDetection(counter) = mean(tempValues(:, tempPosition));
% %     disp(thicknessDetection)
%     counter = counter+1;
% 
% 
%     figure(223)
%     for i=1:length(lambdaList)
%         plot(k+i-1, scrt(i,:), 'o')
%         hold on
%     end
%     figure(222)
%     plot(wl2, bbb3)
%     findpeaks(bbb3, wl2*1e9, 'MinPeakDistance', 8)
% 
%     pause
%     close(223)
%     close(222)

end

figure(224)
plot(timeRangeDetectionThickness, thicknessDetection, 'o')