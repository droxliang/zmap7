function [Mc, Mc90, Mc95, magco, prf]= mcperc_ca3(magnitudes) 
    % MCPERC_CA3 This is a completeness determination test
    %
    % FIXME: WHAT MAKES THIS SPECIAL?  doesn't calc_Mc do this? what is this method, specifically!
    %
    % MCPERC_CA3(catalog)
    % returns:
    %     [Mc, Mc90, Mc95, magco, prf]
  
    % used to pull from newt2
    
    % 
    magwin_centers = -2 : 0.1 : 6;
    [bval,xt2] = histcounts(magnitudes, centers2edges(magwin_centers));
    xt2=edges2centers(xt2);
    l = find(bval == max(bval), 1, 'last' );
    magco0 =  xt2(l);
    
    loopMags= magco0-0.5 : 0.1 : magco0+0.7; % from near magnitude of completion to a little past it.
    nMags = numel(loopMags);
    dat=nan(nMags,2);
    for n = 1:nMags
        thisMag = loopMags(n);
        l = magnitudes >= thisMag - 0.0499;
        nEvents=sum(l);
        if nEvents >= 25
            smallcat = magnitudes(l);
            %[bv magco stan,  av] =  bvalca3(catalog.Magnitude(l), McAutoEstimate.manual);
            [bv2, stan2, av] = calc_bmemag(smallcat, 0.1);
            try
                res2=synthb_aut(smallcat, bv2,thisMag, 0.1);
            catch ME
                warning(ME.message);
                res2=nan;
            end
            dat(n,:) = [thisMag, res2];
        else
            dat(n,:) = [thisMag NaN];
        end
        
    end
    
    j =  find(dat(:,2) < 10 , 1 );
    if isempty(j)
        Mc90 = NaN ;
    else
        Mc90 = dat(j,1);
    end
    
    j =  find(dat(:,2) < 5 , 1 );
    if isempty(j) 
        Mc95 = NaN ;
    else
        Mc95 = dat(j,1);
    end
    
    j =  find(dat(:,2) < 10 , 1 );
    if isempty(j)
        j =  find(dat(:,2) < 15 , 1 ); 
    end
    if isempty(j)
        j =  find(dat(:,2) < 20 , 1 ); 
    end
    if isempty(j)
        j =  find(dat(:,2) < 25 , 1 );
    end
    j2 =  find(dat(:,2) == min(dat(:,2)) , 1 );
    %j = min([j j2]);
    
    Mc = dat(j,1);
    magco = Mc;
    if isempty(magco)
        magco = NaN;
        prf = 100 - min(dat(:,2));
    else
        magco = Mc;
        prf = 100 - dat(j2,2);
    end
    %disp(['Completeness Mc: ' num2str(Mc) ]);
end
