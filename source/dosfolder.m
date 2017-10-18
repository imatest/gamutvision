function fname = dosfolder(sname)  % Find folder path: sname may have . or .. in it.
% Only runs in the Matlab environment, tested by
% Compiler error message may be ignored (but make sure it's only inside  if ... end).
[aa,ff] = dos(['dir/w ' sname]);  % 2nd argument not available in compiled code.
flow = lower(ff);
kd  = strfind(flow,'directory of ');   % Find shorter string in longer.
klf = strfind(flow,char(10));
klast = klf(find(klf>kd))-1;
fname = ff(kd+13:klast);  % Folder full path name