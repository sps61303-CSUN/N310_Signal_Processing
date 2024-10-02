%This program connects with GNU Radio over TCP and reads 4 complex data streams.
%Real-time data is used to create an adustable oscilloscope plot.
%When you are done, use the "STOP" button on the plot to halt the program.

clear, clc, close all
format short, format compact

samp_rate = 1E6; %samples per second
refresh_rate = 20; %updates per second

%Compute oscilloscope parameters
SampleSize = round(samp_rate/refresh_rate);

%Connect to virtual machine client
RFclient = tcpclient("192.168.56.101",2000,"Timeout",1);

%Create Stop Button and Axis Controls
yscale = 0; xscale = 0; Loop = 1;
figure(1)
Button1 = uicontrol('Style','pushbutton','Position',[0 0 60 30],'String','STOP','Callback', 'Loop = 0;');
Button2 = uicontrol('Style','pushbutton','Position',[80 0 60 30],'String','x zoom-','Callback', 'xscale = xscale+1;');
Button3 = uicontrol('Style','pushbutton','Position',[160 0 60 30],'String','x zoom+','Callback', 'xscale = xscale-1;');
Button4 = uicontrol('Style','pushbutton','Position',[240 0 60 30],'String','y zoom-','Callback', 'yscale = yscale+1;');
Button5 = uicontrol('Style','pushbutton','Position',[320 0 60 30],'String','y zoom+','Callback', 'yscale = yscale-1;');
while Loop
    %Read RF data from TCP Client
    RFdata = read(RFclient,SampleSize*8,"single");
    X_t = Reshape4Channel(RFdata).';

    %Generate Data Window
    Window = 1:(100*10^(xscale/8));
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
flush(RFclient)
clear all
