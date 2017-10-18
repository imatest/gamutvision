function varargout = gamutvision_axis3d(varargin)
%
%     Use:  [answer save_list filename] = gamutvision_axis3d(old_save_list,old_dir_name);
%     old_save_list and save_list are cell arrays of length 5 containing 0
%     or 1.
%     Output cell (NLK):
% {1} 'Yes' or 'No' response to question
% {2} Cell array indicating which data to save.  Needs to be included in
%     input.
% {3} Save file name.
%
% GAMUTVISION_AXIS3D M-file for gamutvision_axis3d.fig
%      GAMUTVISION_AXIS3D by itself, creates a new GAMUTVISION_AXIS3D or raises the
%      existing singleton*.
%
%      H = GAMUTVISION_AXIS3D returns the handle to a new GAMUTVISION_AXIS3D or the handle to
%      the existing singleton*.
%
%      GAMUTVISION_AXIS3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAMUTVISION_AXIS3D.M with the given input arguments.
%
%      GAMUTVISION_AXIS3D('Property','Value',...) creates a new GAMUTVISION_AXIS3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gamutvision_axis3d_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gamutvision_axis3d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gamutvision_axis3d

% Last Modified by GUIDE v2.5 02-Jan-2007 12:28:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gamutvision_axis3d_OpeningFcn, ...
                   'gui_OutputFcn',  @gamutvision_axis3d_OutputFcn, ...
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

% --- Executes just before gamutvision_axis3d is made visible.
function gamutvision_axis3d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gamutvision_axis3d (see VARARGIN)

% Choose default command line output for gamutvision_axis3d

handles.output    = 'OK';
handles.axis3d    = varargin{1};    % Must be numeric-- OK here
handles.bk3d      = varargin{2};    % Background color
handles.lightpos  = varargin{3};    % Light position: 'left' or 'right'
handles.wire      = varargin{4};    % Wire frame color
handles.pltres    = varargin{5};    % 3D Plot resolution
handles.OpenGL    = varargin{6};    % Use OpenGL renderer (may cause instability)
handles.transface = varargin{7};    % Transparency face color
handles.vol       = varargin{8};    % Gamut volumes
if strcmpi(handles.lightpos,'left')
   set(handles.radio_lightleft, 'Value', 1);  set(handles.radio_lightrt, 'Value', 0);
else
   set(handles.radio_lightleft, 'Value', 0);  set(handles.radio_lightrt, 'Value', 1);
end
set(handles.popupmenu_3d,     'Value', handles.axis3d);
set(handles.popupmenu_wire,   'Value', handles.wire);
set(handles.checkbox_openGL,  'Value', handles.OpenGL);
set(handles.checkbox_vol,     'Value', handles.vol);
set(handles.slider_bk,        'Value', handles.bk3d);  % 3D background color.
set(handles.text_bk,          'String',['Background ' num2str(round(handles.bk3d*100)/100,2)]);
set(handles.slider_transface, 'Value', handles.transface);  % 3D background color.
set(handles.text_transface,   'String',{'Wire frame'; ['transparency color ' ...
      num2str(round(handles.transface*100)/100,2)]});

%                            SET FONT SIZES.
% handles  % Use to list values and diagnose number of dimensions in call. Comment out normally.
dfz = get(0,'DefaulttextFontSize');  % Default font size.
set(handles.pushbutton1,     'FontSize', dfz);
set(handles.pushbutton2,     'FontSize', dfz);
set(handles.pushbutton_reset,'FontSize', dfz);
set(handles.text_3d,         'FontSize', dfz-1);
set(handles.text_wire,       'FontSize', dfz-1);
set(handles.text_bk,         'FontSize', dfz-1);
set(handles.text_transface,  'FontSize', dfz-1);
set(handles.text_3dhelp,     'FontSize', dfz-2);
set(handles.popupmenu_3d,    'FontSize', dfz-1);
set(handles.popupmenu_wire,  'FontSize', dfz-1);
set(handles.radio_lightleft, 'FontSize', dfz-1);
set(handles.radio_lightrt,   'FontSize', dfz-1);
set(handles.checkbox_openGL, 'FontSize', dfz-1);
set(handles.checkbox_vol,    'FontSize', dfz-1);
set(handles.text_openGL,     'FontSize', dfz-2);
set(handles.pushbutton_MW,   'FontSize', dfz-2);


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

% UIWAIT makes gamutvision_axis3d wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gamutvision_axis3d_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% Get default command line output from handles structure
varargout{1} = handles.output;  % 'Yes' or 'No' (for writing output files)

varargout{2} = handles.axis3d; 
varargout{3} = handles.bk3d; 
varargout{4} = handles.lightpos;
varargout{5} = handles.wire;
varargout{6} = handles.pltres;
varargout{7} = handles.OpenGL;
varargout{8} = handles.transface;
varargout{9} = handles.vol;

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
% handles.output = 'No';      % from sfr_save.m
% guidata(hObject, handles);  % from sfr_save.m
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


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
handles.axis3d = 4;
handles.wire = 1;
set(handles.popupmenu_3d,   'Value', handles.axis3d);
set(handles.popupmenu_wire, 'Value', handles.wire);
handles.bk3d = 0.3;
set(handles.text_bk,   'String', 'Background 0.3');
set(handles.slider_bk, 'Value' ,   0.3);  % 3D background color.
handles.lightpos = 'left';
set(handles.radio_lightleft, 'Value', 1);
set(handles.radio_lightrt,   'Value', 0);
handles.pltres = 3;  % Default display: Low res wireframe, smooth.
handles.OpenGL = 1;  % Turn on OpenGL.
set(handles.checkbox_openGL, 'Value', 1);
handles.vol    = 1;  % Turn on volume calculation.
set(handles.checkbox_vol,    'Value', 1);
handles.transface = 0.8;
set(handles.text_transface,   'String',{'Wire frame'; 'transparency color 0.8'});
set(handles.slider_transface, 'Value' ,   0.8);  % 3D background color.
guidata(hObject, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function popupmenu_3d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_3d (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu_3d.
function popupmenu_3d_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_3d (see GCBO)
handles.axis3d = get(hObject, 'Value');
guidata(hObject, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function slider_bk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_bk (see GCBO)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_bk_Callback(hObject, eventdata, handles)
% hObject    handle to slider_bk (see GCBO)
handles.bk3d = get(hObject,'Value');
set(handles.text_bk,'String',['Background ' num2str(round(handles.bk3d*100)/100,2)]);
guidata(hObject, handles);  % Update handles structure


% --- Executes during object creation, after setting all properties.
function slider_transface_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_transface (see GCBO)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_transface_Callback(hObject, eventdata, handles)
% hObject    handle to slider_transface (see GCBO)
handles.transface = get(hObject,'Value');
set(handles.text_transface,'String',{'Wire frame'; ['transparency color ' ...
      num2str(round(handles.transface*100)/100,2)]});
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in radio_lightleft.
function radio_lightleft_Callback(hObject, eventdata, handles)
% hObject    handle to radio_lightleft (see GCBO)
lt = get(hObject,'Value');
if lt  handles.lightpos = 'left';
else   handles.lightpos = 'right';  end
set(handles.radio_lightrt, 'Value', 1-lt);
guidata(hObject, handles);  % Update handles structure
% Hint: get(hObject,'Value') returns toggle state of radio_lightleft


% --- Executes on button press in radio_lightrt.
function radio_lightrt_Callback(hObject, eventdata, handles)
% hObject    handle to radio_lightrt (see GCBO)
lt = get(hObject,'Value');
if lt  handles.lightpos = 'right';
else   handles.lightpos = 'left';  end
set(handles.radio_lightleft, 'Value', 1-lt);
guidata(hObject, handles);  % Update handles structure
% Hint: get(hObject,'Value') returns toggle state of radio_lightrt


% --- Executes during object creation, after setting all properties.
function popupmenu_wire_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_wire (see GCBO)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu_wire.
function popupmenu_wire_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_wire (see GCBO)
handles.wire = get(hObject, 'Value');
guidata(hObject, handles);  % Update handles structure


% --- Executes on button press in checkbox_openGL.
function checkbox_openGL_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_openGL (see GCBO)
handles.OpenGL = get(hObject,'Value');
guidata(hObject, handles);  % Update handles structure

% --- Executes on button press in pushbutton_MW.
function pushbutton_MW_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_MW (see GCBO)
web('http://www.mathworks.com/support/tech-notes/1200/1201.html','-browser');


% --- Executes on button press in checkbox_vol.
function checkbox_vol_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_vol (see GCBO)
handles.vol = get(hObject,'Value');
guidata(hObject, handles);  % Update handles structure


