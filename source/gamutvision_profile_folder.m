function varargout = gamutvision_profile_folder(varargin)
%
%     Use:  [answer save_list filename] = gamutvision_profile_folder(old_save_list,old_dir_name);
%     old_save_list and save_list are cell arrays of length 5 containing 0
%     or 1.
%     Output cell (NLK):
% {1} 'Yes' or 'No' response to question
% {2} Cell array indicating which data to save.  Needs to be included in
%     input.
% {3} Save file name.
%
% GAMUTVISION_PROFILE_FOLDER M-file for gamutvision_profile_folder.fig
%      GAMUTVISION_PROFILE_FOLDER by itself, creates a new GAMUTVISION_PROFILE_FOLDER or raises the
%      existing singleton*.
%
%      H = GAMUTVISION_PROFILE_FOLDER returns the handle to a new GAMUTVISION_PROFILE_FOLDER or the handle to
%      the existing singleton*.
%
%      GAMUTVISION_PROFILE_FOLDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMUTVISION_PROFILE_FOLDER.M with the given input arguments.
%
%      GAMUTVISION_PROFILE_FOLDER('Property','Value',...) creates a new GAMUTVISION_PROFILE_FOLDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gamutvision_profile_folder_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gamutvision_profile_folder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gamutvision_profile_folder

% Last Modified by GUIDE v2.5 11-Mar-2006 07:41:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gamutvision_profile_folder_OpeningFcn, ...
                   'gui_OutputFcn',  @gamutvision_profile_folder_OutputFcn, ...
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

% --- Executes just before gamutvision_profile_folder is made visible.
function gamutvision_profile_folder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gamutvision_profile_folder (see VARARGIN)

% Choose default command line output for gamutvision_profile_folder

handles.output = 'OK';

dummy = varargin{1};  % Must be numeric?
handles.iccfolder = varargin{2};  % Results directory name
if (~strcmp(handles.iccfolder(length(handles.iccfolder)),filesep))
    handles.iccfolder = [handles.iccfolder filesep];  % '\' or '/' (filesep) at end.
end
handles.savedir = handles.iccfolder;  % Save directory to revert in case of error.

set(handles.show_dir,      'String',handles.iccfolder);  % Put current directory in text box.

%                            SET FONT SIZES.
% handles  % Use to list values and diagnose number of dimensions in call. Comment out normally.
dfz = get(0,'DefaulttextFontSize');  % Default font size.
set(handles.pushbutton1,     'FontSize', dfz);
set(handles.pushbutton2,     'FontSize', dfz);
set(handles.pushbutton_reset,'FontSize', dfz);
set(handles.change_dir,      'FontSize', dfz-2);
set(handles.show_dir,        'FontSize', dfz-2);
set(handles.res_dir,         'FontSize', dfz-1);

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

% UIWAIT makes gamutvision_profile_folder wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gamutvision_profile_folder_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;  % 'Yes' or 'No' (for writing output files)

varargout{2} = handles.iccfolder;     % Directory for results.

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');
guidata(hObject, handles);  % Update handles structure

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');
guidata(hObject, handles);  % Update handles structure

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


% --- Executes on button press in change_dir.
function change_dir_Callback(hObject, eventdata, handles)
% hObject    handle to change_dir (see GCBO)
if (~(exist(handles.iccfolder)==7))  % ERROR.  Will this compile???
   uiwait(warndlg(['Reverting to ' handles.savedir], ...
      'Folder not found'));
   handles.iccfolder = handles.savedir;  % Revert to saved (good) directory.
   set(handles.show_dir,'String',handles.iccfolder);  % Put current directory in text box.
   guidata(hObject, handles);  % Update handles structure
end
tempdir = uigetfolder('Select a directory',handles.iccfolder);
% handles.iccfolder = uigetdir(handles.iccfolder,'Select a directory');  % Uses object; doesn't compile.
if ~isempty(tempdir)  handles.iccfolder = tempdir;  end
if (~strcmp(handles.iccfolder(length(handles.iccfolder)),filesep))
    handles.iccfolder = [handles.iccfolder filesep];
end
set(handles.show_dir,'String',handles.iccfolder);  % Put current directory in text box.

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
handles.iccfolder = get(hObject,'String');
if (~strcmp(handles.iccfolder(length(handles.iccfolder)),filesep))
    handles.iccfolder = [handles.iccfolder filesep];  % '\' or '/' (filesep) at end.
end

if (~(exist(handles.iccfolder)==7))  % Create new folder?  Seems to compile.
   newf =questdlg(['Create ' handles.iccfolder ' ?'], 'Create new folder?','Yes','No','Yes');
   switch lower(newf),
      case ('yes')
         dos(['mkdir "' handles.iccfolder '"']);
         handles.savedir = handles.iccfolder;
      otherwise
         handles.iccfolder = handles.savedir;  % Revert to saved (good) directory.
   end
   set(handles.show_dir,'String',handles.iccfolder);  % Put current directory in text box.
end
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
handles.iccfolder = 'C:\Windows\System32\Spool\Drivers\Color\';
set(handles.show_dir,'String',handles.iccfolder);  % Put current directory in text box.
guidata(hObject, handles);  % Update handles structure


