function varargout = readrecent(varargin)
% READRECENT M-file for readrecent.fig
%      READRECENT, by itself, creates a new READRECENT or raises the existing
%      singleton*.
%
%      H = READRECENT returns the handle to a new READRECENT or the handle to
%      the existing singleton*.
%
%      READRECENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in READRECENT.M with the given input arguments.
%
%      READRECENT('Property','Value',...) creates a new READRECENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before readrecent_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to readrecent_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help readrecent

% Last Modified by GUIDE v2.5 03-Nov-2007 09:30:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @readrecent_OpeningFcn, ...
                   'gui_OutputFcn',  @readrecent_OutputFcn, ...
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


% --- Executes just before readrecent is made visible.
function readrecent_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to readrecent (see VARARGIN)

handles.readin     = varargin{1};  % handles.readin.lastfile = full path name.
handles.path_ui    = varargin{2};  % Used only by Browse...
handles.browsetext = varargin{3};  % Used only by Browse...
set(handles.listfiles,  'string', handles.readin.fileonly);
handles.newnum = 1;
handles.addname = '';  % Used when Browse is added.
set(handles.listfiles,     'Value', handles.newnum);
set(handles.text_title,    'String', {'Select a recent file:'; handles.readin.subtitle});
set(handles.text_fullpath, 'String', 'Full path will be displayed here after selection has been made.');


%                            SET FONT SIZES.
% handles  % Use to list values and diagnose number of dimensions in call. Comment out normally.
dfz = get(0,'DefaulttextFontSize');  % Default font size.
set(handles.text_title,          'FontSize', dfz  );
set(handles.text_fullpath,       'FontSize', dfz-1);
set(handles.listfiles,           'FontSize', dfz-2);
set(handles.pushbutton_cancel,   'FontSize', dfz  );
set(handles.pushbutton_cont,     'FontSize', dfz+1);

% Choose default command line output for readrecent
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal');  %  'modal' or 'normal'

% UIWAIT makes Multicharts_special wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = readrecent_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.newnum;   % Selected file.
varargout{3} = handles.addname;  % Returned by Browse...

% The figure can be deleted now
delete(handles.figure1);



% --- Executes on button press in                      pushbutton_cont.
function pushbutton_cont_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cont (see GCBO)
handles.output = get(hObject,'String');
guidata(hObject, handles);  % Update handles structure

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);



% --- Executes on button press in                          pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
handles.output = get(hObject,'String');
guidata(hObject, handles);  % Update handles structure

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
handles.output = 'Cancel';
guidata(hObject, handles);  % Update handles structure

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes during object creation, after setting all properties.
function listfiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listfiles (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listfiles.
function listfiles_Callback(hObject, eventdata, handles)
% hObject    handle to listfiles (see GCBO)
tempnum = get(hObject,'Value');
hf = handles.readin.fileonly{tempnum};
if isempty(hf)
   hwarn = msgbox({'File name is empty.'; 'Make another choice.'}, 'Selection warning','warn');
   pause(1);  close(hwarn);
else
   handles.newnum = tempnum;
   set(handles.text_fullpath,'String',handles.readin.lastfile{tempnum});
end
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in pushbutton_browse.
function pushbutton_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browse (see GCBO)
[fn1, pathname] = uigetfile(handles.path_ui, handles.browsetext);
if (isequal(fn1,0) | isequal(pathname,0))   % Cancel read.
   return;  % Cancel read.
end
handles.addname = [pathname fn1];
handles.output = get(handles.pushbutton_cont,'String');  % 'OK'
guidata(hObject, handles);  % Update handles structure

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);
% readrecent_OutputFcn(hObject, eventdata, handles);  % Return values to calling function???


