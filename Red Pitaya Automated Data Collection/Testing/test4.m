%% Define Red Pitaya as TCP/IP object
clear;
IP = '169.254.140.86'; % Input IP of my Red Pitaya
port = 5000;
tcpipObj = tcpip(IP, port);   % MATLAB interfacing with Red Pitaya
tcpipObj.InputBufferSize = 16384*32;    % 2-bit float

%% Open connection with your Red Pitaya
fopen(tcpipObj);    % Open up object
tcpipObj.Terminator = 'CR/LF';  % Terminate object

flushinput(tcpipObj);   % Start communication
flushoutput(tcpipObj);  % Start communication

%% Send SCPI command to Red Pitaya
fprintf(tcpipObj, 'GEN:RST');    % Start fresh
fprintf(tcpipObj, 'SOUR1:FUNC SINE');   % Sine wave
fprintf(tcpipObj, 'SOUR1:FREQ:FIX 1000');    % Set frequency of output to 1000
fprintf(tcpipObj, 'SOUR1:VOLT 1');   % Set amplitude of output to 1

%% Set Acquire/generator properties
fprintf(tcpipObj, 'ACQ:RST');   % Start fresh
fprintf(tcpipObj, 'ACQ:DEC 8'); % Set decade to 1
fprintf(tcpipObj, 'ACQ:SOUR1:GAIN HV');
fprintf(tcpipObj, 'ACQ:TRIG:LEV 0');    % Set trigger level to 0
fprintf(tcpipObj, 'ACQ:TRIG:DLY 0');    % Set delay to 0

%% Start gen % acq and measuring
fprintf(tcpipObj, 'OUTPUT1:STATE ON');  % Set outoput to on

pause(1);

fprintf(tcpipObj, 'ACQ:START');     % Start measuring
fprintf(tcpipObj, 'ACQ:TRIG CH1_PE');   % Channel 1 Positive Edge

%% Wait for the trigger
while 1
    trig_rsp = query(tcpipObj, 'ACQ:TRIG:STAT?');
    if strcmp('TD', trig_rsp(1:2))
        break
    end
end

%% Read and plot
signal_str = query(tcpipObj, 'ACQ:SOUR1:DATA?');
signal_num = str2num(signal_str(1, (2:length(signal_str)-3)));    % Remove the first and last two characters from string
%time = linspace(0, length(signal_num/15258, length(signal_num)));

plot(signal_num);
%hold on
grid on;

%% Close connection
fclose(tcpipObj);
