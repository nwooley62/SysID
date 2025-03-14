close all; clear all; clc;
warning('off','all')

% Data Import from arduino generated csv files
M1=csvread('step_input.csv');
M2=csvread('random_input.csv');
M3=csvread('sin_input.csv');
M4=csvread('square_input.csv');


% Seperate input and output from imported data
u = M1(:,1);
y = M1(:,2);

% Create iddata objects from imported data
t=1:length(u);
T=1;
data = iddata(y, u, T);

                
%**************************************************************************
% ARX Estimation
arx_sys = arx(data, [8,9,1]);
arx_output = lsim(arx_sys, u, t);
[theta, cond_num] = BatchLeastSquaresV2(u, y, 100, 100, t);

% Prediction Error Function to get a new system
arx_pem_sys = pem(data, arx_sys);
arx_pem_output = lsim(arx_pem_sys, u, t);


% Final Predictor Error of models
arx_fpe = fpe(arx_sys);
arx_pem_fpe = fpe(arx_sys);

% Best Fit
[yx, arx_fit] = compare(data, arx_sys);
[yx, arx_pem_fit] = compare(data, arx_pem_sys);

% Mean Error
arx_mean_error = mean(abs(y - arx_output));
arx_fpe_mean_error = mean(abs(y - arx_pem_output));


%**************************************************************************
% ARMAX Estimation
armax_sys = armax(data, [3,3,2,1]);
armax_output = lsim(armax_sys, u, t);

% Prediction Error Function to get a new system
armax_pem_sys = pem(data, armax_sys);
armax_pem_output = lsim(armax_pem_sys, u, t);


% Final Predictor Error of models
armax_fpe = fpe(armax_sys);
armax_pem_fpe = fpe(armax_pem_sys);

% Best Fit
[yx, armax_fit] = compare(data, armax_sys);
[yx, armax_pem_fit] = compare(data, armax_pem_sys);

% Mean Error
armax_mean_error = mean(abs(y - armax_output));
armax_pem_mean_error = mean(abs(y - armax_pem_output));



%**************************************************************************
% Test vs Data

test_filename = 'data_test2.csv';
M_test=csvread(test_filename); %#ok<CSVRD> 
t_test=1:length(M_test(:,1));
T = 1;

% Seperate input and output from imported data
u_test = M_test(:,1);
y_test = M_test(:,2);

% Create iddata object from imported data
data1 = iddata(y, u, T);

% Generate model output vs test data & calculate best fit and mean error
arx_test = lsim(arx_pem_sys, u_test, t_test);
arx_test_mean_error = mean(abs(y_test - arx_test));
[yx, arx_test_fit] = compare(data1, arx_pem_sys);

% Generate model output vs test data & calculate best fit and mean error
armax_test = lsim(armax_pem_sys, u_test, t_test);
armax_test_mean_error = mean(abs(y_test - armax_test));
[yx, armax_test_fit] = compare(data1, armax_pem_sys);

%**************************************************************************
% Graphing

% Graph ARX Model
figure(1);
hold on; grid on;
title("Experimental Data vs ARX");
plot(t, u);
plot(t, y);
plot(t, arx_output);
legend('Input', 'Measured Output', 'ARX');

% Graph ARX PEM Model
figure(2)
hold on; grid on;
title("Experimental Data vs ARX PEM");
plot(t, u);
plot(t, y);
plot(t, arx_pem_output);

% Graph ARX Test Model
figure(3);
hold on; grid on;
title("Test Data vs ARX");
plot(t_test, u_test);
plot(t_test, y_test);
plot(t_test, arx_test);
legend('Input', 'Measured Output', 'ARX');

% Graph ARMAX Model
figure(4)
subplot(2,1,1);
hold on; grid on;
title("Experimental Data vs ARMAX");
plot(t, u);
plot(t, y);
plot(t, armax_output);
legend('Input', 'Measured Output', 'ARXMAX');

% Graph ARMAX PEM Model
subplot(2,1,2);
hold on; grid on;
title("Experimental Data vs ARMAX PEM");
plot(t, u);
plot(t, y);
plot(t, armax_pem_output);

% Graph ARMAX Test Model
figure(6);
hold on; grid on;
title("Test Data vs ARMAX");
plot(t_test, u_test);
plot(t_test, y_test);
plot(t_test, armax_test);
legend('Input', 'Measured Output', 'ARMAX');


% Graph all System Inputs
figure(7);
hold on; grid on;
subplot(4,1,1);
plot(1:length(M1(:,1)), M1(:,1));
subplot(4,1,2);
plot(1:length(M2(:,1)), M2(:,1));
subplot(4,1,3);
plot(1:length(M3(:,1)), M3(:,1));
subplot(4,1,4);
plot(1:length(M4(:,1)), M4(:,1));

% Graph all System Outputs
figure(8);
hold on; grid on;
subplot(4,1,1);
plot(1:length(M1(:,2)), M1(:,2));
subplot(4,1,2);
plot(1:length(M2(:,2)), M2(:,2));
subplot(4,1,3);
plot(1:length(M3(:,2)), M3(:,2));
subplot(4,1,4);
plot(1:length(M4(:,2)), M4(:,2));
