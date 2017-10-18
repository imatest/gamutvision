function varargout = about_imatest(varargin)
% ABOUT_IMATEST M-file for about_imatest.fig
%      ABOUT_IMATEST, by itself, creates a new ABOUT_IMATEST or raises the existing
%      singleton*.
%
%      H = ABOUT_IMATEST returns the handle to a new ABOUT_IMATEST or the handle to
%      the existing singleton*.
%
%      ABOUT_IMATEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABOUT_IMATEST.M with the given input arguments.
%
%      ABOUT_IMATEST('Property','Value',...) creates a new ABOUT_IMATEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before about_imatest_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to about_imatest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help about_imatest

% Last Modified by GUIDE v2.5 05-Nov-2005 08:13:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @about_imatest_OpeningFcn, ...
                   'gui_OutputFcn',  @about_imatest_OutputFcn, ...
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

% --- Executes just before about_imatest is made visible.
function about_imatest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to about_imatest (see VARARGIN)

global imavers versname versnum trialimit progname
% [handles.bitx, handles.basever, handles.syear, handles.smonth, handles.sdate,] ...
%    = parstatus(0,progname);  % 'devware-enabled-imatest');  % Do not decrement if 0.
handles.evalver = 0; % handles.syear<trialimit;   % 0 is full version. 1 or greater is evaluation.

% handles.evalver = varargin{1};
set(handles.version,        'String', ['Version: ' versnum '  ' versname]);  % An object...
handles.rootimg = varargin{2};
handles.progname = varargin{3};  % Program name: 'Imatest','Gamutvision', etc.

set(hObject, 'Name',['About ' handles.progname]);  % Set top of window.

dfz = get(0,'DefaulttextFontSize');  % Default font size.
set(handles.copyright,      'FontSize', dfz-2);
set(handles.version,        'FontSize', dfz+1);
set(handles.uses,           'FontSize', dfz-2);
% set(handles.purchasebutton, 'FontSize', dfz);
% set(handles.regbutton,      'FontSize', dfz);
set(handles.closebutton,    'FontSize', dfz);
set(handles.text_regto,     'FontSize', dfz);

% readKeys = {'registration','', 'Name',    '',  ''; ...
%             'registration','', 'Company', '', ''; ...
%             'registration','', 'E-mail',  '', '' };
appdata = getenv('APPDATA');
file_ini = [appdata filesep 'Imatest' filesep lower(handles.progname) '.ini'];  % .ini control file.
% readSett = inifile(file_ini,'read',readKeys);   % Read imatest.ini or gamutvision.ini. 
% handles.username = readSett{1};
% handles.company =  readSett{2};
% handles.email =    readSett{3};
% if ~(isempty(handles.username) & isempty(handles.company) & isempty(handles.email))
%    stregto = {'Registered to:'; handles.username; handles.company; handles.email};
% else
%    stregto = '';
% end
% set(handles.text_regto, 'String',stregto);
crt = get(handles.copyright, 'String');
crt{3} = ['Build  ' compiledate];
set(handles.copyright,  'String', crt);


% if handles.syear>20  % Program is registered
%    set(handles.regbutton,       'Enable','off');
%    set(handles.purchasebutton , 'Enable','off');
%    exdatenum = datenum(handles.syear,handles.smonth,handles.sdate);
%    todaynum  = datenum(date);
%    if exdatenum>todaynum
%       daytogo = [num2str(exdatenum-todaynum) ' days to go'];
%    else
%       daytogo = [num2str(todaynum-exdatenum) ' days since expiration'];
%    end
%    % ustring was used for add-ons. Long since removed, use for expiration date???
%    ustring = {'Expiration mm/dm/yyyy'; [num2str(handles.smonth,'%02d') '/' ...
%       num2str(handles.sdate,'%02d') '/' num2str(handles.syear)]; daytogo}; 
%    set(handles.uses,   'String',ustring);
% elseif handles.syear==0  % Evaluation expired
%    set(handles.uses,   'String',['Evaluation expired: Please purchase and register ' handles.progname]);
% else  % Evaluation version: Uses remaining
%    set(handles.uses,   'String',['Uses remaining:  ' num2str(handles.syear)]);
% end


% Choose default command line output for about_imatest
handles.output = hObject;

guidata(hObject, handles);  % Update handles structure

% Show the Logo
handles.imlogo = imread([handles.rootimg 'Gamutvision_logo_100W.png']);   % LOGO IMAGE
info = imfinfo([handles.rootimg 'Gamutvision_logo_100W.png']); % Determine the size of the image file
%axes(handles.BigLogobox);
set(handles.BigLogobox, 'Units', 'pixels');
logoloc = get(handles.BigLogobox, 'Position');
image(handles.imlogo);
set(handles.BigLogobox, 'Visible', 'off', 'Units', 'pixels', ...
   'Position', [logoloc(1:2) info.Width info.Height]);

uiposition(hObject)      %       POSITION THE WINDOW.
% uipos_old(hObject)      %       POSITION THE WINDOW.

% UIWAIT makes about_imatest wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% set(handles.axes1, ...
%     'Visible', 'off', ...
%     'YDir'   , 'reverse'       , ...
%     'XLim'   , get(Img,'XData'), ...
%     'YLim'   , get(Img,'YData')  ...
%     );

% Make the GUI modal  (NORMAL!)
set(handles.figure1,'WindowStyle','modal')  %  'modal')

% UIWAIT makes q13_save wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = about_imatest_OutputFcn(hObject, eventdata, handles)
global progname
% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = gcf;  % Handle to current figure.
% [handles.bitx, handles.basever, handles.syear, handles.smonth, handles.sdate,] = ...
%    parstatus(0,progname);  % Do not decrement if 0.
varargout{2} = ''  % handles.syear;  % Should year (>=2004) or # of remaining runs.
% m = handles.smonth, d = handles.sdate, y = handles.syear  % Use eventually to inform customers of expired versions


% % --- Executes on button press in regbutton.
% function regbutton_Callback(hObject, eventdata, handles)
% % hObject    handle to regbutton (see GCBO)
% global trialimit progname
% register_imatest;
% [handles.bitx, handles.basever, handles.syear, handles.smonth, handles.sdate,] = ...
%    parstatus(0,progname);  % 'devware-enabled-imatest');  % Do not decrement if 0.
% handles.evalver = handles.syear<trialimit;   % 0 is full version. 1 or greater is evaluation.
% 
% guidata(hObject, handles);  % Update handles structure
% 
% 
% % --- Executes on button press in purchasebutton.
% function purchasebutton_Callback(hObject, eventdata, handles)
% % hObject    handle to closebutton (see GCBO)
% % Purchase goes to a website; it should not close the current figure.
% web('http://www.imatest.com','-browser');


% --- Executes on button press in closebutton.
function closebutton_Callback(hObject, eventdata, handles)
% hObject    handle to closebutton (see GCBO)
close(gcf);

