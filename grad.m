c = input('Print ''1'' for JAP or ''2'' for PIV: ');
tic
switch c
    case 1
        NumOfFrames = 621;
        AverageFPS = 29.97;
        FolderName = 'C:\Users\Vladimir\Documents\Курсовая\Задания\Градиент\Японка';
    case 2
        NumOfFrames = 2167;
        AverageFPS = 10;
        FolderName = 'C:\Users\Vladimir\Documents\Курсовая\Задания\Градиент\PIV';
    otherwise
        disp('Error: please print ''1'' or ''2''.')
        return
end
Average = zeros(1, NumOfFrames);
AverageGrad = zeros(1, NumOfFrames);
Time = ( (1: NumOfFrames) - 1 ) / AverageFPS;
I=(1:NumOfFrames);
switch c
    case 1
        ControlParam = exist('dataJAP.txt','file');
        if ControlParam==2
            load('dataJAP.txt')
            Average = dataJAP(3,:);
            AverageGrad = dataJAP(4,:);
            disp('data loaded successfully')
        else
            disp ('data not found')
        end
    case 2
        ControlParam = exist('dataPIV.txt','file');
        if ControlParam==2
            load('dataPIV.txt')
            Average = dataPIV(3,:);
            AverageGrad = dataPIV(4,:);
            disp('data loaded successfully')
        else
            disp ('data not found')
        end
end
 
for i = 1:NumOfFrames
    switch c
        case 1
            FileName=sprintf('%s\\j%04d.jpeg',...
            FolderName,...
            i-1);
        case 2
            FileName=sprintf('%s\\PIV%04d.jpeg',...
            FolderName,...
            i-1);
    end
    if Average(i)==0 && AverageGrad(i)==0
        im = imread( FileName );
        [av, avg] = calc(im);
        Average(i) = av;
        AverageGrad(i) = avg;
    end
    switch c
        case 1
            if (i/10-round(i/10))==0
                save ('dataJAP.txt', 'I', 'Time', 'Average', 'AverageGrad', '-ascii')
            elseif i==NumOfFrames
                save ('dataJAP.txt', 'I', 'Time', 'Average', 'AverageGrad', '-ascii')
            end
        case 2
            if (i/10-round(i/10))==0
                save ('dataPIV.txt', 'I', 'Time', 'Average', 'AverageGrad', '-ascii')
            elseif i==NumOfFrames
                save ('dataPIV.txt', 'I', 'Time', 'Average', 'AverageGrad', '-ascii')
            end
    end
end
figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);
subplot(2, 2, [1, 2]);
yyaxis left
plot( Time, Average, 'b--')
switch c
    case 1
        axis([0 21 60 123]);
    case 2
        axis([0 217 5 40]);
end
grid on;
title('Зависимость среднего значения и средней амплитуды градиента от времени'); 
xlabel('Вреия (с)'); 
ylabel('Величина среднего значения (отн. ед.)');
hold on
yyaxis right
switch c
    case 1
        axis([0 21 35 130]);
    case 2
        axis([0 217 0 30]);
end
plot( Time, AverageGrad, 'r-')
ylabel('Величина средней амплитуды градиента (отн. ед.)');
legend('Среднее значение','Средняя амплитуда', 'Location','southeast','Orientation','horizontal')
hold off
subplot(2, 2, 3); histogram(Average);
title('Распределение среднего значения')
switch c
    case 1
        axis([73 110 0 400]);
    case 2
        axis([33.5 36.5 0 500]);
end
subplot(2, 2, 4); histogram(AverageGrad)
title('Распределение средней амплитуды градиента')
switch c
    case 1
        axis([60 125 0 130]);
        saveas(gcf,'Вывод(графики и распределения)JAP.jpg')
    case 2
        axis([0 30 0 300]);
        saveas(gcf,'Вывод(графики и распределения)PIV.jpg')
end

F = fft(Average);
FG = fft(AverageGrad);
f=real(F);
fg=real(FG);
k = AverageFPS/(2*Time((round(NumOfFrames/2)+1)));
Freq = Time*k;
figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);
% f=abs(F);
% fg=abs(FG);
subplot(1, 2, 1); plot(Freq(1:(round(NumOfFrames/2)+1)),f(1:(round(NumOfFrames/2)+1)))
switch c
    case 1
        axis([0 3 0 1500]);
    case 2
        axis([0, 1, 0, 75]);
end
[peakA,locA] = findpeaks(f);
[~, locMaxA] = max(peakA);
Frequency1 = Freq(locA(locMaxA))/2;
fprintf('Частота, определенная из спектра среднего значения равна %d Гц.\n',Frequency1)
title('Спектр среднего значения')
xlabel('Частота (Гц)'); 
ylabel('Спектральная плотность (отн. ед.)');
subplot(1, 2, 2); plot(Freq(1:(round(NumOfFrames/2)+1)),fg(1:(round(NumOfFrames/2)+1)))
title('Спектр средней амплитуды градиента')
xlabel('Частота (Гц)'); 
ylabel('Спектральная плотность (отн. ед.)');
[peakAG,locAG] = findpeaks(fg);
[~, locMaxAG] = max(peakAG);
Frequency2 = Freq(locAG(locMaxAG))/2;
fprintf('Частота, определенная из спектра амплитуды градиента равна %d Гц.\n',Frequency2)
switch c
    case 1
        axis([0 3 0 1000]);
        saveas(gcf,'Вывод(спектры)JAP.jpg')
    case 2
        axis([0 1 0 1500])
        saveas(gcf,'Вывод(спектры)PIV.jpg')
end
disp( 'done' )
toc


function [av, avg] = calc(im)
    IM = int8( mean(im, 3) );
    centre = round( size(IM)/2 );
    part = IM( centre(1)-50:centre(1)+50, centre(2)-50:centre(2)+50);
    av = mean( mean( part ), 2 );
    [ Gmag, ~ ] = imgradient( part );
    avg = mean( mean( Gmag ), 2 );
end
