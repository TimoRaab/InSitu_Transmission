function [M] = fftSmoothing(trans, wl, time, wlDetectFFT, timeRangeFFT, speedRangeFFT)

    [~,indLowFFT] = min(abs(time-min(timeRangeFFT)));
    [~,indHighFFT] = min(abs(time-max(timeRangeFFT)));          
    [~,indWlFFT] = min(abs(wl-wlDetectFFT));
    plotFFT(time(indLowFFT:indHighFFT), trans(indWlFFT,indLowFFT:indHighFFT), 1,1);

    f = figure(5002);
    xDat = f.Children(1).Children(1).XData;
    yDat = f.Children(1).Children(1).YData;
    figure(5000);
    close
    figure(5001);
    close
    figure(5002);
%     close
    figure(5004);
    close

    [~,indSpeedMin] = min(abs(xDat-min(speedRangeFFT)));
    [~,indSpeedMax] = min(abs(xDat-max(speedRangeFFT)));

    [~,ind] = max(yDat(indSpeedMin:indSpeedMax));
    ind = ind + indSpeedMin -1;
    disp(['RPM:' num2str(xDat(ind)*60)])
    movTime = round(1/xDat(ind)/mean(diff(time(indLowFFT:indHighFFT))));
    M = movmean(trans, movTime,2);
end