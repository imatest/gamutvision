function varargout = gamutvision(varargin)
% GAMUTVISION M-file for gamutvision.fig
%      GAMUTVISION, by itself, creates a new GAMUTVISION or raises the existing
%      singleton*.
%
%      H = GAMUTVISION returns the handle to a new GAMUTVISION or the handle to
%      the existing singleton*.
%
%      GAMUTVISION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMUTVISION.M with the given input arguments.
%
%      GAMUTVISION('Property','Value',...) creates a new GAMUTVISION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gamutvision_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gamutvision_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gamutvision

% Last Modified by GUIDE v2.5 12-May-2007 15:17:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gamutvision_OpeningFcn, ...
                   'gui_OutputFcn',  @gamutvision_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before gamutvision is made visible.
function gamutvision_OpeningFcn(hObject, eventdata, handles, varargin)
% To do: save settings. Test input profiles with CMYK. Fix tonal response.
% CMYK profiles cannot be used for inputs (1 or 3). CYM is not supported. bigplot() is plot routine.
% Would also be nice to detect Description, etc. of profile.

global versname versnum diagnostics  compvers
versname = 'Gamutvision';
%#function shutdown_gv
format compact;  % for testing/debugging


handles.diag = 0;
diagnostics = handles.diag;  % Use to add diagnostics to various modules.


% if     nargin==5  % Run from Imatest (not standalone);  nargin is 3 + no. of args.
%    handles.nrun    =  varargin{1};  handles.evalver =  varargin{2};
%    handles.standalone = 0;  handles.imfile = 'images';  % Logo & image files.
if nargin==3 | nargin==4         % Standalone (DOS or DLL) program.
   handles.nrun = 0;
   handles.standalone = 1;
   %                      TEST INTEGRITY OF STATUS.DLL AND REGISTER.DLL
   handles.imfile = 'images';  % Location of logo & image files.
   if nargin==4
      if isequal(varargin{1},'diag')
         handles.diag = 1;
         disp('Gamutvision diagnostic mode');
      end
   end
else 
   disp(['Wrong number of arguments: ' num2str(nargin-3)]);  pause(1);
   delete(handles.gamutvision_fig);  return;
end
handles.nsav = handles.nrun;

%                               VERSION:  selected by handles.version
handles.version = '1.4';
versnum = handles.version;  imavers = 0;  % For compatibility with about_imatest.m.
set(handles.gamutvision_fig, 'Name', ['Gamutvision ' handles.version], ...
   'CloseRequestFcn','shutdown_gv');  % For fig file


% datxtexp  = '15-Aug-2006';  datexp = datenum(datxtexp);
% if datexp-datenum(date)<0
%    disp(['Expiration: ' datxtexp '  Detected date: ' date]);
%    uiwait(errordlg('Gamutvision Beta has expired','Expired Gamutvision Beta'));
%    error('Gamutvision Beta has expired');  close all;
% end
   
% The following code needs to be evaluated since the remerge of R14_devel
% branch.
% if 1
%   compvers = '3';  % Compiler version. Global. Must alter manually ('3' or '4'+). 
%   handles.program = 'imatest';
% else
%   compvers = '4';  % Compiler version. Global. Must alter manually ('3' or '4'+). 
%   handles.program = 'dw-imatest';
% end
   
   
vvv = 0;
if exist('vvv')  % MATLAB environment 
   handles.rootdir = '..\installation\';   % May be different on Henry's computer.
   handles.compenv = 0;  % Not compiled.
   % disp(['MATLAB environment: handles.rootdir = ' rootdir])
else             % Standalone (compiled) application. Must start in same directory as the executable!
   handles.rootdir = [pwd filesep];  % dos('cd');
   handles.compenv = 1;  % Compiled (DOS).
   % disp(['Standalone application: handles.rootdir = ' rootdir])
   % Windows Vista: Must be sure we are running in Administrator mode.
   % dosret = dos('copy  "gamutstart.bat" "start2.bat"');
end

% From http://www.mathworks.com/support/solutions/data/1-H3S5V.html?solution=1-H3S5V
% opengl bug fix. THIS MIGHT HAVE FIXED LIGHTING CRASH!
feature('usegenericopengl',1)

% Things seem to work better if the buttons, which change, are set here.
handles.defbg   = get(0,'defaultUicontrolBackgroundColor');  % Default background color
handles = gray_buttons(handles);
set(handles.edit_printest,        'BackgroundColor',handles.defbg);
set(handles.pushbutton_printest,  'BackgroundColor',handles.defbg);
set(handles.frame_printest,       'BackgroundColor',handles.defbg);
set(handles.frame_printest2,      'BackgroundColor',handles.defbg);

%                   SETINGS LATER AFFECTED BY GAMUTVISION.INI
handles.transp = 0;  handles.transimg = 0;  % Wireframe transparency.
handles.vector = 0;  % Vector setting for 3D plots.
handles.vectab = 0;  % Vector setting for a*b* plots.

%                     MISC. SETTINGS
% 10/14/05 (new Toshiba Pentium) Trouble? Some blanks with opengl, and zbuffer fails entirely.
handles.labtmpr = ' *Lab ';  % Lab color temperature. Either ' *Lab ' or ' *LabD65 ' Use spaces!
handles.nprt =     0;     % Number of Printest run.
handles.lab3Daxis = [0 0 0 0];  % Saved axis for LAB 3D plots.
handles.lab2Daxis = [0 0 0 0];  % Saved axis for LAB 2D plots.
handles.save_cmyk = [0 0 0 0];
handles.fulltemp = {'','','',''};  % Contains profile names. For conversion.
handles.outarg2  = [];  handles.outarg4 = [];
handles.lastplot = 0;  handles.lastype = 0;  % Last plot type. Use for clearing graphics objects.
handles.lastHL   = 0;      % Last handles.HLview
handles.diflast  = 0;   handles.bwlast = 0;  % Last Difference & B&W types.
handles.lastm    = 0;      % Last input plot  (set later to mplt).
handles.lastn    = 0;      % Last output plot (set later to nplt).
handles.axpos    = get(handles.axes1,'Position');  % Save; will be resized for some plots.
handles.pltype   = 0;        % Plot type.  None yet.
handles.actival  = [0 0];   % Active profiles (1-4). Two or them.
handles.pltin    = 0;   handles.pltout = 0;      % Initialize: avoid crashes.
handles.pltOK    = 0;         % Returns 1 if plot finishes OK; 0 if it fails.
handles.azim     = -30;  handles.azim_save = -30;     % 3D azimuth. Use with view.  Was -37.5.
handles.elev     = 20;   handles.elev_save = 20;      % 3D elevation.  Was 30.
handles.HL_azim  = 160;  handles.HL_azim_save = 160;  % 3D azimuth. Use with view. For HL plots
handles.HL_elev  = 35;   handles.HL_elev_save = 35;   % 3D elevation.
handles.blackpt  = {' -b '; ' -b '};  % ' -b ' for black point comp.
handles.bpcomp = [1 1];  handles.bpc = 4;  % Black pt comp settings: bpc is the index of the popup menu.
handles.prtitle  = 'not selected';
handles.printest.on = 0;   % Printest is off.
handles.hzoom    = 0;
handles.viewtype = 0;   % 1 for L, 2 for R, 3 for WF1, 4 for WF2.
handles.xybdry   = 1;   % Plot boundary points in xy plot.
handles.hsldelta = 0;   % Display HSL coutour differences.
handles.xycolor  = 1;   % Pale colors in xy plot.
handles.difplt   = 1;   % Difference plot.
handles.hslight  = 0.5;  handles.graysc = 0;
handles.outype   = 2;   % Output mapped for bigplot.
handles.bk3d = 0.3;     % 3D Background
handles.lightpos = 'left';
handles.axis3d = 4;  handles.wire = 1;
handles.HLview = 1;     % HL plot view
handles.colormap = 1;   % Colormap for image.
handles.HLinvert = 0;   % Set to invert HL 3D plots.
handles.cmapinv  = 0;   % Invert color map.
set(handles.edit_printest, 'String', handles.prtitle);
set(handles.pushbutton_resv,   'Enable',  'off');
set(handles.pushbutton_resc,   'Enable',  'off');
set(handles.pushbutton_topv,   'Enable',  'off');
set(handles.slider_transp,     'Visible', 'off');
set(handles.slider_sat,        'Visible', 'off');
set(handles.text_sat,          'Visible', 'off');
set(handles.text_satvar,       'Visible', 'off');
set(handles.slider_vector,     'Enable',  'off');
set(handles.text_transp,       'Visible', 'off');
set(handles.text_vector,       'Visible', 'off');
set(handles.popupmenu_pltres,  'Enable',  'off');
set(handles.check_light,       'Visible', 'off');
set(handles.pushbutton_axis3d, 'Visible', 'off');
set(handles.toggle_autorotate, 'Visible', 'off');
set(handles.frame_1_2, 'BackgroundColor', [.5 .5 .5]);
set(handles.frame_3_4, 'BackgroundColor', [.5 .5 .5]);
guidata(hObject, handles);  % Update handles structure. Extra, just in case...
handles.save_full_1 = '*sRGB';  handles.save_full_3 = '*sRGB';  % Recovery from round-trip.
handles.save_pop_P1 = 1;  handles.save_pop_P3 = 1;  % Recovery from round-trip.
handles.cax = [1e6,-1e6];  % Miminum, maximum (pseudo)color map.
handles.hl3dax = [1e6,-1e6];  % Miminum, maximum (pseudo)color map.
handles.probeim = 0;  % Probe for image color difference
handles.hxtop = axes('position',[.01 .08 .03 .06], 'Visible','off');  % [L B W H]  Upper image Probe
handles.hxbot = axes('position',[.01 .02 .03 .06], 'Visible','off');  % [L B W H]  Lower image Probe
handles.satvar = 1;      % Variable saturation
handles.lightvar = 0.5;  % Variable lightness
handles.satupdate = 0;   % Flag for updating saturation
handles.plt3d = 0;
handles.OpenGL = 1;      % Turn on OpenGL.
handles.vol = 1;         % Display gamut volumes.
handles.zoomorig = [0 1 0 1];
handles.lastint = 0;
handles.imgstate = [0 0];  % For reading in image (handles.pltype==11 or 12).
handles.gamdisp = 1;     % Gamut display for image scatter plot.
handles.autorot = 0;     % Turned on during auto rotate
handles.lastrot = -1;    % Last rotation direction: toggles between -1 and 1.
handles.profile = [1 1 1 1];
handles.dfz = get(0,'DefaulttextFontSize');
% Comment out to test or keep Soft proofing gamut mappings.
% stemp = get(handles.popupmenu_gamutmap_L,'String');  % Truncate the gamut mapping strings: remove soft proof.
% set(handles.popupmenu_gamutmap_L,'String',stemp(1:7))
% stemp = get(handles.popupmenu_gamutmap_R,'String');  % Truncate the gamut mapping strings: remove soft proof.
% set(handles.popupmenu_gamutmap_R,'String',stemp(1:7));

handles = maketarg(hObject, handles);  % Create targets.


%                       READ GAMUTVISION.INI (OR CREATE IT).
% 4/28/2007: Look in %APPDATA% (environment variable only available through dos call).
appdata = getenv('APPDATA');
handles.file_ini = [appdata filesep 'Imatest' filesep 'gamutvision.ini'];
exini  = exist(handles.file_ini);  % New Vista file.
exini_old = exist('gamutvision.ini');  % Old XP file. Works with compiler. was fini>0;

if (exini_old & ~exini)  % Old gamutvision.ini exists, but not new one in %APPDATA%\Imatest.
   if ~isdir([appdata filesep 'Imatest'])  % New Vista folder. Should exist!
      fmake = dos(['mkdir "' [appdata filesep 'Imatest'] '"']);  % Create subdir if it doesn't exist.
   end
   copystr = ['copy "gamutvision.ini" "' handles.file_ini '"'];
   % fcop = dos('copy "gamutvision.ini" "%APPDATA%\Imatest\gamutvision.ini"');  % Old
   fcop = dos(copystr);
   if fcop  disp('Copy error: new gamutvision.ini not created');
   else     disp(copystr);  exini = 1;   end
end

if ~exini      % gamutvision.ini does not exist; create it.
   handles.save_dir_name = [pwd filesep 'Results' filesep];
   handles.iccfolder = 'C:\Windows\System32\Spool\Drivers\Color\';
   handles.monprof   = '*sRGB';
   handles.mon_intent = 1;
   writeKeys = {'gamut','','save_dir'    , handles.save_dir_name; ...
                'gamut','','iccfolder'   , handles.iccfolder; ...
                'gamut','','monprof'     , handles.monprof; ...
                'gamut','','mon_intent'  , handles.mon_intent };
   inifile(handles.file_ini,'write',writeKeys,'plain');
end

% Read gamutvision.ini (which may have been just created).  % if exini
readKeys = { ...
   'gamut','','save_dir',   '',  [pwd filesep 'Results' filesep]; ...
   'gamut','','iccfolder',   '', 'C:\Windows\System32\Spool\Drivers\Color\'; ...
   'gamut','','pltres',      'i', 3; ...
   'gamut','','light',       'i', 0; ...
   'gamut','','transparency','',  '0'; ...  % Floating point: can't use 'i'
   'gamut','','pltype',      'i', 1; ...
   'gamut','','actival'      'i', [0,0]; ...
   'gamut','','fullname_1'   '',  ''; ...
   'gamut','','fullname_2'   '',  ''; ...
   'gamut','','fullname_3'   '',  ''; ...
   'gamut','','fullname_4'   '',  ''; ...
   'gamut','','profile_1'   'i',  1; ...
   'gamut','','profile_2'   'i',  1; ...
   'gamut','','profile_3'   'i',  1; ...
   'gamut','','profile_4'   'i',  1; ...
   'gamut','','gamutmap_L'  'i',  1; ...
   'gamut','','gamutmap_R'  'i',  1; ...
   'gamut','','INW1'        'i',  1; ...
   'gamut','','OUTW1'       'i',  3; ...
   'gamut','','INW2'        'i',  2; ...
   'gamut','','OUTW2'       'i',  4; ...
   'gamut','','dfz'         'i',  handles.dfz; ...
   'gamut','','monprof',     '',  '*sRGB'; ...
   'gamut','','mon_intent', 'i',  2; ...
   'gamut','','vector',      '',  '0'; ...    % Floating point: can't use 'i'
   'gamut','','xybdry',      'i', 1;  ... 
   'gamut','','xycolor',     'i', 1;  ... 
   'gamut','','hslplot',     'i', 3;  ...     % HSL plot type
   'gamut','','hslight',     '',  '0.5'; ...  % Floating point: can't use 'i'
   'gamut','','hsldelta',    'i', 0;  ... 
   'gamut','','bwplot',      'i', 1;  ...     % BW plot type
   'gamut','','axis3d',      'i', 4;  ...     % 3D plot axis setting
   'gamut','','vectab',      '',  '0'; ...    % Floating point: can't use 'i'
   'gamut','','bk3d',        '',  '0.3'; ...    % Floating point: can't use 'i'
   'gamut','','lab2dv',      'i', 1;  ...     % 2D Lab plot view (light, dark)
   'gamut','','lightpos',    '',  'left'; ...
   'gamut','','lab2dg',      'i', 1;  ...     % 2D Lab plot view (markers)
   'gamut','','wire',        'i', 1;  ...     % wire frame color
   'gamut','','difplt',      'i', 1;  ...     % difference plot
   'gamut','','HLview',      'i', 1;  ...     % HL view
   'gamut','','colormap',    'i', 1;  ...     % Color map
   'gamut','','graysc',      '',  '0.4'; ...  % Floating point: can't use 'i'
   'gamut','','blackpt',     'i', 4;  ...     % Black point compensation (4 for both on; 1 L, 2 R)
   'gamut','','openGL',      'i', 1;  ...     % Turns on OpenGL
   'gamut','','cmyk'         'i', [0,0,0,0]; ...  % Indicates cmyk profile.
   'gamut','','gamdisp'      'i', 1; ...      % Gamut display for image scatter plot.
   'gamut','','transface',   '',  '0.8'; ...  % Transparency face color: Floating point: can't use 'i'
   'gamut','','transimg',    '',  '0'; ...    % Transparency for image: Floating point: can't use 'i'
   'gamut','','vol',         'i', 1;  ...     % Turns on gamut volume calculation
   'gamut','','edfile'       '',  'Enter image editor pathname here.'; ...
   'gamut','','resultsave'   'i', 1; ...      % Save screen... in subfolder Results.
   };
readSett = inifile(handles.file_ini,'read',readKeys);   % READ GAMUTVISION.INI
handles.save_dir_name =   readSett{1};   % directory for saving plots.
handles.iccfolder    =  readSett{2};  % ICC profile folder.
set(handles.popupmenu_pltres, 'Value', readSett{3});  % Plot resolution window
handles.pltres       = readSett{3};  % Plot resolution
set(handles.check_light,      'Value', readSett{4});
handles.radio_ltsave = readSett{4};
handles.transp      = str2num(readSett{5});  % Transparency. Floating point numbers are strings!
handles.pltype      = readSett{6};  % Plot type
if handles.pltype==11 | handles.pltype==12  handles.pltype = 1;  end  % Do not reuse image plot.
set(handles.popupmenu_pltype,   'Value', handles.pltype);  % Plot type.
handles.actival     = readSett{7};  % Active plot values.
handles.fullname{1} = readSett{8};   % Profile name; default is blank
handles.fullname{2} = readSett{9};
handles.fullname{3} = readSett{10};
handles.fullname{4} = readSett{11};
handles.profile(1)  = readSett{12};  % Numeric: 1 for Browse..., etc.
handles.profile(2)  = readSett{13};
handles.profile(3)  = readSett{14};
handles.profile(4)  = readSett{15};
handles.gamutmap_L  = readSett{16};
if handles.gamutmap_L==5 | handles.gamutmap_L==6  
   handles.gamutmap_L = handles.gamutmap_L-1;
end
handles.intent_L = handles.gamutmap_L-1;
handles.gamutmap_R  = readSett{17};
if handles.gamutmap_R==5 | handles.gamutmap_R==6  
   handles.gamutmap_R = handles.gamutmap_R-1;
end
handles.intent_R = handles.gamutmap_R-1;
handles.INW1        = readSett{18};
handles.OUTW1       = readSett{19};
handles.INW2        = readSett{20};
handles.OUTW2       = readSett{21};
handles.dfz         = readSett{22};  % Font size.
handles.monprof     = readSett{23};  % Monitor profile.
handles.mon_intent  = readSett{24};  % Monitor rendering intent.
handles.vector      = str2num(readSett{25});  % Floating point numbers are strings!
handles.xybdry      = readSett{26};  % Monitor profile.
handles.xycolor     = readSett{27};  % Display spectrum wavelentghs.
handles.hslplot     = readSett{28};  % HSL plot type
handles.hslight     = str2num(readSett{29});  % HSL image lightness.
handles.hsldelta    = readSett{30};  % HSL difference contour.
handles.bwplot      = readSett{31};  % BW plot type
handles.axis3d      = readSett{32};  % 3D plot axis setting
handles.vectab      = str2num(readSett{33});  % Floating point numbers are strings!
handles.bk3d        = str2num(readSett{34});  % Floating point : 3D background
handles.lab2dv      = readSett{35};  % 2D sat map Lightness and markers.
handles.lightpos    = readSett{36};  % Light position
handles.lab2dg      = readSett{37};  % 2D gamut map markers.
handles.wire        = readSett{38};  % 3D plot axis setting
handles.difplt      = readSett{39};  % Display spectrum wavelentghs.
handles.HLview      = readSett{40};  % HL view setting
handles.colormap    = readSett{41};  % 
handles.graysc      = str2num(readSett{42});  % Floating point : 3D background
handles.bpc         = readSett{43};  % Black point compensation
handles.OpenGL      = readSett{44};  % 
handles.cmyk        = readSett{45};  handles.cmyksave = handles.cmyk;  % CMYK profile
handles.gamdisp     = readSett{46};  % Gamut display for image scatter plot
handles.transface   = str2num(readSett{47});  % Transparency face color
handles.transimg    = str2num(readSett{48});  % Transparency of image
handles.vol         = readSett{49};  % Gamut volume calculation
handles.edfile      = readSett{50}; 
handles.resultsave  = readSett{51};  % Save screen... in subfolder Results.

set(handles.popupmenu_bpc,'Value',handles.bpc);
handles.bpcomp = [~mod(handles.bpc,2) handles.bpc>2];  % Off, Left, Right, Both
if handles.bpcomp(1)  handles.blackpt{1} = ' -b ';  else  handles.blackpt{1} = ' ';  end  % Left
if handles.bpcomp(2)  handles.blackpt{2} = ' -b ';  else  handles.blackpt{2} = ' ';  end  % Right


set(handles.popupmenu_gamutmap_L, 'Value', handles.gamutmap_L);
set(handles.popupmenu_gamutmap_R, 'Value', handles.gamutmap_R);
set(handles.popupmenu_INW1,       'Value', handles.INW1);
set(handles.popupmenu_OUTW1,      'Value', handles.OUTW1);
set(handles.popupmenu_INW2,       'Value', handles.INW2);
set(handles.popupmenu_OUTW2,      'Value', handles.OUTW2);
set(handles.slider_transp, 'Value'  ,1-handles.transp);  % Opacity = 1-transparency.
set(handles.text_transp  , 'String' ,['Transparency ' num2str(1-handles.transp,2)]);
set(handles.slider_sat,    'Value'  ,handles.satvar);    % Saturation: for color differences.
set(handles.text_satvar,   'String', num2str(handles.satvar,2));
set(handles.slider_vector, 'Value'  ,handles.vector);  % Vector (HSL L setting).
set(handles.text_vector  , 'String' ,['Vectors ' num2str(round(100*handles.vector)/100,2)]);

if handles.diag
   disp('Call initialize_mappings');
   button = questdlg({'If profile names are corrupted, Gamutvision may crash.'; ...
         'Reset them before continuing?'; ...
         '( If ''Yes'' you''ll be asked if you want to reset defaults permanently. )'}, ...
      'Gamutvision diagnostic options','Yes','No','No');
   if strcmpi(button,'Yes')
		handles.fullname{1} = '';	handles.fullname{2} = '';   % Profile name; default is blank
		handles.fullname{3} = '';	handles.fullname{4} = '';
      handles.monprof     = '*sRGB';
		handles.profile = [1 1 1 1];
      Reset_defaults_Callback(hObject, eventdata, handles);
   end
end
handles = initialize_mappings(hObject, eventdata, handles);  % Initialize the gamut mappings.

setfonts(handles)

guidata(hObject, handles);  % Update handles structure. Extra, just in case...

%                           LOGO
handles.rootimg = handles.imfile;  % For compatibility with about_imatest.m
imdotcom = [handles.rootdir handles.imfile filesep 'Gamutvision_logo_80W.png'];  % 80x48 pixels
% disp(imdotcom);
imlogo =  imread(imdotcom,'png');  imlogf =  imfinfo(imdotcom);
axes(handles.axes_logo);  set(handles.axes_logo,'Units','pixels');  % On rescharts.fig
logoloc = get(handles.axes_logo, 'Position');
image(imlogo);  axis image;
set(handles.axes_logo, 'Visible','off', 'Position', [logoloc(1:2) imlogf.Width imlogf.Height]);
set(handles.axes_logo, 'Units','normalized');  % Change after pixel size setting.

locarrow = [handles.rootdir handles.imfile filesep 'downarrow.png'];
imarrow = imread(locarrow,'png');
axes(handles.axes_arrow1);
image(imarrow);  axis off;  axis image;  set(gca,'Units','normalized');
axes(handles.axes_arrow2);
image(imarrow);  axis off;  axis image;  set(gca,'Units','normalized');
  
axes(handles.axes1);
welcomsg = {'Welcome to GamutVision 1.4 (identical to 1.3.7, but with registration removed).'; ''; ...
   'Learn color management. Explore color spaces, gamut mappings,'; ...
   'rendering intents, and device performance.';  '';
   'To get started, select at least one input profile (box 1 or 2), '; ...
   'one corresponding output profile (box 3 or 4),'; ...
   'and the corresponding rendering intent '; ...
   'You can browse for profiles'; ...
   'or use profiles built into LittleCMS (starting with *). '; ''; ...
   'Then click ''View.'''; ''; ...
   'The Help button (lower right) opens a browser window with '; ...
   'GamutVision instructions (www.gamutvision.com/docs/gamutvision.html).'; ''; ...
   'CIEDE2000 color difference formulas (Delta-E 00, ...) have been added (v. 1.3.7).'; ''; ...
   'To learn more about LittleCMS, go to www.littlecms.com.'};
gnumsg = {'Gamutvision is free software: you can redistribute it and/or modify it under the terms'; ...
    'of the GNU General Public License as published by the Free Software Foundation,'; ...
    'either version 3 of the License, or (at your option) any later version.'; ...
    'Gamutvision is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;'; ...
    'without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.'; ...
    'See the GNU General Public License for more details. You should have received a copy '; ...
    'along with Gamutvision.  If not, see <http://www.gnu.org/licenses/>.'};

text(.02,.62,welcomsg,'FontSize',handles.dfz-1);
text(.02,.15,gnumsg, 'FontSize',handles.dfz-2);

%                                          ROOT DIRECTORY
%   [handles.rootdir p2 p3 p4] = fileparts(mfilename('fullpath'));  % M-file name parts

vvv = 0;  % replaced later by iscompiled
if exist('vvv')  % MATLAB environment     BEWARE R14 !
   %if ~iscompiled  % MATLAB environment 
    handles.rootdir =  [dosfolder('..') filesep 'installation' filesep]; 
    handles.compenv = 0;  % Not compiled.
else             % Standalone (COMPILED) application. Must start in same directory as the executable!
    handles.rootdir = [pwd filesep];  % dos('cd');
    handles.compenv = 1;  % Compiled (DOS).
end
handles.rootimg = [handles.rootdir handles.imfile filesep];  % Root folder for images. 'images' in Imatest.


%                            POSITION THE WINDOW.
screen = get(0, 'ScreenSize');      % L B W H ; Screen position.  L=B=1.
usave = get(hObject,'Units');  set(hObject,'Units','pixels');  % Set units to pixels.
figpos = get(hObject,'Position');   % L B W H ; Only works if Units are pixels.
xpos = round(screen(3)-figpos(3))/2;  ypos = round(screen(4)-figpos(4))/2;
set(hObject,'Position',[xpos ypos figpos(3:4)]);
set(hObject,'Units',usave);  % Set units to pixels.
handles.figstart = get(gcf,'Position');  % Initial position: Use to restore Window.

set(gcf, 'Units', 'pixels');  % For getting correct tic marks. (Why does this work???)

% Choose default command line output for gamutvision
handles.output = hObject;

guidata(hObject, handles);  % Update handles structure

% UIWAIT makes gamutvision wait for user response (see UIRESUME)
uiwait(handles.gamutvision_fig);



% --- Outputs from this function are returned to the command line.
function varargout = gamutvision_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
% if ~handles.standalone
varargout{1} = handles.nrun;  %  handles.output;  % ????
% end
delete(handles.gamutvision_fig);  % ???????????  
close all;


% --- Executes on button press in pushbutton_exit.
function pushbutton_exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exit (see GCBO)
uiresume(handles.gamutvision_fig);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)


% --------------------------------------------------------------------
function SettingsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)


% function PrintPreview_Callback(hObject, eventdata, handles)
% % hObject    handle to PrintPreview (see GCBO)
% % printpreview;  % (gcf);  % (handles.gamutvision_fig);  % Compiler failure!
% hwarn = msgbox('Print Preview does not compile', 'Gamutvision warning','warn');
% pause(1);  close(hwarn);
% 
% function PrintMenuItem_Callback(hObject, eventdata, handles)
% % hObject    handle to PrintMenuItem (see GCBO)
% % printdlg;  % (gcf);  % (handles.gamutvision_fig);  % Compiler failure?
% hwarn = msgbox({'Print does not compile. To print the page,'; 'Click File, Save screen.'; ...
%    'Open and print the file in an image editor.'}, 'Gamutvision warning','warn');
% pause(2);  close(hwarn);
% 
% function PageSetup_Callback(hObject, eventdata, handles)
% % hObject    handle to PageSetup (see GCBO)
% % dlg = pagesetupdlg;  % (gcf);  % (handles.gamutvision_fig);  % Compiler failure?
% hwarn = msgbox('Page Setup does not compile', 'Gamutvision warning','warn');
% pause(1);  close(hwarn);


% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
uiresume(handles.gamutvision_fig);  % Try this here!
% delete(handles.gamutvision_fig)


% --------------------------------------------------------------------
function Small_fonts_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
handles.dfz = 8;
setfonts(handles)
guidata(hObject, handles);  % Update handles structure


% --------------------------------------------------------------------
function Normal_fonts_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
handles.dfz = 10;
setfonts(handles)
guidata(hObject, handles);  % Update handles structure


% --------------------------------------------------------------------
function Large_fonts_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
handles.dfz = 12;
setfonts(handles)
guidata(hObject, handles);  % Update handles structure


% --------------------------------------------------------------------
function setfonts(handles)      % Called near start of run.
%                            SET FONT SIZES.
% handles  % Use to list values and diagnose number of dimensions in call. Comment out normally.
set(0, 'DefaulttextFontSize', handles.dfz);  % checkbox is not checked-take approriate action
set(0, 'DefaultAxesFontSize', handles.dfz);  % Attempt to solve Scott's problem.
writeKeys = {'gamut','','fontsize',handles.dfz};
inifile(handles.file_ini,'write',writeKeys,'plain');
dfz = handles.dfz;  % Default font size.
set(handles.axes1,               'FontSize', dfz-1);
set(handles.text2,               'FontSize', dfz-2);
set(handles.popupmenu_P1,        'FontSize', dfz-2);
set(handles.popupmenu_P2,        'FontSize', dfz-2);
set(handles.popupmenu_P3,        'FontSize', dfz-2);
set(handles.popupmenu_P4,        'FontSize', dfz-2);
set(handles.text_WF1,            'FontSize', dfz-1);
set(handles.text_WF2,            'FontSize', dfz-1);
set(handles.pushbutton_View_WF1, 'FontSize', dfz-1);
set(handles.pushbutton_View_WF2, 'FontSize', dfz-1);
set(handles.popupmenu_INW1,      'FontSize', dfz-1);
set(handles.popupmenu_OUTW1,     'FontSize', dfz-1);
set(handles.text_OUTW1,          'FontSize', dfz-1);
set(handles.popupmenu_INW2,      'FontSize', dfz-1);
set(handles.popupmenu_OUTW2,     'FontSize', dfz-1);
set(handles.text_OUTW2,          'FontSize', dfz-1);
set(handles.popupmenu_gamutmap_L,'FontSize', dfz-1);
set(handles.popupmenu_gamutmap_R,'FontSize', dfz-1);
set(handles.pushbutton_view_L,   'FontSize', dfz-1);
set(handles.pushbutton_view_R,   'FontSize', dfz-1);
set(handles.inp_raw,             'FontSize', dfz-2);
set(handles.inp_mapped,          'FontSize', dfz-2);
set(handles.out_raw,             'FontSize', dfz-2);
set(handles.out_mapped,          'FontSize', dfz-2);
set(handles.pushbutton_resc,     'FontSize', dfz-2);
set(handles.pushbutton_resv,     'FontSize', dfz-2);
set(handles.pushbutton_topv,     'FontSize', dfz-2);
set(handles.pushbutton_axis3d,   'FontSize', dfz-2);
set(handles.text_black,          'FontSize', dfz-2);
set(handles.popupmenu_bpc,       'FontSize', dfz-2);
set(handles.pushbutton_help,     'FontSize', dfz-1);
set(handles.pushbutton_exit,     'FontSize', dfz-1);
set(handles.text_transp,         'FontSize', dfz-2);
set(handles.text_sat,            'FontSize', dfz-2);
set(handles.text_satvar,         'FontSize', dfz-2);
set(handles.text_vector,         'FontSize', dfz-2);
set(handles.popupmenu_pltype,    'FontSize', dfz-1);
set(handles.popupmenu_pltres,    'FontSize', dfz-1);
set(handles.popupmenu_HL,        'FontSize', dfz-2);
set(handles.check_zoom,          'FontSize', dfz-1);
set(handles.push_zout,           'FontSize', dfz-2);
set(handles.check_light,         'FontSize', dfz-1);
set(handles.pushbutton_printest, 'FontSize', dfz-2);  % was dfz-1
set(handles.edit_printest,       'FontSize', dfz-2);
set(handles.checkbox_HLinvert,   'FontSize', dfz-2);
set(handles.text_vol,            'FontSize', dfz-1);
set(handles.toggle_autorotate,   'FontSize', dfz-2);


% ----------------------  USER-DEFINED FUNCTIONS (not GUI buttons)  ---------------------


function handles = initialize_mappings(hObject, eventdata, handles);  % INITIALIZE THE GAMUT MAPPINGS.

handles.initialize = 1;  % Initial settings/gamut mappings. Run AFTER setting popupmenu values.
if ~handles.satupdate
   handles = Monitor_profile_Callback(hObject, eventdata, handles);  % Must go first
end
if ~isempty(handles.fullname{1}) & (exist(handles.fullname{1}) | isequal(handles.fullname{1}(1),'*'))
   handles = popupmenu_P1_Callback(handles.popupmenu_P1, eventdata, handles);
end
if ~isempty(handles.fullname{2}) & (exist(handles.fullname{2}) | isequal(handles.fullname{2}(1),'*'))
   handles = popupmenu_P2_Callback(handles.popupmenu_P2, eventdata, handles);
end
if ~isempty(handles.fullname{3}) & (exist(handles.fullname{3}) | isequal(handles.fullname{3}(1),'*'))
   handles = popupmenu_P3_Callback(handles.popupmenu_P3, eventdata, handles);  % Must call after P2!
end
if ~isempty(handles.fullname{4}) & (exist(handles.fullname{4}) | isequal(handles.fullname{4}(1),'*'))
   handles = popupmenu_P4_Callback(handles.popupmenu_P4, eventdata, handles);
end
handles.initialize = 0;  % Standard (non-initialization) mode.
guidata(hObject, handles);  % Update handles structure
% disp(['CMYK = ' num2str(handles.cmyk)]);  % Diagnostic for CMYK problems.
return;


function handles = maketarg(hObject, handles);  % CREATE THE TARGET.

handles.ftarg = zeros(256,832,3);  % Target. rows, cols. 2 color + 1 BW charts.

handles.ftarg(:,1:256,1) = ones(1,256)'*linspace(0,1,256);  % (0:1/255:1);  % H
handles.ftarg(:,1:256,2) = 1;  % ones(256,256);                   % Max S
handles.ftarg(:,1:256,3) = linspace(1,0,256)'*ones(1,256);  % L; high to low.

% L = .5, varying H and S.
handles.ftarg(:,257:512,1) = ones(1,256)'*linspace(0,1,256);  % H
handles.ftarg(:,257:512,2) = linspace(1,0,256)'*ones(1,256); % S % S; high to low.
handles.ftarg(:,257:512,3) = .5; % *ones(256,256);          % L = 0.5

handles.ftarg(:,577:1088,:) = handles.ftarg(:,1:512,:);  % For varying saturation
handles.ftarg(:,577:832,2)  = handles.satvar;    % HSL Saturation (variable).
handles.ftarg(:,833:1088,3) = handles.lightvar;  % HSL Lightness

% B&W
handles.ftarg(:,513:576,1) = 0;  % H
handles.ftarg(:,513:576,2) = 0; % S
handles.ftarg(:,513:576,3) = linspace(1,0,256)'*ones(1,64); % L; high to low.

handles.ftarg = hsl2rgb(handles.ftarg);  % Convert from HSL to RGB.

% figure; image(handles.ftarg);  axis image; % View the test image.

handles.sz_L5 =   size(handles.ftarg(:,257:512,:));  % Size of L5_crop area.
handles.sz_s1 =   size(handles.ftarg(:,  1:256,:));  % Size of S1_crop region.

guidata(hObject, handles);  % Update handles structure
return;


function handles = geticc(hObject, handles, nicc);     % GET ICC PROFILE NAME
% Get name of ICC profile.  
% handles.fullname{} is read from gamutvision.ini. Original file name; may have blanks.
% handles.fulltemp{} is used for actual transformation. Blanks removed.
% handles.fullsave{} is used for recovering last named ICC file from objstring(7).
objstring = get(hObject,'String');  % Profile selection string. First 6 items never change.
if handles.initialize  % Initialize: Do not call uigetfile.
   [pathname,name,ext,versn] = fileparts(handles.fullname{nicc});  % Read in.
   handles.iccname{nicc} = [name ext];    % In handles so it can be used as a title.
	objstring{7} = [name ext];
	set(hObject, 'String', objstring);     % Store loaded name in this value.
   if handles.profile(nicc)==1
	   set(hObject, 'Value', 7);  % Set value to display.
   else
	   set(hObject, 'Value', handles.profile(nicc));  % Set value to display.
   end
	if nicc==3 & handles.profile(nicc)==8  % Image and profile from 2 into 3.
      handles.fulltemp{3} = handles.fulltemp{2};
      handles.iccname{3}  = handles.iccname{2};
      handles.fullname{3} = handles.fullname{2};
   end
   handles.fullsave{nicc} = handles.fullname{nicc};
elseif handles.profile(nicc)==1              % Read ICC profile from file.
   browsetext = ['Select ICC profile (' num2str(nicc) ').'];
	foldersave = pwd;  fn1 = [];  % This code for uigetfiles (Rex Tenorio version; not uigetfile).
	if isdir(handles.iccfolder)  cd(handles.iccfolder);  end  % uigetfiles only works with current directory.
	[fn1, pathname] = uigetfiles('*.*',browsetext);
	cd(foldersave);  % Always go back!
	if (isempty(fn1)) fn1 = 0;       % No input file returned. Compatible with uigetfile.
	else              fn1 = fn1{1};  % Convert from cell (for uigetfiles only)
	end
   % path_ui = [handles.iccfolder '*.*'];
   % [fn1, pathname] = uigetfile(path_ui, browsetext);
   if (isequal(fn1,0) | isequal(pathname,0))   % Cancel read. Keep profile unchanged.
      handles.fulltemp{nicc} = handles.fullsave{nicc};
      handles.fullname{nicc} = handles.fullsave{nicc};
      handles.cmyk(nicc)     = handles.cmyksave(nicc);
   else  % File name returned.
      handles.iccname{nicc}  = fn1;  % pathname has trailing filesep. Last use of fn1.
      handles.fullname{nicc} = [pathname handles.iccname{nicc}];  % Last use of pathname.
      handles.fulltemp{nicc} = handles.fullname{nicc};     % Full path name of input profile.
      % Store handles.fullname{nicc} in recent profiles.
      fname = recentfiles(handles.file_ini,'recent','add',handles.fullname{nicc},'','');  % dummy results. 
      [iccdesc, iccout] =geticcontents(handles.rootdir,handles.fulltemp{nicc});  % Run external pgm
      if    ((nicc==1 | nicc==3) & strcmpi(iccout.dataCS,'CmykData'  ))  %  | ...
            %  ((nicc==2 | nicc==4) & strcmpi(iccout.type,  'InputClass'))  % ??? type never set???
         handles.fulltemp{nicc} = handles.fullsave{nicc};  % Restore previous value.
         [pathname,name,ext,versn] = fileparts(handles.fulltemp{nicc});
         handles.iccname{nicc} = [name ext];
         handles.fullname = handles.fulltemp;
		   set(hObject, 'Value' , 7);  % Set value to display.
         if (nicc==1 | nicc==3)
            hwarn = msgbox('CMYK profile not allowed for 1 or 3', 'Bad profile choice','warn');
         else
            hwarn = msgbox('Source profile not allowed for 2 or 4', 'Bad profile choice','warn');
         end
         pause(1);  close(hwarn);  return;
      end
      handles.iccdesc{nicc} = iccdesc;  % Pure cell array
      handles.iccout{nicc}  = iccout;   % Structure
      % d1 = handles.rootdir,  d2 = handles.fulltemp{nicc}
      % handles.iccout{nicc}.dataCS,  handles.iccout{nicc}.type  % How to reference...
      istmp = isfield(iccout,'dataCS');  % was handles.iccout{nicc}; didn't work for some reason.
      if istmp
         handles.cmyk(nicc) = strcmpi(handles.iccout{nicc}.dataCS,'CmykData');  % 1 for CMYK; 0 otherwise.
      else
         handles.cmyk(nicc) = 0;  % Not CMYK.
      end
		objstring{7} = handles.iccname{nicc};  % Save only for file name returned.
		set(hObject, 'String', objstring);     % Store loaded name in this value.
      writeKeys = {'gamut','',['fullname_' num2str(nicc)], handles.fullname{nicc}; ...
                   'gamut','','cmyk', handles.cmyk; ... 
                  };
      inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
   end 
	set(hObject, 'Value' , 7);  % Set value to display.
elseif handles.profile(nicc)==7  % Restore previous name.
   handles.fulltemp{nicc} = handles.fullsave{nicc};  % Saved file back into current file.
   [pathname,name,ext,versn] = fileparts(handles.fulltemp{nicc});
   handles.iccname{nicc} = [name ext];
   handles.fullname      = handles.fulltemp; 
   handles.cmyk(nicc)    = handles.cmyksave(nicc);
elseif nicc==3 & handles.profile(nicc)==8  % Image and profile from 2 into 3.
   handles.fulltemp{3} = handles.fulltemp{2};
   handles.iccname{3}  = handles.iccname{2};
   handles.fullname{3} = handles.fullname{2};
   hansles.cmyk(3)     = handles.cmyk(2);
elseif (nicc~=3 & handles.profile(nicc)==8) | (nicc==3 & handles.profile(nicc)==9)  % Read from list.
   % Get file name from list of recent files.  12/26/06
   path_ui = [handles.iccfolder '*.*'];
   browsetext = ['Select ICC profile (' num2str(nicc) ').'];
   fname = recentfiles(handles.file_ini,'recent','get',['ICC Profile ' num2str(nicc)], ...
      path_ui, browsetext);  % Recent file name 
   if isempty(fname)  % Cancel read
      handles.fulltemp{nicc} = handles.fullsave{nicc};  % Saved file back into current file.
      [pathname,name,ext,versn] = fileparts(handles.fulltemp{nicc});
      handles.iccname{nicc}  = [name ext];
      handles.fullname       = handles.fulltemp;
      handles.cmyk(nicc)     = handles.cmyksave(nicc);
   else       % File name returned (not cancelled)
      [pathname,name,ext,versn] = fileparts(fname);
      handles.iccname{nicc}  = [name ext];  % pathname has trailing filesep.
      handles.fullname{nicc} = fname;
      handles.fulltemp{nicc} = handles.fullname{nicc}; 
      % Store handles.fullname{nicc} in recent profiles.
      [iccdesc, iccout] =geticcontents(handles.rootdir,handles.fulltemp{nicc});
      if    ((nicc==1 | nicc==3) & strcmpi(iccout.dataCS,'CmykData'  ))  %  | ...
            %  ((nicc==2 | nicc==4) & strcmpi(iccout.type,  'InputClass'))  % ??? type never set???
         handles.fulltemp{nicc} = handles.fullsave{nicc};  % Restore previous value.
         [pathname,name,ext,versn] = fileparts(handles.fulltemp{nicc});
         handles.iccname{nicc} = [name ext];
         handles.fullname = handles.fulltemp;
		   set(hObject, 'Value' , 7);  % Set value to display.
         if (nicc==1 | nicc==3)
            hwarn = msgbox('CMYK profile not allowed for 1 or 3', 'Bad profile choice','warn');
         else
            hwarn = msgbox('Source profile not allowed for 2 or 4', 'Bad profile choice','warn');
         end
         pause(1);  close(hwarn);  return;
      end
      handles.iccdesc{nicc} = iccdesc;  % Pure cell array
      handles.iccout{nicc}  = iccout;   % Structure
      % d1 = handles.rootdir,  d2 = handles.fulltemp{nicc}
      % handles.iccout{nicc}.dataCS,  handles.iccout{nicc}.type  % How to reference...
      istmp = isfield(iccout,'dataCS');  % was handles.iccout{nicc}; didn't work for some reason.
      if istmp
         handles.cmyk(nicc) = strcmpi(handles.iccout{nicc}.dataCS,'CmykData');  % 1 for CMYK; 0 otherwise.
      else
         handles.cmyk(nicc) = 0;  % Assume it's not CMYK.
      end
		objstring{7} = handles.iccname{nicc};  % Save only for file name returned.
		set(hObject, 'String', objstring);     % Store loaded name in this value.
      writeKeys = {'gamut','',['fullname_' num2str(nicc)], handles.fullname{nicc}; ...
                   'gamut','','cmyk', handles.cmyk; ... 
                  };
      inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
   end
   set(hObject, 'Value' , 7);  % Set value to display.
else             % Predefined values in icctrans: *sRGB, etc. 2 <= handles.profile(nicc) <= 6.
   handles.fulltemp{nicc} = strtok(objstring{handles.profile(nicc)},' ');  pathname = '';
   handles.fullname{nicc} = handles.fulltemp{nicc};
   handles.iccname{nicc}  = handles.fulltemp{nicc};  % For title
   handles.cmyk(nicc) = 0;
   writeKeys = {'gamut','',['fullname_' num2str(nicc)], handles.fullname{nicc}; ...
                'gamut','','cmyk', handles.cmyk  };  % 1 <= nicc <= 4
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
end


% These scripts should run during if handles.initialize is set.
if findstr(handles.fullname{nicc}, ' ')              % Blanks in file name.
   icctemp = strrep(handles.iccname{nicc},' ','_');  % Replace blanks with underscores.
   handles.fulltemp{nicc} = [tempdir icctemp];       % Matlab system temp path name (save)
   disp([handles.iccname{nicc} '  -->  ' icctemp]);
   dos(['copy  "' handles.fullname{nicc} '"  "' handles.fulltemp{nicc} '"']);
else
   handles.fulltemp{nicc} = handles.fullname{nicc};
end

if handles.profile(nicc)==1 | ...    % Save setting.
      (nicc~=3 & handles.profile(nicc)==8) | (nicc==3 & handles.profile(nicc)==9)
   handles.fullsave{nicc} = handles.fulltemp{nicc};
   handles.cmyksave(nicc) = handles.cmyk(nicc);
   handles.profile(nicc) = 7;  % Set to display last profile.
end

if ~isequal(handles.fulltemp{nicc}(1),'*')
   [iccdesc, iccout] =geticcontents(handles.rootdir,handles.fulltemp{nicc});
   handles.iccdesc{nicc} = iccdesc;  % Pure cell array
   handles.iccout{nicc}  = iccout;   % Structure
   % d1 = handles.rootdir,  d2 = handles.fulltemp{nicc}
   % handles.iccout{nicc}.dataCS,  handles.iccout{nicc}.type  % How to reference...
   istmp = isfield(iccout,'dataCS');
   if istmp
      handles.cmyk(nicc) = strcmpi(handles.iccout{nicc}.dataCS,'CmykData');  % 1 for CMYK; 0 otherwise.
   else
      handles.cmyk(nicc) = 0;  % Assume it's not CMYK.
   end
else  % Built-in profile
   handles.iccdesc{nicc} = ['Profile:      ' handles.fulltemp{nicc} ' (built into ICCtrans)'];
   handles.iccout{nicc}.profile = handles.fulltemp{nicc};
   handles.cmyk(nicc) = 0;
end

writeKeys = {
             'gamut','',['profile_' num2str(nicc)], handles.profile(nicc); ...  % 1 <= nicc <= 4};
            };
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.

guidata(hObject, handles);  % Update handles structure


% ------------------  END USER-DEFINED FUNCTIONS ---------------------


% --- Executes during object creation, after setting all properties.
function popupmenu_P1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu_P1.
% Set profile 1: Upper left.
function handles = popupmenu_P1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_P1 (see GCBO)
nicc = 1;  % 1-4; for each icc name.
if ~handles.satupdate
   if  handles.initialize
      set(hObject,'Value',handles.profile(nicc));
   else  % Normal call.
      handles.profile(nicc) = get(hObject,'Value');  % 1 is browse; 7 is where ICC file name will go.
      % writeKeys = {'gamut','',['profile_' num2str(nicc)], handles.profile(nicc) };  % 1 <= nicc <= 4
      % inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
   end
   guidata(hObject, handles);  % Update handles structure
   handles = geticc(hObject, handles, nicc);
end
handles = update_L(handles,0,[1:1088]);  % 0 for input.
guidata(hObject, handles);  % Update handles structure
% Update the view if this profile is active.
if (length(find(handles.actival==1)) | length(find(handles.actival==2)) | ...
      handles.profile(3)==8) & ~ handles.initialize  % One of the display elements == 1 or 2
   guidata(hObject, handles);  % Update handles structure
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end


% --- Executes during object creation, after setting all properties.
function popupmenu_P2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu_P2.
function handles = popupmenu_P2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_P2 (see GCBO)
nicc = 2;  % 1-4; for each icc name.
if ~handles.satupdate
	if  handles.initialize
       set(hObject,'Value',handles.profile(nicc));
	else  % Normal call.
       handles.profile(nicc)    = get(hObject,'Value');  % 1 is browse; 7+ is where ICC file name will go.
	end
   guidata(hObject, handles);  % Update handles structure
   handles = geticc(hObject, handles, nicc);
end
handles = update_L(handles,1,[1:1088]);  % 1 for output.
guidata(hObject, handles);  % Update handles structure
% Update the view if this profile is active (one of the display elements == 2).
if (length(find(handles.actival==2)) | handles.profile(3)==8) & ~ handles.initialize 
   guidata(hObject, handles);  % Update handles structure
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end


% --- Executes during object creation, after setting all properties.
function popupmenu_P3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_P3 (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu_P3.
function handles = popupmenu_P3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_P3 (see GCBO)
nicc = 3;  % 1-4; for each icc name.
if ~handles.satupdate
	if  handles.initialize
       set(hObject,'Value',handles.profile(nicc));
	else  % Normal call.
       % For nicc==3 only, 8 means use image and profile from 2.
       handles.profile(nicc) = get(hObject,'Value');  % 1 is browse; 7+ is where ICC file name will go.
       if handles.profile(3)==8 & handles.intent_L>4
          hwarn = warndlg({'Round-trip or Soft-proofing rendering intents'; 'are not compatible with'; ...
                '"Profile and output from box 2" in box 3'}, 'Gamutvision warning');  % ,'warn','modal');
          pause(2);  close(hwarn);
       end
	end
	guidata(hObject, handles);  % Update handles structure
   handles = geticc(hObject, handles, nicc); 
end
handles = update_R(handles,0,[1:1088]);  % 0 for input
guidata(hObject, handles);  % Update handles structure
% Update the view if this profile is active (one of the display elements == 3 or 4).
if (length(find(handles.actival==3)) | length(find(handles.actival==4)) | ...
      handles.profile(3)==8) & ~ handles.initialize 
   guidata(hObject, handles);  % Update handles structure
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end


% --- Executes during object creation, after setting all properties.
function popupmenu_P4_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu_P4.
function handles = popupmenu_P4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_P4 (see GCBO)
nicc = 4;  % 1-4; for each icc name.
if ~handles.satupdate
	if  handles.initialize
       set(hObject,'Value',handles.profile(nicc));
	else  % Normal call.
       handles.profile(nicc)    = get(hObject,'Value');  % 1 is browse; 7+ is where ICC file name will go.
	end
   guidata(hObject, handles);  % Update handles structure
   handles = geticc(hObject, handles, nicc);
end
handles = update_R(handles,1,[1:1088]);  % 1 for output
guidata(hObject, handles);  % Update handles structure
% Update the view if this profile is active (one of the display elements == 4).
if (length(find(handles.actival==4)) | handles.profile(3)==8) & ~ handles.initialize 
   guidata(hObject, handles);  % Update handles structure
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end


function handles = update_L(handles,nio,range)
% Update left side (1 and 2).  nio = 0 for input; 1 for output.
if ~isempty(handles.fulltemp{1}) & ~isempty(handles.fulltemp{2})  % Update targets.
   handles.imgstate(1)=0;  % Recalculate image settings if needed.
   if     handles.pltype==11 | handles.pltype==12  % Image color difference: Update entire array.
      if handles.pltype==11
         handles.outarg2 = handles.ftarg2;
      elseif handles.pltype==12  % Map handles.ftarg2 from L*a*b* D65 NOW.
         handles.outarg2 = icctrans(handles.ftarg2, ['-t1 -i *LabD65 -o ' handles.fulltemp{1}]);
      end
      temp = handles.outarg2;
      sz = size(handles.ftarg);  rng1 = [1:sz(1)];  rng2 = [1:sz(2)];
      handles.outgam2 = handles.ftarg(1:2:256,1:2:256,:);  tempg = handles.outgam2;
   elseif handles.initialize | handles.lastype==11 | handles.lastype==12  % Restore gamut array.
      handles.outarg2 = handles.ftarg;  temp = handles.ftarg;
      sz = size(handles.ftarg);  rng1 = [1:sz(1)];  rng2 = [1:sz(2)];
   else  % normal plot    % Standard test pattern.
      rng1 = [1:256];  rng2 = range;  temp = handles.ftarg;
   end
   set(handles.popupmenu_P1, 'Enable', 'on');  % For all but Round Trips.
   bpc = handles.blackpt{1};
   istmp = isfield(handles.iccout,'type');
   if istmp  % Don't apply BPC when input profile is OutputClass.
      if isequal(handles.iccout{1}.type,'OutputClass')  bpc = ' ';   end
   end
   if handles.intent_L<4  % Perform a gamut mapping. Otherwise use same output, input targets.
      iccstring = ['-t' num2str(mod(handles.intent_L,5)) ' -i ' handles.fulltemp{1} bpc ...
         ' -o ' handles.fulltemp{2}];
      % Partial update fails when CMYK profile is used.
      % temp = rgb2cmyk(handles.ftarg(rng1,rng2,:),handles.cmyk(1));  % Convert to CMYK if needed. 
	   % handles.outarg2(rng1,rng2,:) = icctrans(temp, iccstring);   % Output target (input is original).
      temp = rgb2cmyk(temp, handles.cmyk(1));  % Convert to CMYK if needed. 
	   handles.outarg2 = icctrans(temp, iccstring);   % Output target (input is original).
      if handles.pltype==11 | handles.pltype==12
         tempg = rgb2cmyk(tempg, handles.cmyk(1));
	      handles.outgam2 = icctrans(tempg, iccstring);
      end
   elseif nio & (handles.intent_L==5 | handles.intent_L==6)  % Round trip
      if handles.lastint<=4 | handles.lastint >=7
         handles.save_full_1 = handles.fulltemp{1};  handles.save_cmyk(1) = handles.cmyk(1);
         handles.save_pop_P1 = get(handles.popupmenu_P1, 'Value');
      end
      set(handles.popupmenu_P1, 'Enable', 'off');  set(handles.popupmenu_P1, 'Value', 1);
      handles.fulltemp{1} = handles.fulltemp{2};  handles.cmyk(1) = handles.cmyk(2);
      iccstring = ['-t' num2str(mod(handles.intent_L,5)) ' -i ' handles.fulltemp{2} handles.blackpt{1} ...
         ' -o ' handles.labtmpr];
      % temp = rgb2cmyk(handles.ftarg(rng1,rng2,:),handles.cmyk(2));  % Convert to CMYK if needed.        
      temp = rgb2cmyk(temp, handles.cmyk(2));  % Convert to CMYK if needed.        
      % size(temp), hc = handles.cmyk, pause(.1) %%%%%%%%%%
      temp2 =  icctrans(temp, iccstring);   % Output target (input is original).
      iccstr2   = ['-t' num2str(mod(handles.intent_L,5)) ' -i ' handles.labtmpr handles.blackpt{1} ...
         ' -o ' handles.fulltemp{2}];
      % handles.outarg2(rng1,rng2,:) =  icctrans(temp2, iccstr2);   % Output target (input is original).
      handles.outarg2 =  icctrans(temp2, iccstr2);   % Output target (input is original).
   elseif handles.intent_L>=7  % Perform a gamut mapping. Otherwise use same output, input targets.
      iccstring = ['-t' num2str(handles.intent_L-7) ' -i ' handles.fulltemp{1} bpc ...
         ' -p ' handles.fulltemp{2} ' -o ' handles.monprof ' -r' num2str(handles.mon_intent-1)];
      % temp = rgb2cmyk(handles.ftarg(rng1,rng2,:),handles.cmyk(1));  % Convert to CMYK if needed.   
	   % handles.outarg2(rng1,rng2,:) = icctrans(temp, iccstring);   % Output target (input is original).
      temp = rgb2cmyk(temp,handles.cmyk(1));  % Convert to CMYK if needed.   
	   handles.outarg2 = icctrans(temp, iccstring);   % Output target (input is original).
      if handles.pltype==11 | handles.pltype==12
         tempg = rgb2cmyk(tempg, handles.cmyk(1));
	      handles.outgam2 = icctrans(tempg, iccstring);
      end
   elseif ~handles.printest.on  % For Print Test, handles.outarg2 is already set.
      % This applies to handles.intent_L==4.
      handles.outarg2 = rgb2cmyk(temp,handles.cmyk(2));  % Convert to CMYK if needed.  Check (2)???
      if handles.pltype==11 | handles.pltype==12
	      handles.outgam2 = rgb2cmyk(tempg, handles.cmyk(2));
      end
   end
   if handles.profile(3)==8  % 3 is the output of 2; Update 3 and 4.
      handles = update_R(handles,0,range);
      % handles = popupmenu_P3_Callback(handles.popupmenu_P3, eventdata, handles);  % Works OK!
   end
end


function handles = update_R(handles,nio,range)
% Update right side (3 and 4)  nio = 0 for input; 1 for output.
if ~isempty(handles.fulltemp{3}) & ~isempty(handles.fulltemp{4})  % Update targets.
   handles.imgstate(1)=0;  % Recalculate image settings if needed.
   if handles.pltype==11 | handles.pltype==12  % Image color difference: Update entire array.
      if handles.pltype==11
         handles.outarg4 = handles.ftarg2;
      elseif handles.pltype==12  % Map handles.ftarg2 from L*a*b* D65 NOW.
         handles.outarg4 = icctrans(handles.ftarg2, ['-t1 -i *LabD65 -o ' handles.fulltemp{3}]);
      end
      temp = handles.outarg4;
      sz = size(handles.ftarg);  rng1 = [1:sz(1)];  rng2 = [1:sz(2)];
      handles.outgam4  = handles.ftarg(1:2:256,1:2:256,:);  tempg = handles.outgam4;
   elseif handles.initialize | handles.lastype==11 | handles.lastype==12  % Restore gamut array.
      handles.outarg4 = handles.ftarg;  temp = handles.ftarg;
      sz = size(handles.ftarg);  rng1 = [1:sz(1)];  rng2 = [1:sz(2)];
   else  % normal plot    % Standard test pattern.
      rng1 = [1:256];  rng2 = range;  temp = handles.ftarg;
   end
   set(handles.popupmenu_P3, 'Enable', 'on');  % For all but Round Trips.
   bpc = handles.blackpt{2};
   istmp = isfield(handles.iccout,'type');
   if istmp  % Don't apply BPC when input profile is OutputClass.
      if isequal(handles.iccout{3}.type,'OutputClass')  bpc = ' ';   end
   end
   if handles.intent_R<4  % Perform a gamut mapping. Otherwise use same output, input targets.
   	iccstring = ['-t' num2str(handles.intent_R) ' -i ' handles.fulltemp{3} bpc ...
         ' -o ' handles.fulltemp{4}];
      if handles.profile(3)~=8
         % Partial update fails when CMYK profile is used.
         % temp = rgb2cmyk(handles.ftarg(rng1,rng2,:),handles.cmyk(3));  % Convert to CMYK if needed.   
         % handles.outarg4(rng1,rng2,:) = icctrans(temp, iccstring);   % Output target (input is original).
         temp = rgb2cmyk(temp,handles.cmyk(3));  % Convert to CMYK if needed.   
         handles.outarg4 = icctrans(temp, iccstring);   % Output target (input is original).
         if handles.pltype==11 | handles.pltype==12
            tempg = rgb2cmyk(tempg, handles.cmyk(3));  % Convert to CMYK if needed. 
	         handles.outgam4 = icctrans(tempg, iccstring);   % Output target (input is original).
         end
      else  % Use output of 2.
         % handles.outarg4(rng1,rng2,:) = icctrans(handles.outarg2(rng1,rng2,:), iccstring);   % Output target (input is original).
         handles.outarg4 = icctrans(handles.outarg2, iccstring);   % Output target (input is original).
         if handles.pltype==11 | handles.pltype==12
	         handles.outgam4 = icctrans(handles.outgam2, iccstring);   % Output target (input is original).
         end
      end
   elseif handles.intent_R==4  % No mapping
      if handles.profile(3)~=8
         handles.outarg4 = rgb2cmyk(temp, handles.cmyk(4));  % Convert to CMYK if needed.   
         % handles.outarg4 = handles.ftarg;
         if handles.pltype==11 | handles.pltype==12
	         handles.outgam4 = rgb2cmyk(tempg, handles.cmyk(4));
         end
      else  % Use output of 2.
         handles.outarg4 = handles.outarg2;
         if handles.pltype==11 | handles.pltype==12
	         handles.outgam4 = handles.outgam2,;
         end
      end
   elseif nio & (handles.intent_R==5 | handles.intent_R==6)  % Round trip
      if handles.lastint<=4 | handles.lastint>=7
         handles.save_full_3 = handles.fulltemp{3};  handles.save_cmyk(3) = handles.cmyk(3);
         handles.save_pop_P3 = get(handles.popupmenu_P3, 'Value');
      end
      set(handles.popupmenu_P3, 'Enable', 'off');  set(handles.popupmenu_P3, 'Value', 1);
      handles.fulltemp{3} = handles.fulltemp{4};  handles.cmyk(3) = handles.cmyk(4);
      iccstring = ['-t' num2str(mod(handles.intent_R,5)) ' -i ' handles.fulltemp{4} handles.blackpt{2} ...
         ' -o ' handles.labtmpr];
      % temp = rgb2cmyk(handles.ftarg(rng1,rng2,:),handles.cmyk(4));  % Convert to CMYK if needed.        
      temp = rgb2cmyk(temp,handles.cmyk(4));  % Convert to CMYK if needed.        
      temp2 =  icctrans(temp, iccstring);   % Output target (input is original).
      iccstr2   = ['-t' num2str(mod(handles.intent_R,5)) ' -i ' handles.labtmpr handles.blackpt{2} ...
         ' -o ' handles.fulltemp{4}];
      % handles.outarg4(rng1,rng2,:) =  icctrans(temp2(rng1,rng2,:), iccstr2);   % Output target (input is original).
      handles.outarg4 =  icctrans(temp2, iccstr2);   % Output target (input is original).
   elseif handles.intent_R>=7  % Perform a gamut mapping. Otherwise use same output, input targets.
   	iccstring = ['-t' num2str(handles.intent_R-7) ' -i ' handles.fulltemp{3} bpc ...
         ' -p ' handles.fulltemp{4} ' -o ' handles.monprof ' -r' num2str(handles.mon_intent-1)];
      if handles.profile(3)~=8
         % temp = rgb2cmyk(handles.ftarg(rng1,rng2,:),handles.cmyk(3));  % Convert to CMYK if needed.   
         % handles.outarg4(rng1,rng2,:) = icctrans(temp, iccstring);   % Output target (input is original).
         temp = rgb2cmyk(temp,handles.cmyk(3));  % Convert to CMYK if needed.   
         handles.outarg4 = icctrans(temp, iccstring);   % Output target (input is original).
         if handles.pltype==11 | handles.pltype==12
            tempg = rgb2cmyk(tempg, handles.cmyk(3));  
	         handles.outgam4 = icctrans(tempg, iccstring); 
         end
      else  % Use output of 2.
         % handles.outarg4(rng1,rng2,:) = icctrans(handles.outarg2(rng1,rng2,:), iccstring);   % Output target (input is original).
         handles.outarg4 = icctrans(handles.outarg2, iccstring);   % Output target (input is original).
         if handles.pltype==11 | handles.pltype==12
	         handles.outgam4 = icctrans(handles.outgam2, iccstring); 
         end
      end
   end
end


% --- Executes during object creation, after setting all properties.
function popupmenu_gamutmap_L_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%              SELECT GAMUT MAPPING (LEFT) AND UPDATE OUTPUT TARGET.
% --- Executes on selection change in popupmenu_gamutmap_L.
function handles = popupmenu_gamutmap_L_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_gamutmap_L (see GCBO)
handles.imgstate(1)=0;  % Recalculate image settings if needed.
handles.lastint = handles.intent_L;      % Previous rendering intent.
handles.intent_L = get(handles.popupmenu_gamutmap_L,'Value')-1; 
if handles.profile(3)==8 & handles.intent_L>4
   hwarn = warndlg({'"Profile and output from box 2" in box 3'; 'is not compatible with'; ...
         'Round-trip or Soft-proofing rendering intents'; 'in the left data flow (1 > 2)'}, ...
         'Gamutvision warning');  % ,'warn','modal');
   pause(2); close(hwarn);
end
if (handles.lastint==5 | handles.lastint==6) & (handles.intent_L<=4 | handles.intent_L>=7)  % Return from Round Trip.
   handles.fulltemp{1} = handles.save_full_1;  handles.cmyk(1) = handles.save_cmyk(1);
   set(handles.popupmenu_P1, 'Value', handles.save_pop_P1);
end
writeKeys = {'gamut','','gamutmap_L', handles.intent_L+1};  % 1 <= nicc <= 4
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
if handles.printest.on & handles.intent_L~=4  % Turn off Print Test and its indicators.
   handles.printest.on = 0;
   set(handles.edit_printest,        'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
   set(handles.pushbutton_printest,  'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
   set(handles.frame_printest,       'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
   set(handles.frame_printest2,      'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
handles = update_L(handles,1,[1:1088]);  % 1 for output (update RT if needed)
guidata(hObject, handles);  % Update handles structure
% Update the view if this profile is active.
if length(find(handles.actival==2)) | handles.profile(3)==8
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end


% --- Executes during object creation, after setting all properties.
function popupmenu_gamutmap_R_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%              SELECT GAMUT MAPPING (RIGHT) AND UPDATE OUTPUT TARGET.
% --- Executes on selection change in popupmenu_gamutmap_R.
function handles = popupmenu_gamutmap_R_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_gamutmap_R (see GCBO)
handles.imgstate(1)=0;  % Recalculate image settings if needed.
handles.lastint = handles.intent_R;      % Previous rendering intent.
handles.intent_R = get(handles.popupmenu_gamutmap_R,'Value')-1; % Starts at 0. 
if (handles.lastint==5 | handles.lastint==6) & (handles.intent_R<=4 | handles.intent_R>=7)  % Return from Round Trip.
   handles.fulltemp{3} = handles.save_full_3;  handles.cmyk(3) = handles.save_cmyk(3);
   set(handles.popupmenu_P3, 'Value', handles.save_pop_P3);
end
writeKeys = {'gamut','','gamutmap_R', handles.intent_R+1};  % 1 <= nicc <= 4
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
handles = update_R(handles,1,[1:1088]);  % 1 for output (update RT if needed)
guidata(hObject, handles);  % Update handles structure
% Update the view if this profile is active.
if length(find(handles.actival==4)) | handles.profile(3)==8
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end


% ----------------------  VIEW (UPDATE) FUNCTIONS  ------------------------

function handles = gray_buttons(handles);  % Gray out most buttons.
set(handles.popupmenu_P1,         'BackgroundColor',handles.defbg);
set(handles.popupmenu_P2,         'BackgroundColor',handles.defbg);
set(handles.popupmenu_P3,         'BackgroundColor',handles.defbg);
set(handles.popupmenu_P4,         'BackgroundColor',handles.defbg);
set(handles.popupmenu_gamutmap_L, 'BackgroundColor',handles.defbg);
set(handles.popupmenu_gamutmap_R, 'BackgroundColor',handles.defbg);
set(handles.text_WF1,             'BackgroundColor',handles.defbg);
set(handles.frame_WF1,            'BackgroundColor',handles.defbg);
set(handles.text_WF2,             'BackgroundColor',handles.defbg);
set(handles.frame_WF2,            'BackgroundColor',handles.defbg);
set(handles.text_OUTW1,           'BackgroundColor',handles.defbg);
set(handles.text_OUTW2,           'BackgroundColor',handles.defbg);
set(handles.pushbutton_view_L,    'BackgroundColor',handles.defbg); 
set(handles.pushbutton_view_R,    'BackgroundColor',handles.defbg);
set(handles.pushbutton_View_WF1,  'BackgroundColor',handles.defbg);
set(handles.pushbutton_View_WF2,  'BackgroundColor',handles.defbg);
set(handles.frame_1_2,            'BackgroundColor', [.5 .5 .5]);
set(handles.frame_3_4,            'BackgroundColor', [.5 .5 .5]);


%                     VIEW LEFT WORKFLOW.
% --- Executes on button press in pushbutton_view_L.
function handles = pushbutton_view_L_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_L (see GCBO)
handles = gray_buttons(handles);
set(handles.pushbutton_view_L,   'BackgroundColor',[1 1 .8]);
handles.imgstate(1)=0;  % Recalculate image settings if needed.
handles.viewtype = 1;  % 1 for L, 2 for R, 3 for WF1, 4 for WF2.
handles.pltin = 1;  handles.pltout = 2;
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
if handles.pltOK  % Plot completed successfully.
   handles.actival = [1 2];
   set(handles.pushbutton_view_L,   'BackgroundColor',[ 1 1 .8]);
	set(handles.popupmenu_P1,        'BackgroundColor',[ 1 1 .8]);
	set(handles.popupmenu_P2,        'BackgroundColor',[.9 1 .9]);
	set(handles.popupmenu_gamutmap_L,'BackgroundColor',[ 1 1 .9]);
   set(handles.frame_1_2,           'BackgroundColor', [.3 .5 .8]);
end
guidata(hObject, handles);  % Update handles structure


%                     VIEW RIGHT WORKFLOW.
% --- Executes on button press in pushbutton_view_R.
function handles = pushbutton_view_R_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_R (see GCBO)
handles = gray_buttons(handles);
set(handles.pushbutton_view_R,   'BackgroundColor',[1 1 .8]);
handles.imgstate(1)=0;  % Recalculate image settings if needed.
handles.viewtype = 2;  % 1 for L, 2 for R, 3 for WF1, 4 for WF2.
handles.pltin = 3;  handles.pltout = 4;
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
if handles.pltOK  % Plot completed successfully.
   handles.actival = [3 4];
   set(handles.pushbutton_view_R,   'BackgroundColor',[ 1 1 .8]);
	set(handles.popupmenu_P3,        'BackgroundColor',[ 1 1 .8]);
	set(handles.popupmenu_P4,        'BackgroundColor',[.9 1 .9]);
	set(handles.popupmenu_gamutmap_R,'BackgroundColor',[ 1 1 .9]);
   set(handles.frame_3_4,           'BackgroundColor', [.3 .5 .8]);
end
guidata(hObject, handles);  % Update handles structure


%                              VIEW DISPLAY A (was WORKFLOW 1).
% --- Executes on button press in pushbutton_View_WF1.
function handles = pushbutton_View_WF1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_View_WF1 (see GCBO)
handles = gray_buttons(handles);
set(handles.pushbutton_View_WF1,   'BackgroundColor',[1 1 .8]);
handles.imgstate(1)=0;  % Recalculate image settings if needed.
handles.viewtype = 3;  % 1 for L, 2 for R, 3 for WF1, 4 for WF2.
ndin  = get(handles.popupmenu_INW1, 'Value');  handles.pltin  = ndin;
ndout = get(handles.popupmenu_OUTW1,'Value');  handles.pltout = ndout;
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
if handles.pltOK  % Plot completed successfully.
   handles.actival = [ndin ndout];
   set(handles.text_WF1,             'BackgroundColor',[.95 .7 .95]);
   set(handles.frame_WF1,            'BackgroundColor',[.95 .7 .95]);
   set(handles.text_OUTW1,           'BackgroundColor',[.95 .7 .95]);
   set(handles.pushbutton_View_WF1,  'BackgroundColor',[1 1 .8]);
	if     ndin==1    set(handles.popupmenu_P1,        'BackgroundColor',[1 1 .8]);
	elseif ndin==2    set(handles.popupmenu_P2,        'BackgroundColor',[1 1 .8]);
                     set(handles.popupmenu_gamutmap_L,'BackgroundColor',[1 1 .9]);
	elseif ndin==3    set(handles.popupmenu_P3,        'BackgroundColor',[1 1 .8]);
	elseif ndin==4    set(handles.popupmenu_P4,        'BackgroundColor',[1 1 .8]);
                     set(handles.popupmenu_gamutmap_R,'BackgroundColor',[1 1 .9]);
	end
	if     ndout==1   set(handles.popupmenu_P1,        'BackgroundColor',[.9 1 .9]);
	elseif ndout==2   set(handles.popupmenu_P2,        'BackgroundColor',[.9 1 .9]);
                     set(handles.popupmenu_gamutmap_L,'BackgroundColor',[ 1 1 .9]);
	elseif ndout==3   set(handles.popupmenu_P3,        'BackgroundColor',[.9 1 .9]);
	elseif ndout==4   set(handles.popupmenu_P4,        'BackgroundColor',[.9 1 .9]);
                     set(handles.popupmenu_gamutmap_R,'BackgroundColor',[ 1 1 .9]);
	end
end
guidata(hObject, handles);  % Update handles structure


%                              VIEW DISPLAY B (was WORKFLOW 2).
% --- Executes on button press in pushbutton_View_WF2.
function handles = pushbutton_View_WF2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_View_WF2 (see GCBO)
handles = gray_buttons(handles);
set(handles.pushbutton_View_WF2,  'BackgroundColor',[1 1 .8]);  % Kludge!
handles.imgstate(1)=0;  % Recalculate image settings if needed.
handles.viewtype = 4;  % 1 for L, 2 for R, 3 for WF1, 4 for WF2.
ndin  = get(handles.popupmenu_INW2, 'Value');  handles.pltin  = ndin;
ndout = get(handles.popupmenu_OUTW2,'Value');  handles.pltout = ndout;
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
if handles.pltOK  % Plot completed successfully.
   handles.actival = [ndin ndout];
   set(handles.text_WF2,             'BackgroundColor',[.95 .7 .95]);
   set(handles.frame_WF2,            'BackgroundColor',[.95 .7 .95]);
   set(handles.text_OUTW2,           'BackgroundColor',[.95 .7 .95]);
   set(handles.pushbutton_View_WF2,  'BackgroundColor',[1 1 .8]);
	if     ndin==1    set(handles.popupmenu_P1,        'BackgroundColor',[1 1 .8]);
	elseif ndin==2    set(handles.popupmenu_P2,        'BackgroundColor',[1 1 .8]);
                     set(handles.popupmenu_gamutmap_L,'BackgroundColor',[1 1 .9]);
	elseif ndin==3    set(handles.popupmenu_P3,        'BackgroundColor',[1 1 .8]);
	elseif ndin==4    set(handles.popupmenu_P4,        'BackgroundColor',[1 1 .8]);
                     set(handles.popupmenu_gamutmap_R,'BackgroundColor',[1 1 .9]);
	end
	if     ndout==1   set(handles.popupmenu_P1,        'BackgroundColor',[.9 1 .9]);
	elseif ndout==2   set(handles.popupmenu_P2,        'BackgroundColor',[.9 1 .9]);
                     set(handles.popupmenu_gamutmap_L,'BackgroundColor',[ 1 1 .9]);
	elseif ndout==3   set(handles.popupmenu_P3,        'BackgroundColor',[.9 1 .9]);
	elseif ndout==4   set(handles.popupmenu_P4,        'BackgroundColor',[.9 1 .9]);
                     set(handles.popupmenu_gamutmap_R,'BackgroundColor',[ 1 1 .9]);
	end
end
guidata(hObject, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function popupmenu_INW2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_INW2 (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu_INW2.
function popupmenu_INW2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_INW2 (see GCBO)
if handles.viewtype==4
   handles.pltin = get(hObject, 'Value');
   guidata(hObject, handles);  % Update handles structure
   handles = pushbutton_View_WF2_Callback(hObject, eventdata, handles);   
   % handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
end
writeKeys = {'gamut','','INW2', get(hObject,'Value') };  % 1 <= nicc <= 4
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.


% --- Executes during object creation, after setting all properties.
function popupmenu_OUTW2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_OUTW2 (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu_OUTW2.
function popupmenu_OUTW2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_OUTW2 (see GCBO)
if handles.viewtype==4
   handles.pltout = get(hObject, 'Value');
   guidata(hObject, handles);  % Update handles structure
   handles = pushbutton_View_WF2_Callback(hObject, eventdata, handles);   
   % handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end
writeKeys = {'gamut','','OUTW2', get(hObject,'Value') };  % 1 <= nicc <= 4
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.


% --- Executes during object creation, after setting all properties.
function popupmenu_INW1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_INW1 (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu_INW1.
function popupmenu_INW1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_INW1 (see GCBO)
if handles.viewtype==3
   handles.pltin = get(hObject, 'Value');
   guidata(hObject, handles);  % Update handles structure
   handles = pushbutton_View_WF1_Callback(hObject, eventdata, handles);   
   % handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
end
writeKeys = {'gamut','','INW1', get(hObject,'Value') };  % 1 <= nicc <= 4
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.


% --- Executes during object creation, after setting all properties.
function popupmenu_OUTW1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_OUTW1 (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu_OUTW1.
function popupmenu_OUTW1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_OUTW1 (see GCBO)
if handles.viewtype==3
   handles.pltout = get(hObject, 'Value');
   guidata(hObject, handles);  % Update handles structure
   handles = pushbutton_View_WF1_Callback(hObject, eventdata, handles);   
   % handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end
writeKeys = {'gamut','','OUTW1', get(hObject,'Value') };  % 1 <= nicc <= 4
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.


% --- Executes on button press in inp_raw.
function handles = inp_raw_Callback(hObject, eventdata, handles)
% hObject    handle to inp_raw (see GCBO)
handles.outype = 3;  handles = reset_outplot(handles);
set(handles.inp_raw,           'BackgroundColor',[1 1 .8]);
set(handles.inp_raw,           'FontWeight', 'bold');
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [0 1]);

% --- Executes on button press in inp_mapped.
function handles = inp_mapped_Callback(hObject, eventdata, handles)
% hObject    handle to inp_raw_mapped (see GCBO)
handles.outype = 4;  handles = reset_outplot(handles);
set(handles.inp_mapped,        'BackgroundColor',[1 1 .8]);
set(handles.inp_mapped,        'FontWeight', 'bold');
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [0 1]);

% --- Executes on button press in out_raw.
function handles = out_raw_Callback(hObject, eventdata, handles)
% hObject    handle to out_raw (see GCBO)
handles.outype = 1;  handles = reset_outplot(handles);
set(handles.out_raw,           'BackgroundColor',[1 1 .8]);
set(handles.out_raw,           'FontWeight', 'bold');
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [0 1]);


% --- Executes on button press in out_mapped.  O>M button
function handles = out_mapped_Callback(hObject, eventdata, handles)
% hObject    handle to out_raw_mapped (see GCBO)
handles.outype = 2;  handles = reset_outplot(handles);
set(handles.out_mapped,        'BackgroundColor',[1 1 .8]);
set(handles.out_mapped,        'FontWeight', 'bold');
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [0 1]);


function handles = reset_outplot(handles)
set(handles.inp_raw,           'BackgroundColor',handles.defbg);
set(handles.inp_mapped,        'BackgroundColor',handles.defbg);
set(handles.out_raw,           'BackgroundColor',handles.defbg);
set(handles.out_mapped,        'BackgroundColor',handles.defbg);
set(handles.inp_raw,           'FontWeight', 'normal');
set(handles.inp_mapped,        'FontWeight', 'normal');
set(handles.out_raw,           'FontWeight', 'normal');
set(handles.out_mapped,        'FontWeight', 'normal');
handles.imgstate(1)=0;  % Recalculate image settings if needed.


% --- Executes during object creation, after setting all properties.
function popupmenu_pltype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_pltype (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu_pltype.
function popupmenu_pltype_Callback(hObject, eventdata, handles)
handles.lastype = handles.pltype;  % Last value of plot type.
handles.pltype = get(hObject, 'Value');  % Plot type: affects buttons.
guidata(hObject, handles);  % Update handles structure

if (handles.lastype==11 | handles.lastype==12) & ~(handles.pltype==11 | handles.pltype==12)  % restore std target.
   handles = maketarg(hObject, handles);  % Recreate target (handles.ftarg).
   handles.outarg2 = handles.ftarg;  handles.outarg4 = handles.ftarg;  % Correct size.
   handles = initialize_mappings(hObject, eventdata, handles);  % Initialize the gamut mappings.
elseif handles.pltype==11 | handles.pltype==12  % Read and prepare image for Image color difference!
   handles.printest.on = 0;   % Turn off Printest.
   set(handles.edit_printest,        'BackgroundColor',handles.defbg);
   set(handles.pushbutton_printest,  'BackgroundColor',handles.defbg);
   set(handles.frame_printest2,      'BackgroundColor',handles.defbg);
   if handles.pltype==11  % Read image for analysis.
		readKeys = { ...
          'gamut','','imgpath',   '',  [pwd filesep] };
		readSett = inifile(handles.file_ini,'read',readKeys);   % READ GAMUTVISION.INI
		imgpath =   readSett{1};   % (previous) directory for saving plots.
		foldersave = pwd;  imgfile = [];  % This code for uigetfiles (Rex Tenorio version; not uigetfile).
		if isdir(imgpath)  cd(imgpath);  end  % uigetfiles only works with current directory.
		[imgfile, pathname] = uigetfiles('*.*','Image file');  % New file and path name.
		cd(foldersave);  % Always go back!
		if (isempty(imgfile)) imgfile = 0;       % No input file returned. Compatible with uigetfile.
		else                  imgfile = imgfile{1};  % Convert from cell (for uigetfiles only)
		end
      % path_ui = [imgpath '*.*'];  % Still  used for reference file input.
      % [imgfile imgpath] = uigetfile(path_ui,'Image file');
      if (isequal(imgfile,0) | isequal(imgpath,0))  % No file name returned.
         handles.pltype = handles.lastype;  return;
      end  % No input file returned.
      handles.imgfull = [pathname imgfile];  % [imgpath imgfile];
      disp(['Read  ' handles.imgfull]);  % Full path name of input file.
      writeKeys = {'gamut','','imgpath',    pathname;   };
      inifile(handles.file_ini,'write',writeKeys,'plain');
      [im_orig, im_st, fmt] = read_image(handles.imgfull,0,1,'');  % READ INPUT FILE. Image in handles.ftarg.
      hmsg = waitbar(1,'Preparing image (gamut mapping, etc.)');
      sz_orig = size(im_orig);
      nskip = ceil(max(sz_orig)/1000);
      % Reduce image size if too large. Dumb nearest-neighor resize. No AA.
      if (strcmp(class(im_orig),'uint16'))  im255 = 65535;  else  im255 = 255;  end  % Bit depth: 16 or 8
      handles.ftarg2 = double(im_orig([1:nskip:sz_orig(1)],[1:nskip:sz_orig(2)],:))/im255;  % Was handles.ftarg
      if nskip>1  
         disp(['Reduce ' num2str(sz_orig) ' image to ' num2str(size(handles.ftarg2)) ' pixels']);
      end
   elseif handles.pltype==12  % Simulated GretagMacbeth ColorChecker. Calc. im_orig, handles.ftarg2...
      hmsg = waitbar(1,'Preparing image (gamut mapping, etc.)');
		% npatch = 63; nspace = 9;  % 441x297:  7:1 ratio seems just right. Also 42,6.
		npatch = 21; nspace = 3;
		nwidth  = 6*(npatch+nspace)+nspace;
		nheight = 4*(npatch+nspace)+nspace;
		
		im_orig        = zeros(nheight,nwidth,3);  % Was .24 with lab2rgb(...)
		im_orig(:,:,1) = 27;  % Was .24 with lab2rgb(...)
		stdlab = [37.542	12.018	13.33;   65.2	14.821	17.545;     50.366	-1.573	-21.431;  ...
                43.125	-14.63	22.12;   55.343	11.449	-25.289; 71.36	-32.718	1.636; ...
                61.365	32.885	55.155;  40.712	16.908	-45.085; 49.86	45.934	13.876; ...
                30.15	24.915	-22.606; 72.438	-27.464	58.469;  70.916	15.583	66.543; ...
                29.624	21.425	-49.031; 55.643	-40.76	33.274;  40.554	49.972	25.46; ...
                80.982	-1.037	80.03;   51.006	49.876	-16.93;  52.121	-24.61	-26.176; ...
                96.536	-0.694	1.354;   81.274	-0.61	-0.24;      66.787	-0.647	-0.429; ...
                50.872	-0.059	-0.247;  35.68	-0.22	-1.205;        20.475	0.049	-0.972 ];  % D65
		% We need to figure out what colorspace to use or how to map it...
      % Initialize mappings may be different...
      stdrgb = stdlab;  % was lab2rgb(stdlab,'sRGB'); Keep in *LabD65
		% stdrgb255 = round(255*stdrgb)
		
		for i1=1:4
         for j1=1:6
            im_orig(nspace*i1+npatch*(i1-1)+[1:npatch],nspace*j1+npatch*(j1-1)+[1:npatch],1) = ...
               stdrgb(6*(i1-1)+j1,1);
            im_orig(nspace*i1+npatch*(i1-1)+[1:npatch],nspace*j1+npatch*(j1-1)+[1:npatch],2) = ...
               stdrgb(6*(i1-1)+j1,2);
            im_orig(nspace*i1+npatch*(i1-1)+[1:npatch],nspace*j1+npatch*(j1-1)+[1:npatch],3) = ...
               stdrgb(6*(i1-1)+j1,3);
         end
		end
      handles.ftarg2 = im_orig;
   end
   handles = initialize_mappings(hObject, eventdata, handles);  % Initialize the gamut mappings.
   close(hmsg);
   handles.cax = [1e6,-1e6];  % Reset miminum, maximum (pseudo)color map.
   handles.imgstate = [0 0];  % Image just read in.
end

handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);


% --- Executes on button press in check_zoom.
function check_zoom_Callback(hObject, eventdata, handles)
handles.hzoom = get(hObject,'Value');
if handles.hzoom  zoom on; 
else  zoom off;
end
% axes(handles.axes1);  % Not needed? Turns off legend?
if ~handles.hzoom & handles.plt3d==1;
   rotate3d on;  % axis vis3d;
end
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in push_zout.  Zoom out.
function push_zout_Callback(hObject, eventdata, handles)
% hObject    handle to push_zout (see GCBO)
% axes(handles.axes1);  % May remove Legend in Matlab release 12.
% % http://www.mathworks.com/support/solutions/data/1-1MCLZO.html?solution=1-1MCLZO solution:
% ch = get(gcf,'children'); % returns the handles of the legend and the axis. 
% % The axis handle will be the first element in the list
% ch = flipud(ch);  % Re-orders the children such that the legend is the first element  MESS!!!
% set(gcf,'children',ch)
if handles.plt3d
   if handles.pltype==6  axis normal;  end
   [azim, elev] = view;  % Save view azimuth and angle.
   set(handles.axes1,'CameraViewAngleMode','auto', ... % 'CameraPositionMode','auto', ...
      'CameraTargetMode','auto');  % Two of three
   % Removing CameraPositionMode seems to keep angle constant. Looks OK!
   view([azim, elev]);  % Reset view.  Tricky!
else
   set(handles.axes1,'Xlim',handles.zoomorig(1:2), 'Ylim',handles.zoomorig(3:4));
   % xlim(handles.zoomorig(1:2));  ylim(handles.zoomorig(3:4));
   zoom out;
end
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
web('http://www.gamutvision.com/docs/gamutvision.html','-browser');


%                       RESET SCALE
% --- Executes on button press in pushbutton_resc.
function pushbutton_resc_Callback(hObject, eventdata, handles)
% Rescale axes.
if handles.pltype<=2 | ((handles.pltype==11 | handles.pltype==12) & handles.difplt>=19)
   handles.lab3Daxis = [0 0 0 0];  % Saved axis for LAB 3D plots.
elseif (handles.pltype>=3 & handles.pltype<=5)
   handles.lab2Daxis = [0 0 0 0];  % Saved axis for LAB 2D plots.
elseif handles.pltype==6
   handles.hl3dax = [1e6,-1e6];  % Miminum, maximum (pseudo)color map.
elseif (handles.pltype==11 | handles.pltype==12) & handles.difplt<19
   handles.cax    = [1e6,-1e6];  % Miminum, maximum (pseudo)color map.
end
handles.lastplot = -handles.lastplot;  % Ensure that pltsame is not set in bigplot, but keep azim, elev.
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);


%                          RESET VIEW
% --- Executes on button press in pushbutton_resv.
function pushbutton_resv_Callback(hObject, eventdata, handles)

axes(handles.axes2);  reset(handles.axes2);  % Input/output image (on upper right)
set(handles.axes2, 'Visible','off');  axis image;
set(handles.axes2, 'YDir','reverse');  % 'normal' or 'reverse'

axes(handles.axes1);  % May remove Legend in Matlab R 12, but must keep due to previous lines.

if handles.pltype==1 | handles.pltype==2 | ...
      ((handles.pltype==11 | handles.pltype==12) & handles.difplt>=19)
   % 3D plot. Save view azimuth and angle.
	handles.azim = -30;  % -37.5;  % 3D azimuth. Use with view command.
	handles.elev =  20;  %  30;    % 3D elevation.
   view(handles.azim, handles.elev);
   if handles.hzoom  zoom on;   rotate3d off;
   else              zoom off;  rotate3d on;  end  % Switch for 3D plot
   set(handles.check_zoom,'Value',handles.hzoom,'Enable','on');
   % axis vis3d;  % Maybe??? 
elseif handles.pltype==4 | handles.pltype==5
   handles.lightvar = 0.5;  % Reset to standard value.
   set(handles.slider_sat,  'Value', handles.lightvar);  % Saturation slider
   set(handles.text_satvar, 'String', num2str(handles.lightvar,2));
   guidata(hObject, handles);  % Update handles structure
   set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
   set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');
   handles = sat_update(handles,eventdata,0);  % Update saturation
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
elseif handles.pltype==6
   handles.HL_azim = 160;  handles.HL_elev = 35;  % Higher view.
   view(handles.HL_azim, handles.HL_elev);  rotate3d on;
   axis normal;
end
guidata(hObject, handles);  % Update handles structure


%                          RESET SCREEN
function reset_screen_Callback(hObject, eventdata, handles)
set(gcf, 'Position', handles.figstart);
guidata(hObject, handles);  % Update handles structure



%                      TOP VIEW/LAST VIEW
% --- Executes on button press in pushbutton_topv.
function pushbutton_topv_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_topv (see GCBO)
view_name = get(hObject,'String');
axes(handles.axes1);  % May remove Legend in Matlab R 12: N/A here.
if strcmpi(view_name,'Top view')
   if     handles.pltype<3 | ((handles.pltype==11 | handles.pltype==12) & handles.difplt>=19)
      [handles.azim_save,    handles.elev_save] = view;
   elseif handles.pltype==6 & (handles.HLview==2 | handles.HLview==4)
      [handles.HL_azim_save, handles.HL_elev_save] = view;
   end
   view([0,90]);  % Save view azimuth and angle.
   set(hObject,'String','Last view');
else
   if     handles.pltype<3 | ((handles.pltype==11 | handles.pltype==12) & handles.difplt>=19)
      view([handles.azim_save,    handles.elev_save]);
   elseif handles.pltype==6 & (handles.HLview==2 | handles.HLview==4)
      view([handles.HL_azim_save, handles.HL_elev_save]);
   end
   
   set(hObject,'String','Top view');
end
if handles.hzoom  zoom on;   rotate3d off;
else              zoom off;  rotate3d on;  end  % Switch for 3D plot
guidata(hObject, handles);  % Update handles structure


%                     BLACK POINT COMPENSATION  (NEW: POPUP MENU)
% --- Executes on selection change in popupmenu_bpc.
function popupmenu_bpc_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_bpc (see GCBO)
bpcold = handles.bpc;  bpcompold = handles.bpcomp;  % Former values of black point compensation
handles.bpc = get(hObject,'Value');
handles.bpcomp = [~mod(handles.bpc,2) handles.bpc>2];  % Off, Left, Right, Both
if handles.bpcomp(1)  handles.blackpt{1} = ' -b ';  else  handles.blackpt{1} = ' ';  end  % Left
if handles.bpcomp(2)  handles.blackpt{2} = ' -b ';  else  handles.blackpt{2} = ' ';  end  % Right
guidata(hObject, handles);  % Update handles structure
writeKeys = {'gamut','','blackpt', handles.bpc}; 
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
if handles.bpcomp(1)~=bpcompold(1)
   handles = popupmenu_gamutmap_L_Callback(hObject, eventdata, handles);
end
if handles.bpcomp(2)~=bpcompold(2)
   handles = popupmenu_gamutmap_R_Callback(hObject, eventdata, handles);
end
if handles.bpcomp(1)~=bpcompold(1) | handles.bpcomp(2)~=bpcompold(2)
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);
end
% Seems to work only with Colorimetric rendering intent.
%        contents{get(hObject,'Value')} returns selected item from popupmenu_bpc


% --- Executes during object creation, after setting all properties.
function slider_transp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_transp (see GCBO)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',handles.defbg);
end

% --- Executes on slider movement.
function slider_transp_Callback(hObject, eventdata, handles)
% hObject    handle to slider_transp (see GCBO)
opacity = get(hObject,'Value');
if     handles.pltype<3
   handles.transp = 1-opacity;
   set(handles.text_transp,'String',['Transparency ' num2str(opacity,2)]);
   set(handles.wiresurf, 'FaceAlpha',handles.transp);
   writeKeys = {'gamut','','transparency', num2str(handles.transp,3) };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
elseif (handles.pltype==11 | handles.pltype==12) & handles.difplt>=19
   handles.transimg = 1-opacity;
   set(handles.text_transp,'String',['Transparency ' num2str(opacity,2)]);
   set(handles.wiresurf, 'FaceAlpha',handles.transimg);
   writeKeys = {'gamut','','transimg', num2str(handles.transimg,3) };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
elseif handles.pltype==6 | handles.pltype==9  % 2D HSL or Difference
   handles.hslight = opacity;
   set(handles.text_transp,'String',['Image lightness ' num2str(opacity,2)]);
end
guidata(hObject, handles);  % Update handles structure
if handles.pltype==6 | handles.pltype==9  %  | handles.pltype<3
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_vector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_vector (see GCBO)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',handles.defbg);
end


% --- Executes on slider movement.
function slider_vector_Callback(hObject, eventdata, handles)
% hObject    handle to slider_vector (see GCBO)
if handles.pltype<3
   handles.vector = get(hObject,'Value');
   set(handles.text_vector,'String',['Vectors ' num2str(round(handles.vector*100)/100,2)]);
elseif handles.pltype<5  % a*b* plots (3 or 4)
   handles.vectab = get(hObject,'Value');
   set(handles.text_vector,'String',['Vectors ' num2str(round(handles.vectab*100)/100,2)]);
end
guidata(hObject, handles);  % Update handles structure
if handles.pltype<5
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
end


% --- Executes during object creation, after setting all properties.
function popupmenu_pltres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_pltres (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',handles.defbg);
end

%                       3D PLOT RESOLUTION, XYCOLOR, DIFPLT, ETC.
% --- Executes on selection change in popupmenu_pltres.
function popupmenu_pltres_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_pltres (see GCBO)
pltupd = [1 0];  % Plot update indicator
if handles.pltype<3
   handles.pltres = get(hObject,'Value');
elseif handles.pltype==3
   handles.lab2dg  = get(hObject,'Value');
   writeKeys = {'gamut','','lab2dg',       handles.lab2dg; };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
elseif handles.pltype==4
   handles.lab2dv  = get(hObject,'Value');
   writeKeys = {'gamut','','lab2dv',       handles.lab2dv; };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
elseif handles.pltype==5 | handles.pltype==6 | handles.pltype==11 | handles.pltype==12  % Difference plots.
   handles.dlast = handles.difplt;
   handles.difplt = get(hObject,'Value');
   handles.cax    = [1e6,-1e6];  % Reset miminum, maximum (pseudo)color map.
   handles.hl3dax = [1e6,-1e6];  % Reset miminum, maximum (pseudo)color map.
   writeKeys = {'gamut','','difplt',      handles.difplt; };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
elseif handles.pltype==7 | handles.pltype==8  % xy or uv chromaticity plot.
   handles.xycolor = get(hObject,'Value');
   writeKeys = {'gamut','','xycolor',      handles.xycolor; };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
elseif handles.pltype==9
   handles.hslplot = get(hObject,'Value');
   writeKeys = {'gamut','','hslplot',      handles.hslplot; };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
   pltupd = [1 1];
elseif handles.pltype==10
   handles.bwplot  = get(hObject,'Value');
   writeKeys = {'gamut','','bwplot',       handles.bwplot; };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
end
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, pltupd);
if (handles.pltype==11 | handles.pltype==12) & ((handles.difplt>=19 & handles.dlast<19) | ...
      (handles.difplt<19 & handles.dlast>=19))      % One more attempt at a bug fix!  WORKED !!!!!!!!!!
   push_zout_Callback(hObject, eventdata, handles);  % Well, doesn't work...
   % hwarn = msgbox({'Press Z-Out for correct scale and position'; '(workaround for a strange bug)'}, ...
   %    'Press Z-Out','warn');
   % pause(1);  close(hwarn);
end


% --- Executes on button press in check_light.
function handles = check_light_Callback(hObject, eventdata, handles)
% hObject    handle to check_light (see GCBO)
if handles.pltype<3 | handles.pltype==6
   handles.radio_ltsave = get(hObject,'Value');
   if handles.radio_ltsave
      set(handles.lightsurf,'Facelighting',handles.flight);
      % if handles.pltype<3  camlight(handles.lightpos);  % So far, harsh results!
      % else                 camlight(-45,45);
      % end
   else
      set(handles.lightsurf,'Facelighting','none');
   end
   guidata(hObject, handles);  % Update handles structure
   return;  % Exit function: Don't call bigplot.
elseif handles.pltype==7 | handles.pltype==8  % xy or UV chromaticity plot.
   handles.xybdry       = get(hObject,'Value');
   writeKeys = {'gamut','','xybdry',      handles.xybdry; };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
elseif handles.pltype==9  % HSL coutours.
   handles.hsldelta     = get(hObject,'Value');
   writeKeys = {'gamut','','hsldelta',    handles.hsldelta; };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
elseif handles.pltype==11 | handles.pltype==12  % Probe for Image color difference.
   handles.probeim      = get(hObject,'Value');
   if handles.probeim      % Turn on probe.
      if handles.hzoom        % Turn off zoom.
         zoomsave = 1;  handles.hzoom = 0;
         zoom off;  set(handles.check_zoom,'Value',0);
      else
         zoomsave = 0;
      end
      set(handles.popupmenu_P1,'Visible','off');  set(handles.popupmenu_P2,'Visible','off');  
      set(handles.popupmenu_P3,'Visible','off');  set(handles.popupmenu_P4,'Visible','off');  
      set(handles.popupmenu_gamutmap_L,'Visible','off');
      set(handles.popupmenu_gamutmap_R,'Visible','off');  
      set(handles.pushbutton_view_L,'Visible','off');  set(handles.pushbutton_view_R,'Visible','off');  
      set(handles.frame_1_2,  'Visible','off');  set(handles.frame_3_4,  'Visible','off');  
      set(handles.text2,      'Visible','off');  
      set(handles.text_B1,    'Visible','off');  set(handles.text_B2,    'Visible','off');
      set(handles.text_B3,    'Visible','off');  set(handles.text_B4,    'Visible','off');
      % set(handles.axes_arrow1,'Visible','off');  set(handles.axes_arrow2,'Visible','off');
      xlm = get(gca,'Xlim'); ylm = get(gca,'Ylim');  % Affected by zoom!
      while 1
         [xa,ya] = ginput(1);  ixa = round(xa); iya = round(ya);
         if ixa<xlm(1) | ixa>xlm(2) | iya<ylm(1) | iya>ylm(2)       % Terminate probe.
            set(handles.popupmenu_P1,'Visible','on');  set(handles.popupmenu_P2,'Visible','on');  
            set(handles.popupmenu_P3,'Visible','on');  set(handles.popupmenu_P4,'Visible','on');  
            set(handles.popupmenu_gamutmap_L,'Visible','on');
            set(handles.popupmenu_gamutmap_R,'Visible','on');  
            set(handles.pushbutton_view_L,'Visible','on');  set(handles.pushbutton_view_R,'Visible','on');  
            set(handles.frame_1_2,  'Visible','on');  set(handles.frame_3_4,  'Visible','on');  
            set(handles.text2,      'Visible','on');  
            set(handles.text_B1,    'Visible','on');  set(handles.text_B2,    'Visible','on');
            set(handles.text_B3,    'Visible','on');  set(handles.text_B4,    'Visible','on');
            % set(handles.axes_arrow1,'Visible','on');  set(handles.axes_arrow2,'Visible','on');
            axes(handles.axes3);  cla;  set(handles.axes3,'Visible','off');
            axes(handles.hxbot);  cla reset;  set(gca, 'Visible','off');
            axes(handles.hxtop);  cla reset;  set(gca, 'Visible','off');
            axes(handles.axes1); 
            if zoomsave  % Restore zoom
               handles.hzoom = 1;  zoom on;  set(handles.check_zoom,'Value',1);
            end
            break;  
         end  % escape.
         axes(handles.axes3);  cla;  % set(handles.axes3,'Visible','on');
	   	[deltaC,       deltaE] = colorerr(handles.samplab(iya,ixa,:),handles.reflab(iya,ixa,:),1);
 			[deltaC94,   deltaE94] = colorerr(handles.samplab(iya,ixa,:),handles.reflab(iya,ixa,:),2); 
		   [deltaCCMC, deltaECMC] = colorerr(handles.samplab(iya,ixa,:),handles.reflab(iya,ixa,:),3); 
         delta_L = min(handles.samplab(iya,ixa,1),100)-min(handles.reflab(iya,ixa,1),100);
         delta_C = sqrt(handles.samplab(iya,ixa,2).^2 + handles.samplab(iya,ixa,3).^2) - ...
                   sqrt(handles.reflab(iya,ixa,2).^2  + handles.reflab(iya,ixa,3).^2);
         temp1 = sqrt(handles.samplab(iya,ixa,2).^2 + handles.samplab(iya,ixa,3).^2) - ...
                 sqrt(handles.reflab(iya,ixa,2).^2  + handles.reflab(iya,ixa,3).^2);  % Delta-Chroma
         temp = (handles.samplab(iya,ixa,2)-handles.reflab(iya,ixa,2)).^2 + (handles.samplab(iya,ixa,3) ...
            -handles.reflab(iya,ixa,3)).^2- temp1.^2 + 20*eps;  % Sharma (1.45) errata  20*eps makes it > 0 always.
         delta_H = sqrt(temp);
         
         %Delta-angle calculation
         temp  = 180/pi*atan2( handles.reflab(iya,ixa,3), handles.reflab(iya,ixa,2)); 
         temp1 = 180/pi*atan2(handles.samplab(iya,ixa,3),handles.samplab(iya,ixa,2)); 
         temp2 = (handles.reflab(iya,ixa,1)<2 | handles.samplab(iya,ixa,1)<2 | ...
            max(handles.reflab(iya,ixa,2),handles.reflab(iya,ixa,3))<2 | ...
            max(handles.samplab(iya,ixa,2),handles.samplab(iya,ixa,3))<2 );  % 11/17/06
         delta_angle = temp-temp1;
         if temp2  delta_angle = 0;  end
         if delta_angle>200   delta_angle = delta_angle-360;  end
         if delta_angle<-200  delta_angle = delta_angle+360;  end
         
         dcolor{1} = sprintf('L*a*b* Inp =%6.2f,%6.2f,%6.2f; Out =%6.2f,%6.2f,%6.2f', ...
            handles.reflab(iya,ixa,:), handles.samplab(iya,ixa,:)); 
         dcolor{2} = sprintf(['\\DeltaE*_a_b =%6.2f; \\DeltaC*_a_b =%6.2f;  ' ...
            '\\DeltaE*_9_4 =%6.2f; \\DeltaC*_9_4 =%6.2f'], deltaE, deltaC, deltaE94, deltaC94 );
         dcolor{3} = sprintf('\\DeltaE*_C_M_C =%6.2f; \\DeltaC*_C_M_C =%6.2f', deltaECMC, deltaCCMC );
         dcolor{4} = sprintf('\\DeltaL* =%6.2f; \\DeltaC* =%6.2f; \\DeltaH* =%6.2f; \\DeltaHue =%6.1f^o', ...
            delta_L, delta_C, delta_H, delta_angle );
		   text(-2.06,.5, dcolor,'Fontsize',handles.dfz-2 ,'FontName','FixedWidth');  % x-value?????
         dsamp = icctrans(handles.samplab(iya,ixa,:), ['-t1 -i *LabD65 -o ' handles.montemp]);
         dref  = icctrans(handles.reflab(iya,ixa,:),  ['-t1 -i *LabD65 -o ' handles.montemp]);
         axes(handles.hxbot);  
         set(gca, 'position',[.006 .02 .034 .06],'Color',dsamp, ...
            'XTickLabel','','YTickLabel','', 'Visible','on', ...
            'Xcolor',dsamp, 'Ycolor',dsamp);  % [L B W H] Lower
         axes(handles.hxtop); 
         set(gca, 'position',[.006 .08 .034 .06],'Color',dref, ...
            'XTickLabel','','YTickLabel','', 'Visible','on', ...
            'Xcolor',dref, 'Ycolor',dref);  % [L B W H] Upper
         axes(handles.axes1);  set(handles.axes3,'Visible','off');  
      end
      handles.probeim = 0;   set(hObject, 'Value', 0);
   end
end
guidata(hObject, handles);  % Update handles structure
if handles.pltype~=11  % Do not redraw after probe.
   handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
end


% --- Executes on button press in pushbutton_printest.
function handles = pushbutton_printest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_printest (see GCBO)
sgca = gca;  %  sgcf = gcf, sgco = gco, sgcbo = gcbo  %%%%%%%%%%
handles.printest.on = 1;  % Turn Printest on.
handles.lastm = 0;  handles.lastn = 0;  % Ensure that plot updates.
handles.actival = [0 0];  % Set later by pushbutton_view_L.
if handles.pltype==11 | handles.pltype==12  % Don't allow Image color analysis.
   handles.pltype = 1;  set(handles.popupmenu_pltype,'Value', 1);
   handles = maketarg(hObject, handles);  % Recreate target (handles.ftarg).
   handles = initialize_mappings(hObject, eventdata, handles);  % Initialize the gamut mappings.
end

if handles.satvar<.995
   handles.satvar = 1;  % Reset saturation.
   handles = sat_update(handles,eventdata,1);  % Update saturation
end
if abs(handles.lightvar-0.5)>.005
   handles.lightvar = 0.5;  % Reset saturation.
   handles = sat_update(handles,eventdata,1);  % Update saturation
end
set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');

vsave = get(handles.popupmenu_gamutmap_L, 'Value');

set(handles.popupmenu_gamutmap_L, 'Value', 5);  % Gamut mapping: none. Do first.

if handles.cmyk(2)  % Profile 2 cannot be CMYK for Printest!  Troublesome...
   set(handles.popupmenu_P2, 'Value', 2);  % Set value *sRGB.
   handles.profile(2) = 2;  handles.cmyk(2) = 0;
   handles = geticc(handles.popupmenu_P2, handles, 2);
end

handles = popupmenu_gamutmap_L_Callback(handles.popupmenu_gamutmap_L, eventdata, handles);
if get(handles.popupmenu_P1, 'Value')==1  
   set(handles.popupmenu_P1, 'Value', 2);  % sRGB 
end
handles = popupmenu_P1_Callback(handles.popupmenu_P1, eventdata, handles); % Set window 1.
if get(handles.popupmenu_P2, 'Value')==1  
   set(handles.popupmenu_P2, 'Value', 2);  % sRGB 
end
handles = popupmenu_P2_Callback(handles.popupmenu_P2, eventdata, handles); % Set window 2.
nsave = handles.nprt;

ptout = printestg(handles);          % CALL PRINTESTG!  Ptout structure has critical output.
if isequal(ptout.title,'/\/\ cancelled /\/\')  % Cancelled
   handles.printest.on = 0;  
   set(handles.popupmenu_gamutmap_L, 'Value', vsave);  % Restore old value.
   return;  % Turn Printest off.
end
handles.prtitle = ptout.title;
handles.outarg2 = ptout.outarg2;     % Output!
handles.nprt    = ptout.nprt;
guidata(hObject, handles);  % Update handles structure before view (?)

% if (gca~=sgca)  disp(['gca changed before view_L: ' num2str(sgca) ' to ' num2str(gca)]);  end
handles = pushbutton_view_L_Callback(handles.pushbutton_view_L, eventdata, handles);  % Display left workflow.

set(handles.edit_printest,       'String', handles.prtitle);
set(handles.edit_printest,       'BackgroundColor', [1 .9 .9]);
set(handles.pushbutton_printest, 'BackgroundColor', [1 1 .9]);
set(handles.frame_printest,      'BackgroundColor', [.9 .6 .6]);
set(handles.frame_printest2,     'BackgroundColor', [.9 .6 .6]);
if (gca~=sgca)  disp(['gca changed at end: ' num2str(sgca) ' to ' num2str(gca)]);  end
% figure; image(handles.outarg2);  axis image;  %%%%%%%%%%%%%
handles.output = hObject;
guidata(hObject, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function edit_printest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_printest (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',handles.defbg);
end


function edit_printest_Callback(hObject, eventdata, handles)
% hObject    handle to edit_printest (see GCBO)


% --------------------------------------------------------------------
function Save_screen_Callback(hObject, eventdata, handles)  % Save screen
% hObject    handle to Save_screen (see GCBO)
readKeys = { 'gamut','','save_dir',   '',  [pwd filesep 'Results' filesep] };
readSett = inifile(handles.file_ini,'read',readKeys);   % READ GAMUTVISION.INI
handles.save_dir_name = readSett{1};   % directory for saving plots.
save_file_name = ['gv_' datestr(now,31)];
save_file_name = strrep(save_file_name,':','-');
save_file_name = strrep(save_file_name,' ','_');
[save_answer handles.save_dir_name save_file_name,handles.edfile,eddisp,handles.resultsave] = ...
   save_screen_generic(handles.resultsave, handles.save_dir_name, save_file_name, ...
   handles.edfile,'Save Gamutvision screen?',handles.fullname{1});
if strcmpi(save_answer,'Yes')
   fileplt = [handles.save_dir_name save_file_name];
   if isempty(strfind(fileplt,'.png'))  fileplt = [fileplt '.png'];  end
   writeKeys = {'gamut','','save_dir',   handles.save_dir_name; ...
                'gamut','','edfile',     handles.edfile; ...
                'gamut','','resultsave', handles.resultsave; ...
               };
   inifile(handles.file_ini,'write',writeKeys,'plain');  % Write new save directory.
   set(gcf,'PaperPositionMode','auto','InvertHardcopy','off');
   I = getframe(gcf); imwrite(I.cdata, fileplt);
   %getframe grabs current figure, and imwrite saves it.
   disp(['Plot written to ' fileplt]);
   if eddisp  % Open image in an editor. 
      if isempty(handles.edfile)  % Open default image editor.
         doscall = ['start "' datestr(now) '" "' fileplt];  % '.png"']; 
      else  % Open image editor of choice.
         doscall = ['start "' datestr(now) '" "' handles.edfile '" "' fileplt];  % '.png"']; 
      end
      % doscall = ['start /B "' handles.edfile '" "' fileplt];  % '.png"'];  % works, but gets default viewer...
      dos(doscall);  % disp(doscall);
   end
end
if handles.plt3d==1;  % 3D rotate does not work after save. Must restore.
   rotate3d on;  % axis vis3d;
end
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in checkbox_warning.
function checkbox_warning_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_warning (see GCBO)


% ---------------------------------------------
function handles = Monitor_profile_Callback(hObject, eventdata, handles)
% hObject    handle to Monitor_profile (see GCBO)
if ~handles.initialize  % Get monitor profile. Skip during initialization.
   [answer, newmon, new_intent] = gamutvision_mon_prof(0, ...
      handles.monprof, handles.iccfolder, handles.mon_intent, handles.rootdir);
   if strcmpi(answer,'OK')
      handles.monprof = newmon;
      handles.mon_intent = new_intent;
      writeKeys = {'gamut','','monprof',    handles.monprof; ...
                   'gamut','','mon_intent', handles.mon_intent  };
      inifile(handles.file_ini,'write',writeKeys,'plain');
   end
end 
% Deal with blanks in path name: Must store.
handles.montemp = handles.monprof;  % *sRGB or no blanks in name.
if findstr(handles.monprof, ' ')         % Blanks in file name.
   [pathname,name,ext,versn] = fileparts(handles.monprof);  % Read in.
   monfile = [name ext];    % File name only; Omit path.
   icctemp = strrep(monfile,' ','_');    % Replace blanks with underscores.
   handles.montemp = [tempdir icctemp];  % Matlab system temp path name to use (save)
   disp([handles.monprof '  -->  ' icctemp]);
   dos(['copy  "' handles.monprof '"  "' handles.montemp '"']);
end
guidata(hObject, handles);  % Update handles structure
if ~handles.initialize & (handles.outype==2 | handles.outype==4)
   handles = bigplot(handles, handles.pltin, handles.pltout, [0 1]);  % Update image.
end


% ---------------------------------------------
function Profile_folder_Callback(hObject, eventdata, handles)
% hObject    handle to Profile_folder (see GCBO)
[answer, newfolder] = gamutvision_profile_folder(0, handles.iccfolder);
if strcmpi(answer,'OK')
   handles.iccfolder = newfolder;
   writeKeys = {'gamut','','iccfolder', handles.iccfolder };
   inifile(handles.file_ini,'write',writeKeys,'plain');
end
guidata(hObject, handles);  % Update handles structure


% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)


% --- Save Settings in a named folder ---
function save_set_Callback(hObject, eventdata, handles)
readKeys = {'settings','','settingfolder', '',['settings' filesep]};
readSett = inifile(handles.file_ini,'read',readKeys);
settingfolder = readSett{1};
savesettings(handles.file_ini, settingfolder);
guidata(hObject, handles);
% hObject    handle to save_set (see GCBO)


% --- Retrieve settings ---
function retrieve_set_Callback(hObject, eventdata, handles)
readKeys = {'settings','','settingfolder', '',['settings' filesep]};
readSett = inifile(handles.file_ini,'read',readKeys);
settingfolder = readSett{1};
readsettings(handles.file_ini, settingfolder);
guidata(hObject, handles);
% hObject    handle to retrieve_set (see GCBO)


function view_set_Callback(hObject, eventdata, handles)  % View settings: Display gamutvision.ini.
systemroot = getenv('SystemRoot');
dini = ['start "' datestr(now) '" "' systemroot filesep 'notepad.exe" "' handles.file_ini '"'];  % Works compiled.
% dini = ['"%SystemRoot%\notepad.exe" "' handles.file_ini '"'];  % Doesn't work compiled.
disp(dini);  vini = dos(dini);


% --------------------------------------------------------------------
function Reset_defaults_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_defaults (see GCBO)
qbutton = questdlg('Do you want to reset settings to their default values?','Reset defaults', ...
   'Yes','No','Yes');
if (isequal(qbutton,'Yes'))
   delete(handles.file_ini);
   handles.dfz = get(0,'DefaulttextFontSize');
   writeKeys = {'gamut','','fontsize',handles.dfz};
   inifile(handles.file_ini,'write',writeKeys,'plain');
end
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in save_3DV.
function save_3DV_Callback(hObject, eventdata, handles)
if ~handles.plt3d
   hwarn = msgbox('A 3D plot must be displayed', 'Gamutvision warning','warn');
   pause(1);  close(hwarn);  return;
end
readKeys = {'settings','','settingfolder', '',['settings' filesep]};
readSett = inifile(handles.file_ini,'read',readKeys);
settingfolder = readSett{1};
[azim, elev] = view;  % view azimuth and angle.
camva = get(handles.axes1,'CameraViewAngle');  % Single value float.
camta = get(handles.axes1,'CameraTarget');     % Three value array; float.
% campo = get(handles.axes1,'CameraPosition');

if (~strcmp(settingfolder(end),filesep))
    settingfolder = [settingfolder filesep];  % '\' or '/' (filesep) at end.
end
[filename, pathname] = uiputfile([settingfolder '*.ini'],'Save 3D view (create a .ini file)');
if (filename==0)
  disp('No file selected. Try again.');
  return
end
if (~isdir(pathname))  % Test for existence of folder.
   dos(['mkdir "' pathname '"']);  % Create subdirectory Results if it doesn't exist.
end

% save  pathname in stdini (imatest.ini, gamutvision.ini, etc.) BEFORE copying.
writeKeys = {'settings','','settingfolder', pathname };
inifile(handles.file_ini,'write',writeKeys,'plain');

fullname=[pathname, filename];  % Full path name
dotz = findstr(filename,'.');   % Locate all dots in pathname. Check last dot.
if (length(dotz)>=1)
   filext = lower(filename(dotz(length(dotz))+1:length(filename)));  % File extension in lower case.
else
   filext = 'ini';
   filename = [filename '.ini'];  fullname = [fullname '.ini'];
end
if ~strcmpi(filext ,'ini')  % Add .ini for different extensions.
   filename = [filename '.ini'];  fullname = [fullname '.ini'];
   % warnmsg = ['WARNING: .ini file required. You selected ' filext];
   % warndlg(warnmsg, ['Unknown file format: ' filext]);
end

% Now write the data.
writeKeys = {'3DV','','azim',  azim;  ...
             '3DV','','elev',  elev;  ...
             '3DV','','camva', camva; ...
             '3DV','','camta', camta};
inifile([pathname filename],'write',writeKeys,'plain');
disp(['3D view stored on ' pathname filename]);
% hObject    handle to save_set (see GCBO)


% --- Executes on button press in retrieve_3DV.
function retrieve_3DV_Callback(hObject, eventdata, handles)
if ~handles.plt3d
   hwarn = msgbox('A 3D plot must be displayed', 'Gamutvision warning','warn');
   pause(1);  close(hwarn);  return;
end
readKeys = {'settings','','settingfolder', '',['settings' filesep]};
readSett = inifile(handles.file_ini,'read',readKeys);
settingfolder = readSett{1};

isalready = isdir(settingfolder);  % Test for existence of folder. Defaults to 'settings'
if (~isalready)
   hwarn = warndlg(['No saved settings in folder ''' settingfolder '''']);
   pause(1);  close(hwarn);
   dos(['mkdir "' settingfolder '"']);  % Create subdirectory if it doesn't exist.
   % return;
end

[filename, pathname] = uigetfile([settingfolder '*.ini'],'Retrieve 3D View (select .ini file)');
if (filename==0)
  disp('No file selected. Try again.');
  return
end
dotz = findstr(filename,'.');   % Locate all dots in pathname.
filext = lower(filename(dotz(length(dotz))+1:length(filename)));  % File extension in lower case.
readstat = 0;

% Check for common extensions for JPEG, TIFF images
if ~strcmpi(filext ,'ini')
   warnmsg = ['WARNING: .ini file required. You selected ' filext];
   warndlg(warnmsg, ['Unknown file format: ' filext]);
else
   writeKeys = {'settings','','settingfolder', pathname };
   inifile(handles.file_ini,'write',writeKeys,'plain');

   % Now read the data and set the view.
   readKeys = {'3DV','','azim',   '', '-30'; ...
               '3DV','','elev',   '', '20'; ...
               '3DV','','camva',  '', '10.3396'; ...
               '3DV','','camta',  '', '-10    -5    50'; ...
              };
   readSett = inifile([pathname, filename],'read',readKeys);   % Read .INI file
   azim =  readSett{1};
   elev =  readSett{2};
   camva = readSett{3};
   camta = readSett{4};
   axes(handles.axes1);  view([str2num(azim), str2num(elev)]);
   set(handles.axes1,'CameraViewAngle', str2num(camva), 'CameraTarget', str2num(camta));
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function about_Callback(hObject, eventdata, handles)
% hObject    handle to about (see GCBO)
global versname versnum
about_imatest(0,handles.rootimg,'Gamutvision');  % First arg numeric (was handles.evalver)
guidata(hObject, handles);


% --- Executes on button press in pushbutton_axis3d.  (More button)
function pushbutton_axis3d_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_axis3d (see GCBO)
if handles.pltype<3 | ((handles.pltype==11 | handles.pltype==12) & handles.difplt>=19)
	% Set 3d axis.
	axsave = handles.axis3d;
	[answer, axis3d, bk3d, lightpos, wire, pltres, ogl, tf, vol] = gamutvision_axis3d(handles.axis3d, ...
       handles.bk3d, handles.lightpos, handles.wire, handles.pltres, handles.OpenGL, ...
       handles.transface, handles.vol);
	if strcmpi(answer,'OK')
       handles.axis3d = axis3d;
       handles.bk3d = bk3d;
       handles.lightpos = lightpos;
       handles.wire = wire;
       handles.pltres = pltres;
       handles.OpenGL = ogl;
       handles.transface = tf;
       handles.vol = vol;
       guidata(hObject, handles);  % Update handles structure
       handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
       if handles.axis3d==4 & ~isequal(axsave,handles.axis3d)  % Reset size.
          view(3);  % view([-40,30]);  % view([-45,52]);  %  Low magnification???
          axis normal;  %  square?? % set(gca,'PlotBoxAspectRatio',[1 1 1]);
          handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
          view([-30,20]);  % view(3); 
          axis vis3d;
       end
       writeKeys = {'gamut','','axis3d',    handles.axis3d; ...
                    'gamut','','wire',      handles.wire; ...
                    'gamut','','bk3d',      handles.bk3d; ...
                    'gamut','','lightpos',  handles.lightpos; ...
                    'gamut','','openGL',    handles.OpenGL; ...
                    'gamut','','transface', handles.transface; ...
                    'gamut','','vol',       handles.vol; ...
                   };
       inifile(handles.file_ini,'write',writeKeys,'plain');
	end
end


% --- Executes during object creation, after setting all properties.
function popupmenu_HL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_HL (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',handles.defbg);
end


% --- Executes on selection change in popupmenu_HL.
function popupmenu_HL_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_HL (see GCBO)
if     handles.pltype==6
   handles.HLview   = get(hObject, 'Value');
   writeKeys = {'gamut','','HLview',    handles.HLview };
elseif (handles.pltype==11 | handles.pltype==12) & handles.difplt<19
   handles.colormap = get(hObject, 'Value');
   writeKeys = {'gamut','','colormap',  handles.colormap };
elseif (handles.pltype==11 | handles.pltype==12) & handles.difplt>=19
   handles.gamdisp = get(hObject, 'Value');
   writeKeys = {'gamut','','gamdisp',  handles.gamdisp };
end
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);
inifile(handles.file_ini,'write',writeKeys,'plain');


% --- Executes on button press in checkbox_HLinvert.
function checkbox_HLinvert_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_HLinvert (see GCBO)
if     handles.pltype==6
   handles.HLinvert = get(hObject,'Value');
elseif handles.pltype==11 | handles.pltype==12
   handles.cmapinv  = get(hObject,'Value');
end
guidata(hObject, handles);  % Update handles structure
handles = bigplot(handles, handles.pltin, handles.pltout, [1 0]);


% --- Executes during object creation, after setting all properties.
function slider_sat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_sat (see GCBO)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',handles.defbg);
end


% --- Executes on slider movement.
function slider_sat_Callback(hObject, eventdata, handles)
% hObject    handle to slider_sat (see GCBO)
if handles.pltype<=2 | handles.pltype==10
   set(handles.slider_sat, 'Min',0,'Max',1,   'SliderStep',[.05 .25]);
   handles.satvar = get(hObject,'Value');
   if handles.satvar>.99
      set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
      set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');
   else
      set(handles.slider_sat, 'BackgroundColor' ,[1 .8 .8]);
      set(handles.text_sat,   'ForegroundColor' ,[.6 0 0], 'FontWeight','bold');
   end
elseif handles.pltype==6
   set(handles.slider_sat, 'Min',.05,'Max',1,   'SliderStep',[.05/.95 .25/.95]);
   handles.satvar = get(hObject,'Value');
   if handles.satvar>.99
      set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
      set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');
   else
      set(handles.slider_sat, 'BackgroundColor' ,[1 .8 .8]);
      set(handles.text_sat,   'ForegroundColor' ,[.6 0 0], 'FontWeight','bold');
   end
elseif handles.pltype==4 | handles.pltype==5
   set(handles.slider_sat, 'Min',.05,'Max',.95, 'SliderStep',[.05/.9 .15/.9]);
   handles.lightvar = get(hObject,'Value');
   if abs(handles.lightvar-0.5)>.005
      set(handles.pushbutton_resv, 'Enable', 'on');
      set(handles.slider_sat, 'BackgroundColor' ,[1 .8 .8]);
      set(handles.text_sat,   'ForegroundColor' ,[.6 0 0], 'FontWeight','bold');
   else
      set(handles.pushbutton_resv, 'Enable', 'off');
      set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
      set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');
   end
end
guidata(hObject, handles);  % Update handles structure
handles = sat_update(handles,eventdata,0);  % Update saturation
handles = bigplot(handles, handles.pltin, handles.pltout, [1 1]);


function handles = sat_update(handles,eventdata,resetb);  % Update saturation (ftarg(:,577:832,:);
% Reset both values if resetb is set (set by printest).
if handles.pltype==11 | handles.pltype==12  return;  end  % Just to make sure!!!
if handles.pltype<=2 | handles.pltype==6
   set(handles.text_satvar, 'String', num2str(handles.satvar,2));
   set(handles.slider_sat,'Value',handles.satvar);  % Used when not called from slider_sat  button.
elseif handles.pltype==4 | handles.pltype==5
   set(handles.text_satvar, 'String', num2str(handles.lightvar,2));
   set(handles.slider_sat,'Value',handles.lightvar);
end
handles.satupdate = 1;  % Flag for updating saturation

% Recreate the key portion of ftarg.
% 3            D/2D difference  resetb for reset both.
if handles.pltype<=2 | handles.pltype==6 | handles.pltype==10 | resetb  
   range2 = [577:832];
   handles.ftarg(:,range2,1) = ones(1,256)'*linspace(0,1,256);  % (0:1/255:1);  % H
   handles.ftarg(:,range2,2) = handles.satvar;                  % S
   handles.ftarg(:,range2,3) = linspace(1,0,256)'*ones(1,256);  % L; high to low.
end
if handles.pltype==4 | handles.pltype==5 | resetb  % 2D saturation or difference
   range2 = [833:1088];
   handles.ftarg(:,range2,1) = ones(1,256)'*linspace(0,1,256);  % (0:1/255:1);  % H
   handles.ftarg(:,range2,2) = linspace(1,0,256)'*ones(1,256);  % L; high to low.
   handles.ftarg(:,range2,3) = handles.lightvar;                % S
end
handles.ftarg(:,range2,:) = hsl2rgb(handles.ftarg(:,range2,:));
guidata(handles.slider_sat, handles);  % Update handles structure

handles = update_L(handles,1,range2);  % Range2 speeds up updates.
handles = update_R(handles,1,range2);

handles.satupdate = 0;  % Flag for updating saturation
guidata(handles.slider_sat, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function popupmenu_bpc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_bpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',handles.defbg);
end


% --- Executes on button press in toggle_autorotate.
function toggle_autorotate_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_autorotate (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of toggle_autorotate
handles.autorot = get(hObject,'Value');  % Last value of setting-- use for reset.
axes(handles.axes1);
[azi, ele] = view;  % Initialize
if     handles.pltype==1 | handles.pltype==2 | ...
      ((handles.pltype==11 | handles.pltype==12) & handles.difplt>=19)
   [handles.azim,    handles.elev]    = view;  % Save settings.
elseif handles.pltype==6 & (handles.HLview==2 | handles.HLview==4)
   [handles.HL_azim, handles.HL_elev] = view;
end
i1 = 0;
if get(hObject,'Value')  
   handles.lastrot = -handles.lastrot;  % Rotation direction: toggle between -1 and 1.
   if handles.lastrot==1
      set(hObject,'BackgroundColor',[1,.8,.8],    'ForegroundColor',[.5 0 0], 'FontWeight','bold');
   else
      set(hObject,'BackgroundColor',[.95,.95,.6], 'ForegroundColor',[.3 .3 0], 'FontWeight','bold');
   end
end
while get(hObject,'Value')
   i1 = i1+handles.lastrot;  
   if     handles.pltype<3 | ((handles.pltype==11 | handles.pltype==12) & handles.difplt>=19)
      handles.azim = mod(azi+i1,360);
      view([handles.azim, ele]); pause(0.05);
   elseif handles.pltype==6 & (handles.HLview==2 | handles.HLview==4)
      handles.HL_azim = mod(azi+i1,360);
      view([handles.HL_azim, ele]); pause(0.02);
   end
end
% view(mod(azi+i1,360), ele);  % Makes a difference!  view(2) later for 3D views...
set(handles.toggle_autorotate,'Value',0, 'ForegroundColor',[0 0 0], 'FontWeight', ...
   'normal', 'BackgroundColor',handles.defbg);
guidata(hObject, handles);  % Update handles structure


