function bwithde2(catalog) 
    % BWITHDE2 plot b-values with depth
    % BWITHDE2(catalog_name);
    
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    myFigName='b-value with depth';
    
    BV = [];
    BV3 = [];
    mag = [];
    me = [];
    av2=[];
    Nmin = 50;
    sdlg.prompt='Number of events in each window';sdlg.value=150;
    sdlg(2).prompt='Overlap factor';sdlg(2).value=5;
    
    [~,~, ni, ofac] = smart_inputdlg('b with depth input parameters',sdlg);
    
    ButtonName=questdlg('Mc determination?', ...
        ' Question', ...
        'Automatic','Fixed Mc=Mmin','Automatic');
    
    newt1=catalog;
    newt1.sort('Depth');
    watchon;
    
    for t = 1:ni/ofac:newt1.Count-ni
        % calculate b-value based an weighted LS
        b = newt1.subset(t:t+ni);
        
        switch ButtonName
            case 'Automatic'
                [Mc, Mc90, Mc95, magco]=mcperc_ca3(b.Magnitude);
                if ~isnan(Mc95)
                    magco = Mc95;
                elseif ~isnan(Mc90)
                    magco = Mc90;
                else
                    [bv, magco, stan, av] =  bvalca3(b.Magnitude, McAutoEstimate.auto);
                end
            case 'Fixed Mc=Mmin'
                magco = min(newt1.Magnitude);
        end
        
        l = b.Magnitude >= magco-0.05;
        if sum(l) >= Nmin
            [bv, stan, av] = calc_bmemag(b.Magnitude(l), 0.1);
        else
            [bv, bv2, magco, av, av2] = deal(nan);
        end
        BV = [BV ; bv newt1.Depth(t) ; bv newt1.Depth(t+ni) ; inf inf];
        BV3 = [BV3 ; bv newt1.Depth(t+round(ni/2)) stan ];
    end
    
    watchoff
    
    % Find out if figure already exists
    %
    bdep=findobj('Type','Figure','-and','Name',myFigName);
    
    % Set up the Cumulative Number window
    
    if isempty(bdep)
        bdep = figure_w_normalized_uicontrolunits( ...
            'Name',myFigName,...
            'NumberTitle','off', ...
            'NextPlot','add', ...
            'backingstore','on',...
            'Visible','on', ...
            'Position',position_in_current_monitor(ZG.map_len(1)-50, ZG.map_len(2)-20));
        
   %     uicontrol('Units','normal',...
   %         'Position',[.0 .85 .08 .06],'String','Info ',...
   %        'callback',@(~,~)infoz(1));
    end
    
    figure(bdep);
    delete(findobj(bdep,'Type','axes'));
    axis off
    set(gca,'NextPlot','add')
    orient tall
    rect = [0.25 0.15 0.5 0.75];
    axes('position',rect);
    ple = errorbar(BV3(:,2),BV3(:,1),BV3(:,3),BV3(:,3),'k');
    set(ple(1),'color',[0.5 0.5 0.5]);
    
    set(gca,'NextPlot','add')
    pl = plot(BV(:,2),BV(:,1),'color',[0.5 0.5 0.5]);
    pl = plot(BV3(:,2),BV3(:,1),'sk');
    
    set(pl,'LineWidth',1.0,'MarkerSize',4,...
        'MarkerFaceColor','w','MarkerEdgeColor','k','Marker','s');
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.m,'Linewidth',1,'Ticklength',[ 0.02 0.02])
    
    bax = gca;
    strib = [catalog.Name ', ni = ' num2str(ni), ', Mmin = ' num2str(min(catalog.Magnitude)) ];
    ylabel('b-value')
    xlabel('Depth [km]')
    title(strib,'FontWeight','bold',...
        'FontSize',ZmapGlobal.Data.fontsz.m,...
        'Color','k',...
        'Interpreter','none')
    
    xl = get(gca,'Xlim');
    view([90 90])
    
end
