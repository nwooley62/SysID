function [ theta, cond_num ] = RecursiveLeastSquares ( input, output, time, graphCount)
p=0;
q=0;
numSamples = length(time);
for i=1:numSamples
    %Create the phi matrix
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
    
    % Recursively find theta
    p = p + phi(i,:)' * output(i);
    q = q + phi(i,:)' * phi (i,:);
    theta(:,i) = pinv(q) * p;
end
cond_num = cond(phi' * phi);

% Graphing
graphWidth = [100,2000];
for(x=1:length(graphWidth))
    graphCount = graphCount+1;
    figure(graphCount)
    hold on
    grid on
    title("Recursive Least Squares");
    for i=1:7
        plot(time((graphWidth(x)-99):graphWidth(x)), theta(i,(graphWidth(x)-99):graphWidth(x)));
    end
    hold off
end