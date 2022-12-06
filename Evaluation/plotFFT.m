function [fShift, P1, f, P2, phs, Y] = plotFFT(time, signal, shift, tr, varargin)

    usePlots = 1;
    
    %% Use varargin to remove plots
    if nargin > 0
        if mod(nargin, 2) == 0
        while ~isempty(varargin)
            switch lower(varargin{1})
                case 'plot'
                    switch lower(varargin{2})
                        case 'on'
                            usePlots = 1;
                        case 'off'
                            usePlots = 0;
                    end
                    
                otherwise
                    error(['Unexpected Option: ' varargin{1}])
            end
            
            varargin(1:2) = [];
        end
        else
            error(['Unexpected Number of Arguments']);
        end
    end
    

    %%
    if shift
        signal = signal-mean(signal);
    end
    if tr ~= 0
        if mod(length(signal),2) ~= 0 
            signal = signal(1:end-1);
            time = time(1:end-1);
        end
    end
    %%
    if usePlots
        figure(5000)
        set(gcf, 'Name', 'Signal');
        plot(time,signal);
    end

    %%
    dt = median(diff(time));
    f = linspace(-1/(2*dt),1/(2*dt),length(time)+1);
    f = f(1:end-1);
    L = length(f);
    
    %%
    Y = fft(signal);
    threshold = max(abs(Y))/10000;
    Y(abs(Y) < threshold) = 0;
%     phs = angle(fftshift(Y));
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    phs = atan2(imag(Y),real(Y));
    
    fShift = fftshift(f);
    fShift = abs(fShift(1:L/2+1));
    %%
    if usePlots
        figure(5001);
        set(gcf, 'Name', 'Double Sided');
        plot(f, fftshift(P2));
        title('Double Sided');

        figure(5002);
        set(gcf, 'Name', 'Single Sided'); 
        plot(fShift, P1);
    end
    
    %%
%     figure(5003);
%     set(gcf, 'Name', 'Phase');
%     plot(f, fftshift(phs/pi*180));
end
    