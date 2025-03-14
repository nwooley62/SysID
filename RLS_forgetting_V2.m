function [ theta, cond_num ] = RLS_forgetting_V2( input, output, lambda, time, graphCount)

numSamples = length(time);

for(L = 1:length(lambda))
    % Reset output to original output
    p=0;
    q=0;
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
        p = lambda(L) * p + phi(i,:)' * output(i);
        q = lambda(L) * q + phi(i,:)' * phi (i,:);
        theta{L}(:,i) = pinv(q) * p;
        
        
    end
end
cond_num = cond(phi' * phi);

% Graphing
graphWidth = [100,2000];
for x = 1:length(lambda)
    for y = 1:length(graphWidth)
        graphCount = graphCount+1;
        figure(graphCount)
        hold on
        grid on
        title("RLS with lambda =" + lambda(x))
        for i=1:7
            plot(time((graphWidth(y)-99):graphWidth(y)), theta{x}(i,(graphWidth(y)-99):graphWidth(y)));
        end
        hold off
    end
end