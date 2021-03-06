function show_map(in, in2, compare_window_dur) 
    % ZMAP script show_map.m. Creates Dialog boxes for Z-map calculation
    % does the calculation and makes displays the map
    % stefan wiemer 11/94
    %
    % make dialog interface and call maxzlta
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    %FIXME (maybe) changing compare_window_dur doesn't change the global version.
    
    % Input Rubberband
    %
    report_this_filefun();
    
    if in2 ~= 'calma'
        
        %initial values
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
            'Position',[.80 .775 .18 .15],...
            'Units','normalized','String',num2str(it),...
            'callback',@callbackfun_001);
        
        txt2 = text(...
            'Position',[0. 0.9 0 ],...
            'FontWeight','bold',...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'String','Please input time of cut in years (e.g. 86.5):');
        
        if in == 'rub' || in == 'lta'
            
            txt3 = text(...
                'Position',[0. 0.65 0 ],...
                'FontWeight','bold',...
                'FontSize',ZmapGlobal.Data.fontsz.m ,...
                'String','Please input window length in years (e.g. 1.5):');
            inp3_field=uicontrol('Style','edit',...
                'Position',[.80 .575 .18 .15],...
                'Units','normalized','String',num2str(years(compare_window_dur)),...
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
        if ~exist('it', 'var')
            it = t0b + (teb-t0b)/2;
        end
        if it + compare_window_dur > teb || it < t0b
            errordlg('Time out of limits')
            in2 = 'nocal';
            show_map
        end
        
        
        % initial parameter
        winlen_days = floor(compare_window_dur/ZG.bin_dur); 
        ti = floor((it -t0b)/days(ZG.bin_dur));
        [len, ncu] = size(cumuall); len = len-2;
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
        
        
        if in == 'maz'
            
            maxlta = zeros(1,ncu);
            maxlta = maxlta -5;
            mean1 = mean(cumuall(1:len,:));
            wai = waitbar(0,'Please wait...')
            set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Percent done');
            
            for i = 1:ncu
                var1(i) = cov(cumuall(1:len,i));
            end     % for i
            for ti = 1:step: len - winlen_days
                waitbar(ti/len)
                mean1 = mean(cumuall(1:len,:));
                mean2 = mean(cumuall(ti:ti+winlen_days,:));
                for i = 1:ncu
                    var1(i) = cov(cumuall(1:len,i));
                    var2(i) = cov(cumuall(ti:ti+winlen_days,i));
                end     % for i
                as = (mean1 - mean2)./(sqrt(var1/len+var2/winlen_days));
                maxlta2 = [maxlta ;  as ];
                maxlta = max(maxlta2);
            end    % for it
            %as = reshape(maxlta,length(gy),length(gx));
            close(wai)
            
        end   % if in = 'maz'
        
        %l = isnan(cumuall(t,:));
        %proball(t,l) = zeros(1,length(proball(t,l)));
        %normalisation of lap1
        normlap1=nan(length(tmpgri(:,1)),1)
        normlap2=nan(length(tmpgri(:,1)),1)
        
        lv = ll ==1 ;
        ll = lv;
        normlap2(lv)= as(:);
        %construct a matrix for the color plot
        valueMap=reshape(normlap2,length(yvect),length(xvect));
        
        
        [n1, n2] = size(cumuall);
        s = cumuall(n1,:);
        normlap2(lv)= s(:);
        %construct a matrix for the color plot
        r=reshape(normlap2,length(yvect),length(xvect));
        ZG.tresh_km = max(r(:));
        % find max and min of data for automatic scaling
        %
        ZG.maxc = max(valueMap(:));
        ZG.maxc = fix(ZG.maxc)+1;
        ZG.minc = min(valueMap(:));
        ZG.minc = fix(ZG.minc)-1;
        %plot imge
        %
        det = 'nop';
        old = valueMap;
        clear cu
        view_max(valueMap,gx,gy,stri,'nop')
        %end
        
    end   % if calma ~| in2
    
    
    function callbackfun_001(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        it=str2double(mysrc.String);
    end
    
    function callbackfun_002(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        compare_window_dur=years(str2double(mysrc.String));
    end
    
    function callbackfun_003(mysrc,myevt)
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        
        watchon;
        drawnow;
        in2 = 'calma';
        show_map;
    end
end
