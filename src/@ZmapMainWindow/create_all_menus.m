function create_all_menus(obj, force)
    % create menus for main zmap figure
    % create_all_menus() - will create all menus, if they don't exist
    % create_all_menus(force) - will delete and recreate menus if force is true
    h = findobj(obj.fig,'Tag','mainmap_menu_divider');
    if ~exist('force','var')
        force=false;
    end
    if ~isempty(h) && force
        delete(h); h=[];
    end
    if isempty(h)
        add_menu_divider('mainmap_menu_divider');
    end
    create_overlay_menu();
    %ShapeGeneral.AddMenu(gcf);
    %add_grid_menu(uimenu('Label','Grid'));
    obj.catalog_menu(force);
    
    create_decluster_menu(findobj(obj.fig,'Label','Catalog','-and','type','uimenu'));
    
    add_grid_menu(obj);
    create_ztools_menu();
    
    
    uimenu('Label','|Analyse:','Enable','off');
    create_map_analysis_menu();
    create_xsec_analysis_menu();
    create_3d_analysis_menu();
    add_menu_divider();
    addQuitMenuItem();
    addAboutMenuItem();
    
    %% map-view analysis menu
    % analyze items according to spacing in a horizontal plane
    function create_map_analysis_menu()
        submenu = uimenu('Label','Map');
        % AB menu
        bvalgrid.AddMenuItem(submenu, @()obj.map_zap);
        bvalmapt.AddMenuItem(submenu, @()obj.map_zap);
        bdepth_ratio.AddMenuItem(submenu,@()obj.map_zap);
        
        % P menu
        h=bpvalgrid.AddMenuItem(submenu,@()obj.map_zap);
        rcvalgrid_a2.AddMenuItem(submenu, @()obj.map_zap);
        h.Separator='on';
        
        % Rate Change menu
        h=comp2periodz.AddMenuItem(submenu, @()obj.map_zap);
        uimenu(submenu,'Label','Calculate a z-value map','Enable','off','MenuSelectedFcn',@(~,~)inmakegr(obj.catalog));
        h.Separator='on'
        
        % Quarry menu : detect quarry contamination
        h=findquar.AddMenuItem(submenu,@()obj.map_zap);
        h.Separator='on';
        
        h=uimenu(submenu,'Label','Map stress tensor','MenuSelectedFcn',@(~,~)stressgrid());
        h.Separator='on';
        %{
            uimenu(tmp,'Label','Load...','Enable','off','MenuSelectedFcn',  @(~,~)rcvalgrid_a2('lo'));
            uimenu(submenu,'Label','Load a z-value movie (map-view)','MenuSelectedFcn',@(~,~)loadmovz());
        %}
    end
    
    %% xsec-view analysis menu
    % analyze items according to position & depth along strike.
    
    function create_xsec_analysis_menu()
        submenu = uimenu('Label','X-sect');
        uimenu(submenu,'Label','Define a cross-section','MenuSelectedFcn',@(~,~)obj.cb_xsection,'Tag','CreateXsec');
        
        h=magrcros.AddMenuItem(submenu, @()obj.xsec_zap);% @()obj.map_zap);
        rc_cross_a2.AddMenuItem(submenu, @()obj.xsec_zap);
        h.Separator='on';
        
        uimenu(submenu,'Label','Calc a b-value cross-section','MenuSelectedFcn', @(~,~)nlammap(@()obj.xsec_zap));
        
        
        % DONE ALREADY? : uimenu(submenu,'Label','Calculate a z-value cross-section','MenuSelectedFcn',@(~,~)nlammap());
        %{
            uimenu(submenu,'Label','Load a b-value grid (cross-section-view)','MenuSelectedFcn',@(~,~)bcross('lo'));
        	uimenu(submenu,'Label','Load a z-value grid (cross-section-view)','MenuSelectedFcn',@(~,~)magrcros('lo'));
        %}
    end
    
    
    %% 3D-view analysis menu
    % analyze items in a volume
    
    function create_3d_analysis_menu()
        submenu = uimenu('Label','3D-Vol');
        uimenu(submenu, 'Label','Nothing here yet','Enable','off');
        return
        uimenu(submenu,'Label','Calc 3D b-value distribution','Enable','off','MenuSelectedFcn', @(~,~)bgrid3dB());
        
        uimenu(submenu,'Label','Calculate a 3D  z-value distribution','Enable','off','MenuSelectedFcn',@(~,~)zgrid3d('in',obj.catalog));
        %{
            uimenu(submenu,'Label','Load a 3D b-value grid','MenuSelectedFcn',@(~,~)myslicer('load'));
        %}
        
    end
    
    
    %% individual menus to create
    
    function create_overlay_menu()
        h = findobj(obj.fig,'Tag','mainmap_menu_overlay');
        axm=obj.map_axes;
        if ~isempty(h) && exist('force','var') && force
            delete(h); h=[];
        end
        if ~isempty(h)
            return
        end
        
        % Make the menu to change symbol size and type
        %
        mapoptionmenu = uimenu(obj.fig,'Label','Map Options','Tag','mainmap_menu_overlay');
        
        uimenu(mapoptionmenu,'Label','3-D view',...
            'MenuSelectedFcn',@obj.set_3d_view); % callback was plot3d
        
        uimenu(mapoptionmenu,'Label','Set aspect ratio by latitude',...
            'MenuSelectedFcn',@toggle_aspectratio,...
            'Checked',char(ZmapGlobal.Data.lock_aspect));
        if ZmapGlobal.Data.lock_aspect
            daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
        end
        
        uimenu(mapoptionmenu,'Label','Toggle Lat/Lon Grid',...
            'MenuSelectedFcn',@toggle_grid,...
            'checked',char(ZmapGlobal.Data.mainmap_grid));
        grid(axm,char(ZmapGlobal.Data.mainmap_grid));
        
        
        add_symbol_menu(axm, mapoptionmenu, 'Map Symbols');
        ovmenu = uimenu(mapoptionmenu,'Label','Layers');
        try
            MapFeature.foreach(obj.Features,'addToggleMenu',ovmenu,axm)
        catch ME
            warning(ME.message)
        end
        
        uimenu(ovmenu,'Label','Plot stations + station names',...
            'Separator', 'on',...
            'MenuSelectedFcn',@(~,~)plotstations(axm));
        
        lemenu = uimenu(mapoptionmenu,'Label','Legend by ...  ','Enable','off');
        
        uimenu(lemenu,'Label','Change legend breakpoints',...
            'MenuSelectedFcn',@change_legend_breakpoints);
        legend_types = {'Legend by time','tim';...
            'Legend by depth','depth';...
            'Legend by magnitudes','mag';...
            'Mag by size, Depth by color','mad' %;...
            % 'Symbol color by faulting type','fau'...
            };
        
        for i=1:size(legend_types,1)
            m=uimenu(lemenu,'Label',legend_types{i,1},...
                'MenuSelectedFcn', {@cb_plotby,legend_types{i,2}});
            if i==1
                m.Separator='on';
            end
        end
        clear legend_types
        
        uimenu(mapoptionmenu,'Label','Change font size ...','Enable','off',...
            'MenuSelectedFcn',@change_map_fonts);
        
        uimenu(mapoptionmenu,'Label','Change background colors',...
            'MenuSelectedFcn',@(~,~)setcol,'Enable','off'); %
        
        uimenu(mapoptionmenu,...
            'Label',['Mark large event with M > ' num2str(ZmapGlobal.Data.big_eq_minmag)],...
            'MenuSelectedFcn',@cb_plot_large_quakes);
        
        function cb_plotby(~,~, s)
            ZG=ZmapGlobal.Data;
            ZG.mainmap_plotby=s;
            watchon;
            % zmap_update_displays();
            watchoff;
        end
        
        
        function cb_plot_large_quakes(src,~)
            ZG=ZmapGlobal.Data;
            [~,~,ZG.big_eq_minmag] = smart_inputdlg('Choose magnitude threshold',...
                struct('prompt','Mark events with M > ? ','value',ZG.big_eq_minmag));
            src.Label=['Mark large event with M > ' num2str(ZG.big_eq_minmag)];
            ZG.maepi = obj.catalog.subset(obj.catalog.Magnitude > ZG.big_eq_minmag);
            obj.replot_all();
        end
        
        
        function toggle_aspectratio(src, ~)
            src.Checked=toggleOnOff(src.Checked);
            switch src.Checked
                case 'on'
                    daspect(axm, [1 cosd(mean(axm.YLim)) 10]);
                case 'off'
                    daspect(axm,'auto');
            end
            ZG = ZmapGlobal.Data;
            ZG.lock_aspect = matlab.lang.OnOffSwitchState(src.Checked);
            %align_supplimentary_legends();
        end
        
        function toggle_grid(src, ~)
            src.Checked=toggleOnOff(src.Checked);
            grid(axm,src.Checked);
            drawnow
        end
        
    end
    
    function create_ztools_menu()
        h = findobj(obj.fig,'Tag','mainmap_menu_ztools');
        if ~isempty(h) && exist('force','var') && force
            delete(h); h=[];
        end
        if ~isempty(h)
            return
        end
        submenu = uimenu('Label','ZTools','Tag','mainmap_menu_ztools');
        
        uimenu(submenu,'Label','Show main message window',...
            'MenuSelectedFcn', @(s,e)ZmapMessageCenter());
        
        uimenu(submenu,'Label','Analyze time series ...',...
            'Separator','on',...
            'MenuSelectedFcn',@(s,e)analyze_time_series_cb);
        
        create_topo_map_menu(submenu);
        create_random_data_simulations_menu(submenu);
        % uimenu(submenu,'Label','Create [simple] cross-section','MenuSelectedFcn',@(~,~)obj.cb_xsection);
        
        create_histogram_menu(submenu);
        
        uimenu(submenu,'Label','Misfit calculation','MenuSelectedFcn',@(~,~)inmisfit(),...
            'Enable','off'); %FIXME: misfitcalclulation poorly documented, not sure what it is comparing.
        
        function analyze_time_series_cb(~,~)
            % analyze time series for current catalog view
            ZG=ZmapGlobal.Data;
            ZG.newt2 = obj.catalog;
            timeplot();
        end
    end
    function create_topo_map_menu(parent)
        submenu   =  uimenu(parent,'Label','Plot topographic map');
        uimenu(submenu,'Label','Open a Web Map Display','MenuSelectedFcn',@(~,~)webmap_of_catalog(obj.catalog,true));
        return
        uimenu(submenu,'Label','Open DEM GUI','MenuSelectedFcn', @(~,~)prepinp());
        uimenu(submenu,'Label','3 arc sec resolution (USGS DEM)','MenuSelectedFcn', @(~,~)pltopo('lo3'));
        uimenu(submenu,'Label','30 arc sec resolution (GLOBE DEM)','MenuSelectedFcn', @(~,~)pltopo('lo1'));
        uimenu(submenu,'Label','30 arc sec resolution (GTOPO30)','MenuSelectedFcn', @(~,~)pltopo('lo30'));
        uimenu(submenu,'Label','2 deg resolution (ETOPO 2)','MenuSelectedFcn', @(~,~)pltopo('lo2'));
        uimenu(submenu,'Label','5 deg resolution (ETOPO 5, Terrain Base)','MenuSelectedFcn', @(~,~)pltopo('lo5'));
        uimenu(submenu,'Label','Your topography (mydem, mx, my must be defined)','MenuSelectedFcn', @(~,~)pltopo('yourdem'));
        uimenu(submenu,'Label','Help on plotting topography','MenuSelectedFcn', @(~,~)pltopo('genhelp'));
    end
    
    function create_random_data_simulations_menu(parent)
        submenu  =   uimenu(parent,'Label','Random data simulations');
        uimenu(submenu,'label','Create permutated catalog (also new b-value)...','MenuSelectedFcn',@cb_create_permutated);
        uimenu(submenu,'label','Create synthetic catalog...','MenuSelectedFcn',@cb_create_synhthetic_cat);
        
        % uimenu(submenu,'Label','Evaluate significance of b- and a-values','MenuSelectedFcn',@(~,~)brand());
        %  uimenu(submenu,'Label','Calculate a random b map and compare to observed data','MenuSelectedFcn',@(~,~)brand2());
        uimenu(submenu,'Label','Info on synthetic catalogs','MenuSelectedFcn',@(~,~)web(['file:' ZmapGlobal.Data.hodi '/zmapwww/syntcat.htm']));
        
        
        function cb_create_permutated(src,~)
            % will replace existing primary catalog
            ZG=ZmapGlobal.Data;
            [rand_catalog,ok]=syn_invoke_random_dialog(obj.catalog);
            if ok
                ZmapMainWindow(figure,rand_catalog);
            end
            %ZG.newt2 = ZmapCatalog(ZG.primeCatalog);
            %timeplot();
            %zmap_update_displays();
            %bdiff(ZG.primeCatalog);
            %revertcat
        end
        
        function cb_create_synhthetic_cat(src,~)
            % will replace existing primary catalog
            ZG=ZmapGlobal.Data;
            [syn_cat,ok]=syn_invoke_dialog(obj.catalog);
            if ok
                ZmapMainWindow(figure,syn_cat);
            end
%             ZG.newt2 = ZG.primeCatalog;
%             timeplot();
%             zmap_update_displays();
%             bdiff(ZG.primeCatalog);
%             revertcat
        end

        
    end


    
    function create_histogram_menu(parent)
        
        submenu = parent; %uimenu(parent,'Label','Histograms');
        
        uimenu(submenu,'Label','Magnitude Hist.','MenuSelectedFcn',@(~,~)histo_callback('Magnitude'), ...
            'Separator','on');
        uimenu(submenu,'Label','Depth Hist.','MenuSelectedFcn',@(~,~)histo_callback('Depth'));
        uimenu(submenu,'Label','Time Hist.','MenuSelectedFcn',@(~,~)histo_callback('Date'));
        uimenu(submenu,'Label','Hr of the day Hist.','MenuSelectedFcn',@(~,~)histo_callback('Hour'));
        % uimenu(submenu,'Label','Stress tensor quality','MenuSelectedFcn',@(~,~)histo_callback('Quality '));
        
        function histo_callback(hist_type)
            hisgra(obj.catalog, hist_type);
        end
        
    end
    
    function create_decluster_menu(parent)
        submenu = parent;% uimenu(parent,'Label','Decluster the catalog');
        
        uimenu(submenu,'Label','Decluster (Reasenberg)','MenuSelectedFcn',@(~,~)inpudenew(),...
            'Separator','on');
        uimenu(submenu,'Label','Decluster (Gardner & Knopoff)',...
            'Enable','off',... %TODO this needs to be turned into a function
            'MenuSelectedFcn',@(~,~)declus_inp());
    end
    
end