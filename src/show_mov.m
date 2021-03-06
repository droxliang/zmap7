function show_mov(in, in2) 
    % ZMAP script show_map.m. Creates Dialog boxes for Z-map calculation
    % does the calculation and makes displays the map
    % stefan wiemer 11/94
    %
    % make dialog interface and call maxzlta
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    % Input Rubberband
    %
    report_this_filefun();
    
    if in2 ~= 'calma'
        
        %initial values
        nustep = 10;
        ZG.compare_window_dur_v3 = years(1.5);
        it = t0b +1;
        figure(mess);
        clf
        set(gca,'visible','off')
        set(gcf,'Units','pixel','NumberTitle','off','Name','Input Parameters');

        set(gcf,'pos',[ ZG.welcome_pos, ZG.welcome_len +[200, -50]]);
        
        
        % creates a dialog box to input some parameters
        %
        
        inp2_field=uicontrol('Style','edit',...
            'Position',[.80 .80 .18 .15],...
            'Units','normalized','String',num2str(nustep),...
            'callback',@callbackfun_001);
        
        txt2 = text(...
            'Position',[0. 0.9 0 ],...
            'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'String','Please input Number of Frames:');
        
        if in == 'rub' | in == 'lta'
            
            txt3 = text(...
                'Position',[0. 0.65 0 ],...
                'FontWeight','bold',...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'String','Please input window length in years (e.g. 1.5):');
            inp3_field=uicontrol('Style','edit',...
                'Position',[.80 .575 .18 .15],...
                'Units','normalized','String',num2str(years(ZG.compare_window_dur)),...
                'callback',@callbackfun_002);
            
        end   % if in = rub
        
        close_button=uicontrol('Style','Pushbutton',...
            'Position', [.60 .05 .15 .15 ],...
            'Units','normalized','Callback',@(~,~)close(),'String','Cancel');
        
        go_button=uicontrol('Style','Pushbutton',...
            'Position',[.25 .05 .15 .15 ],...
            'Units','normalized',...
            'callback',@callbackfun_003,...
            'String','Go');
        
        set(gcf,'visible','on');watchoff
        
        % do the calculations:
        %
        
    else     % if in2 ~=calma
        
        % check if time are with limits
        %
        
        
        % initial parameter
        winlen_days = ZG.compare_window_dur/ZG.bin_dur; 
        ti = (it -t0b)/days(ZG.bin_dur);
        var1 = zeros(1,ncu);
        var2 = zeros(1,ncu);
        mean1 = zeros(1,ncu);
        mean2 = zeros(1,ncu);
        as = zeros(1,ncu);
        [len, ncu] = size(cumuall); len = len-2;
        len = len -2;
        step = len/nustep;
        
        
        % loop over all frames
        
        j = 0;
        figure
        rect = [0.10 0.30 0.55 0.50 ];
        rect1 = rect;
        axes('position',rect1)
        axis('off')
        m = moviein(length(1:step:len-winlen_days));
        for ti = winlen_days:step:len-winlen_days
            j = j+1;
            var1 = zeros(1,ncu);
            var2 = zeros(1,ncu);
            mean1 = zeros(1,ncu);
            mean2 = zeros(1,ncu);
            as = zeros(1,ncu);
            
            % loop over all grid points for percent
            %
            %
            if in =='per'
                
                for i = 1:ncu
                    mean1(i) = mean(cumuall(1:ti,i));
                    mean2(i) = mean(cumuall(ti:len,i));
                end    %for i
                as = -((mean1-mean2)./mean1)*100;
                
                strib = 'Change in Percent';
                stri2 = ['ti=' num2str(ti*days(ZG.bin_dur) + t0b)  ];
                
                
                
            end  % if in = = per
            
            % loop over all point for rubber band
            %
            if in =='rub'
                
                for i = 1:ncu
                    mean1(i) = mean(cumuall(1:ti,i));
                    mean2(i) = mean(cumuall(ti+1:ti+winlen_days,i));
                    var1(i) = cov(cumuall(1:ti,i));
                    var2(i) = cov(cumuall(ti+1:ti+winlen_days,i));
                end %  for i ;
                as = (mean1 - mean2)./(sqrt(var1/ti+var2/winlen_days));
                
            end % if in = rub
            
            % make the AST function map
            if in =='ast'
                for i = 1:ncu
                    mean1(i) = mean(cumuall(1:ti,i));
                    var1(i) = cov(cumuall(1:ti,i));
                    mean2(i) = mean(cumuall(ti+1:len,i));
                    var2(i) = cov(cumuall(ti+1:len,i));
                end    %for i
                as = (mean1 - mean2)./(sqrt(var1/ti+var2/(len-ti)));
            end % if in = ast
            
            if in =='lta'
                disp('Calculate LTA')
                %cu = [cumuall(1:ti-1,:) ; cumuall(ti+winlen_days+1:len,:)];
                mean1 = mean([cumuall(1:ti-1,:) ; cumuall(ti+winlen_days+1:len,:)]);
                mean2 = mean(cumuall(ti:ti+winlen_days,:));
                for i = 1:ncu
                    var1(i) = cov([cumuall(1:ti-1,i) ; cumuall(ti+winlen_days+1:len,i)]);
                    var2(i) = cov(cumuall(ti:ti+winlen_days,i));
                end     % for i
                as = (mean1 - mean2)./(sqrt(var1/(len-winlen_days)+var2/winlen_days));
            end % if in = lta
            
            
            normlap1=nan(length(tmpgri(:,1)),1)
            normlap2=nan(length(tmpgri(:,1)),1)
            normlap2(ll)= as(:);
            %construct a matrix for the color plot
            valueMap=reshape(normlap2,length(yvect),length(xvect));
            
            
            %plot imge
            % set values gretaer ZG.tresh_km = nan
            %
            re4 = valueMap;
            [len, ncu] = size(cumuall);
            [n1, n2] = size(cumuall);
            s = cumuall(n1,:);
            normlap2(ll)= s(:);
            r=reshape(normlap2,length(yvect),length(xvect));
            l = r > ZG.tresh_km;
            re4(l) = nan(1,length(find(l)));
            
            orient landscape
            set(gcf,'PaperPosition',[ 0.1 0.1 8 6])
            axes('position',rect1)
            set(gca,'NextPlot','add')
            pco1 = pcolor(gx,gy,re4);
            caxis([ZG.minc ZG.maxc]);
            axis([ s2 s1 s4 s3])
            set(gca,'NextPlot','add')
            %overlay
            if in == 'ast'
                tx2 = text(0.07,0.85 ,['AS; t=' num2str(ti*days(ZG.bin_dur)+t0b)  ] ,...
                    'Units','Norm','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold');
            end
            
            if in == 'lta'
                tx2 = text(0.07,0.85 ,['LTA; t=' num2str(ti*days(ZG.bin_dur)+t0b)  ] ,...
                    'Units','Norm','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold');
            end
            
            if in == 'rub'
                tx2 = text(0.07,0.85 ,['RUB; t=' num2str(ti*days(ZG.bin_dur)+t0b)  ] ,...
                    'Units','Norm','FontSize',ZmapGlobal.Data.fontsz.m,'Color','k','FontWeight','bold');
            end
            
            set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
                'FontWeight','bold','LineWidth',1.5,...
                'Box','on','SortMethod','childorder')
            
            
            shading interp
            has = gca;
            disp('now getting frame...')
            m(:,j) = getframe(has);
            delete(gca);
            delete(gca);
            delete(gca)
            fs_m = get(gcf,'pos');
            
        end  % loop over frames
        
        close(gcf)
        
        showmovi
    end   % if calma ~| in2
    
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nustep=str2double(inp2_field.String);
        inp2_field.String=num2str(nustep);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ZG.compare_window_dur=years(str2double(mysrc.String));
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        nustep=str2num(inp2_field.String);
        ZG.compare_window_dur=years(str2num(inp3_field.String));
        watchon;
        drawnow;
        in2 = 'calma';
        fixaxmo;
    end
    
end
