function sv_load
% function sv_load
%   Opens a open dialog to load result data
%   and invokes the display dialog
%
% J. Woessner
% last update: 11.02.03

global bDebug;
if bDebug
  report_this_filefun(mfilename('fullpath'));
end

% Invoke the open dialog
[newfile, newpath] = uigetfile('*.mat','Load calculated data');
% Cancel pressed?
if newfile == 0
  return;
end
% Everything ok?
newfile = [newpath newfile];
if length(newfile) > 1
  % Load the data
  load(newfile, 'vResults');
  % Open dialog
  hResultFig = sv_result(vResults);
end
