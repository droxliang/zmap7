function [res, newMags]=synthb_aut(actualMags, B, startMag, magStep) 
    %This program generates a synthetic catalog of given total number of events, b-value, minimum magnitude,
    %and magnitude increment. matches number of events provided
    %
    % VALUE RETURNED IS some sort of residual from binned actual mags vs synth mags
    %  
    %   actualMags: total # events
    %   B : desired b-value
    %   startMag : starting magnitude (hypothetical Mc)
    %   //removed//l : index into existing catalog?   Should instead get mag increment.
    %   magStep = 0.1 ;%magnitude increment
    %
    % Yuzo Toya 2/1999
    % turned into function by Celso G Reyes 2017
    % rewritten by Celso G Reyes 2017
    
    %report_this_filefun();
    
    nEvents=numel(actualMags);
    mags= startMag : magStep : 10;
    
    N = 10 .^ (log10(nEvents) - B*(mags - startMag)); %expected events per mag step
    % N=round(N);
    N=round(N / sum(N) * nEvents); % get distribution at this number
    
    N(1) = N(1) + (nEvents - sum(N)); % we might be off by an event or two due to rounding
    mags(N<1)=[];
    N(N<1) = [];
    
    newMags=zeros(nEvents,1);
    next=1;
    for i=1:numel(N)
        howmany=N(i);
        whichmag=mags(i);
        last= next + howmany -1;
        newMags(next:last) = whichmag;
        next=last+1;
    end
        
    newMags=newMags(randperm(nEvents));
    %{
    new = nan(nEvents,1);
    
    ct1  = find(N == 0, 1 ) - 1;
    if isempty(ct1) 
        ct1 = length(N); 
    end
    
    ctM = mags(ct1);
    count=0;
    ct=0;
    for I=startMag:magStep:ctM
        ct=ct+1;
        if I ~= ctM
            for sc=1:(N(ct)-N(ct+1))
                count=count+1;
                new(count)=I;
            end
        else
            count=count+1;
            new(count)=I;
        end
    end
    
    PM=mags(1:ct);
    N = N(1:ct);
    %}
    halfStep = magStep /2;
    magBinEdges = [mags - halfStep , max(newMags)];
    bval = histcounts(actualMags,magBinEdges);
    % bval = hist(actualMags,mags); % guessing l comes from caller
    b3 = cumsum(bval,'reverse');
    res = sum(abs(b3 - N)) / sum(b3)*100;
    
end
