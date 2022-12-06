% close all
figure(13670);figure(13671); figure(13672); figure(13680); figure(13681); figure(13682);
range = [41:52 1:20]
cc = linspecer(8, 'sequential');
cc = flip(cc);

for ttttt = 1:4:length(range)
    iiiii = range(ttttt);
    for kkkkk = 0:3
        bbb = num2str(iiiii+kkkkk);
        disp(bbb)
        if length(bbb) == 1
        bbb = ['0' bbb];
    end
    if (iiiii > 25)
        cellName = ['PC' bbb];
    else
        cellName = ['PD' bbb]
    end
    plot_SpinCoating_v06
    [~,indAAA] = min(abs(time-timeStamps(end)-27));
    figure(13680)
    plot(wl*1e9, R(:,indAAA), 'Color', cc(floor((ttttt-1)/4)+1,:), 'LineWidth', 2)
    title('Transmission after 27s, all');
    hold on
    tempR27(:,kkkkk+1) = R(:, indAAA);
    [~,indAAA] = min(abs(time-timeStamps(end)-5));
    figure(13681)
    plot(wl*1e9, R(:,indAAA), 'Color', cc(floor((ttttt-1)/4)+1,:), 'LineWidth', 2)
    title('Transmission after 5s, all');
    hold on
    tempR05(:,kkkkk+1) = R(:, indAAA);
    [~,indAAA] = min(abs(time-timeStamps(end)-3));
    figure(13682)
    plot(wl*1e9, R(:,indAAA), 'Color', cc(floor((ttttt-1)/4)+1,:), 'LineWidth', 2)
    title('Transmission after 3s, all');
    hold on
    tempR03(:,kkkkk+1) = R(:, indAAA);
end
tempTempR27 = median(tempR27, 2);
tempTempR05 = median(tempR05, 2);
tempTempR03 = median(tempR03, 2);
figure(13670)
plot(wl*1e9, tempTempR27, 'Color', cc(floor((ttttt-1)/4)+1,:), 'LineWidth', 2)
title('Transmission after 27s');
hold on
figure(13671)
[~,indAAA] = min(abs(time-timeStamps(end)-5));
tempR = R(:, indAAA);
plot(wl*1e9, tempTempR05, 'Color', cc(floor((ttttt-1)/4)+1,:), 'LineWidth', 2)
title('Transmission after 5s');
hold on
figure(13672)
[~,indAAA] = min(abs(time-timeStamps(end)-3));
tempR = R(:, indAAA);
plot(wl*1e9, tempTempR03, 'Color', cc(floor((ttttt-1)/4)+1,:), 'LineWidth', 2)
title('Transmission after 3s');
hold on
end