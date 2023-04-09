%% Define Red Pitaya as TCP/IP object
clear;
IP = '169.254.140.86'; % Input IP of my Red Pitaya
port = 5000;
tcpipObj=tcpip(IP, port);   % MATLAB interfacing with Red Pitaya

%% Open connection with your Red Pitaya
fopen(tcpipObj);    % Open up object
tcpipObj.Terminator = 'CR/LF';  % Terminate object

%% Send SCPI command to Red Pitaya to turn ON LED1
fprintf(tcpipObj,'DIG:PIN LED1,1');
pause(5)                         % Set time of LED ON

%% Send SCPI command to Red Pitaya to turn OFF LED1
fprintf(tcpipObj,'DIG:PIN LED1,0');

%% Close connection with Red Pitaya
fclose(tcpipObj);