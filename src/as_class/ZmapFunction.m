classdef(Abstract) ZmapFunction < matlab.mixin.Copyable
    %ZmapFunction base class for functions in Zmap, providing a common interface
    %   expects that functions can be called from command prompt or menus
    %
    %  To use, first create a class that inherits from ZmapFunction and provides
    %  the following:
    %
    %
    %     define variables here that would be used in calculation
    %
    %   ZmapFunction Properties(Constant):
    %      PlotTag - string name used to access all items from the plot this creates.
    %
    %
    %   ZmapFunction Methods:
    %
    %       The following methods are RECOMMENDED, but do not need to be defined in your derrived
    %       class:
    %
    %       ModifyGlobals - change ZmapGlobal.Data items here. If possible: ONLY here.
    %
    %       The following methods MUST BE DEFINED.  They provide a
    %       coherent framework for this function's behaviors and to make it easy to
    %       control when this routine does things (IO, for example)
    %
    %       function obj=<name of this class/function>(varargin)
    %           % this is your function constructor that should behave so:
    %           % if varargin is empty, then do the interactive setup.
    %           % otherwise, check pronditions, calculate values, plot, and then modify globals.
    %
    %       InteractiveSetup - create a ZmapDialog that provides the user a way to manipulate parameters used by the Calculate() method.
    %
    %       Calculate - do the calculations, and put all important results into fields of the obj.Results variable.
    %         optionally return the Results so that the caller can directly manipulate them
    %
    %       plot - plot the results of this function
    %
    %  METHODS(Static)
    %       AddMenuItem - create a menu item that calls the constructor
    %
    %
    % TROUBLESHOOTING HELP.
    %    If not all methods have been created, then MATLAB will fail to create
    %    your function with a message "Abstract classes cannot be instantiated."
    %    that includes a clickable link.  Click it go get a list of methodes/properties
    %    that still need to be created.
    %
    %
    % see also ZmapDialog, sample_ZmapFunction, blank_ZmapFunction, ZmapQuickResultPcolor
    
    properties
        % THESE ARE ACCESSIBLE BY ALL DERRIVED CLASSES
        
         % holds complete catalog to be analyzed. defaults to the primary catalog
        RawCatalog      ZmapCatalog  = ZmapGlobal.Data.primeCatalog
        Result          struct            % results of the calculation, stored in a struct
        
        ZG                           = ZmapGlobal.Data; % provides access to the ZMAP global variables.
        hPlot                               % tracks the plot(s) for each function
        ax                           = [];       % axis where plotting will go
        
        AutoShowPlots   logical      = true; % will plots be generated upon calculation?
        InteractiveMode logical      = true;
        DelayProcessing logical      = false;
        CalcFinishedFcn function_handle = @do_nothing ; %call this once calculation ("do it") has finished.
    end
    
    properties(Constant,Abstract)
        PlotTag % string used for tracking the plot for each function (assign in your function)
        ParameterableProperties % properties from each class that can be used as constructor parameters 
        References % paper references for calculations contained within this fn
    end
    
    properties(Dependent)
        FunctionCall    char; % text representation of the function call.
    end
    
    methods
        function obj=ZmapFunction(catalog)
            if exist('catalog','var')
                obj.RawCatalog=catalog;
                obj.verify_catalog(catalog);
            end
        end
        
        function fcall = get.FunctionCall(obj)
            % FUNCTIONCALL provides probable function call for CURRENT STATE of object
            % obj.SETFUNCTIONCALL(varargin)
            
            fcall = class(obj) + "(ZAP";
            for j=1:numel(obj.ParameterableProperties)
                fld = obj.ParameterableProperties(j);
                val=obj.(fld);
                switch class(val)
                    case 'char'
                        fcall = fcall + sprintf(", '%s', '%s'", fld, val);
                    case 'string'
                        fcall = fcall + sprintf(', ''%s'', "%s"', fld, val);
                    case 'datetime'
                        fcall = fcall + sprintf(", '%s', datetime('%s')", fld, string(val));
                    case 'duration'
                        val.Format = 'dd:hh:mm:ss.SSS';
                        fcall = fcall + sprintf(", '%s', duration('%s')", fld,string(val));
                    case 'McMethods' 
                        fcall = fcall + sprintf(", '%s', McMethods.%s", fld,string(val));
                        
                    otherwise
                        if isnumeric(val) && isempty(val)
                            val = '[]';
                        elseif (isnumeric(val) || islogical(val)) && numel(val)>1
                            v="";
                            for r=1:size(val,1)
                                v(r)=strjoin(string(val(r,:)),',');
                            end
                            val="[" + strjoin(v,';') + "]";
                        else
                            try
                            val=string(val);
                            if ismissing(val)
                                val = "<missing>";
                            end
                            catch
                                val = "<some " + class(val) + ">";
                            end
                        end
                        fcall = fcall + sprintf(", '%s', %s", fld, val);
                end
            end
            fcall = fcall + ", 'AutoShowPlots', " + string(obj.AutoShowPlots);
            fcall = fcall + ", 'InteractiveMode', " + string(obj.InteractiveMode);
            % fcall = fcall + ", 'DelayProcessing', " + string(obj.DelayProcessing);
            fcall = fcall + ")";
        end
        
        function p = parseParameters(obj, varginstuff)
            
            % property list is a list of this objects properties that
            % can be set via the parameter list.
            p=inputParser();
            for i=1:numel(obj.ParameterableProperties)
                % use this object's default properties as the... uh. default.
                p.addParameter(obj.ParameterableProperties(i), obj.(obj.ParameterableProperties(i)));
            end
            
            % add parameters inheritable by all functions
            p.addParameter('AutoShowPlots',   obj.AutoShowPlots)
            p.addParameter('InteractiveMode', obj.InteractiveMode);
            p.addParameter('DelayProcessing', obj.DelayProcessing);
            p.addParameter('CalcFinishedFcn', obj.CalcFinishedFcn);
            p.parse(varginstuff{:});
            
            % assign values from parameter to this object
            for i=1:numel(obj.ParameterableProperties)
                obj.(obj.ParameterableProperties(i)) = p.Results.(obj.ParameterableProperties(i));
            end
            obj.AutoShowPlots = p.Results.AutoShowPlots;
            obj.InteractiveMode = p.Results.InteractiveMode;
            obj.DelayProcessing = p.Results.DelayProcessing;
            obj.CalcFinishedFcn = p.Results.CalcFinishedFcn;
        end
        
        function StartProcess(obj)
            if obj.DelayProcessing
                msg.dbdisp('Delaying processing',class(obj))
                return
            end
            
            if obj.InteractiveMode
                obj.InteractiveSetup();
            else
                obj.doIt();
            end
        end
        
        function clearPlot(obj)
            % CLEARPLOT remove all plot items added by this function
            delete(obj.hPlot);
            obj.hPlot=[];
        end
                
        function doIt(obj)
            % DOIT called by the interactive dialog box once OK is pressed. 
            % Calls, in turn: Calculate, plot, ModifyGlobals, saveToDesktop
            %
            % each of these functions is defined in the subclass.
            % change DOIT behavior by redefining DOIT in the sublcass.
            obj.Calculate();
            obj.ModifyGlobals();
            obj.saveToDesktop();
            if obj.AutoShowPlots
                obj.plot();
            end
        end
        
        function  ModifyGlobals(obj)
            % MODIFYGLOBALS modify zmapglobals (define in subclass)
            % do any changing of zmap globals here
            do_nothing(obj)
        end
        
        function saveToDesktop(obj)
            % SAVETODESKTOP saves results to desktop
            vname = matlab.lang.makeValidName([class(obj),'_result']);
            %assert(~isfield(obj.Result,'FunctionCall'), 'FunctionCall is a reserved field in the results');
            obj.Result.FunctionCall = obj.FunctionCall;
           
            obj.Result.InCatalogName = obj.RawCatalog.Name; %was OperatingCatalog
            assignin('base', vname, obj.Result);
            fprintf('%s  %% called by Zmap : %s\n',obj.FunctionCall, char(datetime));
            fprintf('%% results in: %s\n',vname);
        end
        
        function f=Figure(obj,option, menufun)
            % finds my figure, and will create if necessary
            % sets obj.ax to any/all axes in figure
            % option:
            %    'deleteaxes' : all axes for this figure be deleted
            %
            % if figure needs to be created, then menufun is called
            % menufun is a function handle
            if ~exist('option','var')
                option='';
            end
            
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
                if exist('menufun','var') && isa(menufun, 'function_handle')
                    menufun();
                end
            end
            
            figure(f);
            obj.ax=findobj(f,'Type','axes');
            switch option
                case 'deleteaxes'
                    delete(obj.ax);
                case ''
                otherwise
                    error('unknown');
            end
        end
    end % PUBLIC METHODS
    
    methods(Abstract)  % these functions MUST be defined in every class derived from ZmapFunction
        
        % INTERACTIVESETUP ask the user for additional parameters necessary for the calculation
        InteractiveSetup(obj);
        
        % CALCULATE perform calculations
        % obj.CALCULATE() stores results in obj.Result  (obj.Result.values = results)
        % RESULTS = OBJ.CALCULATE() also, return results
        Results=Calculate(obj);
        
        % PLOT visually communicate results to the user
        %
        % obj.PLOT(varargin) plot results, passing along all parameters
        %
        % if plots can be generalized, such as xsection-plots, or map-view plots, then
        % sublcass ZmapFunction and define the plot in the subclass. Then, make your function
        % a subclass of THAT class. 
        % for examples, see also ZmapGridFunction, ZmapTimeFunction,  ZmapHGridFunction
        plot(obj,varargin); % plot
        
    end %ABSTRACT METHODS
    
    methods % will be protected
        function t = helptext(obj, subject)
            % provides help text, based on the subject.
            switch subject
                case 'PlotTag'
                    t = "Title for this plot will be <strong>'" + obj.PlotTag+"'</strong>";
                case 'ParameterableProperties'
                    m=metaclass(obj);
                    t = "<strong>Name-Value</strong> pairs that can be specified when creating this function:"+newline+...
                        "";
                    plist = [string(obj.ParameterableProperties),"AutoShowPlots","InteractiveMode","DelayProcessing"];
                    for j=1:numel(plist)
                        pidx=string({m.PropertyList.Name})==plist(j);
                        p = m.PropertyList(pidx);
                        t=t+newline+"   <strong>"+ pad(plist(j),20,'right') + "</strong> : " + class(obj.(plist(j)));
                        if p.HasDefault
                            if numel(p.DefaultValue)>0 && (isnumeric(p.DefaultValue) || islogical(p.DefaultValue))
                                dv=string(mat2str(p.DefaultValue));
                            else
                                dv = string(p.DefaultValue);
                            end
                            if ismissing(dv)
                                if isnumeric(p.DefaultValue)
                                    dv="nan";
                                else
                                    dv="<missing>";
                                end
                            end
                            
                        if dv.strlength > 33
                            dv=dv.extractBefore(15) + "<strong>...</strong>"+dv.extractAfter(dv.strlength-14);
                        end
                            t=t+" [default: "+dv+"]";
                        end
                        try
                        if ~isempty(p.Validation) && ~isempty(p.Validation.ValidatorFunctions)
                            fn = cellfun(@func2str,p.Validation.ValidatorFunctions,'UniformOutput',false);
                            t=t+ " that " + strjoin(fn,',');
                        end
                        catch ME
                            disp("error wile parsing validator functions:"+ me.identifier)
                        end
                    end
                    
                    if ~isempty(plist)
                        pv = obj.(obj.ParameterableProperties(1));
                        if ischar(pv)
                            pp = sprintf("'%s'",pv);
                        elseif isstring(pv)
                            pp = sprintf('"%s"',pv);
                        elseif isa(pv,'function_handle')
                            pp = sprintf('@%s', func2str(pv)');
                        elseif (isnumeric(pv) || islogical(pv)) && length(pv)>1
                            pp=string(mat2str(pv));
                        else
                            try
                                pp = string(pv);
                            catch
                                pp="some_"+ class(pv);
                            end
                        end
                        
                        t = t+ newline+newline+ "For example:"+newline+...
                            "    obj = "+class(obj) +"(... , '" + ...
                            obj.ParameterableProperties(1) + "', " + ...
                            pp + ")";
                    end
                        
                    assert(numel(t)==1)
                    
                case "ReturnDetails"
                    t = "This function calculates :" + newline + ...
                        strjoin("  <strong>"+pad(obj.ReturnDetails.Names,20,'right') + "</strong> "+ obj.ReturnDetails.Descriptions,newline);
                    
                case "References"
                    t = "References for this function:"+newline;
                    padValue = "  ";
                    r = strjoin(padValue + string(obj.References),newline);
                    if r~=padValue
                        t = t + r;
                    else
                        t = t + "   <missing>";
                    end
                    
                case "-choices"
                    t = ["PlotTag","ParameterableProperties","ReturnDetails", "References"];
                case "-all"
                    ch = obj.helptext("-choices");
                    t="";
                    for i=1:numel(ch)
                        t = t+ newline + newline + obj.helptext(ch(i));
                    end
                    
                otherwise
                    error('help for item %s not found', subject)
            end
        end
    end
    
    methods(Static, Abstract)
        
        % create a menu item that will be used to call this function/class (Define this as a static member of your class)
        %    sample implementation here:
        %
        %    function h=AddMenuItem(parent,zapFcn)
        %        % ADDMENUITEM create a menu item that will be used to call this function/class
        %        % h = AddMenuItem(parent, zapFcn) creates a menu item under the container PARENT
        %        %     that will call this class/fuction.  ZAPFCN is a function_handle that, when
        %        %     called returns a ZmapAnalysisPkg containing all the state details used to
        %        %     process the data.
        %
        %       label = 'testmenuitem';                        % CHANGE THIS TO YOUR MENUNAME
        %       cb = @(~,~)sample_ZmapFunction(zapFcn());      % CHANGE THIS TO YOUR CALLBACK
        %       h=uimenu(parent,'Label',label,MenuSelectedField(),cb);
        %    end
        %
        % you can copy/paste the above into your Static methods section
        AddMenuItem(parent, zapFcn)
        
    end % STATIC ABSTRACT METHODS
    
    methods(Static, Access=protected)
        function verify_catalog(c)
            % VERIFY_CATALOG makes sure the catalog is valid and has events
            % verify_catalog( CATALOG )
            assert(~isempty(c),'Catalog is empty');
            assert(isa(c,'ZmapCatalog'),'Please provide a ZmapCatalog, not a ',class(c));
        end
    end
end
