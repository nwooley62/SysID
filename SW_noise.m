function [ theta ] = SW_noise( input, output, noise, output2,lambda, N, changeParam, time, graphCount)

numSamples = length(time);
output = output + noise;
output2 = output2 + noise;

for L=1:length(lambda)
    p=0;
    q=0;
    for i=1:numSamples
        %Create the phi matrix
        for j=1:3
            if(i-j <=0)
                phi(i,j)=0;
            else
                if(i <= changeParam)
                    phi(i,j)=-output(i-j);
                else
                    phi(i,j)=-output2(i-j);
                end
            end
        end
        for j=0:3
            if(i-j-1 <=0)
                phi(i,j+4)=0;
            else
                phi(i,j+4)=input(i-j-1);
            end
        end
        
        % Generate theta with sliding window
        % Note: This is inside of this if block to handle 'forgetting' the correct
        % values from the original vs changed paramater outputs
        if(i <= N)
            p = lambda(L) * p + phi(i,:)' * output(i);
            q = lambda(L) * q + phi(i,:)' * phi (i,:);
            theta{L}(:,i) = inv(q) * p;
            
        elseif(i > N && i < changeParam)
            p = lambda(L) * p + phi(i,:)'*output(i) - phi(i-N,:)'*output(i-N);
            q = lambda(L) * q + phi(i,:)'*phi(i,:) - phi(i-N,:)'*phi(i-N,:);
            theta{L}(:,i) = inv(q) * p;
            
        elseif(i >= changeParam && i <= changeParam + N)
            p = lambda(L) * p + phi(i,:)'*output2(i) - phi(i-N,:)'*output(i-N);
            q = lambda(L) * q + phi(i,:)'*phi(i,:) - phi(i-N,:)'*phi(i-N,:);
            theta{L}(:,i) = inv(q) * p;
            
        else
            p = lambda(L) * p + phi(i,:)'*output2(i) - phi(i-N,:)'*output2(i-N);
            q = lambda(L) * q + phi(i,:)'*phi(i,:) - phi(i-N,:)'*phi(i-N,:);
            theta{L}(:,i) = inv(q) * p;
        end
    end
end

% Graphing
graphWidth = [20,1000];
for L=1:length(lambda)
    for x = 1:length(graphWidth)
        graphCount = graphCount+1;
        figure(graphCount)
        hold on
        grid on
        title("Sliding window + noise with N =" + N + " and lambda = " + lambda(L))
        for i=1:7
            plot(time(1:graphWidth(x)), theta{L}(i,1:graphWidth(x)));
        end
        hold off
    end
end
