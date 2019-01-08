function fdparain(gobut)
    % Creates the input window for the parameters of the factal dimension calculation.
    %
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    figure_w_normalized_uicontrolunits('Units','pixel','pos',[200 400 550 200 ],'Name','Parameters','visible','off',...
        'NumberTitle','off','Color',ZG.color_bg,'NextPlot','new'); % was color_fbg
    axis off;
    
    
    input1 = uicontrol('Style','popupmenu','Position',[.75 .75 .23 .09],...
        'Units','normalized','String','Automatic Range|Manual Fixed Range|Manual',...
        'Value',1, 'Callback', @callbackfun_001);
    
    input2 = uicontrol('Style','edit','Position',[.34 .43 .10 .09],...
        'Units','normalized','String',num2str(radm), 'enable', 'off',...
        'Value',1, 'Callback', @callbackfun_002);
    
    input3 = uicontrol('Style','edit','Position',[.75 .43 .10 .09],...
        'Units','normalized','String',num2str(rasm), 'enable', 'off',...
        'Value',1, 'Callback', @callbackfun_003);
    
    
    
    
    tx1 = text('Position',[0 .85 0 ], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String',' Distance Range within which D is computed: ');
    
    tx2 = text('Position',[0 .45 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','Minimum value: ', 'color', 'w');
    
    tx3 = text('Position',[.52 .45 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','Maximum value: ', 'color', 'w');
    
    tx4 = text('Position',[.41 .45 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','km', 'color', 'w');
    
    tx5 = text('Position',[.94 .45 0], ...
        'FontSize',ZmapGlobal.Data.fontsz.m , 'FontWeight','bold' , 'String','km', 'color', 'w');
    
    
    close_button=uicontrol('Style','Pushbutton',...
        'Position',[.60 .05 .20 .15 ],...
        'Units','normalized', 'Callback', @callbackfun_004,'String','Cancel');
    
    
    switch (gobut)
        
        case 1   %Defined in timeplot.m, dorand.m,
            
            go_button=uicontrol('Style','Pushbutton',...
                'Position',[.20 .05 .20 .15 ],...
                'Units','normalized',...
                'callback',@callbackfun_005,...
                'String','Go');
            
            
        case 2  %defined in fdtimin.m
            
            go_button=uicontrol('Style','Pushbutton',...
                'Position',[.20 .05 .20 .15 ],...
                'Units','normalized',...
                'callback',@callbackfun_006,...
                'String','Go');
            
            
        case 3  %defined in Dcross.m
            
            go_button=uicontrol('Style','Pushbutton',...
                'Position',[.20 .05 .20 .15 ],...
                'Units','normalized',...
                'callback',@callbackfun_007,...
                'String','Go');
            
    end  %switch(gobut)
    
    set(gcf,'visible','on');
    watchoff;
    
    function callbackfun_001(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        range=(get(input1,'Value'));
        input1.Value=range;
        actrange(range);
    end
    
    function callbackfun_002(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        radm=str2double(input2.String);
        input2.String= num2str(radm);
    end
    
    function callbackfun_003(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        rasm=str2double(input3.String);
        input3.String= num2str(rasm);
    end
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
    end
    
    function callbackfun_005(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
        org = 2;
        startfd(2);
    end
    
    function callbackfun_006(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
        fdtime;
    end
    
    function callbackfun_007(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        
        Dcross('ca');
    end
    
end
