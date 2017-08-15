function bgrid3dB() % autogenerated function wrapper
    % This subroutine assigns creates a 3D grid with
    % spacing dx,dy, dz (in degreees). The size will
    % be selected interactiVELY. The pvalue in each
    % volume around a grid point containing ni earthquakes
    % will be calculated as well as the magnitude
    % of completness
    %   Stefan Wiemer 1/98
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    global inb1 inb2
    
    if sel == 'i1'
        % make the interface
        %
        figure_w_normalized_uicontrolunits(...
            'Name','Grid Input Parameter',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'units','points',...
            'Visible','on', ...
            'Position',[ ZG.wex+200 ZG.wey-200 550 300]);
        axis off
        R = 5; Nmin = 50;
        
        labelList2=[' Automatic Mcomp (max curvature) | Fixed Mc (Mc = Mmin) | Automatic Mcomp (90% probability) | Automatic Mcomp (95% probability) | Best (?) combination (Mc95 - Mc90 - max curvature)'];
        labelPos = [0.2 0.77  0.6  0.08];
        hndl2=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','normalized',...
            'String',labelList2,...
            'callback',@callbackfun_001);
        
        set(hndl2,'value',5);
        
        
        % creates a dialog box to input grid parameters
        %
        freq_field=uicontrol('Style','edit',...
            'Position',[.30 .50 .12 .10],...
            'Units','normalized','String',num2str(ni),...
            'callback',@callbackfun_002);
        
        
        freq_field0=uicontrol('Style','edit',...
            'Position',[.70 .50 .12 .10],...
            'Units','normalized','String',num2str(R),...
            'callback',@callbackfun_003);
        
        
        tgl1 = uicontrol('Style','checkbox',...
            'string','Number of Events:',...
            'Position',[.05 .50 .2 .10], 'callback',@callbackfun_004,...
            'Units','normalized');
        
        set(tgl1,'value',1);
        
        tgl2 =  uicontrol('Style','checkbox',...
            'string','OR: Constant Radius',...
            'Position',[.47 .50 .2 .10], 'callback',@callbackfun_005,...
            'Units','normalized');
        
        
        freq_field4 = uicontrol('Style','edit',...
            'Position',[.30 .20 .12 .10],...
            'Units','normalized','String',num2str(Nmin),...
            'callback',@callbackfun_006);
        
        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.50 .05 .15 .12 ],...
            'Units','normalized','callback',@callbackfun_007,'String','Cancel');
        
        help_button=uicontrol('Style','Pushbutton',...
            'Position',[.70 .05 .15 .12 ],...
            'Units','normalized','callback',@callbackfun_008,'String','Help');
        
        
        go_button1=uicontrol('Style','Pushbutton',...
            'Position',[.20 .05 .15 .12 ],...
            'Units','normalized',...
            'callback',@callbackfun_009,...
            'String','Go');
        
        text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.20 1.0 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold',...
            'String','Please choose and Mc estimation option ');
        
        txt3 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[0.30 0.67 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.l ,...
            'FontWeight','bold',...
            'String',' Grid Parameter');
        
        txt1 = text(...
            'Color',[0 0 0 ],...
            'EraseMode','normal',...
            'Position',[-0.1 0.2 0 ],...
            'Rotation',0 ,...
            'FontSize',ZmapGlobal.Data.fontsz.m,...
            'FontWeight','bold',...
            'String','Min No. of events:');
        
    end  % if sel = i1
    if sel == 'in'
        % get the grid parameter
        % initial values
        [dx,dy,dz,z1,z2] = request_3dgrid_params('Three dimesional b-value analysis');
        bgrid3dB('ca');
        
        
    end   % if sel == 'in'
    
    % get the grid-size interactively and
    % calculate the b-value in the grid by sorting
    % thge seimicity and selectiong the ni neighbors
    % to each grid point
    
    if sel == 'ca'
        [t5, gx, gy, gz]=selgp3dB(dx, dy, dz, z1, z2);
        
        vol_dimensions=[length(gx), length(gy), length(gz)];
        
        itotal = length(t5);
        zmap_message_center.set_info(' ','Running... ');think
        %  make grid, calculate start- endtime etc.  ...
        %
        [bvg, bvg_wls, ram, go, avm, mcma] = deal(nan(vol_dimensions));
        
        t0b = min(ZG.a.Date)  ;
        n = ZG.a.Count;
        teb = max(ZG.a.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_days);
        loc = zeros(3, length(gx)*length(gy));
        ZG.Rconst = R;
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name',' 3D gridding - percent done');;
        drawnow
        %
        %
        
        z0 = 0; x0 = 0; y0 = 0; dt = 1;
        % loop over all points
        for il =1:length(t5)
            
            x = t5(il,1);
            y = t5(il,2);
            z = t5(il,3);
            
            allcount = allcount + 1.;
            
            % calculate distance from center point and sort wrt distance
            l = sqrt(((ZG.a.Longitude-x)*cosd(y)*111).^2 + ((ZG.a.Latitude-y)*111).^2 + ((ZG.a.Depth - z)).^2 ) ;
            [s,is] = sort(l);
            b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            
            if tgl1 == 0   % take point within r
                l3 = l <= R;
                b = ZG.a.subset(l3);      % new data per grid point (b) is sorted in distanc
                rd = b.Count;
            else
                % take first ni points
                b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                l2 = sort(l); rd = l2(ni);
                
            end
            
            %estimate the completeness and b-value
            ZG.newt2 = b;
            if length(b) >= Nmin  % enough events?
                
                if inb1 == 3
                    mcperc_ca3;  l = b.Magnitude >= Mc90-0.05; magco = Mc90;
                    if length(b(l,:)) >= Nmin
                        [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                        [mea bv2 stan2 av2 ] =  bmemag(b(l,:));
                    else
                        bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
                    end
                    
                elseif inb1 == 4
                    mcperc_ca3;  l = b.Magnitude >= Mc95-0.05; magco = Mc95;
                    if length(b(l,:)) >= Nmin
                        [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                        [mea bv2 stan2 av2 ] =  bmemag(b(l,:));
                    else
                        bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
                    end
                elseif inb1 == 5
                    mcperc_ca3;
                    if isnan(Mc95) == 0
                        magco = Mc95;
                    elseif isnan(Mc90) == 0
                        magco = Mc90;
                    else
                        [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                    end
                    l = b.Magnitude >= magco-0.05;
                    if length(b(l,:)) >= Nmin
                        [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                        [mea bv2 stan2,  av2] =  bmemag(b(l,:));
                    else
                        bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan; dP = 0;
                    end
                    
                elseif inb1 == 1
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                    l = b.Magnitude >= magco-0.05;
                    if length(b(l,:)) >= Nmin
                        [mea bv2 stan2,  av2] =  bmemag(b(l,:));
                    else
                        bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
                    end
                    
                elseif inb1 == 2
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,2,2);
                    [mea  bv2 stan2 av2 ] =  bmemag(b);
                end
                ZG.newt2 = b;
                %  predi_ca
                
            else
                bv = nan; bv2 = nan; magco = nan; av = nan; av2 = nan; prf = nan; dP = 0;
            end
            
            
            bvg(t5(il,5),t5(il,6),t5(il,7)) = bv2;
            bvg_wls(t5(il,5),t5(il,6),t5(il,7)) = bv;
            
            ram(t5(il,5),t5(il,6),t5(il,7)) = rd;
            %go(t5(il,5),t5(il,6),t5(il,7)) = prf;
            avm(t5(il,5),t5(il,6),t5(il,7)) = av2;
            mcma(t5(il,5),t5(il,6),t5(il,7)) = magco;
            
            
            waitbar(allcount/itotal)
        end  % for t5
        
        % save data
        %
        gz = -gz;
        zv2 = bvg;
        zvg = bvg;
        
        catSave3 =...
            [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
            '[file1,path1] = uiputfile(fullfile(ZmapGlobal.Data.data_dir, ''*.mat''), ''Grid Datafile Name?'') ;',...
            ' sapa2 = [''save '' path1 file1 '' zvg teb ram go avm mcma gx gy gz dx dy dz ZG.bin_days bvg tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri well ll ni''];',...
            ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)
        
        close(wai)
        watchoff
        
        sel = 'no';
        
        ButtonName=questdlg('Which viewer would you like to use?', ...
            'Question', ...
            'Slicer - map view','Slicer - 3D ','Help','none');
        
        
        switch ButtonName
            case 'Slicer - map view'
                slicemap();
            case 'Slicer - 3D '
                myslicer('new');
            case 'Help'
                showweb('3dbgrids')
        end % switch
        
        uicontrol('Units','normal',...
            'Position',[.90 .95 .04 .04],'String','Slicer',...
            'callback',@callbackfun_010);
        
    end  % if cal
    
    
    function callbackfun_001(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        inb2=hndl2.Value;
    end
    
    function callbackfun_002(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2double(freq_field.String);
        freq_field.String=num2str(ni);
        tgl2.Value=0;
        tgl1.Value=1;
    end
    
    function callbackfun_003(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        R=str2double(freq_field0.String);
        freq_field0.String=num2str(R);
        tgl2.Value=1;
        tgl1.Value=0;
    end
    
    function callbackfun_004(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl2.Value=0;
    end
    
    function callbackfun_005(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        tgl1.Value=0;
    end
    
    function callbackfun_006(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        Nmin=str2double(freq_field4.String);
        freq_field4.String=num2str(Nmin);
    end
    
    function callbackfun_007(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        done;
    end
    
    function callbackfun_008(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        done;
    end
    
    function callbackfun_009(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        inb1=hndl2.Value;
        tgl1=tgl1.Value;
        tgl2=tgl2.Value;
        close;
        bgrid3dB('in');
    end
    
    function callbackfun_010(mysrc,myevt)
        % automatically created callback function from text
        callback_tracker(mysrc,myevt,mfilename('fullpath'));
    end
    
end
