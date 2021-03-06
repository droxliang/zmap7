function zhist() 
    % this script plots the z-values from a timecut of the map
    % works off ZG.ZG.valueMap
    % Stefan Wiemer  11/94
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    % This is the info window text
    %
    ttlStr='The Histogram Window                                ';
    hlpStr1= ...
        ['                                                '
        ' This window displays all z-values displayed in '
        ' the z-value map, therefore all the z-values at '
        ' this specific cut in time for the applied      '
        'statstical function.                            '];
    
    
    watchon
    hi=findobj('Type','Figure','-and','Name','Histogram');
    
    %
    % Set up the Cumulative Number window
    
    if isempty(hi)
        hi= figure_w_normalized_uicontrolunits( ...
            'Name','Histogram',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1)-200, ZG.map_len(2)-200));
        
    else
        clf(hi)
    end
    figure(hi);
    
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')
    
    orient tall
    rect = [0.25,  0.18, 0.60, 0.70];
    axes('position',rect)
    set(gca,'NextPlot','add')
    [m,n] = size(ZG.valueMap);
    reall = reshape(ZG.valueMap,1,m*n);
    l = isnan(reall);
    reall(l) = [];
    [n,x] =hist(reall,30);
    bar(x,n,'k');
    grid
    xlabel('z-value','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m) %what is lab1, at the moment just print 'z-value'
    ylabel('Number ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')
    set(hi,'Visible','on');
    figure(hi);
    watchoff;
    
end
