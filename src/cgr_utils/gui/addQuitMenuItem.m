function addQuitMenuItem()
    % ADDQUITMENUITEM add quit menu to main file menu
    hQuit=findall(gcf,'Label','QuitZmap');
    if isempty(hQuit)
        mainfile=findall(gcf,'Tag','figMenuFile');
        uimenu(mainfile,'Label','Quit Zmap','Separator','on','Callback',@(~,~)restartZmap);
    end
end