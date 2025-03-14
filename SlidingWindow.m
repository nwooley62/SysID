function [ theta ] = SlidingWindow( input, output, N, time, graphCount)
%%8. Sliding window (N=10) least squares
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
    
    %Sliding window calculation
    if(i <= N)
        p = p + phi(i,:)' * output(i);
        q = q + phi(i,:)' * phi (i,:);
        theta(:,i) = inv(q) * p;   
    else
        p = p + phi(i,:)'*output(i) - phi(i-N,:)'*output(i-N);
        q = q + phi(i,:)'*phi(i,:) - phi(i-N,:)'*phi(i-N,:);
        theta(:,i) = inv(q) * p;
    end
end

% Graphing
graphWidth = [10,1000];
for x = 1:length(graphWidth)
    graphCount = graphCount+1;
    figure(graphCount)
    %ylim([-10, 20])
    hold on
    grid on
    title("Sliding window with N =" + N)
    for i=1:7
        plot(time(1:graphWidth(x)), theta(i,1:graphWidth(x)));
    end
    hold off
end
