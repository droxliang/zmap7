% check the code using codecheck() and report top issues
fn=dir('*.m');
fn={fn.name};
A=checkcode(fn);
a_is_empty = cellfun(@isempty,A);
A(a_is_empty)=[];
fn(a_is_empty)=[];
fn=string(fn)';
tb=table;
tb.filename = fn;
for n=1:numel(A)
    %theseMessages = string({A{n}.message});
    tb.messages(n) = {string({A{n}.message})};
end
zc = categorical([tb.messages{:}]);

cnt = containers.Map(categories(zc),zeros(size(categories(zc))));
for c = zc
    cnt(char(c))=cnt(char(c))+1;
end
k=cnt.keys();
v=cnt.values();
v=[v{:}];
for j = 1 : numel(v)
    sorted_cats(j,1:2)={string(k{j}), v(j)};
end
sorted_cats=sortrows(sorted_cats,2,'descend');
sortedcnt=[sorted_cats{:,2}];
sortedissues=[sorted_cats{:,1}];
for i=1:40
    fprintf('%d : %s\n  ', sortedcnt(i), sortedissues{i});
    for r = 1:height(tb)
        if any(string(sortedissues{i})==tb.messages{r})
            fprintf(' %s ',tb.filename(r));
        end
    end
    fprintf('\n')    
end
if ~exist('last_issue_count','var')
    last_issue_count=0;
end
fprintf('total issues: %d  [prev: %d]\n\n',sum(sortedcnt), last_issue_count)
last_issue_count = sum(sortedcnt);