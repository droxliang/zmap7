function animatorz(action) % autogenerated function wrapper
    % turned into function by Celso G Reyes 2017
    
    animator(action, @slicemapz);
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    
    global ps1 ps2 plin pli
    
    switch(action)
        case 'start'
            [ps1, ps2, plin, pli] = animator_start(@animatorz);% ButtonMotion, ButtonUp
       
        case 'move'
            animator_move(ps2, pli, plin)
        case 'stop'
            animator_stop(gcf);
            slicemapz('newslice');
    end
end