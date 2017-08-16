function findquar() % autogenerated function wrapper
% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The ratio of daytime to
% nighttie evemts will be mapped.
 % turned into function by Celso G Reyes 2017
 
ZG=ZmapGlobal.Data; % used by get_zmap_globals

%   Stefan Wiemer 1/99

report_this_filefun(mfilename('fullpath'));

if sel == 'in'
    % get the grid parameter
    % initial values
    %
    dx = 1.00;
    dy = 1.00 ;
    ni = 100;

    % make the interface
    %
    figure_w_normalized_uicontrolunits(...
        'Name','Map day/nighttime event ratio',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','off', ...
        'Position',[ ZG.wex+200 ZG.wey-200 450 250]);
    axis off



    % creates a dialog box to input grid parameters
    %
    freq_field=uicontrol('Style','edit',...
        'Position',[.60 .50 .22 .10],...
        'Units','normalized','String',num2str(ni),...
        'callback',@callbackfun_001);

    freq_field2=uicontrol('Style','edit',...
        'Position',[.60 .40 .22 .10],...
        'Units','normalized','String',num2str(dx),...
        'callback',@callbackfun_002);

    freq_field3=uicontrol('Style','edit',...
        'Position',[.60 .30 .22 .10],...
        'Units','normalized','String',num2str(dy),...
        'callback',@callbackfun_003);

    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .15 .12 ],...
        'Units','normalized','callback',@callbackfun_004,'String','Cancel');

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.20 .05 .15 .12 ],...
        'Units','normalized',...
        'callback',@callbackfun_005,...
        'String','Go');



    txt3 = text(...
        'Position',[0.30 0.64 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.l ,...
        'FontWeight','bold',...
        'String',' Grid Parameter');
    txt5 = text(...
        'Position',[0. 0.42 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in x (dx) in deg:');

    txt6 = text(...
        'Position',[0. 0.32 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String','Spacing in y (dy) in deg:');

    txt1 = text(...
        'Position',[0. 0.53 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'FontWeight','bold',...
        'String','Number of Events (Ni):');
    set(gcf,'visible','on');
    watchoff

end   % if nargin ==0

% get the grid-size interactively and
% calculate the b-value in the grid by sorting
% thge seimicity and selectiong the ni neighbors
% to each grid point


if sel == 'hr'

    figure_w_normalized_uicontrolunits(...
        'Name','Daytime (explosion) hours',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'units','points',...
        'Visible','on', ...
        'Position',[ 100 200 400 450]);
    axis off
    text(...
        'Position',[0. 0.90 0 ],...
        'FontSize',ZmapGlobal.Data.fontsz.m ,...
        'FontWeight','bold',...
        'String',' Select the daytime hours and then ''GO''  ');

    fihr = gcf
    hold on
    axes('pos',[0.1 0.2 0.6 0.6]);
    histogram(ZG.a.Date.Hour,-0.5:1:24.5);
    [X,N] = hist(ZG.a.Date.Hour,-0.5:1:24.5);

    xlabel('Hr of the day')
    ylabel('Number of events per hour')


    for i = 1:24
        uicontrol('Style','checkbox',...
            'string',[num2str(i-1) ' - ' num2str(i) ],...
            'Position',[.80 1-i/28-0.03 .17 1/26],'tag',num2str(i),...
            'Units','normalized');
    end

    l = find(X > prctile2(X,60));
    for i = 1:length(l)
        j = findobj('tag',num2str(l(i)));
        set(j,'value',1);
    end

    go_button1=uicontrol('Style','Pushbutton',...
        'Position',[.0 .05 .1 .1 ],...
        'Units','normalized',...
        'callback',@callbackfun_006,...
        'String','Go');

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Info ',...
         'callback',@callbackfun_007);

end



if sel == 'ca'

    D = [];
    for i = 1:24
        j = findobj('tag',num2str(i));
        k = get(j,'value');
        if k == 1; D = [D i]; end
    end
    D = D-1;

    close(fihr)


    selgp
    itotal = length(newgri(:,1));
    zmap_message_center.set_info(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = min(ZG.a.Date)  ;
    n = ZG.a.Count;
    teb = max(ZG.a.Date) ;
    tdiff = round((teb-t0b)/ZG.bin_days);
    loc = zeros(3, length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    ld = length(D);
    ln = 24 - ld;


    % loop over all points
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l=ZG.a.epicentralDistanceTo(x,y);
        [s,is] = sort(l);
        b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise

        % take first ni points
        b = b(1:ni,:);      % new data per grid point (b) is sorted in distance

        % call the b-value function


        l2 = sort(l);
        l = ismember(b(:,8),D);
        %l = b(:,8) >=7 & b(:,8) <=18;
        day = b(l,:);
        nig = b;
        nig(l,:) = [];
        rat = length(day(:,1))/length(nig(:,1)) * ln/ld;

        bvg = [bvg; rat  x y l2(ni) ];
        waitbar(allcount/itotal)
    end  % for newgr

    close(wai)
    watchoff

    % plot the results
    % old and re3 (initially ) is the b-value matrix
    %
    normlap2=ones(length(tmpgri(:,1)),1)*nan;
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));

    normlap2(ll)= bvg(:,4);
    r=reshape(normlap2,length(yvect),length(xvect));

    old = re3;

    % View the b-value map
    view_qva
    %deleted an end


end   % if sel = na


function callbackfun_001(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  ni=str2double(freq_field.String);
   freq_field.String=num2str(ni);
end
 
function callbackfun_002(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  dx=str2double(freq_field2.String);
   freq_field2.String=num2str(dx);
end
 
function callbackfun_003(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  dy=str2double(freq_field3.String);
   freq_field3.String=num2str(dy);
end
 
function callbackfun_004(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  close;
  done;
end
 
function callbackfun_005(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  close;
  sel ='hr';
   findquar;
end
 
function callbackfun_006(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
  sel ='ca';
   findquar;
end
 
function callbackfun_007(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'));
   web(['file:' hodi '/help/quarry.htm']) ;
end
 
end
