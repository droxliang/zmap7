function plot_DeclusReasen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Load catalogs
cFile=cellstr(char('08011401-Landers20-reasen-MCS100.mat'));


% cFile=[cellstr(char('07103003-scec-reasen.mat')),...
%     cellstr(char('07103004-scec-reasen.mat')),...
%     cellstr(char('07103002-scec-reasen.mat')),...
%     cellstr(char('07102504-scec-reasen.mat')),...
%     cellstr(char('07103101-scec-reasen.mat')),...
%     cellstr(char('07102503-scec-GK')),...
%     cellstr(char('07103006-scec-Utsu.mat')),...
%     cellstr(char('07102901-scec-Uhrhammer')),...
%     ]


fMc=2.0;
fYear=1981;

sString=sprintf('load %s',char(cFile(1)));
eval(sString);

figure;
% plot undeclustered cat
vSel=( (params.mCatalog(:,3)>=fYear) & ...
        (params.mCatalog(:,6)>=fMc));
plot(params.mCatalog(vSel,3),...
    cumsum(ones(sum(vSel),1)),...
    '-','LineWidth',2,'Color',[1 0 0]);

for i=1:size(params.mNumDeclus,2)
    vSel=( (params.mCatalog(:,3)>=fYear) & ...
        (params.mCatalog(:,6)>=fMc) & ...
        (params.mNumDeclus(:,i)==1) );

    hold on;
    plot(params.mCatalog(vSel,3),...
        cumsum(params.mNumDeclus(vSel,i)),...
        '-','LineWidth',1,'Color',[.8 .8 .8]);
end

set(gca,'FontSize',16)
xlabel('Years','fontsize',20)
ylabel('Cum # Earthquakes','fontsize',20)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear params
% Load catalogs
cFile=[cellstr(char('08021305-Landers20-reasen-MCS1.mat')),...
    cellstr(char('08021302-Landers-M20-GK2-MCS1.mat')),...
    cellstr(char('08011701-Landers20-misd-MCS1.mat')),...
    ];



    clear params
    sString=sprintf('load %s',char(cFile(1)));
    eval(sString);
    vSel=((params.mCatalog(:,3) > fYear) & ...
        (params.mCatalog(:,6) > fMc) );

    hold on;
    plot(params.mCatalog(vSel,3),...
        cumsum(params.mNumDeclus(vSel,1)),...
        'k-','LineWidth',2);

     clear params
    sString=sprintf('load %s',char(cFile(2)));
    eval(sString);
    vSel=((params.mCatalog(:,3) > fYear) & ...
        (params.mCatalog(:,6) > fMc) );

    hold on;
    plot(params.mCatalog(vSel,3),...
        cumsum(params.mNumDeclus(vSel,1)),...
        '-','LineWidth',2,'Color',[0 0 1]);

     clear params
    sString=sprintf('load %s',char(cFile(3)));
    eval(sString);
    vSel=((params.mCatalog(:,3) > fYear) & ...
        (params.mCatalog(:,6) > fMc) );

    hold on;
    plot(params.mCatalog(vSel,3),...
        cumsum(params.mNumDeclus(vSel,1)),...
        '--','LineWidth',2,'Color',[0 0 1]);

params;



% legend('Reasenberg 1985, Xmeff=3.0',...
%     'Reasenberg (Helmstetter 2007), Xmeff=3.0',...
%     'Reasenberg 1985, Xmeff=2.5',...
%     'Reasenberg 1985, Xmeff=2.0',...
%     'Reasenberg 1985, Xmeff=1.5',...
%     'Gardner & Knopoff 1974',...
%     'Utsu 2002',...
%     'Uhrhammer 1986');