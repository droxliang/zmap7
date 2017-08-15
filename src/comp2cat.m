function comp2cat(do) % autogenerated function wrapper
% This file finds identical events in two catalogs, and
% compares the locations and magnitudes etc.
 % turned into function by Celso G Reyes 2017
 
ZG=ZmapGlobal.Data; % used by get_zmap_globals

% Stefan wiemer 02/99

report_this_filefun(mfilename('fullpath'));

switch(do)

    case 'initial'

        butt =    questdlg('This file finds identical events in two catalogs. please load both catalogs in mat format. Press help for HTML documentation', ...
            'Compare two catalogs', ...
            'OK','Help','Cancel','Cancel');

        switch butt
            case 'OK'

                [file1,path1] = uigetfile([ '*.mat'],'First catalog in *.mat format');
                lopa = [path1 file1];
                do = ['load(lopa)'];
                eval(do,'disp(''Error lodaing data! Are they in the right *.mat format??'')');
                if max(ZG.a.Date) < 100;
                    ZG.a.Date = ZG.a.Date+1900;
                    errdisp = ...
                        ['The catalog dates appear to be 2 digit.    '
                        'Action taken: added 1900 for Y2K compliance'];
                    zmap_message_center.set_message('Error!  Alert!',errdisp)
                    warndlg(errdisp)
                end
                %R calculate time in decimals and substitute in column 3 of file  "a"
                if length(a(1,:))== 7
                    ZG.a.Date = decyear(a(:,3:5));
                elseif length(a(1,:))>=9       %if catalog includes hr and minutes
                    ZG.a.Date = decyear(a(:,[3:5 8 9]));
                end

                nie = a(:,:);

                [file2,path2] = uigetfile([ '*.mat'],'Second catalog in *.mat format');
                lopa = [path2 file2];
                try
                    load(lopa)
                catch ME
                    error_handler(ME, 'Error loading data! Are they in the right *.mat format?');
                end
                if max(ZG.a.Date) < 100
                    ZG.a.Date = ZG.a.Date+1900;
                    errdisp = ...
                        ['The catalog dates appear to be 2 digit.    '
                        'Action taken: added 1900 for Y2K compliance'];
                    zmap_message_center.set_message('Error!  Alert!',errdisp)
                    warndlg(errdisp)
                end
                %R calculate time in decimals and substitute in column 3 of file  "a"
                if length(a(1,:))== 7
                    ZG.a.Date = decyear(a(:,3:5));
                elseif length(a(1,:))>=9       %if catalog includes hr and minutes
                    ZG.a.Date = decyear(a(:,[3:5 8 9]));
                end

                jm = a(:,:);
                do = 'comp'; comp2cat;

            case 'Help'
                try
                    web([ hodi '/help/comps2cat.htm']);
                catch ME
                    errordlg(' Error while opening, please open the browser first and try again or open the file ./help/comp2cat.htm manually');
                end

            case 'Cancel'
                zmap_message_center(); return

        end %swith butt


    case 'comp'
        % find identical events
        def = {'50','2'};
        tit ='Input paramters: Identical events';
        prompt={'Maximum distance of events in km', 'Maximum Time Seperation in Minutes'};

        ni2 = inputdlg(prompt,tit,1,def);
        l = ni2{2};
        timax = str2double(l);
        l = ni2{1};
        dimax = str2double(l);
        id = [];

        for i = 1:length(jm)
            dt = abs(nie(:,3) - jm(i,3));
            xa0 = jm(i,1);     ya0 = jm(i,2);
            di = sqrt(((nie(:,1)-xa0)*cosd(ya0)*111).^2 + ((nie(:,2)-ya0)*111).^2);
            f = find(dt <= timax/(365*24*60) & di <= dimax);
            if rem(i,100) == 0;disp([' Percent completed: '  num2str(i/length(jm)*100)]) ; end
            if length(f) == 1
                id = [id ;  i f ] ;
            end
        end
        do = 'plotres'; comp2cat;

    case('plotres')

        uj = jm;
        uj(id(:,1),:) = [];
        un = nie;
        un(id(:,2),:) = [];

        ij = jm(id(:,1),:);
        in = nie(id(:,2),:);

        disp(['Number of events unique in ' file1 ': ' num2str(length(un(:,1))) ]);
        disp(['Number of events unique in ' file2 ': ' num2str(length(uj(:,1))) ]);
        disp(['Number of  identical events: ' num2str(length(in(:,1))) ]);

        figure_w_normalized_uicontrolunits('pos',[100 100 900 700]);
        subplot(2,2,1)
        tmin = floor(min([nie(:,3) ; jm(:,3)])) ;
        tmax = ceil(max([nie(:,3) ; jm(:,3)])) ;

        [h1, t1]  = histogram(nie(:,3),(tmin:0.02:tmax));
        [h2, t1]  = histogram(jm(:,3),(tmin:0.02:tmax));
        [h3, t1]  = histogram(uj(:,3),(tmin:0.02:tmax));
        [h4, t1]  = histogram(un(:,3),(tmin:0.02:tmax));

        p1 = plot(t1,h1); set(p1,'LineWidth',2);  hold on
        p2 = plot(t1,h2,'r'); set(p2,'LineWidth',2);
        p3 = plot(t1,h3,'g-.'); set(p3,'LineWidth',2);
        p4 = plot(t1,h4,'k-.'); set(p2,'LineWidth',2)

        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out','Xlim',[tmin tmax])

        le2 = legend([p1, p2, p3 , p4 ],file1,file2,['Unique in ' file1 ],['Unique in ' file2]);
        set(le2,'FontSize',4);
        xlabel('Time [yrs]')
        ylabel('Number of detected events');

        % plot magnitude differences
        tmax = max(jm(id(:,1),3))
        dmt = [];
        % for t = tmin:2:tmax-3
        for t =tmin:0.1:tmax
            l = ij(:,3) >= t & ij(:,3) < t+3 ;
            dm = jm(id(l,1),6) - nie(id(l,2),6);
            dmt = [dmt ; t mean(dm) var(dm) length(dm) ];
        end

        subplot(2,2,2)
        pl = errorbar(dmt(:,1),dmt(:,2),dmt(:,3))
        hold on
        pl = plot(dmt(:,1),dmt(:,2),'rs','LineWidth',2.0);
        pl = plot(dmt(:,1),dmt(:,2),'k','LineWidth',2.0);

        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel('Time [years]')
        ylabel([ 'M(' file2 ') - M(' file1 ')']);


        subplot(2,2,3)
        plot(jm(id(:,1),6),nie(id(:,2),6),'^')
        hold on
        t = (0:0.1:6);
        plot(t,t,'r','LineWidth',2)

        [p,s] = polyfit(ij(:,6),in(:,6),1);
        f = polyval(p,(0:0.1:7));

        hold on
        r = corrcoef(in(:,6),ij(:,6));
        r = r(1,2);
        stri = [ 'p = ' num2str(p(1)) '*m +' num2str(p(2))  ];
        stri2 = [ 'r = ' num2str(r) ];
        te1 = text(1,5.8,stri);
        set(te1,'FontSize',12,'FontWeight','bold')
        te1 = text(1,5.4,stri2);
        set(te1,'FontSize',12,'FontWeight','bold')
        mb2 = polyval(p,0:0.1:7);
        plot(0:0.1:7,mb2,'k','LineWidth',2)

        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        axis([ 0 6 0 6.5])
        xlabel([ file2 ' Magnitudes'])
        ylabel([ file1 ' Magnitudes'])
        grid


        subplot(2,2,4)
        dm = jm(id(:,1),6) - nie(id(:,2),6);
        histogram(dm,(-1.8:0.1:1.8))
        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel([ 'M(' file2 ') - M(' file1 ')']);
        stri = ['Mean: ' num2str(mean(dm),2) ];
        yl = max(get(gca,'Ylim'));
        te1 = text(-0.4,yl*0.95,stri);
        set(te1,'FontSize',12,'FontWeight','bold')
        stri = ['STD: ' num2str(std(dm),2) ];
        te1 = text(-0.4,yl*0.9,stri);
        set(te1,'FontSize',12,'FontWeight','bold')
        orient landscape
        ; matdraw

        figure_w_normalized_uicontrolunits('pos',[100 100 1100 600])
        xa0 = jm(id(:,1),1);
        xb0 = nie(id(:,2),1);
        ya0 = jm(id(:,1),2);
        yb0 = nie(id(:,2),2);
        za0 = jm(id(:,1),7);
        zb0 = nie(id(:,2),7);
        di = sqrt(((xb0 -xa0)*cosd(36)*111).^2 + ((yb0-ya0)*111).^2);


        p2 = plot(xa0,ya0,'or');
        hold on
        p1 = plot(xb0,yb0,'^b');
        p3 = plot(un(:,1),un(:,2),'sg');
        p4 = plot(uj(:,1),uj(:,2),'rx');

        overlay_

        v = [];
        for i = 1:length(xa0)
            v = [v ; xa0(i) ya0(i) ; xb0(i) yb0(i) ; inf inf];
        end

        plot(v(:,1),v(:,2),'k');

        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel('Longitude');
        ylabel('Latitude');

        le2 = legend([p1, p2, p3 , p4 ],['Ident. in ' file1 ],['Ident. in ' file2],['Unique in ' file1 ],['Unique in ' file2], 'location', 'NorthEastOutside');
        set(le2,'FontSize',4);
        , matdraw;

        % evaluate depth dependecy
        figure_w_normalized_uicontrolunits('pos',[100 100 900 700]);
        subplot(2,2,1)

        plot(jm(id(:,1),7),nie(id(:,2),7),'^')
        hold on
        maxde = ceil(max([jm(id(:,1),7) ; nie(id(:,2),7)]));
        t = (0:1:maxde);
        plot(t,t,'r','LineWidth',2)

        [p,s] = polyfit(jm(id(:,1),7),nie(id(:,2),7),1);
        f = polyval(p,(0:1:maxde));

        hold on
        r = corrcoef(jm(id(:,1),7),nie(id(:,2),7));
        r = r(1,2);
        stri = [ 'p = ' num2str(p(1)) '*m +' num2str(p(2))  ];
        stri2 = [ 'r = ' num2str(r) ];
        te1 = text(1,58,stri);
        set(te1,'FontSize',12,'FontWeight','bold')
        te1 = text(1,54,stri2);
        set(te1,'FontSize',12,'FontWeight','bold')
        mb2 = polyval(p,0:1:maxde);
        plot(0:1:maxde,mb2,'k','LineWidth',2)

        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel([ file2 ' depth in [km]' ])
        ylabel([ file1 ' depth in [km]']);
        grid


        subplot(2,2,2)
        de = jm(id(:,1),7) - nie(id(:,2),7);
        histogram(de,(-50.:1:50.))
        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel([file2 ' - ' file1 ' depth in [km]'])
        stri = ['Mean: ' num2str(mean(de),2) ];
        te1 = text(-25,80,stri);
        set(te1,'FontSize',12,'FontWeight','bold')
        stri = ['STD: ' num2str(std(de),2) ];
        te1 = text(-25,70,stri);
        set(te1,'FontSize',12,'FontWeight','bold')


        dmt = [];
        for t = tmin:0.5:tmax
            l = ij(:,3) >= t & ij(:,3) < t+2 ;
            dm = jm(id(l,1),7) - nie(id(l,2),7);
            dmt = [dmt ; t+1 mean(dm) std(dm) ];
        end

        subplot(2,2,3)
        pl = errorbar(dmt(:,1),dmt(:,2),dmt(:,3));
        hold on
        pl = plot(dmt(:,1),dmt(:,2),'rs','LineWidth',2.0);
        pl = plot(dmt(:,1),dmt(:,2),'k','LineWidth',2.0);

        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel('Time [years]')
        ylabel('Delta(D)')

        dmt = [];
        for t = 0:1:maxde
            l = ij(:,7) >= t & ij(:,7) < t+10 & ij(:,3) > maxde-10 ;
            dm = jm(id(l,1),7) - nie(id(l,2),7);
            dmt = [dmt ; t+5 mean(dm) std(dm) ];
        end

        subplot(2,2,4)
        pl = errorbar(dmt(:,1),dmt(:,2),dmt(:,3));
        hold on
        pl = plot(dmt(:,1),dmt(:,2),'rs','LineWidth',2.0);
        pl = plot(dmt(:,1),dmt(:,2),'k','LineWidth',2.0);

        set(gca,'FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','normal',...
            'FontWeight','bold','LineWidth',2.0,...
            'Box','on','SortMethod','childorder','TickDir','out')
        xlabel('Depth [km]')
        ylabel([file2 ' - ' file1 ' depth in [km]'])
        ; matdraw


end % switch



end
