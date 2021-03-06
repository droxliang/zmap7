function sucra() 
    % This script evaluates the percentage of space time coevered by
    %alarms
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    global iala
    re = [];
    % Stefan Wiemer    4/95
    
    report_this_filefun();
    
    abo = abo2;
    
    for tre2 = min(abo(:,4)):0.1:max(abo(:,4)-0.1)
        abo = abo2;
        abo(:,5) = abo(:,5)* days(ZG.bin_dur) + ZG.primeCatalog.Date(1);
        l = abo(:,4) >= tre2;
        abo = abo(l,:);
        l = abo(:,3) < ZG.tresh_km;
        abo = abo(l,:);
        set(gca,'NextPlot','add')
        
        % space time volume covered by alarms
        if isempty(abo)
            Va = 0;
        else
            Va = sum(pi*abo(:,3).^2)*iala;
        end
        
        % All space time
        [len, ncu] = size(cumuall);
        
        r = loc(3,:);
        %r = reshape(cumuall(len,:),length(gy),length(gx));
        %r=reshape(normlap2,length(yvect),length(xvect));
        l = r < ZG.tresh_km;
        V = sum(pi*r(l).^2*(teb-t0b));
        disp([' Zalarm = ' num2str(tre2)])
        disp([' =============================================='])
        disp([' Total space-time volume (R<Rmin):  ' num2str(V)])
        disp([' Space-time volume covered with alarms (R<Rmin):  ' num2str(Va)])
        disp([' Percent of total covered with alarms (R<Rmin):  ' num2str(Va/V*100) ' Percent' ])
        
        re = [re ; tre2 Va/V*100 ];
    end   % for tre2
    
    
    figure
    
    
    axis off
    
    uicontrol('Units','normal',...
        'Position',[.0 .65 .08 .06],'String','Save ',...
        'Callback',{@calSave9, re(:,1), re(:,2)})
    
    rect = [0.20,  0.10, 0.70, 0.60];
    axes('position',rect)
    set(gca,'NextPlot','add')
    pl = semilogy(re(:,1),re(:,2),'r');
    set(pl,'LineWidth',1.5)
    pl = semilogy(re(:,1),re(:,2),'ob');
    set(pl,'LineWidth',1.5,'MarkerSize',10)
    set(gca,'YScale','log')
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on')
    grid
    
    ylabel('Va/Vtotal in %')
    xlabel('Zalarm ')
    watchoff
    
    
end
