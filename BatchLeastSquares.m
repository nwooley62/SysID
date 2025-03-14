function [ theta, cond_num ] = BatchLeastSquares ( input, output, time)
% 3 Batch LS program to identify the parameters
numSamples = length(time);

% Create the phi matrix based
for i=3:numSamples
    for j=1:3
        if(i-j <=0)
            phi(i,j)=0;
        else
            phi(i,j)=-output(i-j);
        end
    end
    for j=0:3
        if(i-j-1 <=0)
            phi(i,j+4)=0;
        else
            phi(i,j+4)=input(i-j-1);
        end
    end
end

% Calculate Batch Parameters
theta =pinv(phi' * phi)*phi'*output;
cond_num = cond(phi' * phi);