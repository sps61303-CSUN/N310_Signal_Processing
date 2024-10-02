function FourChannelOscope(samp_rate)
%This program connects with GNU Radio over TCP and reads 4 complex data streams.
%Real-time data is used to create an adustable oscilloscope plot.
%When you are done, use the "STOP" button on the plot to halt the program.

%Address = '192.168.56.101'

%Compute oscilloscope parameters
refresh_rate = 20;
SampleSize = round(samp_rate/refresh_rate);

%Ping GNU Radio Host
Ping = evalc('!ping -c 1 192.168.56.101');
Loss = regexp(Ping, '([0-9]*)%.*loss', 'tokens');
if isempty(Loss) | str2double(Loss{1}{1})~=0
    disp("Host Unreachable")
    return
end

%Connect to host over TCP
try
RFclient = tcpclient('192.168.56.101',2000,'Timeout',1,'EnableTransferDelay',false);
catch
   disp("TCP Connection Refused.")
   return
end

%Create Stop Button and Axis Controls
yscale = 0; xscale = 0; Loop = 1;
figure(1)
Button1 = uicontrol('Style','pushbutton','Position',[0 0 60 30],'String','STOP','Callback', @Stop);
Button2 = uicontrol('Style','pushbutton','Position',[80 0 60 30],'String','x zoom-','Callback', @xpp);
Button3 = uicontrol('Style','pushbutton','Position',[160 0 60 30],'String','x zoom+','Callback', @xmm);
Button4 = uicontrol('Style','pushbutton','Position',[240 0 60 30],'String','y zoom-','Callback', @ypp);
Button5 = uicontrol('Style','pushbutton','Position',[320 0 60 30],'String','y zoom+','Callback', @ymm);
while Loop
    %Read RF data from TCP Client
    RFdata = read(RFclient,SampleSize*8,"single");
    X_t = Reshape4Channel(RFdata).';

    %Generate Data Window
    Window = 1:(200*10^(xscale/8));
    TimeWindow = (Window-1)/samp_rate;

    %Start graph at signal peak
    [Max Start] = max(real(X_t(1,Window)));
    SampleWindow = Start:(Start+length(Window)-1);

    %Plot real part of channels
    plot(TimeWindow,real(X_t(:,SampleWindow)))
    ylim([-10^(yscale/8) 10^(yscale/8)])
    xlim('tight')
    grid on
end

% Nested callback functions for buttons:
  function Stop(~, ~)
    Loop = false;
  end

  function xpp(~, ~)
    if xscale<14
        xscale = xscale+1;
    end
  end

  function xmm(~, ~)
      if xscale>-10
        xscale = xscale-1;
      end
  end

  function ypp(~, ~)
    yscale = yscale+1;
  end

  function ymm(~, ~)
    yscale = yscale-1;
  end
end

function A = Reshape4Channel(B)
%4CHANNELRESHAPE 
T = [1 0 0 0; 1j 0 0 0; 0 1 0 0; 0 1j 0 0; 0 0 1 0; 0 0 1j 0; 0 0 0 1; ...
     0 0 0 1j];
A = reshape(B,8,length(B)/8).'*T; 
end