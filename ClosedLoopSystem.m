function [theta, cond_num] = ClosedLoopSystem(Gc, Gp, input, noise, t, graphNum)

% Define some variables for future use
H = Gc * Gp;
r = input;

% Construct my feedback system per the project instructions
Sum2 = sumblk('f = yH + n');
Sum1 = sumblk('uH = r - f');
H.u = 'uH';  H.y = 'yH';
T=connect(H,Sum1, Sum2, {'r','n'} , 'f');

% Simulate system for all inputs
y = lsim(T, [r,noise]);

% Re-simulate inputs with controller system to calculate u for the system
for i=1:length(y)
    d(i) = r(i) - y(i);
end
u = lsim(Gc,d);

% Estimate plant parameters using Batch Least Squares method
[theta, cond_num] = BatchLeastSquares(u,y,t);

figure(graphNum);
hold on; grid on;
if(r(1) == 0 && r(2) == 0)
    if(Gc.Ki == 0)
        title("Closed Loop P Controller System with Zero Input")
    else
        title("Closed Loop PI Controller System with Zero Input")
    end
else
    if(Gc.Ki == 0)
        title("Closed Loop P Controller System with Random Input")
    else
        title("Closed Loop PI Controller System with Random Input")
    end
end
plot (t, u);
plot (t, y);