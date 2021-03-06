classdef rcvalgrid_a2 < ZmapHGridFunction
    % RCVALGRID_A2 Calculates relative rate change map, p-,c-,k- values and standard deviations after model selection by AIC
    % Uses view_rcva_a2 to plot the results
    
    properties
        bootloops           = 100       % number of bootstrap loops [bootloops]
        forec_period duration      = days(20)  % forecast period [forec_period]
        learn_period duration       = days(47)  % learning period  [learn_period]
        addtofig logical    = false     % should this plot in current figure? [oldfig_button]
        minThreshMag        = 0
    end
    properties(Constant)
        PlotTag         ='rcvalgrid_a2'
        ReturnDetails   = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'learn_period',     'learning period','days';...                #1
            'absdiff',  'obs. aftershocks - #events in modeled forecast period','';... #2
            'numreal',  'observed # aftershocks',''; ...            #3
            'nummod',   '#events in modeled forecast period','';... #4
            ...  p,c,k- values for period before large aftershock or just modified Omori law
            'pval1',    'p-value','';...                        #5 [mPval]
            'pmedStd1', 'p-value standard deviation', '';...    #6 [mPvalstd]
            'cval1',    'c-value','';...                        #7 [mCval]
            'cmedStd1', 'c-value standard deviation','';...     #8 [mCvalstd]
            'kval1',    'k-value','';...                        #9 [mKval]
            'kmedStd1', 'k-value standard deviation','';...     #10 [mKvalstd]
            ... Resolution parameters
            'fStdBst',  '',''; ... #11 [?]
            'nMod',     'Chosen fitting model', '';...                  #12 [mMd]
            'nY',       'Number of events per grid node', '';...        #13 [mNumevents]
            'fMaxDist', 'Radii of chosen events, Resolution', '';...    #14 [vRadiusRes]
            'fRcBst',   'Relative rate change (bootstrap)','';...       #15 [mRelchange]
            ... p,c,k- values for period AFTER large aftershock
            'pval2',    'p-value (after large aftershock)','';...           #16 [mPval2]
            'pmedStd2', 'p-value std dev (after large aftershock)','';...   #17 [mPvalstd2]
            'cval2',    'c-value (after large aftershock)','';...           #18 [mCval2]
            'cmedStd2', 'c-value std dev (after large aftershock)','';...   #19 [mCvalstd2]
            'kval2',    'k-value (after large aftershock)','';...           #20 [mKval2]
            'kmedStd2', 'k-value std dev (after large aftershock)','';...   #21 [mKvalstd2]
            'H',        'KS-Test (H-value) binary rejection criterion at 95% confidence level','';...#22 [mKstestH]
            'KSSTAT',   'KS-Test statistic for goodness of fit','';...      #23 [mKsstat]
            'P',        'KS-Test p-value','';...                            #24 [mKsp]
            'fRMS',     'RMS value for goodness of fit','';...              #25 [mRMS]
            'fTBigAf',  'Times of secondary afterhsock',''...               #26 [mBigAf]
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields      = {...
            'learn_period',     'absdiff',  'numredal', 'nummod',...
            'pval1',    'pmedStd1', 'cval1',    'cmedStd1',...
            'kval1',    'kmedStd1', 'fStdBst',  'nMod',...
            'nY',       'fMaxDist', 'fRcBst',...
            'pval2',    'pmedStd2', 'cval2',    'cmedStd2',...
            'kval2',    'kmedStd2', 'H',        'KSSTAT',...
            'P',        'fRMS',     'fTBigAf'}
        
        ParameterableProperties = ["bootloops" "forec_period"....
                "learn_period" "addtofig"...
                "NodeMinEventCount" "minThreshMag"];
            
        References="";
    end
    methods
        function obj=rcvalgrid_a2(zap,varargin)
            
            obj@ZmapHGridFunction(zap, 'fRcBst'); % rfRcBst is rate change
            report_this_filefun();
           
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            
            zdlg = ZmapDialog();
            
            %zdlg.AddPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',McMethods.dropdownList(),double(McMethods.MaxCurvature),...
            %    'Choose the calculation method for Mc')
            
            % add fMaxRadius
            obj.AddDialogOption(zdlg, 'EventSelector');
            zdlg.AddEdit(        'bootloops',   '# boot loops',           obj.bootloops,  'number of bootstraps');
            zdlg.AddDurationEdit('forec_period','forecast period',        obj.forec_period,      'forecast period', @days);
            zdlg.AddDurationEdit('learn_period','learn period',           obj.learn_period,       'learning period', @days);
            zdlg.AddCheckbox(    'addtofig',    'plot in current figure', obj.addtofig,[],'plot in the current figure');
            zdlg.AddEdit(        'minThreshMag', 'min. threshhold Mag',    obj.minThreshMag, 'Minimum magnitude');
            obj.AddDialogOption(zdlg, 'NodeMinEventCount');
            % FIXME min number of events should be the number > Mc
            
            zdlg.Create('Name', 'relative rate change map','WriteToObj',obj,'OkFcn', @obj.doIt);
        end

        function ModifyGlobals(obj)
            obj.ZG.bvg=obj.Result.values;
        end
        
        function results=Calculate(obj)

            % check pre-conditions
            assert(ensure_mainshock(),'No mainshock was defined')

            % cut catalog at mainshock learn_period:
            mainshock=obj.ZG.maepi.subset(1);
            mainshock_time = mainshock.Date;
            learn_to_date = mainshock_time + obj.learn_period;
            forecast_to_date = learn_to_date + obj.forec_period;
            l = obj.RawCatalog.Date > mainshock_time & obj.RawCatalog.Magnitude > obj.minThreshMag;
            
            assert(any(l),'no events meet the criteria of being after the mainshock ,and greater than threshold magnitude');
            
            obj.RawCatalog=obj.RawCatalog.subset(l);
            ZG.newt2=obj.RawCatalog;
            
            
            obj.gridCalculations(@calculation_function);
            
            if nargout
                results=obj.Result.values;
            end
            % view_rcva_a2(lab1,valueMap)
            
            function [cat_learn, cat_forecast] = prep_catalog(catalog)
                % Choose between constant radius or constant number of events with maximum radius
                if UseEventsInRadius   % take point within r
                    catalog = ZG.primeCatalog.selectRadius(y,x,ra);
                    fMaxDist = max(catalog.epicentralDistanceTo(y,x));
                    % Calculate number of events per gridnode in learning period learn_period
                    cat_learn = catalog.subset(catalog.Date <= learn_to_date);
                else
                    % Determine ni number of events in learning period
                    % Set minimum number to constant number
                    NodeMinEventCount = ni;
                    % Select events in learning learn_period period
                    cat_learn = catalog.subset(catalog.Date <= learn_to_date);
                    
                    cat_forecast = catalog.subset(...
                        catalog.Date > learn_to_date & ...
                        catalog.Date <= forecast_to_date);
                    
                    % Distance from grid node for learning period and forecast period
                    [cat_learn, fMaxDist] = cat_learn.selectClosestEvents(ni);
                    
                    if fMaxDist <= fMaxRadius
                        vSel3 = cat_forecast.epicentralDistanceTo(y,x) <= fMaxDist;
                        cat_forecast = cat_forecast.subset(vSel3);
                        catalog = cat_learn.cat(cat_forecast);
                    else
                        vSel4 = (catalog.epicentralDistanceTo(y,x) < fMaxRadius & catalog.Date <= learn_to_date);
                        catalog = catalog.subset(vSel4);
                        cat_learn = catalog;
                    end
                    cat_forecast.Count
                    catalog.Count
                end
                
            end
            
            function out=calculation_function(catalog)
                
                error('hey developer, finish editing the prep_catalog function first')
                [cat_learn, cat_forecast] = prep_catalog(catalog);
                
                % Calculate the relative rate change, p, c, k, resolution
                if cat_learn.Count >= obj.NodeMinEventCount  % enough events?
                    [mRc] = calc_rcloglike_a2(catalog,obj.learn_period,obj.forec_period,obj.bootloops, mainshock);
                    % Relative rate change normalized to sigma of bootstrap
                    if mRc.fStdBst~=0
                        mRc.fRcBst = mRc.absdiff/mRc.fStdBst;
                    else
                        mRc.fRcBst = NaN;
                    end
                    
                    % Number of events per gridnode
                    % Final grid
                    mRc.nY = cat_learn.Count;
                    mRc.fMaxDist = fMaxDist;
                    out = [mRc.learn_period mRc.absdiff mRc.numreal mRc.nummod ...
                        mRc.pval1 mRc.pmedStd1 mRc.cval1 mRc.cmedStd1...
                        mRc.kval1 mRc.kmedStd1 mRc.fStdBst...
                        mRc.nMod mRc.nY mRc.fMaxDist mRc.fRcBst...
                        mRc.pval2 mRc.pmedStd2 mRc.cval2 mRc.cmedStd2...
                        mRc.kval2 mRc.kmedStd2 mRc.H mRc.KSSTAT...
                        mRc.P mRc.fRMS mRc.fTBigAf];
                else
                    out = nan(1,26);
                end
            end
        end
    end
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='Rate change, p-,c-,k-value map in aftershock sequence (MLE)';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XYfun.rcvalgrid_a2(zapFcn()));
        end
    end
end
%{
function [sel]=orig_rcvalgrid_a2()
    % Calculates relative rate change map, p-,c-,k- values and standard deviations after model selection by AIC
    % Uses view_rcva_a2 to plot the results
    %
    % For the execution of this program, the "Cumulative Window" should have been opened before.
    % Otherwise the matrix "ZG.maepi", used by this program, does not exist.
    %
    % J. Woessner
    % updated: 14.02.05
    
    ZG=ZmapGlobal.Data;
    report_this_filefun();
    
    minThreshMag = min(ZG.primeCatalog.Magnitude);
    
    % Set the grid parameter
    % Initial values
    dx = 0.02; % Grid size latitude [deg]
    dy = 0.02; % Grid size longitude [deg]
    ni = 150;  % Minimum number
    NodeMinEventCount = 100; % Minimum number
    learn_period = days(47);  % Learning period [days]
    forec_period= days(20);  % Forecast period [days]
    bootloops = 100; % Bootstrap
    ra = 5;          % Radius [km]
    fMaxRadius = 5;  % Max. radius [km] in case of constant number
    bMap = true; % Map view
    bGridEntireArea = false; % Grid area, interactive or entire map
    UseEventsInRadius=false; % required for variable scoping.
    load_grid=false; % required for variable scoping.
    prev_grid=false; % required for variable scoping.
    Grid=[];
    EventSelector=[];
    
    if ~ensure_mainshock()
        return
    end
    % cut catalog at mainshock learn_period:
    l = ZG.primeCatalog.Date > ZG.maepi.Date(1) & ZG.primeCatalog.Magnitude > minThreshMag;
    ZG.newt2=ZG.primeCatalog.subset(l);
    

    unimplemented_error()
    
    function my_calculate() % 'ca'
        % get the grid-size interactively and
        % calculate the cat_all-value in the grid by sorting
        % the seismicity and selectiong the ni neighbors
        % to each grid point
        %In the following line, the program .m is called, which creates a rectangular grid from which then selects,
        %on the basis of the vector ll, the points within the selected poligon.
        hWindow =  findobj('Name','Coulomb-map');
        if ~isempty(hWindow)
            map = hWindow;
        else
            map = findobj('Name','Seismicity Map');
        end
        %{
        % Select grid
        if load_grid
            [file1,path1] = uigetfile(['*.mat'],'previously saved grid');
            if length(path1) > 1
                
                load([path1 file1])
                gx = xvect;
                gy = yvect;
            end
            plot(newgri(:,1),newgri(:,2),'k+')
        elseif ~load_grid &&  ~prev_grid
            % Create new grid
            [newgri, xvect, yvect, ll] = ex_selectgrid(map, dx, dy, bGridEntireArea);
            gx = xvect;
            gy = yvect;
        elseif prev_grid
            plot(newgri(:,1),newgri(:,2),'k+')
        end
        %   end
        %}
        % Waitbar counting
        itotal = length(newgri(:,1));
        % Plot all grid points
        plot(newgri(:,1),newgri(:,2),'+k')
        drawnow
        
        %  make grid, calculate start- endtime etc.  ...
        %
        [t0b, teb] = bounds(ZG.primeCatalog.Date) ;
        n = ZG.primeCatalog.Count;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        
        % Container
        mRcGrid =[];
        allcount = 0.;
        % Waiting bar
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','Rate change grid - percent done');
        drawnow
        %
        %% Loop over all points
        for i= 1:length(newgri(:,1))
            i/length(newgri(:,1));
            % Grid node point
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            
            % Choose between constant radius or constant number of events with maximum radius
            if UseEventsInRadius   % take point within r
                cat_all = ZG.primeCatalog.selectRadius(y,x,ra);
                fMaxDist = max(cat_all.epicentralDistanceTo(y,x));
                % Calculate number of events per gridnode in learning period learn_period
                vSel = cat_all.Date <= ZG.maepi.Date(1)+days(learn_period);
                cat_tmp = cat_all.subset(vSel);
            else
                % Determine ni number of events in learning period
                % Set minimum number to constant number
                NodeMinEventCount = ni;
                % Select events in learning learn_period period
                vSel = (cat_all.Date <= ZG.maepi.Date(1)+days(learn_period));
                cat_learn = cat_all.subset(vSel);
                
                vSel2 = (cat_all.Date > ZG.maepi.Date(1)+days(learn_period) & cat_all.Date <= ZG.maepi.Date(1)+(learn_period+forec_period)/365);
                cat_forecast = cat_all.subset(vSel2);
                
                % Distance from grid node for learning period and forecast period
                [cat_learn, fMaxDist] = cat_learn.selectClosestEvents(ni);
                
                if fMaxDist <= fMaxRadius
                    vSel3 = cat_forecast.epicentralDistanceTo(y,x) <= fMaxDist;
                    cat_forecast = cat_forecast.subset(vSel3);
                    cat_all = [cat_learn; cat_forecast]; %FIXME I'm sure this isn't concatenating properly
                else
                    vSel4 = (cat_all.epicentralDistanceTo(y,x) < fMaxRadius & cat_all.Date <= ZG.maepi.Date(1)+days(learn_period));
                    cat_all = cat_all.subset(vSel4);
                    cat_learn = cat_all;
                end
                cat_learn.Count
                cat_forecast.Count
                cat_all.Count
                cat_tmp = cat_learn;
            end
            
            % Calculate the relative rate change, p, c, k, resolution
            if cat_tmp.Count >= NodeMinEventCount  % enough events?
                [mRc] = calc_rcloglike_a2(cat_all,obj.learn_period,obj.forec_period,obj.bootloops, ZG.maepi);
                % Relative rate change normalized to sigma of bootstrap
                if mRc.fStdBst~=0
                    mRc.fRcBst = mRc.absdiff/mRc.fStdBst;
                else
                    mRc.fRcBst = NaN;
                end
                
                % Number of events per gridnode
                [nY,nX]=size(cat_tmp);
                % Final grid
                mRc.nY = nY;
                mRc.fMaxDist = fMaxDist;
                mRcGrid = [mRcGrid; ...
                    mRc.learn_period mRc.absdiff mRc.numreal mRc.nummod ...
                    mRc.pval1 mRc.pmedStd1 mRc.cval1 mRc.cmedStd1...
                    mRc.kval1 mRc.kmedStd1 mRc.fStdBst mRc.nMod mRc.nY mRc.fMaxDist mRc.fRcBst...
                    mRc.pval2 mRc.pmedStd2 mRc.cval2 mRc.cmedStd2...
                    mRc.kval2 mRc.kmedStd2 mRc.H mRc.KSSTAT mRc.P mRc.fRMS mRc.fTBigAf];
            else
                mRcGrid = [mRcGrid; nan(1,26)];
            end
            waitbar(allcount/itotal)
        end  % for newgr
        
        %%
        % Save the data to rcval_grid.mat
        % save rcval_grid.mat mRcGrid gx gy dx dy ZG.bin_dur tdiff t0b teb a main faults mainfault coastline yvect xvect tmpgri ll overall_b_value newgri gll ra learn_period forec_period bootloops ZG.maepi
        [sFilename, sPathname] = uiputfile('*.mat', 'Save MAT-file');
        sFileSave = [sPathname sFilename];
        save(sFileSave,'mRcGrid','gx','gy','dx','dy','a','main','yvect','xvect','ll','newgri','ra','learn_period','forec_period','bootloops','ZG.maepi');
        save rcval_grid.mat mRcGrid gx gy dx dy a main yvect xvect ll newgri ra learn_period forec_period bootloops ZG.maepi
        disp('Saving data to rcval_grid.mat in current directory')
        
        close(wai)
        watchoff
        
        %normlap2=NaN(length(xvect(1,:)),1);
        normlap2=NaN(length(ll),1);
        % Relative rate change
        normlap2(ll)= mRcGrid(:,15);
        mRelchange = reshape(normlap2,length(yvect),length(xvect));
        
        %%% p,c,k- values for period before large aftershock or just modified Omori law
        % p-value
        normlap2(ll)= mRcGrid(:,5);
        mPval=reshape(normlap2,length(yvect),length(xvect));
        
        % p-value standard deviation
        normlap2(ll)= mRcGrid(:,6);
        mPvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        % c-value
        normlap2(ll)= mRcGrid(:,7);
        mCval = reshape(normlap2,length(yvect),length(xvect));
        
        % c-value standard deviation
        normlap2(ll)= mRcGrid(:,8);
        mCvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        % k-value
        normlap2(ll)= mRcGrid(:,9);
        mKval = reshape(normlap2,length(yvect),length(xvect));
        
        % k-value standard deviation
        normlap2(ll)= mRcGrid(:,10);
        mKvalstd = reshape(normlap2,length(yvect),length(xvect));
        
        %%% Resolution parameters
        % Number of events per grid node
        normlap2(ll)= mRcGrid(:,13);
        mNumevents = reshape(normlap2,length(yvect),length(xvect));
        
        % Radii of chosen events, Resolution
        normlap2(ll)= mRcGrid(:,14);
        vRadiusRes = reshape(normlap2,length(yvect),length(xvect));
        
        % Chosen fitting model
        normlap2(ll)= mRcGrid(:,12);
        mMod = reshape(normlap2,length(yvect),length(xvect));
        
        try
            %%% p,c,k- values for period AFTER large aftershock
            % p-value
            normlap2(ll)= mRcGrid(:,16);
            mPval2=reshape(normlap2,length(yvect),length(xvect));
            
            % p-value standard deviation
            normlap2(ll)= mRcGrid(:,17);
            mPvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value
            normlap2(ll)= mRcGrid(:,18);
            mCval2 = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value standard deviation
            normlap2(ll)= mRcGrid(:,19);
            mCvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value
            normlap2(ll)= mRcGrid(:,20);
            mKval2 = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value standard deviation
            normlap2(ll)= mRcGrid(:,21);
            mKvalstd2 = reshape(normlap2,length(yvect),length(xvect));
            
            % KS-Test (H-value) binary rejection criterion at 95% confidence level
            normlap2(ll)= mRcGrid(:,22);
            mKstestH = reshape(normlap2,length(yvect),length(xvect));
            
            %  KS-Test statistic for goodness of fit
            normlap2(ll)= mRcGrid(:,23);
            mKsstat = reshape(normlap2,length(yvect),length(xvect));
            
            %  KS-Test p-value
            normlap2(ll)= mRcGrid(:,24);
            mKsp = reshape(normlap2,length(yvect),length(xvect));
            
            % RMS value for goodness of fit
            normlap2(ll)= mRcGrid(:,25);
            mRMS = reshape(normlap2,length(yvect),length(xvect));
            
            % Times of secondary afterhsock
            normlap2(ll)= mRcGrid(:,26);
            mBigAf = reshape(normlap2,length(yvect),length(xvect));
            
        catch
            disp('Values not calculated')
        end
        % Data to plot first map
        valueMap = mRelchange;
        lab1 = 'Rate change';
        
        % View the map
        view_rcva_a2(lab1,valueMap)
        
    end
    function my_load() %'lo'
        % Load exist cat_all-grid
        [file1,path1] = uigetfile(['*.mat'],'cat_all-value gridfile');
        if length(path1) > 1
            
            load([path1 file1])
            
            normlap2=NaN(length(ll),1);
            % Relative rate change
            normlap2(ll)= mRcGrid(:,15);
            mRelchange = reshape(normlap2,length(yvect),length(xvect));
            
            %%% p,c,k- values for period before large aftershock or just modified Omori law
            % p-value
            normlap2(ll)= mRcGrid(:,5);
            mPval=reshape(normlap2,length(yvect),length(xvect));
            
            % p-value standard deviation
            normlap2(ll)= mRcGrid(:,6);
            mPvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value
            normlap2(ll)= mRcGrid(:,7);
            mCval = reshape(normlap2,length(yvect),length(xvect));
            
            % c-value standard deviation
            normlap2(ll)= mRcGrid(:,8);
            mCvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value
            normlap2(ll)= mRcGrid(:,9);
            mKval = reshape(normlap2,length(yvect),length(xvect));
            
            % k-value standard deviation
            normlap2(ll)= mRcGrid(:,10);
            mKvalstd = reshape(normlap2,length(yvect),length(xvect));
            
            %%% Resolution parameters
            % Number of events per grid node
            normlap2(ll)= mRcGrid(:,13);
            mNumevents = reshape(normlap2,length(yvect),length(xvect));
            
            % Radii of chosen events, Resolution
            normlap2(ll)= mRcGrid(:,14);
            vRadiusRes = reshape(normlap2,length(yvect),length(xvect));
            
            % Chosen fitting model
            normlap2(ll)= mRcGrid(:,12);
            mMod = reshape(normlap2,length(yvect),length(xvect));
            
            try
                %%% p,c,k- values for period AFTER large aftershock
                % p-value
                normlap2(ll)= mRcGrid(:,16);
                mPval2=reshape(normlap2,length(yvect),length(xvect));
                
                % p-value standard deviation
                normlap2(ll)= mRcGrid(:,17);
                mPvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % c-value
                normlap2(ll)= mRcGrid(:,18);
                mCval2 = reshape(normlap2,length(yvect),length(xvect));
                
                % c-value standard deviation
                normlap2(ll)= mRcGrid(:,19);
                mCvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % k-value
                normlap2(ll)= mRcGrid(:,20);
                mKval2 = reshape(normlap2,length(yvect),length(xvect));
                
                % k-value standard deviation
                normlap2(ll)= mRcGrid(:,21);
                mKvalstd2 = reshape(normlap2,length(yvect),length(xvect));
                
                % KS-Test (H-value) binary rejection criterion at 95% confidence level
                normlap2(ll)= mRcGrid(:,22);
                mKstestH = reshape(normlap2,length(yvect),length(xvect));
                
                %  KS-Test statistic for goodness of fit
                normlap2(ll)= mRcGrid(:,23);
                mKsstat = reshape(normlap2,length(yvect),length(xvect));
                
                %  KS-Test p-value
                normlap2(ll)= mRcGrid(:,24);
                mKsp = reshape(normlap2,length(yvect),length(xvect));
                
                % RMS value for goodness of fit
                normlap2(ll)= mRcGrid(:,25);
                mRMS = reshape(normlap2,length(yvect),length(xvect));
                
                % Times of secondary afterhsock
                normlap2(ll)= mRcGrid(:,26);
                mBigAf = reshape(normlap2,length(yvect),length(xvect));
            catch
                disp('Values not calculated')
            end
            
            % Initial map set to relative rate change
            valueMap = mRelchange;
            lab1 = 'Rate change';
            
            old = valueMap;
            % Plot
            view_rcva_a2(lab1,valueMap);
        else
            return
        end
    end
    
    
end
%}
