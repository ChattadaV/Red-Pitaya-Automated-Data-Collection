%% Define Red Pitaya as TCP/IP object
clear; clc;
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
setFreq(tcpipObj, 1000);    % Intial frequency
fprintf(tcpipObj, 'SOUR1:VOLT 1');   % Set amplitude of output to 1

%% Set Acquire/generator properties
fprintf(tcpipObj, 'ACQ:RST');   % Start fresh
setDec(tcpipObj, 1000);    % Set decimation from local function
fprintf(tcpipObj, 'ACQ:SOUR1:GAIN HV'); % Set input probe to high voltage
fprintf(tcpipObj, 'ACQ:TRIG:LEV 0');    % Set trigger level to 0
fprintf(tcpipObj, 'ACQ:TRIG:DLY 0');    % Set delay to 0

%% Start gen % acq and measuring
fprintf(tcpipObj, 'OUTPUT1:STATE ON');  % Set outoput to on
pause(1);

%time = linspace(0, length(signal_num/15258, length(signal_num)));

pts = 20;   % Points in the decade
freqRange = 100 * logspace(0, 3, pts);  % From 100Hz to 100kHz log spaced
maxVals = zeros(1, pts);

for i = 1:pts
    setFreq(tcpipObj, freqRange(i));    % Set frquency range
    setDec(tcpipObj, freqRange(i));     % Set decimation
    maxVals(i) = getMax(tcpipObj);      % Max value at each frequency range
end

%% Plot
semilogx(freqRange, maxVals);   %semilog scale on x-axis
ylim([0 1]);    % Y-axis from 0 to 1

%% Write data
table = array2table([freqRange', maxVals']);    % convert table values to columns
table.Properties.VariableNames(1:2) = {'FREQ', 'AMP (V)'};  % Cahnge table column's names
writetable(table, 'data.csv');

%% Close connection
fclose(tcpipObj);

%% Function
function Max = getMax(tcpipObj)
    fprintf(tcpipObj, 'ACQ:START');     % Start measuring
    fprintf(tcpipObj, 'ACQ:TRIG CH1_PE');   % Channel 1 Positive Edge

    % Wait for the trigger
    while 1
        trig_rsp = query(tcpipObj, 'ACQ:TRIG:STAT?');
        if strcmp('TD', trig_rsp(1:2))
            break
        end
    end

    % Read and plot
    signal_str = query(tcpipObj, 'ACQ:SOUR1:DATA?');
    signal_num = str2num(signal_str(1, (2:length(signal_str)-3)));    % Remove the first and last two characters from string
    Max = max(signal_num);
end

function setFreq(tcpipObj, freq)
    str = sprintf('SOUR1:FREQ:FIX %f', freq);  %floats
    fprintf(tcpipObj, str);    % Set frequency of output to 1000
end

function setDec(tcpipObj, freq)
    period = 1 / freq;
    
    % Refer to 2.3.1.4.5 Red Pitaya sampling rate and decimations
    if period > 1.074
        dec = 65536;
    elseif period > (134.218 * 10 ^ (-3))
        dec = 8192;
    elseif period > (8.389 * 10 ^ (-3))
        dec = 1024;
    elseif period > (1.049 * 10 ^ (-3))
        dec = 64;
    elseif period > (131.072 * 10 ^ (-6))
        dec = 8;
    else
        dec = 1;
    end
    
    str = sprintf('ACQ:DEC %d', dec);    % Integer
    fprintf(tcpipObj, str);     % Set decade
end
