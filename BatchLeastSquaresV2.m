function [ theta, cond_num ] = BatchLeastSquaresV2 ( input, output, np, dp, time)
% 3 Batch LS program to identify the parameters
numSamples = length(time);

% Create the phi matrix based
for i=np:numSamples
    for j=1:dp
        if(i-j <=0)
            phi(i,j)=0;
        else
            phi(i,j)=-output(i-j);
        end
    end
    for j=0:np
        if(i-j-1 <=0)
            phi(i,j+dp+1)=0;
        else
            phi(i,j+dp+1)=input(i-j-1);
        end
    end
end

% Calculate Batch Parameters
theta =inv(phi' * phi)*phi'*output;
cond_num = cond(phi' * phi);