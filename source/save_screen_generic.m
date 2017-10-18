function varargout = save_screen_generic(varargin)
%
%     Use:  [answer save_list filename] = save_screen_generic(old_save_list,old_dir_name);
%     old_save_list and save_list are cell arrays of length 5 containing 0
%     or 1.
%     Output cell (NLK):
% {1} 'Yes' or 'No' response to question
% {2} Cell array indicating which data to save.  Needs to be included in
%     input.
% {3} Save file name.
%
% SAVE_SCREEN_GENERIC M-file for save_screen_generic.fig
%      SAVE_SCREEN_GENERIC by itself, creates a new SAVE_SCREEN_GENERIC or raises the
%      existing singleton*.
%
%      H = SAVE_SCREEN_GENERIC returns the handle to a new SAVE_SCREEN_GENERIC or the handle to
%      the existing singleton*.
%
%      SAVE_SCREEN_GENERIC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVE_SCREEN_GENERIC.M with the given input arguments.
%
%      SAVE_SCREEN_GENERIC('Property','Value',...) creates a new SAVE_SCREEN_GENERIC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before save_screen_generic_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to save_screen_generic_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help save_screen_generic

% Last Modified by GUIDE v2.5 01-Mar-2009 08:54:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @save_screen_generic_OpeningFcn, ...
                   'gui_OutputFcn',  @save_screen_generic_OutputFcn, ...
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

% --- Executes just before save_screen_generic is made visible.
function save_screen_generic_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% Choose default command line output for save_screen_generic

handles.resultsave = varargin{1};  % Must be numeric?
handles.newdir     = varargin{2};  % Results directory name
handles.savefile   = varargin{3};  % Save file name
handles.edfile     = varargin{4};  % Image editor path name
handles.inpfile    = varargin{6};  % Input file: Use to find Results subfolder.
handles.eddisp     = 0;  % Display image in editor if checked.

if (~strcmp(handles.newdir(length(handles.newdir)),filesep))
    handles.newdir = [handles.newdir filesep];  % '\' or '/' (filesep) at end.
end
handles.savedir = handles.newdir;  % Save directory to revert in case of error.

if handles.resultsave
   [sfolder sfile sext] = fileparts(handles.inpfile);
   if ~isempty(sfolder)
      handles.newdir       = [sfolder filesep 'Results' filesep];
      set(handles.change_dir,'Enable','off');  set(handles.show_dir,'Enable','off');
   else
      handles.resultsave = 0;  % Don't use subfolder.
   end
end

set(handles.checkbox_results, 'Value', handles.resultsave);
set(handles.show_dir,      'String',handles.newdir);    % Put current directory in text box.
set(handles.edit_filename, 'String',handles.savefile);
set(handles.text_saveq,    'String',varargin{5});  % String with save instructions.
set(handles.image_edfile,  'String',handles.edfile);
%                            SET FONT SIZES.
% handles  % Use to list values and diagnose number of dimensions in call. Comment out normally.
dfz = get(0,'DefaulttextFontSize');  % Default font size.
set(handles.text_saveq,         'FontSize', dfz);
set(handles.pushbutton_yes,     'FontSize', dfz);
set(handles.pushbutton_cancel,  'FontSize', dfz-1);
set(handles.change_dir,         'FontSize', dfz-2);
set(handles.show_dir,           'FontSize', dfz-2);
set(handles.res_dir,            'FontSize', dfz-1);
set(handles.edit_filename,      'FontSize', dfz-2);
set(handles.file_name,          'FontSize', dfz-1);
set(handles.checkbox_open_img,  'FontSize', dfz-1);
set(handles.browse_image_editor,'FontSize', dfz-2);
set(handles.image_edfile,       'FontSize', dfz-2);
set(handles.checkbox_results,   'FontSize', dfz-1);

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.

uiposition(hObject)      %       POSITION THE WINDOW.

handles.output = 'Cancel';  % hObject;
set(gcf, 'CloseRequestFcn',{@pushbutton_cancel_Callback,handles});  % For fig file

% Make the GUI modal
set(handles.save_screen_generic,'WindowStyle','normal');  %  ,'modal')  % Changed from 'modal' to 'normal'

% UIWAIT makes save_screen_generic wait for user response (see UIRESUME)
uiwait(handles.save_screen_generic);


% --- Outputs from this function are returned to the command line.
function varargout = save_screen_generic_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;     % 'Yes' or 'No' (for writing output files)
varargout{2} = handles.newdir;     % Directory for results.
varargout{3} = handles.savefile;   % Close figs after save.
varargout{4} = deblank(handles.edfile);  % Image editor full path name. Remove trailing blanks.
varargout{5} = handles.eddisp;     % Display image in Image editor if 1.
varargout{6} = handles.resultsave; % Display image in Image editor if 1.
delete(handles.save_screen_generic);  % The figure can be deleted now


% --- Executes on button press in pushbutton_yes.
function pushbutton_yes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_yes (see GCBO)
handles.output = get(hObject,'String');
if ~isdir(handles.newdir)  % ~(exist(handles.newdir)==7)  % Create new folder? LAST CHANCE!
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
% % Create output folder if it hasn't changed and doesn't exist.
% if isequal(handles.savedir,handles.newdir) & ~isdir(handles.newdir)
%    dos(['mkdir  "' handles.newdir '"']);  % dos(['mkdir ' handles.newdir]);  % Create new folder.
%    hmsg = msgbox(['Create folder ' handles.newdir ' for saving figure'],'Create folder');
%    pause(1);  close(hmsg);
% end
guidata(hObject, handles);  % Update handles structure
uiresume(handles.save_screen_generic);  % Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
handles.output = 'Cancel';  % get(hObject,'String');
guidata(hObject, handles);  % Update handles structure
if isequal(get(handles.save_screen_generic, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.save_screen_generic);
else
    % The GUI is no longer waiting, just close it
    delete(handles.save_screen_generic);
end


% --- Executes on key press over save_screen_generic with no controls selected.
function save_screen_generic_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to save_screen_generic (see GCBO)
% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'Cancel';
    % Update handles structure
    guidata(hObject, handles);
    uiresume(handles.save_screen_generic);
end    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.save_screen_generic);
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


% --- Executes on button press in checkbox_open_img.
function checkbox_open_img_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_open_img (see GCBO)
handles.eddisp = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in browse_image_editor.
function browse_image_editor_Callback(hObject, eventdata, handles)
% hObject    handle to browse_image_editor (see GCBO)
% Image editor Browse button. Adapted from change_dir. 
pathui = [getenv('ProgramFiles') filesep '*.*']
[filename, pathname] = uigetfile(pathui,'Select an image editor.')
if (isequal(filename,0) | isequal(pathname,0))  % No input file returned.
   return;  % No changes
else
   handles.edfile = [pathname filename];
   set(handles.image_edfile,'String',handles.edfile);  % Put current directory in text box.
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function image_edfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image_edfile (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function image_edfile_Callback(hObject, eventdata, handles)
% hObject    handle to image_edfile (see GCBO)
handles.edfile = get(hObject,'String');  % Full path name
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in checkbox_results.
function checkbox_results_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_results (see GCBO)
handles.resultsave = get(hObject,'Value');  % Save in subfolder Results.
if handles.resultsave  % Save in Subfolder Results.
   [sfolder sfile sext] = fileparts(handles.inpfile);
   if ~isempty(sfolder)
      set(handles.change_dir,'Enable','off');  set(handles.show_dir,'Enable','off');
      handles.newdir       = [sfolder filesep 'Results' filesep];
      set(handles.show_dir, 'String',handles.newdir);    % Put current directory in text box.
   end
else
   set(handles.change_dir,'Enable','on');   set(handles.show_dir,'Enable','on');
end
guidata(hObject, handles);  % Update handles structure



