function [obj, ok]=selectSegmentUsingMouse(ax, color, refEllipse, addlUpdateFcn)
    % tracks user mouse movements to define a great-circle line segment
    % RESULT = SELECTSEGMENTSUSINGMOUSE( AX, COLOR, refEllipse) where AX is the axis in which to
    % draw your line segment as the great-circle line.
    %
    % RESULT is a struct with fields:
    %   xy1 : starting point [x , y]
    %   xy2 : ending point [x , y]
    %   refEllipse affects the fieldname for the distance returned
    %   IF refEllipse.LengthUnit is 'kilometer', then the field returned is:
    %   dist_kilometer : distance between x & y in kilometer.
    %
    % once the segment has been chosen, it is removed from the plot.
    
    ABORTKEY=27; % escape;
    ok=false;
    %% make sure all arguments are accounted for
    if ~exist('ax','var')
        ax=gca; 
    else
        axes(ax);
    end
    
    if ~(isnumeric(ax.XLim) && isnumeric(ax.YLim))
        ed=errordlg('Axes should be degrees or distance, the selected axes has a non numeric scale');
        origcolor=ax.Color;
        bringToForeground(ax);
        drawnow;
        ax.Color=[1 .7 .7];
        waitfor(ed);
        ax.Color=origcolor;
        return
    end
    
    if ~exist('color','var')
        color='r';
    end
        
    if ~exist('addlUpdateFcn','var')
        addlUpdateFcn=@do_nothing;
    end
    
    %% 
    fig=gcf;
    started=false;
    
    obj=struct('xy1',[nan nan],'xy2',[nan nan],['dist_',refEllipse.LengthUnit],0);
    
    [x1, y1, x2, y2]=deal(nan);
    
    % select center point, if it isn't provided
    disp('click on segment start');% . ESC aborts');
    f=gcf;
    
    if f.CurrentCharacter==ABORTKEY
        f.CurrentCharacter=' ';
    end
    
    TMP.aBDF = ax.ButtonDownFcn;
    TMP.fWBUF = f.WindowButtonUpFcn;
    TMP.fWBMF=f.WindowButtonMotionFcn;
    
    h = gobjects(0);
    
    ax.ButtonDownFcn=@startSegment;
    f.WindowButtonMotionFcn=@queryFirstPoint;
    
    
    
    selected=false;
    fig.Pointer='Cross';
    instructionTextFmt = 'Choose start point\n (x:%g, y:%g)';
    instructionText = text(nan,nan,'Choose start point','FontSize',12,...
        'FontWeight','bold','HitTest','off','BackgroundColor','w');
    
    
    dist=@(x1,y1,x2, y2) distance(y1,x1,y2,x2,refEllipse);
    
    distfld=(['dist_',refEllipse.LengthUnit]);
    
    %% pause because we need completed user input before exiting this function
    while ~started
        pause(.01);
    end
    disp('started!')
    
    b=f.CurrentCharacter;
    if b==ABORTKEY
        % restore previous window functions
        f.WindowButtonMotionFcn=TMP.fWBMF;
        f.WindowButtonUpFcn=TMP.fWBUF;
        ax.ButtonDownFcn=TMP.aBDF;
        fig.Pointer='arrow';
        delete(instructionText);
        delete(h);
        f.CurrentCharacter=' ';
        if nargout<2
            error('Aborting segment creation'); %to calling routine: catch me!
        else
            return;
        end
    end
    
    set(gca,'NextPlot','add');
 
    %% loop waits for mouse button to come back up before continuing
    
    while ~selected
        pause(.05)
    end
    disp('selection done!');
    obj.xy1=[x1,y1];
    obj.xy2=[x2,y2];
    obj.(distfld)=dist(x1,y1,x2,y2);
    
    delete(h);
    
    b=f.CurrentCharacter;
    if b==ABORTKEY
        f.CurrentCharacter=' ';
    else
        ok=true;
    end
        
    return
    
    function startSegment(~,ev)
        disp('start Line'); 
        set(gca,'NextPlot','add');
        cp=ax.CurrentPoint;
        
        x1=cp(1,1);
        y1=cp(1,2);
        h=plot(ax,[x1;x1], [y1;y1], 'o:','MarkerSize',15,'color','k',...
            'MarkerFaceColor',color,'MarkerEdgeColor','k',...
            'LineWidth',2,'DisplayName','Choose Xsection');
        started=true;
        
        % write the text
        h(2)=text((x1+x2)/2,(y1+y2)/2,['Dist: 0 ' refEllipse.LengthUnit],...
            'FontSize',12,'FontWeight','bold','Color',color);
        
        f.WindowButtonMotionFcn=@moveMouseGC;
        
        instructionTextFmt = 'Choose end point\n (x:%g, y:%g)';
        instructionText.String=sprintf(instructionTextFmt,x1,y1);
    end
    
    function v = range_limited(v, minmax)
        if v>minmax(2)
            v=minmax(2);
        elseif v<minmax(1)
            v=minmax(1);
        end
    end
        
    function queryFirstPoint(~,~)
        % move mouse before any point is selected
        cp=ax.CurrentPoint;
        xl=ax.XLim; 
        x=range_limited(cp(1,1), xl);
        y=range_limited(cp(1,2), ax.YLim);

        dx=abs(diff(xl))/100;
        if (x > mean(xl)) 
            set(instructionText,'HorizontalAlignment','right','Position',[x-dx y 0],'String',sprintf(instructionTextFmt,x,y));
        else
            set(instructionText,'HorizontalAlignment','left','Position',[x+dx y 0],'String',sprintf(instructionTextFmt,x,y));
        end
    end
    
    function moveMouse(~,~)
        cp=ax.CurrentPoint;
        ax.ButtonDownFcn=@endSegment;
        f.WindowButtonUpFcn=@endSegment;
        x2=range_limited(cp(1,1), ax.XLim);
        y2=range_limited(cp(1,2), ax.YLim);
        h(1).XData(2)=x2;
        h(1).YData(2)=y2;
        obj.(distfld)=dist(x1,y1,x2,y2);
        h(2).Position(1:2)= [(x1+x2)/2,(y1+y2)/2];
        h(2).String=['Dist:' num2str(obj.(distfld),4) ' ' refEllipse.LengthUnit];
        
        % update instruction text
        dx=abs(diff(ax.XLim))/100;
        if (x2 > mean(ax.XLim)) 
            set(instructionText,'HorizontalAlignment','right','Position',[x2-dx y2 0],'String',sprintf(instructionTextFmt,x2,y2));
        else
            set(instructionText,'HorizontalAlignment','left','Position',[x2+dx y2 0],'String',sprintf(instructionTextFmt,x2,y2));
        end
        addlUpdateFcn([x1 y1],[x2 y2],obj.(distfld));
    end
    
    function moveMouseGC(~,~)
        cp=ax.CurrentPoint;
        ax.ButtonDownFcn=@endSegment;
        f.WindowButtonUpFcn=@endSegment;
        x2=range_limited(cp(1,1), ax.XLim);
        y2=range_limited(cp(1,2), ax.YLim);
        [h(1).YData, h(1).XData]=gcwaypts(y1,x1, y2, x2,20);
        h(1).MarkerIndices=[1 numel(h(1).YData)];
        obj.(distfld)=dist(x1,y1,x2,y2);
        h(2).Position(1:2)= [(x1+x2)/2,(y1+y2)/2];
        h(2).String=['Dist:' num2str(obj.(distfld),4) ' ' refEllipse.LengthUnit];
        
        % update instruction text
        dx=abs(diff(ax.XLim))/100;
        if (x2 > mean(ax.XLim)) 
            set(instructionText,'HorizontalAlignment','right','Position',[x2-dx y2 0],'String',sprintf(instructionTextFmt,x2,y2));
        else
            set(instructionText,'HorizontalAlignment','left','Position',[x2+dx y2 0],'String',sprintf(instructionTextFmt,x2,y2));
        end
        addlUpdateFcn([x1 y1],[x2 y2],obj.(distfld));
    end
    
    
    function endSegment(~,~)
        if strcmp(f.SelectionType, 'open')
            % was a double click. just ignore it.
            return
        end
        
        if isvalid(instructionText)
            delete(instructionText);
        end
        
        selected=true;
        f.WindowButtonMotionFcn=TMP.fWBMF;
        f.WindowButtonUpFcn=TMP.fWBUF;
        ax.ButtonDownFcn=TMP.aBDF;
        fig.Pointer='arrow';
        
    end
    
end