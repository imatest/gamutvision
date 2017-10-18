function uiposition(varargin)
% Position the UI Window.  uipos_old (old code) works pretty well also.
% Shift the window from slightly above center by uishift = [x,y].

global mainhandle shiftall  % Will be empty [] if not present.

hObject   = varargin{1};
if nargin>=2     % Must be careful because we don't know the size of screen #2.
   ushift = varargin{2};
else
   ushift = [0 0];
end

usave = get(hObject,'Units');  set(hObject,'Units','pixels');  % Set units to pixels.
screen = get(0, 'ScreenSize');      % L B W H ; Screen position: MONITOR 1!  L=B=1.
figpos = get(hObject,'Position');   % L B W H ; Only works if Units are pixels.
% Note: actual size was 808x598 for an 800x550 figure. 44 on top; 4 on bottom.
if shiftall==1  % Shift UIs so they're always relative to the main window.
   mpos = get(mainhandle,'Position');      % L B W H ; Main window position.
   monitor2 = mpos(1)>screen(3) || mpos(2) >screen(4);      % Image is on 2nd monitor (unknown size).
   xmid = mpos(1)+.5*mpos(3) + screen(3)* ushift(1);        % Middle of window.
   ymid = mpos(2)+.5*mpos(4) + screen(4)*(ushift(2)+.025);  % Slightly above center.
   xpos = round(xmid-.5*figpos(3));  
   ypos = round(ymid-.5*figpos(4));  
   if ~monitor2  % On main monitor
      xpos = max([xpos,40+4]);  xpos = min([xpos,screen(3)-40-4-figpos(3) ]);
      ypos = max([ypos,32+4]);  ypos = min([ypos,screen(4)-32-44-figpos(4)]);
   end
else            % Fixed UI position
   xpos = round((     screen(3)-figpos(3))/2 + screen(3)*ushift(1));
   ypos = round((1.05*screen(4)-figpos(4))/2 + screen(4)*ushift(2));  % Slightly above center
end
set(hObject,'Position',[xpos ypos figpos(3:4)]);
if screen(4)<750  movegui(hObject,'center');  end  % Keep fig on 800x600 screen.  NLK code.
set(hObject,'Units',usave);  % Set units to pixels.


% ------------------- OLD CODE -------------------%

%                  (NEWER)

% screen = get(0, 'ScreenSize');      % L B W H ; Screen position.  L=B=1.
% usave = get(hObject,'Units');  set(hObject,'Units','pixels');  % Set units to pixels.
% figpos = get(hObject,'Position');   % L B W H ; Only works if Units are pixels.
% xpos = round(screen(3)-figpos(3))/2;  ypos = round(1.05*screen(4)-figpos(4))/2;  % Slightly above center
% set(hObject,'Position',[xpos ypos figpos(3:4)]);
% set(hObject,'Units',usave);  % Set units to pixels.

%                  (OLDER)

% % Determine the position of the dialog - centered on the callback figure
% % if available, else, centered on the screen
% FigPos=get(0,'DefaultFigurePosition');
% OldUnits = get(hObject, 'Units');
% set(hObject, 'Units', 'pixels');
% OldPos = get(hObject,'Position');
% FigWidth = OldPos(3);
% FigHeight = OldPos(4);
% if isempty(gcbf)  % Not called!
%     ScreenUnits=get(0,'Units');
%     set(0,'Units','pixels');
%     ScreenSize=get(0,'ScreenSize');
%     set(0,'Units',ScreenUnits);
% 
%     FigPos(1)=round(.75*(ScreenSize(3)-FigWidth));  % x (shifted right)
%     % FigPos(1)=1/2*(ScreenSize(3)-FigWidth);  % x (original)
%     FigPos(2)=2/3*(ScreenSize(4)-FigHeight);  % y
% else  % This one is called!
%     GCBFOldUnits = get(gcbf,'Units');
%     set(gcbf,'Units','pixels');
%     GCBFPos = get(gcbf,'Position');
%     set(gcbf,'Units',GCBFOldUnits);
%     FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
%                    (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
%     ScreenSize=get(0,'ScreenSize');
%     FigPos(1)=round(.75*(ScreenSize(3)-FigWidth));  % x (shifted right)
% end
% FigPos(3:4)=[FigWidth FigHeight];
% set(hObject, 'Position', FigPos);
% set(hObject, 'Units', OldUnits);
% ScreenSize=get(0,'ScreenSize');
% if (ScreenSize(4)<750) movegui(hObject,'center');  end  % Keep fig on 800x600 screen.  NLK code.
