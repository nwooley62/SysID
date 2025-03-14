function [ theta ] = RLS_noise( input, output, noise, output2, lambda, changeParam, time, graphCount)

numSamples = length(time);
original_output = output + noise;
for(L = 1:length(lambda))
    % Before each iteration with each new lamda, rebuild the system to its
    % original state so that the sudden change occurs newly on each run
    output = original_output;
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
        
        % Recursive calculation
        p = lambda(L) * p + phi(i,:)' * output(i);
        q = lambda(L) * q + phi(i,:)' * phi (i,:);
        theta{L}(:,i) = inv(q) * p;
        
        % Change parameters
        if(i == changeParam)
            output = output2;
        end
        
    end
end

% Graphing
graphWidth = [20,1000];
for x = 1:length(graphWidth)
    for y = 1:length(lambda)
        graphCount = graphCount+1;
        figure(graphCount)
        hold on
        grid on
        title("RLS with noise. lambda =" + lambda(y))
        for i=1:7
            plot(time(1:graphWidth(x)), theta{y}(i,1:graphWidth(x)));
        end
        hold off
    end
end