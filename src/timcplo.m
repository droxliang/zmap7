function timcplo() % autogenerated function wrapper
    %  tidpl  plots a time projection plot of the seismicity
    %  Stefan Wiemer 5/95
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun(mfilename('fullpath'));
    
    
    newcat = a;
    xt2  = [ ];
    meand = [ ];
    er = [];
    ind = 0;
    
    % Find out of figure already exists
    %
    [existFlag,figNumber]=figure_exists('Time Distance',1);
    newDepWindowFlag=~existFlag;
    
    % Set up the Seismicity Map window Enviroment
    %
    if newDepWindowFlag
        
        figure_w_normalized_uicontrolunits(...
            'Name','Time Distance',...
            'visible','off',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Units','Pixel',  'Position',[ZG.welcome_pos 550 400'])
        tifg = gcf;
        hold on
        axis off
        
        create_my_menu();
        
    end  % if figure exist
    
    figure_w_normalized_uicontrolunits(tifg)
    
    delete(gca);delete(gca);delete(gca);
    set(gca,'visible','off');
    
    orient tall
    rect = [0.15, 0.15, 0.75, 0.65];
    axes('position',rect)
    p5 = gca;
    
    n = length(newa(1,:));
    deplo1 =plot(newa(newa(:,7)<=dep1,n),newa(newa(:,7)<=dep1,3),'.b');
    set(deplo1,'MarkerSize',ZG.ms6,'Marker',ty1,'era','normal')
    hold on
    deplo2 =plot(newa(newa(:,7)<=dep2&newa(:,7)>dep1,n),newa(newa(:,7)<=dep2&newa(:,7)>dep1,3),'.g');
    set(deplo2,'MarkerSize',ZG.ms6,'Marker',ty2,'era','normal');
    deplo3 =plot(newa(newa(:,7)<=dep3&newa(:,7)>dep2,n),newa(newa(:,7)<=dep3&newa(:,7)>dep2,3),'.r');
    set(deplo3,'MarkerSize',ZG.ms6,'Marker',ty3,'era','normal')
    
    hold on
    
    xlabel('Distance in [km] ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    ylabel('Time  in years ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1.2)
    
    grid
    hold off
    done
    
    %% ui functions
    function create_my_menu()
        add_menu_divider();
        add_symbol_menu();
    end
    
    %% callback functions
    % none.
end
