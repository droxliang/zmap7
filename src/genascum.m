function genascum() 
    % genascum creates a rectangular grid and calls GenAS
    %   at each grid point. The output for each grid point is compressed
    %   (averaged) magnitude-wise and saved in the file "cumgenas.mat".
    %   A map is created with these values.  Operates on catalog "ZG.newcat"
    %                                        R. Zuniga  GI, 5/94
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    figure(mess);
    clf
    set(gca,'visible','off')
    
    te = text(0.01,0.80,'Please use the LEFT mouse button or the cursor \newlineto select the lower left corner of the area of \newlineinvestigation. Use the LEFT mouse button again \newlineto select the upper right corner ');
    set(te,'FontSize',12);
    
    b = ZG.newcat;                       % reset b
    as2 = [];
    count = 0;
    figure(map);
    [x0,y0]  = ginput(1);
    mark1 =    plot(x0,y0,'ro')
    set(mark1,'MarkerSize',10,'LineWidth',2.0)
    [x1,y1]  = ginput(1);
    f = [x0 y0 ; x1 y0 ; x1 y1 ; x0 y1 ; x0 y0];
    fplo = plot(f(:,1),f(:,2),'r');
    set(fplo,'LineWidth',2)
    
    gx = x0:dx:x1;
    gy = y0:dy:y1;
    itotal = length(gx) * length(gy);
    clear ztimes ztime1 ztime2
    incx = days(ZG.bin_dur);
    maxmag = floor(max(ZG.newcat.Magnitude));
    minmg = floor(min(ZG.newcat.Magnitude)); %added the missing minmg similar to maxmag
    magstep = 0.5;                   %set the missing magstep to 0.5
    evsum = ZG.newcat.Count;
    n = evsum;
    [t0b, teb] = bounds(ZG.newcat.Date) ;
    tdiff = round((teb-t0b)/ZG.bin_dur);
    xt = t0b:incx:teb;
    bin0 = 1;
    bin1 = length(xt)
    nmag = minmg:magstep:maxmag;
    ztime1 = 1:bin1;
    ztime2 = zeros(size(ztime1));
    cumu1 = zeros(size(ztime1));
    cumu2 = zeros(size(ztime1));
    [Zsum, Zsuma, Zsumb, Zabs, Zabsa, Zabsb] = deal(zeros(size(ztime1)));
    ncu = length(Zsum)+2;
    Zsumall = zeros(ncu,length(gx)*length(gy));
    Zabsall = Zsumall;
    %
    %               labels and tick marks for figures
    xsum = ni;
    nummag = length(nmag);         %  5 magnitude axis tick marks and labels
    tickinc = nummag/4;
    xtick = 0:tickinc:nummag;
    xtick(1) = 1;
    for i = 1:5
        xtlabls(i,:) = sprintf('%3.1f',nmag(xtick(i)));
    end
    tickinc = bin1/9;                   %  10 tick marks for time axis
    ytick = 0:tickinc:bin1;
    ytick(1) = 1;
    ytlabls(1,:) = sprintf('%3.2f',xt(1));
    for i = 1:10
        ytlabls(i,:) = sprintf('%3.2f',xt(ytick(i)));
    end
    
    
    %  make grid, calculate start- endtime etc.  ...
    %
    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    allcount = 0.;
    wai = waitbar(0,' Please Wait ...  ');
    set(wai,'NumberTitle','off','Name','Makegrid  -Percent done');
    set(gcf,'Pointer','watch');
    pause(0.1)
    figure
    cumfg = gcf;
    set(cumfg,[50 100 550 400 ],'NumberTitle','off','Name','GenAS-Grid-1');
    set(cumfg,'pos',[50 500 550 400]);
    
    set(gca,'visible','off')
    txt1 = text(...
        'Position',[0.1 0.50 0 ],...
        'FontSize',16 );
    set(txt1,'String', '')
    set(txt1,'String',  ' Please Wait...' );
    set(gcf,'Pointer','watch');
    pause(0.1)
    figure;
    gen2 = gcf;
    set(gen2,[100 100 550 400 ],'NumberTitle','off','Name','GenAS-Grid-2');
    figure(cumfg);
    %
    % longitude  loop
    %
    for x =  x0:dx:x1
        i1 = i1+ 1;
        
        % latitude loop
        %
        for  y = y0:dy:y1
            cla                         %clear axis of figure
            allcount = allcount + 1.;
            i2 = i2+1;
            
            % let b be the catalog containing closest ni points to (x,y)
            b=ZG.newcat.selectClosestEvents(y,x,[],ni);
            
            for i = minmg:magstep:maxmag         % steps in magnitude
                clear global ztimes                %clears ztimes from previous results
                cumu1 = cumu1*0;
                cumu2 = cumu2*0;
                ztime1 = ztime1*0;
                ztime2 = ztime2*0;
                
                l =   b.Magnitude < i;            % Mags and below
                junk = b.subset(l);
                if ~isempty(junk)
                    [cumu1, xt] = hist(junk.Date,xt); 
                end
                
                ztime1 = genas(cumu1,xt,bin1,bin0,bin1);    % call GenAS algorithm
                
                if i == minmg
                    ZBEL = ztime1';
                else
                    ZBEL = [ZBEL,  ztime1' ];
                end      % if i
                
                Zsumb = [Zsumb+ztime1 ];           % calculate sum of Z for below M
                Zabsb = [Zabsb+abs(ztime1) ];      % calculate sum of absolute Z
                
                clear global ztimes               %clears ztimes from previous results
                
                l =   b.Magnitude > i;           % Mags and above
                junk = b.subset(l);
                if ~isempty(junk), [cumu2, xt] = hist(junk.Date,xt); end
                
                ztime2 = genas(cumu2,xt,bin1,bin0,bin1);   % call GenAS algorithm
                
                if i == minmg
                    ZABO = ztime2';
                else
                    ZABO = [ZABO,  ztime2' ];
                end  %if i
                
                Zsuma = [Zsuma+ztime2 ];          % calculate sum of Z for above M
                Zabsa = [Zabsa+abs(ztime2) ];     % calculate sum of absolute Z
                
                S = sprintf('                            magnitude %3.1f done!', i);
                disp(S);
                
                cumbelow=cumsum(cumu1);
                cumabove=cumsum(cumu2);
                
                figure(cumfg); set(gca,'visible','on');
                plot(xt,cumbelow,'r');
                plot(xt,cumabove,'b-.');
                xlabel('time (yrs)');
                ylabel('cum number of events');
                
                t1 = xsum-0.05*xsum;
                text(xt(5), t1, '                                   ');
                st1 = num2str(x); st2 = num2str(y); stn = ['grid node ' st2 ' ' st1];
                text(xt(5), t1, stn);
                t1 = xsum-xsum*0.1;
                t1p = [  xt(10)  t1; xt(30)   t1];
                plot(t1p(:,1),t1p(:,2),'r');
                text(xt(35), t1,' mag and below');
                t1 = xsum-xsum*0.2;
                t1p = [  xt(10)  t1; xt(30)   t1];
                plot(t1p(:,1),t1p(:,2),'b-.');
                text(xt(35), t1,' mag and above');
                
            end        % for i
            % calculate mean Z values over magnitude cuts
            Zsuma = Zsuma/i;         % as a function of time per grid point (Zsumall)
            Zsumb = Zsumb/i;
            Zsum = (Zsumb+Zsuma)/2;  % sum belowM + aboveM and average
            Zabsa = Zabsa/i;
            Zabsb = Zabsb/i;
            Zabs = (Zabsa+Zabsb)/2;
            Zabs = Zabsa + Zabsb;    % same for absolute values
            
            Zsumall(:,allcount) = [Zsum';  x; y ];
            Zabsall(:,allcount) = [Zabs';  x; y ];
            
            figure(wai);
            waitbar(allcount/itotal);
            
            figure_w_normalized_uicontrolunits(gen2)                 % show results of GenAS every grid point
            subplot(1,2,1),contour(ZBEL);
            colormap(jet)
            shading interp
            xlabel('Mag and Below');
            ylabel('Time (yrs)');
            set(gca,'Xtick',xtick,'Xticklabels',xtlabls,'Ytick',ytick,...
                'Yticklabels',ytlabls);
            stri = [  ' GenAS - ' file1];
            title(stri)
            %set(gca,'Ytick',ytick,'Yticklabels',ytlabls)
            subplot(1,2,2),contour(ZABO);
            colormap(jet)
            shading interp
            xlabel('Mag and Above');
            set(gca,'Xtick',xtick,'Xticklabels',xtlabls,'Ytick',ytick,...
                'Yticklabels',ytlabls);
            title(stn);
            %set(gca,'Ytick',ytick,'Yticklabels',ytlabls);
            figure(cumfg);
        end  % for y0
        
        i2 = 0;
    end  % for x0
    S = sprintf('                 FINISH!', i);
    disp(S);
    set(gcf,'Pointer','arrow');
    drawnow
    close(wai)
    
    figure;           % plot a comparison of mean Z and  mean absolute Z values
    clf;
    ma1 = max(max(Zsumall(1:ncu-2,:)));
    mi1 = min(min(Zsumall(1:ncu-2,:)));
    
    subplot(1,2,1),pcolor(Zsumall);
    colormap(jet)
    shading interp
    caxis([mi1 ma1])
    xlabel('grid node');
    ylabel('Time (yrs)');
    set(gca,'Ytick',ytick,'Yticklabels',ytlabls);
    stri = [  'MeanZ - ' file1];
    title(stri)
    caxis([mi1 ma1])
    colorbar
    set(gca,'NextPlot','add');
    ma1 = max(max(Zabsall(1:ncu-2,:)));
    mi1 = min(min(Zabsall(1:ncu-2,:)));
    
    subplot(1,2,2),pcolor(Zabsall);
    colormap(jet)
    shading interp
    caxis([mi1 ma1])
    xlabel('grid node');
    set(gca,'Ytick',ytick,'Yticklabels',ytlabls);
    stri = [  'SumAbsZ ' ];
    title(stri)
    caxis([mi1 ma1])
    colorbar
    set(gca,'NextPlot','add');
    
    figure(mess);
    clf
    set(gca,'visible','off')
    
    [len, ncu] = size(Zsumall);       % redefine ncu as number of grid points
    len = len -2;
    max_meanZ = zeros(1,ncu);
    min_meanZ = max_meanZ;
    cumuall = Zsumall;               % to be able to run other routines
    
    meanZ = Zsumall(1:len,:);
    max_meanZ = max(meanZ);           % to use routine view_max
    min_meanZ = min(meanZ);
    re_1 = reshape(max_meanZ,length(gy),length(gx));
    re_2 = reshape(min_meanZ,length(gy),length(gx));
    % save data
    save cumgenas.mat Zsumall Zabsall valueMap ZG.bin_dur ni dx dy gx gy tdiff t0b teb
    
    te = text(0.01,0.90,'The cumulative no. curve was saved in\newline file cumgenas.mat\newline Please rename it if desired.');
    set(te,'FontSize',12);
    
    uicontrol('Units','normal','Position',...
        [.1 .10 .2 .12],'String','meanZ at time', 'callback',@callbackfun_mean_z_at_time)
    
    uicontrol('Units','normal','Position',...
        [.4 .10 .2 .12],'String','minZmap', 'callback',@callbackfun_min_z_map)
    
    uicontrol('Units','normal','Position',...
        [.7 .10 .2 .12],'String','maxZmap', 'callback',@callbackfun_max_z_map)
    
    close_button = uicontrol('Units','normal','Position',...
        [.7 .7 .2 .12],'String','Close ', 'Callback',@(~,~)close)
    
    clear Zsumb Zsuma Zsum Zabsa Zabsb Zabs meanZ max_meanZ min_meanZ;
    
    
    function callbackfun_mean_z_at_time(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        timgenas(gx,gy);
    end
    
    function callbackfun_min_z_map(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        stri = ['Min of mean Z'];
        valueMap = re_2;
        view_max(valueMap,gx,gy,stri,'')
    end
    
    function callbackfun_max_z_map(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        stri = ['Max of mean Z'];
        valueMap = re_1;
        view_max(valueMap,gx,gy,stri,'');
    end
    
end
