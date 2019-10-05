expList = {
    'F19ice0_1_bottom1' 
    };
fragSize = [32,32]; % размер фрагмента дл€ коррел€ции
XYmax0 = [(fragSize(1)/2), (fragSize(2)/2)];
imSize = [2016, 128]; % размер входного изображени€
XYmax = NaN((imSize(2)/fragSize(2)-1),((imSize(1)/fragSize(1))-1), 2); %координаты максимума
shiftXY = NaN(size(XYmax)); %смещение
expName = expList{1};
recPath = 'C:\Users\Vladimir\Documents\ урсова€\';
clear imPaths;
imPaths{1} = [recPath expName '.tif'];
    il = imLoaderMulti(imPaths,10);
 for z = 0:((imSize(1)/fragSize(1))-2) 
     xS1=1 + (z*fragSize(1));
     xE1=1 + fragSize(1)+(z*fragSize(2));
     for w = 0:((imSize(2)/fragSize(2))-2)
         yS1=1 + (w*fragSize(2));
         yE1=1 + fragSize(2)+(w*fragSize(2)); 
         im1 = il.getImage(2);
         im2 = il.getImage(3);
%          im2 = circshift((il.getImage(2)), 10, 2);
         im1c=im1(yS1:yE1, xS1:xE1);
         im2c=im2(yS1:yE1, xS1:xE1); 
         result_conv = fftshift(real(ifft2(conj(fft2(im1c)).*fft2(im2c))));
         [M,I] = max(result_conv(:));
         [ymax,xmax] = ind2sub(size(result_conv), I);
         XYmax(w+1,z+1,1) = (xmax + xS1);
         XYmax(w+1,z+1,2) = (ymax + yS1);
         shiftXY(w+1,z+1,1) = xmax - XYmax0(1);
         shiftXY(w+1,z+1,2) = ymax - XYmax0(2);
         binIm = imregionalmax(result_conv);
         indMax = find(binIm==1);
         locMax = sort(result_conv(indMax),'descend');
         if numel(locMax)==1 || numel(locMax)~=1 && (locMax(2)/locMax(1))<=0.8
              XYmax(w+1,z+1,1) = (xmax + xS1);
              XYmax(w+1,z+1,2) = (ymax + yS1);
              shiftXY(w+1,z+1,1) = xmax - XYmax0(1);
              shiftXY(w+1,z+1,2) = ymax - XYmax0(2);
          elseif numel(locMax)~=1 && (locMax(2)/locMax(1))<=0.8 
               XYmax(w+1,z+1,1) = (xmax + xS1);
               XYmax(w+1,z+1,2) = (ymax + yS1);
               shiftXY(w+1,z+1,1) = xmax - XYmax0(1);
               shiftXY(w+1,z+1,2) = ymax - XYmax0(2);
         end 
         crosscorrNorm = result_conv/M;
          figure, surf(result_conv), shading flat;
          pause 
         if numel(locMax)~=1
             disp(locMax(2)/locMax(1))
         end
     end
 end
 quiver(XYmax(:,:,1),XYmax(:,:,2), shiftXY(:,:,1), shiftXY(:,:,2), 0)
 axis equal;
 disp( 'done' )
 pause
 close all
 
