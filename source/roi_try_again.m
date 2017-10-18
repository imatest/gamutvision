function varargout = roi_try_again(varargin)
% ROI_TRY_AGAIN M-file for roi_try_again.fig
%      ROI_TRY_AGAIN by itself, creates a new ROI_TRY_AGAIN or raises the
%      existing singleton*.
%
%      H = ROI_TRY_AGAIN returns the handle to a new ROI_TRY_AGAIN or the handle to
%      the existing singleton*.
%
%      ROI_TRY_AGAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_TRY_AGAIN.M with the given input arguments.
%
%      ROI_TRY_AGAIN('Property','Value',...) creates a new ROI_TRY_AGAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roi_try_again_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roi_try_again_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roi_try_again

% Last Modified by GUIDE v2.5 15-Jul-2006 12:12:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roi_try_again_OpeningFcn, ...
                   'gui_OutputFcn',  @roi_try_again_OutputFcn, ...
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

% --- Executes just before roi_try_again is made visible.
function roi_try_again_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roi_try_again (see VARARGIN)

% Choose default command line output for roi_try_again
rmsg = varargin{2};
im_example = varargin{3};
handles.helpurl = varargin{4};
im_example = ['images' filesep im_example];
im_axes = imread(im_example);  % Read the image.

handles.output = 'Try again';

set(handles.text_rmsg, 'String', rmsg);

dfz = get(0,'DefaulttextFontSize');  % Default font size.
set(handles.text1,           'FontSize', dfz);
set(handles.text2,           'FontSize', dfz);
set(handles.text_rmsg,       'FontSize', dfz-1);
set(handles.pushbutton_tryagain,     'FontSize', dfz+1);
set(handles.pushbutton_cancel,     'FontSize', dfz);
set(handles.pushbutton_help, 'FontSize', dfz);

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(0)  % nargin > 3)  % Don't use this.
    for index = 1:2:(nargin-3),
        if nargin-3==index break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

uiposition(hObject)      %       POSITION THE WINDOW.

Img=image(im_axes, 'Parent', handles.axes1);
% Img=image(IconData, 'Parent', handles.axes1);  % Original
axis image;

set(handles.figure1,'Name','Unsuitable ROI');

set(handles.axes1, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes roi_try_again wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = roi_try_again_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in pushbutton_tryagain.
function pushbutton_tryagain_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_tryagain (see GCBO)
handles.output = get(hObject,'String');
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
    guidata(hObject, handles);  % Update handles structure
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    


% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
web(handles.helpurl,'-browser');


