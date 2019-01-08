function view_Dv() 
    % plots the maxz LTA values calculated
    % with maxzlta.m or other similar values as a color map
    % needs valueMap, gx, gy, stri
    % Called from Dcross.m
    %
    % define size of the plot etc.
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals

    
    report_this_filefun();
    myFigName='D-value cross-section';
    myFigFinder=@() findobj('Type','Figure','-and','Name',myFigName);
    ZG.someColor = 'w';
    
    bmapc=myFigFinder();
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(bmapc)
        bmapc = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        % make menu bar
        
        lab1 = 'D-value';
        
        uicontrol('Units','normal',...
            'Position',[.0 .95 .08 .06],'String','Info ',...
            'callback',@callbackfun_001)
        
        colormap(jet)
    end   % This is the end of the figure setup
    
    % Now lets plot the color-map of the D-value
    %
    figure(bmapc);
    delete(findobj(bmapc,'Type','axes'));
    % delete(sizmap);
    reset(gca)
    cla
    watchon;
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1,...
        'Box','on','SortMethod','childorder')
    
    rect = [0.10,  0.10, 0.8, 0.75];
    rect1 = rect;
    
    % set values greater ZG.tresh_km = nan
    %
    re4 = valueMap;
    l = r > ZG.tresh_km;
    re4(l) = nan(1,length(find(l)));
    
    % plot image
    %
    orient portrait
    %set(gcf,'PaperPosition', [2. 1 7.0 5.0])
    
    axes('position',rect)
    set(gca,'NextPlot','add')
    % Here is the importnnt  line ...
    pco1 = pcolor(gx,gy,re4);
    
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    set(gca,'NextPlot','add');
    
    shading(ZG.shading_style);
    
    %end
    

    fix_caxis.ApplyIfFrozen(gca); 
    
    title([name],'FontSize',12,...
        'Color','w','FontWeight','bold')
    %num2str(t0b,4) ' to ' num2str(teb,4)
    xlabel('Distance in [km]','FontWeight','bold','FontSize',12)
    ylabel('Depth in [km]','FontWeight','bold','FontSize',12)
    
    % plot overlay
    %
    ploeqc = plot(Da(:,1),-Da(:,7),'.k');
    set(ploeq,'Tag','eqc_plot''MarkerSize',ZG.ms6,'Marker',ty,'Color',ZG.someColor,'Visible','on')
    
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    h1 = gca;
    hzma = gca;
    
    % Create a colorbar
    %
    h5 = colorbar('horz');
    apo = get(h1,'pos');
    set(h5,'Pos',[0.3 0.1 0.4 0.02],...
        'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'TickDir','out')
    
    rect = [0.00,  0.0, 1 1];
    axes('position',rect)
    axis('off')
    
    %  Text Object Creation
    
    txt1 = text(...
        'Color',[ 1 1 1 ],...
        'Position',[0.55 0.03],...
        'HorizontalAlignment','right',...
        'FontSize',ZmapGlobal.Data.fontsz.m,....
        'FontWeight','bold',...
        'String',lab1);
    
    % Make the figure visible
    
    axes(h1)
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
    whitebg(gcf,[0 0 0])
    set(gcf,'Color',[ 0 0 0 ])
    figure(bmapc);
    watchoff(bmapc)
    
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        
        add_symbol_menu('eqc_plot');
        create_my_menu();
        
        
        options = uimenu('Label',' Select ');
        uimenu(options,'Label','Refresh ',MenuSelectedField(),@callbackfun_002)
        
        uimenu(options,'Label','Select EQ in Sphere (const N)',...
            MenuSelectedField(),@callbackfun_003)
        uimenu(options,'Label','Select EQ in Sphere (const R)',...
            MenuSelectedField(),@callbackfun_004)
        uimenu(options,'Label','Select EQ in Sphere (N) - Overlay existing plot',...
            MenuSelectedField(),@callbackfun_005)
        %
        %
        
        op1 = uimenu('Label',' Maps ');
        
        uimenu(op1,'Label','D-value Map (weighted LS)',...
            MenuSelectedField(),@callbackfun_006);
        
        %  uimenu(op1,'Label','Goodness of fit  map',...
        %      MenuSelectedField(),@callbackfun_007);
        
        uimenu(op1,'Label','b-value Map',...
            MenuSelectedField(),@callbackfun_008);
        
        uimenu(op1,'Label','resolution Map',...
            MenuSelectedField(),@callbackfun_009);
        
        uimenu(op1,'Label','Histogram ',MenuSelectedField(),@(~,~)zhist());
        
        uimenu(op1,'Label','D versus b',...
            MenuSelectedField(),@callbackfun_011);
        
        uimenu(op1,'Label','D versus Resolution',...
            MenuSelectedField(),@callbackfun_012)
        %
        add_display_menu(3);
    end
    
    %% callback functions
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        view_Dv;
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        ic = 1;
        org = 5;
        startfd(5);
    end
    
    function callbackfun_004(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=false;
        icCircl = 2;
        org = 5;
        startfd(5);
    end
    
    function callbackfun_005(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        h1 = gca;
        ZG=ZmapGlobal.Data;
        ZG.hold_state=true;
        ic = 1;
        org = 5;
        startfd(5);
    end
    
    function callbackfun_006(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='D-value';
        valueMap = old;
        view_Dv;
    end
    
    function callbackfun_007(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='%';
        valueMap = Prmap;
        view_Dv;
    end
    
    function callbackfun_008(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='b-value';
        valueMap = BM;
        view_Dv;
    end
    
    function callbackfun_009(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        lab1='Radius in [km]';
        valueMap = reso;
        view_Dv;
    end
    
    function callbackfun_011(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        Dvbspat;
    end
    
    function callbackfun_012(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        Dvresfig;
    end
    
end
