function varargout = gamutvision_mon_prof(varargin)
%
%     Use:  [answer save_list filename] = gamutvision_mon_prof(old_save_list,old_dir_name);
%     old_save_list and save_list are cell arrays of length 5 containing 0
%     or 1.
%     Output cell (NLK):
% {1} 'Yes' or 'No' response to question
% {2} Cell array indicating which data to save.  Needs to be included in
%     input.
% {3} Save file name.
%
% GAMUTVISION_MON_PROF M-file for gamutvision_mon_prof.fig
%      GAMUTVISION_MON_PROF by itself, creates a new GAMUTVISION_MON_PROF or raises the
%      existing singleton*.
%
%      H = GAMUTVISION_MON_PROF returns the handle to a new GAMUTVISION_MON_PROF or the handle to
%      the existing singleton*.
%
%      GAMUTVISION_MON_PROF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMUTVISION_MON_PROF.M with the given input arguments.
%
%      GAMUTVISION_MON_PROF('Property','Value',...) creates a new GAMUTVISION_MON_PROF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gamutvision_mon_prof_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gamutvision_mon_prof_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gamutvision_mon_prof

% Last Modified by GUIDE v2.5 13-Mar-2006 08:28:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gamutvision_mon_prof_OpeningFcn, ...
                   'gui_OutputFcn',  @gamutvision_mon_prof_OutputFcn, ...
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

% --- Executes just before gamutvision_mon_prof is made visible.
function gamutvision_mon_prof_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gamutvision_mon_prof (see VARARGIN)

% Choose default command line output for gamutvision_mon_prof

handles.output = 'OK';

dummy              = varargin{1};  % Must be numeric?
handles.monprof    = varargin{2};  % Results directory name
handles.iccfolder  = varargin{3};  % Folder to start search.
handles.mon_intent = varargin{4};  % Monitor rendering intent (1-4)
handles.rootdir    = varargin{5};  % Root directory for running geticcontents().
handles.savedir = handles.monprof;  % Save directory to revert in case of error.

set(handles.show_file,      'String',handles.monprof);     % Put current directory in text box.
set(handles.pop_mon_intent, 'Value', handles.mon_intent);  % Monitor rendering intent.

%                            SET FONT SIZES.
% handles  % Use to list values and diagnose number of dimensions in call. Comment out normally.
dfz = get(0,'DefaulttextFontSize');  % Default font size.
set(handles.pushbutton1,     'FontSize', dfz);
set(handles.pushbutton2,     'FontSize', dfz);
set(handles.pushbutton_reset,'FontSize', dfz);
set(handles.get_file,        'FontSize', dfz-2);
set(handles.show_file,       'FontSize', dfz-2);
set(handles.res_proftitle,   'FontSize', dfz-1);
set(handles.text_intent,     'FontSize', dfz-1);
set(handles.pop_mon_intent,  'FontSize', dfz-1);

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.

% uiposition(hObject)      %       POSITION THE WINDOW.
uipos_old(hObject)      %       POSITION THE WINDOW.

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal');  %  ,'modal')  % Changed from 'modal' to 'normal'

% UIWAIT makes gamutvision_mon_prof wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gamutvision_mon_prof_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
varargout{1} = handles.output;  % 'Yes' or 'No' (for writing output files)
varargout{2} = handles.monprof;     % Directory for results.
varargout{3} = handles.mon_intent;  % Monitor rendering intent.

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
handles.output = get(hObject,'String');
guidata(hObject, handles);  % Update handles structure

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
handles.output = get(hObject,'String');
guidata(hObject, handles);  % Update handles structure

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    


% --- Executes on button press in get_file.
function get_file_Callback(hObject, eventdata, handles)
% hObject    handle to get_file (see GCBO)
handles.monsave = handles.monprof;
path_ui = [handles.iccfolder '*.*'];  % Still  used for reference file input.
[refile refpath] = uigetfile(path_ui,'Monitor profile');
if ~(isequal(refile,0) | isequal(refpath,0))  % Input file returned.
   handles.monprof = [refpath refile];     % Full path name of input file.
end

[iccdesc, iccout] =geticcontents(handles.rootdir,handles.monprof);
if ~strcmpi(iccout.type,  'DisplayClass')
   handles.monprof = handles.monsave;
   hwarn = msgbox('Monitor profile must be a display profile', 'Bad profile choice','warn');
   pause(2);  close(hwarn);
   return;
end

set(handles.show_file,'String',handles.monprof);  % Put current directory in text box.
guidata(hObject, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function show_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to show_file (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function show_file_Callback(hObject, eventdata, handles)
% hObject    handle to show_file (see GCBO)
handles.monprof = get(hObject,'String');
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
handles.monprof = '*sRGB';
handles.mon_intent = 1;
set(handles.show_file,      'String',handles.monprof);     % Put current directory in text box.
set(handles.pop_mon_intent, 'Value', handles.mon_intent);  % Monitor rendering intent.
guidata(hObject, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function pop_mon_intent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_mon_intent (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in pop_mon_intent.
function pop_mon_intent_Callback(hObject, eventdata, handles)
% hObject    handle to pop_mon_intent (see GCBO)
handles.mon_intent = get(hObject,'Value');
guidata(hObject, handles);  % Update handles structure


