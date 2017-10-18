function varargout = gamutvision_save(varargin)
%
%     Use:  [answer save_list filename] = gamutvision_save(old_save_list,old_dir_name);
%     old_save_list and save_list are cell arrays of length 5 containing 0
%     or 1.
%     Output cell (NLK):
% {1} 'Yes' or 'No' response to question
% {2} Cell array indicating which data to save.  Needs to be included in
%     input.
% {3} Save file name.
%
% GAMUTVISION_SAVE M-file for gamutvision_save.fig
%      GAMUTVISION_SAVE by itself, creates a new GAMUTVISION_SAVE or raises the
%      existing singleton*.
%
%      H = GAMUTVISION_SAVE returns the handle to a new GAMUTVISION_SAVE or the handle to
%      the existing singleton*.
%
%      GAMUTVISION_SAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMUTVISION_SAVE.M with the given input arguments.
%
%      GAMUTVISION_SAVE('Property','Value',...) creates a new GAMUTVISION_SAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gamutvision_save_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gamutvision_save_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gamutvision_save

% Last Modified by GUIDE v2.5 07-May-2006 11:23:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gamutvision_save_OpeningFcn, ...
                   'gui_OutputFcn',  @gamutvision_save_OutputFcn, ...
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

% --- Executes just before gamutvision_save is made visible.
function gamutvision_save_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gamutvision_save (see VARARGIN)

% Choose default command line output for gamutvision_save

handles.output = 'Yes';

dummy = varargin{1};  % Must be numeric?
handles.newdir = varargin{2};  % Results directory name
handles.savefile = varargin{3};  % Save file name
if (~strcmp(handles.newdir(length(handles.newdir)),filesep))
    handles.newdir = [handles.newdir filesep];  % '\' or '/' (filesep) at end.
end
handles.savedir = handles.newdir;  % Save directory to revert in case of error.

set(handles.show_dir,      'String',handles.newdir);  % Put current directory in text box.
set(handles.edit_filename, 'String',handles.savefile);  % Put current directory in text box.

%                            SET FONT SIZES.
% handles  % Use to list values and diagnose number of dimensions in call. Comment out normally.
dfz = get(0,'DefaulttextFontSize');  % Default font size.
set(handles.text_saveq,           'FontSize', dfz);
set(handles.pushbutton_yes,     'FontSize', dfz);
set(handles.pushbutton_cancel,     'FontSize', dfz);
set(handles.change_dir,      'FontSize', dfz-2);
set(handles.show_dir,        'FontSize', dfz-2);
set(handles.res_dir,         'FontSize', dfz-1);
set(handles.edit_filename,   'FontSize', dfz-2);
set(handles.file_name,       'FontSize', dfz-1);

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.

% uiposition(hObject)      %       POSITION THE WINDOW.
uipos_old(hObject)      %       POSITION THE WINDOW.

% Make the GUI modal
set(handles.figure1,'WindowStyle','normal');  %  ,'modal')  % Changed from 'modal' to 'normal'

% UIWAIT makes gamutvision_save wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gamutvision_save_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;  % 'Yes' or 'No' (for writing output files)
varargout{2} = handles.newdir;     % Directory for results.
varargout{3} = handles.savefile;  % Close figs after save.
% The figure can be deleted now
delete(handles.figure1);


% --- Executes on button press in pushbutton_yes.
function pushbutton_yes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_yes (see GCBO)
handles.output = get(hObject,'String');
% Create output folder if it hasn't changed and doesn't exist.
% if isequal(handles.savedir,handles.newdir) & ~(exist(handles.newdir)==7)
if isequal(handles.savedir,handles.newdir) & ~isdir(handles.newdir)
   dos(['mkdir  "' handles.newdir '"']);  % dos(['mkdir ' handles.newdir]);  % Create new folder.
   hmsg = msgbox(['Create folder ' handles.newdir ' for saving figure'],'Create folder');
   pause(1);  close(hmsg);
end
guidata(hObject, handles);  % Update handles structure

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in pushbutton_cancel.
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


% --- Executes on button press in change_dir.
function change_dir_Callback(hObject, eventdata, handles)
% hObject    handle to change_dir (see GCBO)
% change_dir is the Browse buttom. 
if ~isdir(handles.newdir)  % ~exist(handles.newdir)==7  % ERROR.
   dos(['mkdir  "' handles.newdir '"']);  % dos(['mkdir ' handles.newdir]);  % Create new folder.
   hmsg = msgbox(['Create folder ' handles.newdir ' for saving figure'],'Create folder');
   pause(1);  close(hmsg);
   guidata(hObject, handles);  % Update handles structure
end
tempdir = uigetfolder('Select a directory', handles.newdir);
% handles.newdir = uigetdir(handles.newdir,'Select a directory');  % Uses object; doesn't compile.
if ~isempty(tempdir)  handles.newdir = tempdir;
else                  handles.newdir = handles.savedir;  % Revert to the saved (good) dir.
end
if ~strcmp(handles.newdir(length(handles.newdir)),filesep)
    handles.newdir = [handles.newdir filesep];
end
set(handles.show_dir,'String',handles.newdir);  % Put current directory in text box.

% handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function show_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to show_dir (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function show_dir_Callback(hObject, eventdata, handles)
% hObject    handle to show_dir (see GCBO)
handles.newdir = get(hObject,'String');
if (~strcmp(handles.newdir(length(handles.newdir)),filesep))
    handles.newdir = [handles.newdir filesep];  % '\' or '/' (filesep) at end.
end

if ~isdir(handles.newdir)  % ~(exist(handles.newdir)==7)  % Create new folder?
   newf =questdlg(['Create ' handles.newdir ' ?'], 'Create new folder?','Yes','No','Yes');
   switch lower(newf),
      case ('yes')
         dos(['mkdir  "' handles.newdir '"']);  % Create new folder.
         handles.savedir = handles.newdir;
      otherwise
         handles.newdir = handles.savedir;  % Revert to saved (good) directory.
   end
   set(handles.show_dir,'String',handles.newdir);  % Put current directory in text box.
end
guidata(hObject, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
handles.savefile = get(hObject,'String');
guidata(hObject, handles);  % Update handles structure


