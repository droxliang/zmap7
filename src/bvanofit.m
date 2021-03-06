function bvanofit(mycat, seg1, seg2) 
    % bvanofit  Calculates Freq-Mag functions (b-value) for two time-segments
    %   finds best fit to the foreground for a modified background
    %   assuming a change in time of the following types:
    %   Mnew = Mold + d     , i.e. Simple magnitude shift
    %   Mnew = c*Mold + d   , i.e. Mag stretch plus shift
    %   Nnew = fac*Nold     , i.e. Rate change (N = number of events)
    %
    % bvanofit(catalog)
    %                                      R. Zuniga IGF-UNAM/GI-UAF  6/94
    % turned into function by Celso G Reyes 2017
    
    % used to work from newt2 and set newcat
    
    report_this_filefun();
    ZG=ZmapGlobal.Data;
    ms3 = 5;
    t1p=seg1(1);
    t2p=seg1(2);
    t3p=seg2(1);
    t4p=seg2(2);
    % This is the info window text
    %
    ttlStr='Comparing Seismicity rates ';
    hlpStr1map= ...
        ['                                                '
        ' To be Implemented                              '
        '                                                '];
    % Find out if figure already exists
    %
    bvfig=findobj('Type','Figure','-and','Name','Compare two rates');
    
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(bvfig)
        bvfig= figure_w_normalized_uicontrolunits( ...
            'Name','Compare two rates',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'Visible','on');%, ...
        %'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)+200));
        
        %{
        uicontrol('Units','normal',...
            'Position',[.0 .93 .08 .06],'String','Print ',...
            'callback',@callbackfun_001)
        
        uicontrol('Units','normal',...
            'Position',[.0 .75 .08 .06],'String','Close ',...
            'callback',@callbackfun_002)
        
        uicontrol('Units','normal',...
            'Position',[.0 .85 .08 .06],'String','Info ',...
            'callback',@callbackfun_003)
        %}
        axis off
        
        
    end % if figure exits
    
    figure(bvfig);
    clf
    %delete(findobj(bvfig,'Type','axes'));
    format short;
    
    if isempty(mycat), mycat = ZG.primeCatalog; end
    [minmag2, maxmag] = bounds(mycat.Magnitude);
    n = mycat.Count;
    tdiff = round(days(mycat.DateSpan()));
    
    % number of mag units
    %nmagu = (maxmag*10)+1;
    
    %backg_beN = [ ];
    %backg_abN = [ ];
    td12 = t2p - t1p;
    td34 = t4p - t3p;
    
    
    magsteps_desc = (maxmag:-0.1:minmag2);
    xt3edges = fliplr([magsteps_desc+.05 magsteps_desc(end)-.05]);
    
    
    %bg_seg = segmentAnalytics(mycat,'background',t1p,t2p); %instead of first segment
    %fg_seg = segmentAnalytics(mycat,'foreground',t3p,t4p); %instead of second segment
    
    %% first segment
    l = mycat.Date > t1p & mycat.Date < t2p ;
    backg =  mycat.subset(l);
    [bval,~] = histcounts(backg.Magnitude,xt3edges);%hist
    xt2=magsteps_desc; % based off of magnitude centers, not edges
    bval = bval / days(td12);                      % normalization
    assert(size(bval,1)<=1,'expecting a long row');
    bvalsum = cumsum(bval);                        % N for M <=
    bvalsum_bkw = cumsum(fliplr(bval));    % N for M >= (counted backwards) (was valsum3)
    %[cumux, xt] = hist(mycat.Date(l),t1p:days(ZG.bin_dur):t2p);
    [cumux, xt] = histcounts(mycat.Date(l),'BinWidth',ZG.bin_dur);
    mean1 = mean(cumux);
    var1 = cov(cumux);
    
    %% second segment
    l = mycat.Date > t3p & mycat.Date < t4p ;
    foreg = mycat.subset(l);
    [bval2,xt3a] = histcounts(foreg.Magnitude,xt3edges); %was histogram
    bval2 = bval2/days(td34);
    bvalsum2 = cumsum(bval2);
    bvalsum2_bkw=cumsum(fliplr(bval2)); % was bvalsum4
    % [cumux2, xt] = hist(mycat.Date(l),t3p:days(ZG.bin_dur):t4p);
    [cumux2, xt] = histcounts(mycat.Date(l),'BinWidth',ZG.bin_dur);
    mean2 = mean(cumux2);
    var2 = cov(cumux2);
    zscore = (mean1 - mean2)/(sqrt(var1/length(cumux)+var2/length(cumux2)));
    
    %change in percent
    R1 = backg.Count/days(t2p-t1p);
    R2 = foreg.Count/days(t4p-t3p);
    change = -((R1-R2)/R1)*100;
    
    %{
    backg_be = log10(bvalsum);
    backg_ab = log10(bvalsum_bkw);
    foreg_be = log10(bvalsum2);
    foreg_ab = log10(bvalsum2_bkw);
    %}
    
    % plot b-value plot
    %
    orient tall
    set(gcf,'PaperPosition',[2 1 5.5 7.5])
    p1 = subplot(5,1,[1 2]);
    %rect = [0.20,  0.7, 0.70, 0.25];           % plot Freq-Mag curves
    %axes('position',rect)
    figure(bvfig);
    
    d2char=@(d)[char(d,'yyyy-') num2str(days(d-dateshift(d,'start','year')),'%06.2f') ];
    
    segA_linespec = 'xb-';
    segA_dispname = [ d2char(t3p) ' - '  d2char(t4p)];
    
    segB_linespec = 'om-.';
    segB_dispname = [d2char(t1p) ' - ' d2char(t2p)]
    
    semilogy(p1,magsteps_desc,bvalsum2_bkw,segA_linespec,'MarkerSize',ms3,'DisplayName',segA_dispname);
    set(gca,'NextPlot','add')
    semilogy(p1,magsteps_desc,bvalsum_bkw,segB_linespec,'MarkerSize',ms3,'DisplayName',segB_dispname);
    legend show
    
    te1 = max([bvalsum  bvalsum2 bvalsum2_bkw bvalsum_bkw]);
    te1 = te1 - 0.2*te1;
    
    ylabel(p1,'Cum. rate/year','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    str = { 'Event rate comparison for 2 time periods',['Change in %: ' num2str(change,6) ]};
    
    title(p1,str,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    
    %  find b-values;
    set(p1,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.0)
    
    
    % Plot histogram
    %rect = [0.20,  0.40 0.70, 0.25];
    %axes('position',rect)
    p2=subplot(5,1,[3 4]);
    plot(p2,xt2,bval2,segA_linespec,'MarkerSize',ms3,'LineWidth',1.0)
    set(gca,'NextPlot','add')
    plot(p2,xt2,bval,segB_linespec,'MarkerSize',ms3,'LineWidth',1.0)
    disp([' Summation: ' num2str(sum(bval-bval2))])
    v = axis;
    xlabel(p2,'Magnitude ','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    ylabel(p2,'rate/year','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    set(p2,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.0)
    
    uic = uicontrol('Units','normal','Position',[.35 .05 .30 .06],'String','Magnitude Signature? ', 'callback',@callbackfun_004,'enable','off');
    
    watchoff
    
    % Plot he b-value comparison
    ZG.hold_state=false;
    bdiff(backg)
    ZG.hold_state=true;
    bdiff(foreg)
    
    function callbackfun_004(mysrc,myevt)
        
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        delete(uic);
        synsig3;
    end
    
    
    
    function seg = segmentAnalytics(mycat, name, t1, t2)
        % alternate way of dong this for the functions
        seg=struct('name',name,'start',t1,'end',t2);
        seg.duration= seg.end - seg.start;
        index = mycat.Date > seg.start & mycat.Date < seg.end;
        seg.catalog = mycat.subset(index);
        seg.bvals = histcounts(seg.catalog.Magnitude, xt3edges);
        seg.scaledbvals = seg.bvals / days(seg.duration);
        seg.bvalcum = cumsum(seg.scaledbvals);
        seg.bvalcum_bkw = cumsum(fliplr(seg.scaledbvals));
        [seg.datecounts, seg.date_edges] = histcounts(seg.catalog.Date,'BinWidth',ZG.bin_dur);
        seg.meanEventsTime = mean(seg.datecounts);
        seg.covEventsTime = cov(seg.datecounts);
    end
    
end