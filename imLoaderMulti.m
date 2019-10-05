classdef imLoaderMulti  < handle
    %IMLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        paths;
        bufferSize;  
        indexArray;
        imArray;
        imSize;
        imNums;
        imNum;
        cumSum; %кумулятивная сумма номеров 
    end
    
    methods
        function il = imLoaderMulti(impaths,bufferSize)
            disp('Loading file info....')
            if (~iscell(impaths))
                impaths = {impaths};
            end
            tic
            il.paths = impaths;
            il.bufferSize = bufferSize;
            
            n = numel(il.paths);
            il.imNums = zeros(n,1);
            im = imread(il.paths{1},'Index',1);%,'Info',il.imInfo);
            il.imSize = fliplr(size(im));
            for i = 1:n
                il.indexArray = zeros(il.bufferSize,1);
                il.imArray = cell(il.bufferSize,1);
                imInfo = imfinfo(il.paths{i});
                il.imNums(i) = numel(imInfo);
                fprintf('File info loaded in %g sec\n',toc);
            end
            il.imNum = sum(il.imNums);
            il.cumSum = cumsum(il.imNums)-il.imNums;   
            fprintf('File info loaded in %g sec\nTotal number of frames %d\n',toc, il.imNum);
        end
        function im = getImage(obj,i)   
            % номер файла
            fileNum = find(obj.cumSum < i,1,'last');
            % номер кадра в файле
            iInFile = i - obj.cumSum(fileNum);
            ii = find(obj.indexArray == i);
            if isempty(ii)
                im = imread(obj.paths{fileNum},'Index',iInFile);%,'Info',obj.imInfo);
                obj.indexArray = circshift(obj.indexArray,1);
                obj.imArray = circshift(obj.imArray,1);
                obj.indexArray(1) = i;
                obj.imArray{1} = im;
            else
                im = obj.imArray{ii};
            end
        end
    end
    
end 

