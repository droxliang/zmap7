% Script: plot_circbootfitF
% Selects earthquakes in the radius ra around a grid node and calculates the forecast
% by using calc_bootfitF.m
%
% Jochen Woessner
% last update: 17.07.03

report_this_filefun(mfilename('fullpath'));
try
    delete(plos1)
catch
    disp(' ');
end

axes(h1)
%zoom off

titStr ='Selecting EQ in Circles                         ';
messtext= ...
    ['                                                '
    '  Please use the LEFT mouse button              '
    ' to select the center point.                    '
    ' The "ni" events nearest to this point          '
    ' will be selected and displayed in the map.     '];

zmap_message_center.set_message(titStr,messtext);

% Input center of circle with mouse
%
[xa0,ya0]  = ginput(1);

stri1 = [ 'Circle: ' num2str(xa0,5) '; ' num2str(ya0,4)];
stri = stri1;
pause(0.1)

%  Calculate distance for each earthquake from center point
%  and sort by distance l
l = ZG.a.epicentralDistanceTo(ya0,xa0);

ZG.newt2=ZG.a.subset(l); % reorder & copy

% Select data in radius ra
l3 = l <=ra;
ZG.newt2 = ZG.newt2.subset(l3);

% Select radius in time
newt3=ZG.newt2;
vSel = (ZG.newt2.Date <= ZG.maepi.Date+days(time));
ZG.newt2 = ZG.newt2.subset(vSel);
R2 = l(ni);
messtext = ['Number of selected events: ' num2str(length(ZG.newt2))  ];
disp(messtext)
zmap_message_center.set_message('Message',messtext)



% Sort the catalog
[st,ist] = sort(ZG.newt2);
ZG.newt2 = ZG.newt2(ist(:,3),:);
R2 = ra;

% Plot selected earthquakes
hold on
plos1 = plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'xk','EraseMode','normal');

% plot circle containing events as circle
x = -pi-0.1:0.1:pi;
pl = plot(xa0+sin(x)*R2/(cosd(ya0)*111), ya0+cos(x)*R2/(cosd(ya0)*111),'k','era','normal')

% Compute and Plot the forecast
calc_bootfitF(newt3,time,timef,bootloops,ZG.maepi)

set(gcf,'Pointer','arrow')
%
newcat = ZG.newt2;                   % resets ZG.newcat and ZG.newt2

% Call program "timeplot to plot cumulative number
clear l s is
timeplot(ZG.newt2)
