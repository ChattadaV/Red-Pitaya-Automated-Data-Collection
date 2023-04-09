%% Define Red Pitaya as TCP/IP object
clear;
IP = '169.254.140.86'; % Input IP of my Red Pitaya
port = 5000;
tcpipObj=tcpip(IP, port);   % MATLAB interfacing with Red Pitaya

%% Open connection with your Red Pitaya
fopen(tcpipObj);    % Open up object
tcpipObj.Terminator = 'CR/LF';  % Terminate object

%% Send SCPI command to Red Pitaya
fprintf(tcpipObj,'GEN:RST');
fprintf(tcpipObj,'SOUR1:FUNC DC');       % Set function of output signal
                                           % {sine, square, triangle, sawu,sawd, pwm}
fprintf(tcpipObj,'SOUR1:VOLT 1');          % Set amplitude of output signal
fprintf(tcpipObj,'OUTPUT1:STATE ON');      % Set output to ON

pause(5);

fprintf(tcpipObj, 'OUTPUT1:STATE OFF'); % Set output to off

%% Close connection with Red Pitaya
fclose(tcpipObj);
