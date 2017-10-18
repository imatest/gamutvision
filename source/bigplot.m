function handles = bigplot(handles, mplt, nplt, pltflag)
% Big plots for Gamutvision.
% mplt is input (usually 1 or 3); nplt is output (usually 2 or 4).
% mplt and nplt can be 1-4.
% intarg and outarg are input, output targets.
% mplt and nplt are the corresponsing (input, output) color spaces.
% pltflag(1): Main figure. Always plot if 1. Plot only for new mplt or nplt if 0.
% pltflag(2): Upper right fig.  ""

handles.pltOK = 1;  % Indicates successful run. Set to 0 on failure.
if mplt==0 & nplt==0  handles.pltOK = 0;  return;  end  % Do nothing: profiles not yet selected.
daterun = datestr(now);  datesort = datestr(now,31);  % Date and time of run. datesort is sortable.
pltupdate = (pltflag | mplt~=handles.lastm | nplt~=handles.lastn);   % Change mplt or nplt. 2-dimensions.

handles.pltype = get(handles.popupmenu_pltype, 'Value');  % Plot type: affects buttons.

% Set handles.plt3d to enable rotation, where appropriate.
handles.plt3d = handles.pltype==1 | handles.pltype==2 | ...
   (handles.pltype==6 & (handles.HLview==2 | handles.HLview==4)) | ...
   ((handles.pltype==11 | handles.pltype==12) & handles.difplt>=19);

% Save view angle(s) regardless of current plot settings.
if handles.lastplot==1 | handles.lastplot==2 | ...
      ((handles.lastplot==11 | handles.lastplot==12) & handles.diflast>=19)
   % Move this if block 02/15/08 to fix bug apparently introduced with autorotate.
   [handles.azim,    handles.elev]    = view;  % Save settings.
end

if handles.lastplot==6 & (handles.lastHL==2 | handles.lastHL==4)
   [handles.HL_azim, handles.HL_elev] = view; 
end

if handles.plt3d
   set(handles.toggle_autorotate, 'Visible', 'on',  'Value', 0);
else
   view(2);  % Set for 2D view: az = 0, el = 90
   set(handles.toggle_autorotate, 'Visible', 'off', 'Value', 0);
end

pltsame = 0;  % Default (no zoom)
if handles.pltype==handles.lastplot & pltupdate(1) & ...
      ((handles.pltype~=6 & handles.pltype~=10) | ...
      (handles.pltype==6 & handles.HLview==handles.lastHL & ...
      (~handles.plt3d | (handles.plt3d & handles.difplt==handles.diflast))) | ...
      (handles.pltype==10 & handles.bwplot==handles.bwlast))
   % Add option for saving zoom factor when keeping plot type. Use xlim, ylim for 2D.
   pltsame = 1;  % Indicates same plot as previous.  Needed because handles.lastplot is reset.
	axes(handles.axes1);
   if handles.plt3d
      camva = get(handles.axes1,'CameraViewAngle');  % Original values to save
      camta = get(handles.axes1,'CameraTarget');
      campo = get(handles.axes1,'CameraPosition');  % Seems to mess up axes position if applied later.
   else
      zoomlims = [xlim, ylim];  % Limits of previous plot (functions).
   end
end
set(handles.slider_sat, 'Visible','off');
set(handles.text_sat,   'Visible', 'off');  set(handles.text_satvar,  'Visible', 'off');
set(handles.text_vol,   'Visible','off');

if handles.pltype~=6
   set(handles.popupmenu_HL,      'Visible', 'off')
   set(handles.checkbox_HLinvert, 'Visible', 'off')
end
if handles.pltype<7 | handles.pltype==11 | handles.pltype==12   % Rescale button.
   set(handles.pushbutton_resc,   'Enable','on');
else                 
   set(handles.pushbutton_resc,   'Enable','off');
end 
   
if handles.pltype>2    % Disable buttons in the plot control area.
	set(handles.pushbutton_resv,   'Enable','off');
	set(handles.pushbutton_topv,   'Enable','off');
	set(handles.text_transp,       'Visible','off');
	set(handles.slider_transp,     'Visible','off');
	set(handles.text_vector,       'Visible','off');
	set(handles.slider_vector,     'Enable','off', 'Visible','off');
	set(handles.popupmenu_pltres,  'Enable','off');
	set(handles.check_light,       'Visible','off');
   set(handles.pushbutton_axis3d, 'Visible','off');
end

if handles.pltype<3    % Enable and set buttons for 3D plots.
   if handles.vol  set(handles.text_vol, 'Visible','on');  end
	set(handles.pushbutton_resv,  'Enable', 'on', 'String','Reset view');
	set(handles.pushbutton_topv,  'Enable', 'on');
   set(handles.slider_transp,    'Visible', 'on', 'Value',  1-handles.transp);  % Opacity = 1-transparency.
   set(handles.slider_transp,    'TooltipString','Wireframe transparency');
   set(handles.text_transp,      'Visible', 'on');
   if handles.pltres==5 | handles.pltres==6 | handles.pltres==8  % No wire frame
      set(handles.slider_transp, 'Visible', 'off');  set(handles.text_transp, 'Visible', 'off');
   end
   set(handles.text_transp,      'String', ['Transparency ' num2str(1-handles.transp,2)]);
   set(handles.slider_vector,    'Enable', 'on', 'Visible', 'on');
   set(handles.slider_vector,    'Value',  handles.vector);
   set(handles.text_vector,      'Visible', 'on');
   set(handles.text_vector,'String',['Vectors ' num2str(round(handles.vector*100)/100,2)]);
   set(handles.check_light,      'Visible', 'on', 'Value',  handles.radio_ltsave, ...
      'String', 'Light', 'TooltipString', 'Lighting on solid 3D image');
   set(handles.popupmenu_pltres, 'Enable', 'on', 'Value',  handles.pltres);  % Saved value.
   pltlist = {'Low res wireframe/flat'; 'High res wireframe/flat'; 'Low res wireframe/smooth'; ...
      'High res wireframe/smooth'; 'No wireframe/flat'; 'No wireframe/smooth'; ...
   };  % 'Lr wf/smooth; Delta-L'; 'No wf/smooth; Delta-L' };  % Plot resolution window
   set(handles.popupmenu_pltres, 'String', pltlist);
   set(handles.pushbutton_axis3d, 'Visible', 'on')
   if handles.pltype<2 & ~handles.printest.on  % Do not make visible during printest.
      set(handles.slider_sat, 'Min',0,'Max',1,   'SliderStep',[.05 .25]);  % set 'Value' afterwards!
      set(handles.slider_sat,  'Visible', 'on','Value', handles.satvar);  % Saturation slider
      set(handles.text_sat,    'Visible', 'on', 'String','Saturation');
      set(handles.text_satvar, 'Visible', 'on', 'String', num2str(handles.satvar,2));
      if handles.satvar>.99
         set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
         set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');
      else
         set(handles.slider_sat, 'BackgroundColor' ,[1 .8 .8]);
         set(handles.text_sat,   'ForegroundColor' ,[.6 0 0], 'FontWeight','bold');
      end
   end
elseif handles.pltype==3 | handles.pltype==4  % a*b* plots
   set(handles.slider_vector,    'Enable', 'on', 'Visible', 'on');
   set(handles.slider_vector,    'Value',  handles.vectab);
   set(handles.text_vector,      'Visible', 'on');
   set(handles.text_vector,'String',['Vectors ' num2str(round(handles.vectab*100)/100,2)]);
   set(handles.popupmenu_pltres, 'Enable', 'on');
   if     handles.pltype==3
      set(handles.popupmenu_pltres, 'Value',  handles.lab2dg);    % Set to saved value.
      pltlist = {'View markers'; 'No markers' };  % View markers
   elseif handles.pltype==4
      set(handles.popupmenu_pltres, 'Value',  handles.lab2dv);    % Set to saved value.
      pltlist = {'Light view'; 'Dark view'; 'Light view, no markers'; ...
         'Dark view, no markers' };  % View brightness, markers
   end
   set(handles.popupmenu_pltres, 'String', pltlist);
   
elseif handles.pltype==5 | handles.pltype==6| handles.pltype==11 | handles.pltype==12  % Difference plots
   if handles.pltype<=6 & handles.difplt>16  handles.difplt = 1;  end  % was ==5
   set(handles.popupmenu_pltres, 'Enable', 'on', 'Value',  handles.difplt);  % Saved value.
   pltlist = {'Delta-E*ab'; 'Delta-C*ab'; 'Delta-E*94'; 'Delta-C*94'; 'Delta-E*CMC'; ...
      'Delta-C*CMC'; 'Delta-E 00'; 'Delta-C 00';; 'Delta-L*'; 'Delta-Chroma'; ...
      'Delta-|Hue distance|'; 'Delta-Hue angle'; 'L* (input)'; 'L* (output)'; ...
      'Chroma (input)'; 'Chroma (output)' };  % ; 'dL*(output) / dL*(input)' };  % for finderr
   if handles.pltype==6  % 3D/2D HL
      if ~handles.printest.on  % Do not make visible during printest.
         set(handles.slider_sat, 'Min',.05,'Max',1,   'SliderStep',[.05/.95 .25/.95]);  % set 'Value' afterwards!
         set(handles.slider_sat,  'Visible', 'on','Value', handles.satvar);  % Saturation slider
         set(handles.text_sat,    'Visible', 'on', 'String','Saturation');
         set(handles.text_satvar, 'Visible', 'on', 'String', num2str(handles.satvar,2));
         handles.satvar = max(handles.satvar,.05);
         if handles.satvar>.99
            set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
            set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');
         else
            set(handles.slider_sat, 'BackgroundColor' ,[1 .8 .8]);
            set(handles.text_sat,   'ForegroundColor' ,[.6 0 0], 'FontWeight','bold');
         end
      end
      set(handles.slider_transp,     'Visible', 'on', 'Value',   handles.hslight);  % HSL image lightness.
      set(handles.slider_transp,     'TooltipString','Background image lightness');
		set(handles.text_transp,       'Visible', 'on');
      set(handles.text_transp,       'String', ['Image lightness ' num2str(handles.hslight,2)]);
      set(handles.popupmenu_HL,      'Visible','on', 'Value', handles.HLview);
      set(handles.popupmenu_HL,      'TooltipString','Select 3D/2D, H-L/H*L* display');
      set(handles.popupmenu_HL,      'String', {'2D HL (HSL) axes'; '3D HL (HSL) axes'; ...
            '2D H*L* axes'; '3D H*L* axes'; });
      if handles.HLview==2 | handles.HLview==4  % 3D  plot
         set(handles.checkbox_HLinvert, 'Visible','on', 'Value', handles.HLinvert);
         set(handles.checkbox_HLinvert, 'TooltipString','Invert display');
    	   set(handles.pushbutton_topv,   'Enable', 'on');
         set(handles.check_light,       'Visible', 'on', 'Value',  handles.radio_ltsave, ...
            'String', 'Light', 'TooltipString', 'Lighting on solid 3D image');
		   set(handles.pushbutton_resv,   'Enable', 'on', 'String','Reset view');
      else
         set(handles.checkbox_HLinvert, 'Visible','off');
      end
      
   elseif handles.pltype==11 | handles.pltype==12  % Image color difference
      % First 15 used for finderr. More added (not differences).
      pltlist = {'Delta-E*ab'; 'Delta-C*ab'; 'Delta-E*94'; 'Delta-C*94'; 'Delta-E*CMC'; ...
         'Delta-C*CMC'; 'Delta-E 00'; 'Delta-C 00'; 'Delta-L*'; 'Delta-Chroma'; ...
         'Delta-|Hue distance|'; 'Delta-Hue angle'; 'L* (input)'; 'L* (output)'; ...
         'Chroma (input)'; 'Chroma (output)'; 'Input > Monitor'; 'Output > Monitor'; ...
         'Input 3D cluster'; 'Output 3D Cluster'; 'Input-Output 3D Vectors'; ...
         'Output-Input 3D Vectors'; };
      if handles.difplt>=19  % 3D cluster and vector plots.
         set(handles.popupmenu_HL,      'Visible','on', 'Value', handles.gamdisp);  % Change to saved value
         set(handles.popupmenu_HL,      'String', {'Vectors only'; 'Input wireframe'; ...
            'Output wireframe'; });  % 'Output solid'; });
         set(handles.popupmenu_HL,      'TooltipString','Color space gamut display');
	      set(handles.pushbutton_resv,   'Enable', 'on', 'String','Reset view');
	      set(handles.pushbutton_topv,   'Enable', 'on');
         set(handles.pushbutton_axis3d, 'Visible', 'on');
         set(handles.slider_transp,     'Visible', 'on', 'Value',  1-handles.transimg);  % Opacity = 1-transparency.
         set(handles.slider_transp,     'TooltipString','Wireframe transparency');
         set(handles.text_transp,       'Visible', 'on');
         set(handles.text_transp,       'String', ['Transparency ' num2str(1-handles.transimg,2)]);
         if handles.gamdisp==3
            set(handles.text_transp, 'Enable', 'on');  set(handles.slider_transp, 'Enable', 'on');
         else
            set(handles.text_transp, 'Enable', 'off');  set(handles.slider_transp, 'Enable', 'off');
         end

     else
         set(handles.popupmenu_HL,      'Visible','on', 'Value', handles.colormap);
         set(handles.popupmenu_HL,      'String', {'WYRMBK color map'; 'WYGCBK color map'; ...
            'Jet color map'; 'Grayscale color map'; });
         set(handles.popupmenu_HL,      'TooltipString','Select color map for pseudocolor display');
         set(handles.checkbox_HLinvert, 'Visible','on', 'Value', handles.cmapinv);
         set(handles.checkbox_HLinvert, 'TooltipString','Invert color map');
		   set(handles.check_light,       'Visible', 'on', 'Value',  handles.probeim, 'String', 'Probe', ...
		      'TooltipString', 'Probe the image. Click outside the image to turn probe off');  % Comment during dev
      end
   end
   set(handles.popupmenu_pltres, 'String', pltlist);
   
elseif handles.pltype==7 | handles.pltype==8  % xy or uv plots
	set(handles.check_light,      'Visible', 'on', 'Value',  handles.xybdry, ...
      'String', 'Wavelth', 'TooltipString', 'Display wavelengths at spectrum boundary');
   set(handles.popupmenu_pltres, 'Enable', 'on');
   set(handles.popupmenu_pltres, 'Value',  handles.xycolor);  % xy plot color: pale or full.
   pltlist = {'Lightened view'; 'Normal (saturated) view'; ...
      'Lightened/gamut boundaries'; 'Normal/gamut boundaries' };
   set(handles.popupmenu_pltres, 'String', pltlist);
   
elseif handles.pltype==9  % 2D HSL plot
	set(handles.check_light,      'Visible', 'on', 'Value',  handles.hsldelta, 'String', 'Delta', ...
	   'TooltipString', 'Display difference contours');
   set(handles.slider_transp,    'Visible', 'on');
   set(handles.slider_transp,    'Value',   handles.hslight);  % HSL image lightness.
   set(handles.slider_transp,    'TooltipString','HSL image lightness');
	set(handles.text_transp,      'Visible', 'on');
   set(handles.text_transp,      'String', ['Image lightness ' num2str(handles.hslight,2)]);
   set(handles.popupmenu_pltres, 'Enable', 'on');
   set(handles.popupmenu_pltres, 'Value', handles.hslplot);  % HSL plot type (H, S, or L).
   pltlist = {'Hue (H) coutours  S=1'; 'Saturation (S) coutours  S=1'; ...
      'Lightness (L) coutours  S=1'; 'Hue (H) coutours  L=0.5'; 'Saturation (S) coutours  L=0.5'; ...
      'Lightness (L) coutours  L=0.5' };
   set(handles.popupmenu_pltres, 'String', pltlist);
   
elseif handles.pltype==10  % B&W density plot
   if handles.bwplot==4  % Output vs. input L*
      set(handles.slider_sat, 'Min',0,'Max',1,   'SliderStep',[.05 .25]);  % set 'Value' afterwards!
      set(handles.slider_sat,  'Visible', 'on','Value', handles.satvar);  % Saturation slider
      set(handles.text_sat,    'Visible', 'on', 'String','Saturation');
      set(handles.text_satvar, 'Visible', 'on', 'String', num2str(handles.satvar,2));
      if handles.satvar>.99
         set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
         set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');
      else
         set(handles.slider_sat, 'BackgroundColor' ,[1 .8 .8]);
         set(handles.text_sat,   'ForegroundColor' ,[.6 0 0], 'FontWeight','bold');
      end
   end
   set(handles.popupmenu_pltres, 'Enable', 'on');
   set(handles.popupmenu_pltres, 'Value', handles.bwplot);  % B&W plot type.
   pltlist = {'Density vs Log Pixels'; 'Output vs Input Density'; ...
      'Output vs Input Luminance'; 'Output vs Input L* a* b* c*' };
   set(handles.popupmenu_pltres, 'String', pltlist);
end

if (handles.pltype==4 | handles.pltype==5) & ~handles.printest.on  % Do not make visible during printest.
   set(handles.slider_sat, 'Min',.05,'Max',.95, 'SliderStep',[.05/.9 .15/.9]);  % set 'Value' afterwards!
   set(handles.slider_sat,  'Visible', 'on', 'Value', handles.lightvar);  % Saturation slider
   set(handles.text_satvar, 'Visible', 'on', 'String', num2str(handles.lightvar,2));
   set(handles.text_sat,    'Visible', 'on', 'String','HSL Lightness (L)');
	set(handles.pushbutton_resv, 'String','Reset L=0.5');
   if abs(handles.lightvar-0.5)>.005
      set(handles.pushbutton_resv, 'Enable', 'on');
      set(handles.slider_sat, 'BackgroundColor' ,[1 .8 .8]);
      set(handles.text_sat,   'ForegroundColor' ,[.6 0 0], 'FontWeight','bold');
   else
      set(handles.slider_sat, 'BackgroundColor' ,[.9 .9 .9]); 
      set(handles.text_sat,   'ForegroundColor' ,[0 0 0], 'FontWeight','normal');
   end
end

%         FIND INPUT AND OUTPUT IMAGES. mplt (inp) and nplt (out) can be 1-4.

infind = 0;  outfind = 0;  % Input, output targets found.
intarg = .8*ones(256,1088,3);  outarg = intarg;  % Empty (light gray) arrays.
if mplt==1 | mplt==3  % Input plot
   if mplt==3 & handles.profile(3)==8 & ~isempty(handles.outarg2)
      infind = 1;  intarg = double(handles.outarg2);  % Input to 3 is the output of 2.
   elseif ~isempty(handles.ftarg)
      infind = 1;
      if handles.pltype==11
         intarg = handles.ftarg2;
      elseif handles.pltype==12  % Must map from *LabD65. Use mplt?????
         intarg = icctrans(handles.ftarg2, ['-t1 -i *LabD65 -o ' handles.fulltemp{mplt}]);
      else  intarg = handles.ftarg;  end
   end
elseif mplt==2
   if ~isempty(handles.outarg2)
      infind = 1;  intarg = double(handles.outarg2);
   end
elseif mplt==4
   if ~isempty(handles.outarg4)
      infind = 1;  intarg = double(handles.outarg4);
   end
end

if nplt==1 | nplt==3  % Output plot
   if nplt==3 & handles.profile(3)==8 & ~isempty(handles.outarg2)
      outfind = 1;  outarg = double(handles.outarg2);  % Input to 3 is the output of 2.
   elseif ~isempty(handles.ftarg)
      % display('nplt = 3: no output target.');  handles.pltOK = 0;  return;
      outfind = 1;
      if handles.pltype==11
         outarg = handles.ftarg2;
      elseif handles.pltype==12  % Must map from *LabD65. Use nplt???
         outarg = icctrans(handles.ftarg2, ['-t1 -i *LabD65 -o ' handles.fulltemp{nplt}]);
      else  outarg = handles.ftarg;  end
   end
elseif nplt==2
   if ~isempty(handles.outarg2)
      outfind = 1;  outarg = double(handles.outarg2);
   end
elseif nplt==4
   if ~isempty(handles.outarg4)
      outfind = 1;  outarg = double(handles.outarg4);
   end
end

if infind==0 & outfind==0
   display('No input or output target.');  handles.pltOK = 0;  return;
end

%                  INPUT AND OUTPUT PROFILES: Important for Soft proofing!
handles.inprof  = handles.fulltemp{mplt};  % Input  profile file name
handles.outprof = handles.fulltemp{nplt};  % Output profile file name 
if (nplt==2 & handles.intent_L>=7) | (nplt==4 & handles.intent_R>=7)
   handles.outprof = handles.monprof;  % The output profile is the monitor profile
end
if (mplt==2 & handles.intent_L>=7) | (mplt==4 & handles.intent_R>=7)
   handles.inprof  = handles.monprof;  % The input  profile is the monitor profile
end

%                   DISPLAY INPUT OR OUTPUT IMAGE (SOFT PROOFING HERE).
if pltupdate(2)
   sz_out = size(outarg);
	axes(handles.axes2);  cla;
	if     handles.pltype==3 | (handles.pltype==9 & handles.hslplot<4) | handles.pltype==13
      handles.plotzone = [1:256];     % Gamut maps (S = 1).
	elseif handles.pltype==4 | handles.pltype==5  % 2D
      handles.plotzone = [833:1088];  % Sat maps (L = 0.5).
   elseif handles.pltype<=2 | handles.pltype==6           % 3D gamut or comparisons
      handles.plotzone = [577:832];
	elseif handles.pltype==7 | handles.pltype==8 | (handles.pltype==9 & handles.hslplot>3)
      handles.plotzone = [257:512];   % Sat maps (L = 0.5).
	elseif handles.pltype==10          % B&W tonal response.
      handles.plotzone = [513:576];
   elseif handles.pltype==11 | handles.pltype==12          % Analyze image
      handles.plotzone = [1:sz_out(2)];
	end
   oldfig = gcf; 
   if length(sz_out)<3
      hwarn = msgbox('B&W image: cannot proceed', 'B&W image warning','warn');
      pause(2);  close(hwarn);
      return;
   end
   
	if handles.outype==1      % Display OUTPUT as is (no transformation).
       if sz_out(3)==4  % CMYK file
          pltdata = icctrans(outarg(:,handles.plotzone,:), ['-t' num2str(handles.mon_intent-1) ...
             ' -i ' handles.outprof ' -o ' handles.montemp]);  % SPED UP! Was just outarg here...
          image(uint8(255*pltdata));  % was image(uint8(255*pltdata(:,handles.plotzone,:)));
	  	 	 handles.outype = 2;  handles = reset_outplot(handles);
			 set(handles.out_mapped,        'BackgroundColor',[1 1 .8]);
			 set(handles.out_mapped,        'FontWeight', 'bold');
          hwarn = msgbox('CMYK output cannot be displayed unmapped', 'Gamutvision warning','warn');
          pause(1);  close(hwarn);
       else
          image(uint8(255*outarg(:,handles.plotzone,:)));  
       end
	elseif handles.outype==2  % Display OUTPUT mapped to monitor profile.
       if isempty(handles.outprof)  % fulltemp{nplt})
          pltdata = .8*ones(256,length(handles.plotzone),3);  %  handles.pltOK = 0;  return;  end  % was 256,832,3...
       else
          % houtp = handles.outprof, sz_out 
          pltdata = icctrans(outarg(:,handles.plotzone,:), ['-t1 -i ' handles.outprof ' -p ' ...
             ' *LabD65 ' ' -o ' handles.montemp]);  % WORKS!!! BIG improvement. *XYZ had color error.
       end
       image(uint8(255*pltdata));
	elseif handles.outype==3  % Display input raw.
       % if isempty(intarg)  handles.pltOK = 0;  return;  end
       image(uint8(255*intarg(:,handles.plotzone,:)));
	elseif handles.outype==4  % Display input mapped to monitor profile.
       if isempty(handles.inprof | isequal(handles.inprof,' '))
          pltdata = .8*ones(256,832,3);
       else
          pltdata = icctrans(intarg(:,handles.plotzone,:), ['-t1 -i ' handles.inprof ' -p ' ...
             ' *LabD65 ' ' -o ' handles.montemp]);  % File to monitor profile.
       end
       image(uint8(255*pltdata));
	end
   % Try to restore control to main image-- for rotation, etc. Matlab bug!
   % if handles.plt3d  % Do this so main image can be rotated after this image has been refreshed.
   %    axes(handles.axes1);  % May remove Legend in Matlab R 12: Restored 12/28/06.
   % end
	set(gca, 'Visible','off');  axis image;
   axes(handles.axes1);  % Restore rotation, if appropriate. Removes Legend in Matlab R 12.
   if handles.plt3d  % Try to restore rotation after updating Upper-Right image.
      if handles.hzoom  zoom on;   rotate3d off;
      else              zoom off;  rotate3d on;  end  % Switch for 3D plot
   end
end

%            CLEAR OLD PLOT DATA & SET VIEW.  Note: exist() doesn't work in complier.

if pltupdate(1)
   axes(handles.axes1);  % Replaces many occurrences that follow. Removes Legend in Matlab R 12.
   lplot = abs(handles.lastplot);  % Do this so that a crash below won't repeat.
   handles.lastplot = 0;      % Set to handles.pltype at successful completion of plot.
	set(handles.axes1,'Position',handles.axpos);  % Original position: Don't delete.
	if lplot==3 | lplot==4
       delete(findobj('Position',handles.sz_harea));  % delete(handles.harea);
   end
   cla reset;  % With light fixed, should work for everything. Must be after view.
else
   return;  % No need for further processing if main plot isn't updated.
end


%           INDIVIDUAL PLOTS FOR handles.pltype (the BIG if... elseif... end block)

if handles.pltype<=2   % 1 or 2: ---------  3D LAB PLOT  ----------
   
   if handles.OpenGL
      set(gcf, 'Renderer', 'opengl');  % 'zbuffer' or 'opengl' here. 'painters' fails.
   else
      set(gcf, 'Renderer', 'zbuffer');  % 'zbuffer' or 'opengl' here. 'painters' fails.
   end
	% Need to resize down the image (nearest neighbor?). A multiple of 6 is important for hue.
   if handles.pltres==1 | handles.pltres==3  % Low resolution wireframe
      nfacet = 36;
   elseif handles.pltres>6  % Extra low resolution
      nfacet = 24;
   else  % High resolution
      nfacet = 72;
   end
   pltzone = [577:2:832];  % Plot zone, was [1:2:256];
   if handles.pltype==1  % Unreversed plot.
		s1_cropin = imgrescale(intarg(1:2:256,[pltzone 577],:), [nfacet+1,nfacet+1]);
      if handles.pltres>6
         temp_crop = imgrescale(intarg(1:2:256,[pltzone 577],:), [128,128]);
      end
      if (handles.pltres==3 | handles.pltres==4 | handles.pltres>=6) % ...
            % & get(handles.check_light,'Value')  % Highest output res.
         % s1_cropout = outarg;  % Too big: too damned slow!
         % s1_cropout = outarg(1:2:256,[pltzone 1],:);  % better, we hope.
         s1_cropout = imgrescale(outarg(1:2:256,[pltzone 577],:), [128,128]);  % even better...
      else
	      s1_cropout = imgrescale(outarg(1:2:256,[pltzone 577],:), [nfacet+1,nfacet+1]);
      end
   else  % Reverse in, out. if handles.pltype==2  invert s1_cropin, s1_cropout.
		s1_cropout = imgrescale(outarg(1:2:256,[pltzone 577],:), [nfacet+1,nfacet+1]);
      if handles.pltres>6
         temp_crop = imgrescale(outarg(1:2:256,[pltzone 577],:), [128,128]);
      end
      if (handles.pltres==3 | handles.pltres==4 | handles.pltres>=6) % ...
            % & get(handles.check_light,'Value')  % Highest output res.
         s1_cropin = imgrescale(intarg(1:2:256,[pltzone 577],:), [128,128]);  % even better, maybe???
      else
	      s1_cropin = imgrescale(intarg(1:2:256,[pltzone 577],:), [nfacet+1,nfacet+1]);
      end
   end
   % clout = class(s1_cropout), clin = class(s1_cropin) 
	s1_cropout = double(s1_cropout);   % should be OK for CMYK. Unneeded???
   
	% Two ways to convert to LAB: labdata = rgb2lab(s1_cropin);  % old...
	if isempty(handles.inprof | isequal(handles.inprof,' '))
      disp(['handles.fulltemp(' num2str(mplt) ') missing']);  % Need at least input profile.
      handles.pltOK = 0;  return;  % No input profile yet.
      % labdata = zeros(size(s1_cropin));
   else  % INPUT
      temp = rgb2cmyk(s1_cropin, handles.cmyk(mplt));  % Convert to CMYK if needed.
	   labdata  = icctrans(temp, ['-t1 -i ' handles.inprof ' -o ' handles.labtmpr]);  % To LAB.
	   surfdata = icctrans(temp, ['-t1 -i ' handles.inprof ' -o *sRGB']);    % File to sRGB.
      clear temp;
	end
   
	if isempty(handles.outprof | isequal(handles.outprof,' '))  % Plot input only.
      labdatb = zeros(size(s1_cropout));  surfdatb = labdatb;
   else  % OUTPUT
      labdatb  = icctrans(s1_cropout, ['-t1 -i ' handles.outprof ...
         ' -o ' handles.labtmpr ]);  % File to LAB. For shape of L*a*b* surface.
      if handles.pltres>6   % Error display instead of natural colors.
         % Labdata and labdatb have different dimensionality: latdata is the wire frame size.
         temp = rgb2cmyk(temp_crop, handles.cmyk(mplt));  % Convert to CMYK if needed.
	      temp_lab = icctrans(temp, ['-t1 -i ' handles.inprof ' -o ' handles.labtmpr]);  % To LAB.
         % temp_lab = icctrans(temp_crop, ['-t1 -i ' handles.outprof ' -o *sRGB']);    % File to sRGB.
         surfdatb = labdatb;  % zeros(size(temp_lab));
         surfdatb(:,:,1) = 50 + 3*(labdatb(:,:,1) - temp_lab(:,:,1));
         surfdatb(:,:,1) = max(surfdatb(:,:,1),0);  surfdatb(:,:,1) = min(surfdatb(:,:,1),100); 
         surfdatb(:,:,2:3) = 0;
         surfdatb = icctrans(surfdatb,   ['-t1 -i ' handles.labtmpr ' -o *sRGB']);    % L*a*b* to sRGB. 
      else
         surfdatb = icctrans(s1_cropout, ['-t1 -i ' handles.outprof ' -o *sRGB']);    % File to sRGB.
      end
   end
   if handles.pltype==2  % Reverse a,b
      temp = labdata;   labdata = labdatb;    labdatb = temp;
      temp = surfdata;  surfdata = surfdatb;  surfdatb = temp;
      clear temp;
   end
   
  	set3daxis(handles);  % axis vis3d is reliable.
   view([handles.azim, handles.elev]);  % Set view azimuth and angle. Here for lighting.
   
   % Plot a point so that wireframe projections will fall on the L*=0 plane.
   plot3([0 .01],[0 .01],[0 .01],'Color',handles.bk3d*[1 1 1]);  hold on;
	% 'FaceColor' should be 'interp' or 'flat' (Chromix is 'flat').
   if handles.pltres<3 | handles.pltres==5
      fcol = 'flat';    handles.flight = 'flat';     % not smooth. OK.
   else
      fcol   = 'interp';  % 'interp' or try 'texturemap'
      handles.flight = 'gouraud';  % smooth... 'phong' or 'gouraud'  % phong may not work for lighting.
   end
   % Lighting can be 'phong' (best) or 'gouraud' (fastest). I see little difference.
   % In surfc, some settings make little difference. For some reason,
   % SpecularStrength is best at 0. SpecularExponent has little effect.
   % Cutting DiffuseStrength reduces specular glare (!!??!!)
   handles.lightsurf = surfc(labdatb(:,:,2), labdatb(:,:,3), labdatb(:,:,1), surfdatb, ...
      'FaceColor', fcol, 'EdgeColor','none','FaceLighting',handles.flight,'AmbientStrength',.8, ...
      'SpecularStrength',0,'DiffuseStrength',.5,'SpecularExponent',25, ...
      'SpecularColorReflectance',.5);
   if ~get(handles.check_light,'Value')  % No lighting.
      set(handles.lightsurf,'Facelighting','none');
%       handles.lightsurf = surfc(labdatb(:,:,2), labdatb(:,:,3), labdatb(:,:,1), surfdatb, ...
%          'FaceColor', fcol, 'EdgeColor','none','Facelighting','none');
   end
	ccmap = zeros(64,3);  % Colormap for the contours. Start in HSL, then convert to RGB.
	ccmap(:,1) = 2/3;  ccmap(:,2) = .6;  ccmap(:,3) = linspace(0,1,64)';  % linspace(0,.9,64)';
	% Play with ccmap(:,3) (L) to get good display tones. Increasing kc makes mid-tones darker.
	kc = 1.0;  ccmap(:,3) = .82*(kc*ccmap(:,3) + (1-kc)*sqrt(ccmap(:,3)));
	ccmap = hsl2rgb(ccmap);  ccmap = brighten(ccmap, .5);
	colormap(ccmap);  % was hot;
	% origpos = campos;    % We might vary camera position???
	% campos(origpos/5);  % Enlarged things a bit much. Not so good!
	contour3(labdatb(:,:,2), labdatb(:,:,3), labdatb(:,:,1), [10:10:90 95]);
   
   % WIREFRAME  Input. Was surfc. 'FaceLighting' could be flat.
   
   temp = surfdata;
   if handles.wire>1  % Other than Normal
      % Normal  Lighter  Darker  Max color Light  Dark  Black  White
      temp = rgb2hsl(temp);  temp(1,:,:) = temp(2,:,:);  % Correct for gray at end.
      if     handles.wire==2  % Lighter
         temp(:,:,3) = .6+.4*temp(:,:,3);
      elseif handles.wire==3  % Darker
         temp(:,:,3) = .4*temp(:,:,3);
      elseif handles.wire==4  % Max color
         temp(:,:,3) = .5;
      elseif handles.wire==5  % Light
         temp(:,:,3) = .8;
      elseif handles.wire==6  % Dark
         temp(:,:,3) = .2;
      elseif handles.wire==7  % Black
         temp(:,:,3) = 0;
      elseif handles.wire==8  % White
         temp(:,:,3) = 1;
      end
      temp = hsl2rgb(temp);
   end
   if handles.pltres<=4 | handles.pltres==7  % Plot wireframe
      if handles.OpenGL
	      handles.wiresurf = surf(labdata(:,:,2), labdata(:,:,3), labdata(:,:,1), temp, ...
            'FaceColor',handles.transface*[1 1 1], 'EdgeColor','flat', 'FaceAlpha',handles.transp, ...
            'FaceLighting','none');
      else
	      handles.wiresurf = mesh(labdata(:,:,2), labdata(:,:,3), labdata(:,:,1), temp);
         hidden off;
      end
   end
   
   %              DRAW VECTORS USING QUIVER PLOTS (ARROWS)
	if handles.vector>.02 & handles.vector<.98
      nquiv = 25;
	   xquiv = 576+round(linspace(1,256,nquiv));  % Hue coordinates of quiver plot.
      y1 = 1+round(255*(1-handles.vector));  % Adding 576 allows reduced saturation.
      qdata = intarg(y1,xquiv,:);  qdatb = outarg(y1,xquiv,:);  % Input and output.
	   qlabdata  = icctrans(qdata, ['-t1 -i ' handles.inprof ...
         ' -o ' handles.labtmpr ]);  % File to LAB.
	   qlabdatb  = icctrans(qdatb, ['-t1 -i ' handles.outprof ...
         ' -o ' handles.labtmpr ]);  % File to LAB.
	   qsurfdata = icctrans(qdata, ['-t1 -i ' handles.inprof ...
         ' -o *sRGB']);  % File to sRGB.
      % The vectors will be most visible if their color is the compliment. 
		chue_hsl = ones(nquiv-1,1,3);
      chue_hsl(:,1,3) = .5;  % Brightness increases.
		for i1=1:nquiv-1
         chue_hsl(i1,1,1) = (i1-1)/(nquiv-1);
		end
		chue_rgb = hsl2rgb(chue_hsl);  nh = floor(nquiv/2);
      chue_rgb = chue_rgb([nh+1:end, 1:nh],:,:);  % Get color complements.
      for i1=1:nquiv-1
         qp = quiver3(qlabdata(1,i1,2), qlabdata(1,i1,3), qlabdata(1,i1,1), ...
            qlabdatb(1,i1,2)-qlabdata(1,i1,2), qlabdatb(1,i1,3)-qlabdata(1,i1,3), ...
            qlabdatb(1,i1,1)-qlabdata(1,i1,1), 0);
         if handles.vector < .75
            qcolor = .6 + .2*handles.vector + .2*chue_rgb(i1,1,:);
         else
            qcolor = .5*chue_rgb(i1,1,:);
         end
         set(qp, 'Color',qcolor);  %  'LineWidth',1.5,
      end
   end      % End Quiver plots
   
	set(gca,'Color',handles.bk3d*[1 1 1]);
   % Set axis color-- lighten for dark backgrounds.
   if handles.bk3d>.35  axclr = [.4*handles.bk3d-.14 .4*handles.bk3d-.14 .4*handles.bk3d-.14];
   else  axclr = [.5*handles.bk3d+.45 .5*handles.bk3d+.45 .5*handles.bk3d+.45];
   end
   set(gca,'Xcolor',axclr, 'Ycolor',axclr, 'Zcolor',axclr);
   
	mina = min(min(labdata(:,:,2)));  maxa = max(max(labdata(:,:,2)));  
	minb = min(min(labdata(:,:,3)));  maxb = max(max(labdata(:,:,3)));  
	axmina = floor(mina/10)*10;       axmaxa = ceil(maxa/10)*10;  
	axminb = floor(minb/10)*10;       axmaxb = ceil(maxb/10)*10;  
	minc = min(min(labdatb(:,:,2)));  maxc = max(max(labdatb(:,:,2)));    % a*
	mind = min(min(labdatb(:,:,3)));  maxd = max(max(labdatb(:,:,3)));    % b*
	axminc = floor(minc/10)*10;       axmaxc = ceil(maxc/10)*10;  
	axmind = floor(mind/10)*10;       axmaxd = ceil(maxd/10)*10;  
	axmina = min([axmina,axminc,handles.lab3Daxis(1)]);
	axmaxa = max([axmaxa,axmaxc,handles.lab3Daxis(2)]);  
	axminb = min([axminb,axmind,handles.lab3Daxis(3)]);
	axmaxb = max([axmaxb,axmaxd,handles.lab3Daxis(4)]);  
   ax = [-130, 130, -130, 130, 0, 100];
	ax(1) = max([ax(1),axmina]);	ax(2) = min([ax(2),axmaxa]);  
	ax(3) = max([ax(3),axminb]);	ax(4) = min([ax(4),axmaxb]);  
	handles.lab3Daxis = ax;  axis(ax);
	xlabel('a*');  ylabel('b*');  zlabel('L');
   % text(.98*ax(1)-.06*ax(2),0,1, 'b*', 'FontSize',handles.dfz, ...
   %    'Color',axclr, 'FontWeight','bold');  % These don't always appear where they shoud.
   % text(0,.98*ax(3)-.06*ax(4),1, 'a*', 'FontSize',handles.dfz, ...
   %    'Color',axclr, 'FontWeight','bold');
	set3daxis(handles);  % axis vis3d is reliable.
	% title([handles.iccname{mplt} ' (wire), ' handles.iccname{nplt} ' (solid)'], ...
   %    'Interpreter','none','FontSize',handles.dfz-2);
   view([handles.azim, handles.elev]);  % Save view azimuth and angle.
   camlight(handles.lightpos);  % Always call because so light can be switched on or off.
   grid on;
   
   %                    
   if handles.vol   %           CALCULATE L*a*b* GAMUT VOLUMES.
      % Recalculate labdata (too small in wireframe calc.).
      
      if handles.pltype==1  % Unreversed plot.
	      s1_cropin  = imgrescale(intarg(1:2:256,[pltzone 577],:), [128,128]);
         temp = rgb2cmyk(s1_cropin, handles.cmyk(mplt));  % Convert to CMYK if needed.
	      labdata  = icctrans(temp, ['-t1 -i ' handles.inprof ' -o ' handles.labtmpr]);  % To LAB.
      elseif handles.pltype==2  % Reversed plot.  % labdata, labdata have been switched.
         labdata = labdatb;
	      s1_cropout = imgrescale(outarg(1:2:256,[pltzone 577],:), [128,128]);
         temp = rgb2cmyk(s1_cropout, handles.cmyk(nplt));  % Convert to CMYK if needed.
	      labdatb  = icctrans(temp, ['-t1 -i ' handles.outprof ' -o ' handles.labtmpr]);  % To LAB.
      end
      clear temp;
      
       ctrLa = mean(mean(labdata(:,:,1)));  ctrLb = mean(mean(labdatb(:,:,1)));
       ctraa = mean(mean(labdata(:,:,2)));  ctrab = mean(mean(labdatb(:,:,2)));
       ctrba = mean(mean(labdata(:,:,2)));  ctrbb = mean(mean(labdatb(:,:,3)));
       % Convert to spherical. Initially, theta and phi are in radians. Center at L* = 50, a* = b* = 0.
       [theta ,phi, rada] = cart2sph(labdata(:,:,2)-ctraa,labdata(:,:,3)-ctrba,labdata(:,:,1)-ctrLa);
       [thetab,phib,radb] = cart2sph(labdatb(:,:,2)-ctrab,labdatb(:,:,3)-ctrbb,labdatb(:,:,1)-ctrLb);
       sz_laba = size(labdata);  sz_labb = size(labdatb);  % input and output
       
       % Used these values in first pass: now use same size array as input.
       % anginc  = 6;  nang  = 180/anginc;  % Angle increment in degrees. Keep <= 6. Originally, 2 --> ft = 60/pi.
       % angincb = 3;  nangb = 180/angincb;
       % ft = nang/pi;  ftb = nangb/pi;  % factor for converting from 0 to ft in phi or 0 to 2*ft in theta.
       nang  = sz_laba(1)-1;  anginc  = 180/nang;  % Angle increment in degrees. Keep <= 6. Originally, 2 --> ft = 60/pi.
       nangb = sz_labb(1)-1;  angincb = 180/nangb;
       ft = nang/pi;  ftb = nangb/pi;  % factor for converting from 0 to ft in phi or 0 to 2*ft in theta.
       % Angle increments in radians
       dpha = anginc *pi/180;  dtha = anginc *pi/90;  % Input  phi, theta increments radians.
       dphb = angincb*pi/180;  dthb = angincb*pi/90;  % Output phi, theta increments radians.
       % Rescale theta and phi and convert them into discrete (integer) values.
       % Original: -pi <= theta <= pi;  -pi/2 <= phi <= pi/2.
       phidis   = 1+round(ft .*(pi/2 + phi ));  % Discrete phi. Latitude. 1-91 for anginc = 4
       phidisb  = 1+round(ftb.*(pi/2 + phib));
       thetdis  = 1+round(ft .*(pi + theta )/2);  % .*cos(phi) *(2/pi));  % Discrete theta. Longitude  % /2 added
       thetdisb = 1+round(ftb.*(pi + thetab)/2);  % .*cos(phib)*(2/pi));  % Discrete theta.
       % mxph = max(phidis(:)),  mxphb = max(phidisb(:)), mxth = max(thetdis(:)), mxthb = max(thetdisb(:))  %%%%%
       
       radra   = zeros(nang +1,nang +1);  % Radius: 1st index for theta; 2nd for phi
       radrb   = zeros(nangb+1,nangb+1);  % Radius: 1st index for theta; 2nd for phi
       radsuma = zeros(nang +1,nang +1); 
       radsumb = zeros(nangb+1,nangb+1);
       % sz_all = size(theta);  % Size of input arrays.
       sz_a = [length(phidis ), length(thetdis )];  % Size of input arrays.
       sz_b = [length(phidisb), length(thetdisb)];  % Size of input arrays.
       phideala = linspace(-pi/2,pi/2,length(phidis )); 
       phidealb = linspace(-pi/2,pi/2,length(phidisb)); 
       
       for i1 = 1:sz_a(1);
          for j1 = 1:sz_a(2);  % Fill the radius array.
             radra(  thetdis(i1,j1), phidis(i1,j1))  = radra(  thetdis(i1,j1), phidis(i1,j1)) +rada(i1,j1);
             radsuma(thetdis(i1,j1), phidis(i1,j1))  = radsuma(thetdis(i1,j1), phidis(i1,j1)) +1;
          end
       end
       for i1 = 1:sz_b(1);
          for j1 = 1:sz_b(2);  % Fill the radius array.
             radrb(  thetdisb(i1,j1),phidisb(i1,j1)) = radrb(  thetdisb(i1,j1),phidisb(i1,j1))+radb(i1,j1);
             radsumb(thetdisb(i1,j1),phidisb(i1,j1)) = radsumb(thetdisb(i1,j1),phidisb(i1,j1))+1;
          end
       end
       
       % figure; imagesc(min(radsuma,3)); colormap('bone');  %%%%%%%%%%%%%%%%%%
       % [xfa, yfa] = find(radsum );  % Populated locations
       % [xfb, yfb] = find(radsumb);
       fa = find(radsuma);  fb = find(radsumb);
       % Find mean radius of each populated segment.
       radra(fa) = radra(fa)./radsuma(fa);    % Mean radii.
       radrb(fb) = radrb(fb)./radsumb(fb);
       [xfa,yfa] = ind2sub(size(radra),fa);
       [xfb,yfb] = ind2sub(size(radrb),fb);
       
       %  figure;  surf(radinvb);  %%%%
       % sz_xa = size(xfa), sz_ya = size(yfa), sz_ra = size(radinv([xfa,yfa]))  %%%%
       % Interpolate to fill unpopulated segments. Use griddata. See ind2sub, sub2ind 
       radia = griddata(xfa, yfa, radra(fa),[1:(nang +1)],[1:(nang +1)]');  % The BIG one. Interpolated
       % figure;  surf(radra);  figure;  surf(radia);
       radib = griddata(xfb, yfb, radrb(fb),[1:(nangb+1)],[1:(nangb+1)]');  % The BIG one.
       % figure;  surf(radrb);  figure;  surf(radib);
       % Problem??? Griddata may be giving NaNs.
       sz_a = size(radia);  sz_b = size(radib);  % Size of outpyt arrays.
       nradia = find(isnan(radia));  fradia = find(isfinite(radia));
       radia(nradia) = 0;  % Set invalid (NaN) points to 0.
       nradib = find(isnan(radib));  fradib = find(isfinite(radib));
       radib(nradib) = 0;  % Set invalid (NaN) points to 0.
       % figure;  imagesc(radia);  colormap('bone');  %%%%
       % mn_a = mean(radia(fradia)),  mn_b = mean(radib(fradib))  %%%%
       % mx_a = max(radia(fradia))  %%%%
       % cos(dpha*[0:sz_a(1)-1]-pi/2),  cos(dphb*[0:sz_b(1)-1]-pi/2)  %%%%
       for i1=1:sz_a(1)
          radia(i1,:) = radia(i1,:).^3 * (dpha * dtha * cos(dpha*(i1-1)-pi/2) / 3);
       end
       for i1=1:sz_b(1)
          radib(i1,:) = radib(i1,:).^3 * (dphb * dthb * cos(dphb*(i1-1)-pi/2) / 3);
       end
       vola = round(sum(radia(fradia)));  volb = round(sum(radib(fradib)));  % The volumes!
       set(handles.text_vol,'String',{'Gamut volumes'; ['(' num2str(mplt) ')  ', num2str(vola,7)]; ...
             ['(' num2str(nplt) ')  ', num2str(volb,7)]});
       
       % Seems to work, except that griddata gave me a mirror image. May not be a problem.
       % Now we need to integrate (sum) it with the appropriate weighting factors.
       % size(radia), size(radib), size(phideala), size(phidealb), phideala  %%%%%%%%%%%%%%%%%%
       
       clear theta phi radb thetab phib
       % mrad = mean(radinv(fa)), mradb = mean(radinvb(fb))  %%%%%%%%%%%%%%%%%%%
       % sza = size(labdata),  szb = size(labdatb)  %%%%%%%%%%%%%
       % sz_a(1)*sz_a(2), size(fa), sz_b(1)*sz_b(2), size(fb)  %%%%%%%%%%%%%%
       % Use equations of spherical geometry. CRC tables 19th ed. p. 18:
       % Spherical sector: V = (2*pi/3) * R^2 * h,  where h = delta(phi)*cos(phi) (height of incremental segment).
       
   end                 % END GAMUT VOLUME CALCULATION
   
	clear labdata labdatb surfdata surfdatb;
   %                                         END 3D LAB PLOT
   
   
elseif handles.pltype==3   %  S(HSL)=1 a*b* GAMUT MAP FOR L(HSL); 0.1 <= L <= 0.9
	
	%             NOTE:  L in this plot is HSL L (not La*b* L).
   % Plot goes from light to dark.
   set(gcf, 'Renderer', 'painters');  rotate3d off;  % 'zbuffer' 'opengl' or 'painters'
	nis = 5;  % Number of steps
   llvl = [.9 .7 .5 .3 .1];  % 03/28/06  LOWER INDEX = LIGHTER
   y5 = round(1+(1-llvl)*(handles.sz_L5(1)-1));  % Opposite order from L: lower index = lighter.
   temp = rgb2cmyk(intarg(y5,1:256,:),handles.cmyk(mplt));  % Convert to CMYK if needed.        
 	sslab =  icctrans(temp, ['-t1 -i ' handles.inprof ' -o ' handles.labtmpr]);  % Inpt to LAB.
	xbound = [min(min(sslab(:,:,2))) max(max(sslab(:,:,2)))];  % min, max a (x) for input
	ybound = [min(min(sslab(:,:,3))) max(max(sslab(:,:,3)))];  % min, max b (y) for input
	xlims =  [floor(xbound(1))-1 ceil(xbound(2))+1];  % Limits for plotting
	ylims =  [floor(ybound(1))-1 ceil(ybound(2))+1];
	xlims = [min([xlims,handles.lab2Daxis(1)]) max([xlims,handles.lab2Daxis(2)])];
	ylims = [min([ylims,handles.lab2Daxis(3)]) max([ylims,handles.lab2Daxis(4)])];
   handles.lab2Daxis = [xlims ylims];
	
	% Calculate lines of constant hue.
	chue_hsl = ones(13,41,3);
	for i1=1:13
       chue_hsl(i1,:,1) = (i1-1)/12;  % Hue
       chue_hsl(i1,:,3) = linspace(1,0,41);  % Brightness decreases. Switched 3/28/06
	end
	chue_rgb = hsl2rgb(chue_hsl);
	% chue_lab = rgb2lab(chue_rgb,colorig);
	chue_lab =  icctrans(chue_rgb, ['-t1 -i ' handles.inprof ...
      ' -o ' handles.labtmpr]);  % File to LAB.
	hueplt_hsl = ones(13,3);  hueplt_hsl(:,1) = (0:12)'/12;  % Color of hue plot. 3rd is Y
	hueplt_hsl(:,3) = [.46; .36; .40; .28; .28;   .27; .32; .37; .5; .45;   .40; .40; .5]*.8;
	hueplt_rgb = hsl2rgb(hueplt_hsl);
	huept2_hsl = hueplt_hsl;  huept2_hsl(:,3) = 1.5*hueplt_hsl(:,3);  % Lighter.
	huept2_rgb = hsl2rgb(huept2_hsl);
	
	mark_hsl = ones(3,13,3);  mark_L = [.65 .5 .4];
	for i1=1:3
       mark_hsl(i1,:,1) = (0:12)'/12;  % Color of hue plot
       mark_hsl(i1,:,3) = mark_L(i1);
       mark_hsl(i1,9,3) = mark_L(i1)*1.22;  mark_hsl(i1,10,3) = mark_L(i1)*1.14;
       mark_hsl(i1,5:6,3) = mark_L(i1)*.92;  mark_hsl(i1,7,3) = mark_L(i1)*.86;
	end  % mark_hsl(3:7,3) = .45;
	mark_rgb = hsl2rgb(mark_hsl);      % Color of marker
	
	% Use native size for LAB. 
	xvals = [xlims(1):xlims(2)];  lenx = length(xvals);
	yvals = [ylims(1):ylims(2)];  leny = length(yvals);
	labdata = ones(leny,lenx,3);
	labdata(:,:,2) = ones(leny,1)*xvals;   % a (x)
	labdata(:,:,3) = yvals'*ones(1,lenx);  % b (y)
	labdata(:,:,1) = linspace(60,86,leny)'*ones(1,lenx);  % L gradation (background plot).
	
	rgbdata = lab2rgb(labdata,'sRGB');  %  For display 
	x20 = 20*fix(.98*xlims/20);  % x-limits for plotting '+' every 20 0 a*b* values.
	y20 = 20*fix(.98*ylims/20);  % y-limits for plotting '+' every  20 a*b* values.
	
	cla;  set(gca,'Visible','on');
   newpos = handles.axpos;  % L B W H  Original position of axes1.
   newpos(1) = newpos(1)+.1*newpos(3);   newpos(3) =  .8*newpos(3);
   newpos(2) = newpos(2)+.15*newpos(4);  newpos(4) = .81*newpos(4);
   set(handles.axes1,'Position',newpos);
	
	image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)]);
	ax = axis;  % [xmin, xmax, ymin, ymax]
	set(gca,'YDir','normal');  % 'reverse' or 'normal'
	
   % Remove the second axes, for solving the problem of plots disappearing with the legend is moved.
	hold on;  
	% This plot cannot be done with a single contour(...) because it is mult-valued.
	% No contourable surface. % But there could be tricks: Those contour plots look cool!
	% If we do multiple contours, numbers could overlap.
	axis(ax);
	for i1=x20(1):20:x20(2)  % Plot '+' every 20 points vertically and horizontally.
       for j1=y20(1):20:y20(2)
          i2 = .55+.15*(j1-y20(1))/(y20(2)-y20(1));  % Lighten from bottom to top.
          text(i1,j1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
       end
	end
	
	plot(sslab(3,:,2),sslab(3,:,3),'Color',[.7 .7 .7], ...
       'LineWidth',1.5,'LineStyle',':');  % Ideal L=0.5.  Repeat to emphasize
	gcolors = [.99 .99 .99;  .86 .86 .86;  .7 .7 .7;  .38 .38 .38;  0 0 0 ];  % for heavy lines.
   % L order: light to dark.
	for i1=1:nis  % Look at cross-sections of s1_crop (cropped S1 area image; light on top).
       sgamut = outarg(y5(i1),1:256,:);  % Should be RGB.
       szg = size(sgamut);  sgamut = reshape(sgamut, szg(1)*szg(2), szg(3));
       szg = size(sgamut);  % 2D
       sgamut = [sgamut(szg(1)-3:szg(1),:); sgamut; sgamut(1:4,:)];  % Wrap: 4 pts extra each end.
       for ism=1:3  sgamut(:,ism) = smoothp(sgamut(:,ism),3);  end
       szg2 = size(sgamut);
       sgamut = sgamut(4:szg2(1)-3,:);  % Keep 1 extra point at each end.
       % sglab = rgb2lab(sgamut,colorspace);
       % plot(sglab(:,2),sglab(:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
       % sglab(i1,:,:) = rgb2lab(sgamut,colorspace);  % Measured data
	    sglab(i1,:,:) = icctrans(sgamut, ['-t1 -i ' handles.outprof ...
          ' -o ' handles.labtmpr ]);
       sgvort(i1,:) = round(linspace(3,length(sgamut)-2,13));  % Vortex locations
       % Try reversing colors between gcolors(i1,:) and gcolors(nis+1-i1).
       plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:), ...
          'LineStyle','-','LineWidth',1.5);  % Output plot.  First.
       % if i1==3  sglab3 = sglab;  end  % Save to replot for clarity.
       gideal(i1) = polyarea(sslab(i1,:,2),sslab(i1,:,3));
       garea(i1) =  polyarea(sglab(i1,:,2),sglab(i1,:,3));
	end
   
   handles.sz_harea = handles.axpos;  % Move from end to help with Legend (???)
   handles.sz_harea(2) = .12; handles.sz_harea(4) = .12;
	handles.harea = axes('Position',handles.sz_harea,'Visible','off');  % [L B W H]
	% harea = axes('Position',[.06 .02 .88 .12],'Visible','off');  % [L B W H]
	darea{1} = sprintf('L (HSL lightness)%7.1f %7.1f %7.1f %7.1f %7.1f', ...
       llvl(5),llvl(4),llvl(3),llvl(2),llvl(1));
	darea{2} = sprintf('Area (ideal)     %7.0f %7.0f %7.0f %7.0f %7.0f', ...
       gideal(5),gideal(4),gideal(3),gideal(2),gideal(1));
	darea{3} = sprintf('Area (measured)  %7.0f %7.0f %7.0f %7.0f %7.0f', ...
       garea(5),garea(4),garea(3),garea(2),garea(1));
	text(0.05,.4, darea,'Fontsize',handles.dfz-2 ,'FontName','FixedWidth');
   axes(handles.axes1);  % Restore after handles.harea.
   
	set(gca,'Xlim',xlims,'Ylim',ylims);
	hleg = legend('Input','L=0.1','L=0.3','L=0.5','L=0.7','L=0.9',3);
	set(hleg,'Color',[.7 .85 .95]);  % ,'Position',get(hleg,'Position')+[.04 0 0 0]);  % Fix Position BUG!
	
	% line([0 0], [.92*ax(3)+.08*ax(4) .03*ax(3)+.97*ax(4)],'Color',[.55 .55 .55], ...
   %    'LineStyle','-','LineWidth',1);  % y-axis
	% line([.97*ax(1)+.03*ax(2) .03*ax(1)+.97*ax(2)], [0 0],'Color',[.55 .55 .55], ...
   %    'LineStyle','-','LineWidth',1);  % x-axis
	for i1=1:12  % Radial curves (?)
       plot(chue_lab(i1, 1:20,2),chue_lab(i1, 1:20,3),'Color',huept2_rgb(i1,:), ...
          'LineStyle',':','LineWidth',1);
       plot(chue_lab(i1,21:41,2),chue_lab(i1,21:41,3),'Color',hueplt_rgb(i1,:), ...
          'LineStyle',':','LineWidth',1);
	end
	plot(sslab(3,:,2),sslab(3,:,3),'Color',[.5 .5 .5], ...
       'LineWidth',2.5,'LineStyle','-');  % Ideal L=0.5.  Background for emphasis.
	for i1=1:nis  % Ideal (input) values
       plot(sslab(i1,:,2),sslab(i1,:,3),'Color',gcolors(i1,:), ...
          'LineWidth',1.5,'LineStyle',':');  % Ideal.
	end
	ggcolors = gcolors;  ggcolors(3,:) = [.5 .5 .5];  % Darken outline for L=0.5.
	for i1=2:4
      sgvort(i1,1) = mean(sgvort(i1,1),sgvort(i1,13));
      if i1==3  % Middle color.
         plot(sglab(i1,:,2),sglab(i1,:,3),'Color',[.5 .5 .5],'LineStyle','-','LineWidth',3.0);
      end
      plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
   end
   if handles.lab2dg<2
		for i1=2:4
         for j1=1:12  % Length of sslab changed from printest.m.
            ssind2 = round(1+(j1-1)*256/12);  % sslab index
            plot(sslab(i1,ssind2,2),sslab(i1,ssind2,3),'s', ...  % Input data
               'MarkerEdgeColor',ggcolors(i1,:),'MarkerFaceColor',mark_rgb(i1-1,j1,:),'MarkerSize',5)
            plot(sglab(i1,sgvort(i1,j1),2),sglab(i1,sgvort(i1,j1),3),'o', ...   % Vortices.
               'MarkerEdgeColor',ggcolors(i1,:),'MarkerFaceColor',mark_rgb(i1-1,j1,:),'MarkerSize',6)
         end
		end
   end
   %              DRAW VECTORS USING QUIVER PLOTS (ARROWS)
	if handles.vectab>.02 & handles.vectab<.98
      nquiv = 25;
	   xquiv = round(linspace(1,256,nquiv));  % Hue coordinates of quiver plot.
      y1 = 1+round(255*(1-handles.vectab));
      qdata = intarg(y1,xquiv,:);  qdatb = outarg(y1,xquiv,:);  % Input and output.
	   qlabdata  = icctrans(qdata, ['-t1 -i ' handles.inprof ...
         ' -o ' handles.labtmpr ]);  % File to LAB.
	   qlabdatb  = icctrans(qdatb, ['-t1 -i ' handles.outprof ...
         ' -o ' handles.labtmpr ]);  % File to LAB.
	   qsurfdata = icctrans(qdata, ['-t1 -i ' handles.inprof ...
         ' -o *sRGB']);    % File to sRGB.
      % The vectors will be most visible if their color is the compliment. 
		chue_hsl = ones(nquiv-1,1,3);
      chue_hsl(:,1,3) = .5;  % Brightness increases.
		for i1=1:nquiv-1
         chue_hsl(i1,1,1) = (i1-1)/(nquiv-1);
		end
		chue_rgb = hsl2rgb(chue_hsl);  nh = floor(nquiv/2);
      % chue_rgb = chue_rgb([nh+1:end, 1:nh],:,:);  % Get color complements.
      for i1=1:nquiv-1
         qp = quiver(qlabdata(1,i1,2), qlabdata(1,i1,3), ...
            qlabdatb(1,i1,2)-qlabdata(1,i1,2), qlabdatb(1,i1,3)-qlabdata(1,i1,3), 0);
         if handles.vectab<.51
            qcolor = .4*chue_rgb(i1,1,:);
         else
            qcolor = .85 + handles.vectab*.15*chue_rgb(i1,1,:);
         end
         set(qp, 'Color',qcolor);  % 'LineWidth',1.5,
      end
   end
      
	text(.03*ax(1)+.97*ax(2),.03*ax(3)+.97*ax(4),['Input:  ' handles.iccname{mplt}], ...
       'FontSize',handles.dfz-2,'Color',[.2 .2 .4],'HorizontalAlignment','right', ...
       'Interpreter','none');
	text(.03*ax(1)+.97*ax(2),.06*ax(3)+.94*ax(4),['Output: ' handles.iccname{nplt}], ...
       'FontSize',handles.dfz-2,'Color',[.2 .2 .4],'HorizontalAlignment','right', ...
       'Interpreter','none');
	text(.55*ax(1)+.45*ax(2),.97*ax(3)+.03*ax(4), daterun, 'Fontsize',handles.dfz-2, ...
       'HorizontalAlignment','center');  % Date
	title('a*b* Gamut map for S(HSL)=1; L(HSL) from 0.1 to 0.9', ...
       'FontWeight','bold','Fontsize',handles.dfz);
	xlabel('a*','FontWeight','bold');
	ylabel('b*','FontWeight','bold');
	clear sglab
	
	%                             END S1 a*b* GAMUT MAP for S=1; 0.1 <= L <= 0.9
	
   
elseif handles.pltype==4   %  L(HSL)=.5 (or other) a*b* SATURATION MAP FOR S FROM 0 TO 1
   
   set(gcf, 'Renderer', 'painters');  rotate3d off;  % 'zbuffer' 'opengl' or 'painters'
	
	nis = 6;
   y5 = round(1+linspace(0,1,6)*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
   if ~handles.printest.on  xrange = [833:1088];
   else                     xrange = [257:512];
   end
   temp = rgb2cmyk(intarg(y5,xrange,:),handles.cmyk(mplt));  % Convert to CMYK if needed.        
	sslab =  icctrans(temp,  ['-t1 -i ' handles.inprof ...
      ' -o ' handles.labtmpr ]);  % Inpt to LAB.
	sslab2 = icctrans(outarg(y5,xrange,:), ['-t1 -i ' handles.outprof ...
      ' -o ' handles.labtmpr ]);  % Outp to LAB.
	xbound = [min(min(sslab(1,:,2),[],2), min(sslab2(1,:,2),[],2)) ...
      max(max(sslab(1,:,2),[],2), max(sslab2(1,:,2),[],2))];  % min, max a (x) for Color space
	ybound = [min(min(sslab(1,:,3),[],2), min(sslab2(1,:,3),[],2)) ...
      max(max(sslab(1,:,3),[],2), max(sslab2(1,:,3),[],2))];  % min, max b (y) for Color space
	xlims =  [floor(xbound(1))-1 ceil(xbound(2))+1];  % Limits for plotting
	ylims =  [floor(ybound(1))-1 ceil(ybound(2))+1];
	xlims = [min([xlims,handles.lab2Daxis(1)]) max([xlims,handles.lab2Daxis(2)])];
	ylims = [min([ylims,handles.lab2Daxis(3)]) max([ylims,handles.lab2Daxis(4)])];
   handles.lab2Daxis = [xlims ylims];
	
	% Calculate lines of constant hue.
	chue_hsl = ones(13,41,3);
	for i1=1:13
       chue_hsl(i1,:,1) = (i1-1)/12;
       chue_hsl(i1,:,2) = linspace(0,1,41);
	end
	chue_hsl(:,:,3) = handles.lightvar;  % 0.5;
	chue_rgb = hsl2rgb(chue_hsl);
	% chue_lab = rgb2lab(chue_rgb,colorig);
   temp = rgb2cmyk(chue_rgb,handles.cmyk(mplt));  % Convert to CMYK if needed.        
	chue_lab =  icctrans(temp, ['-t1 -i ' handles.inprof ...
      ' -o ' handles.labtmpr ]);  % File to LAB.
	hueplt_hsl = ones(13,3);  hueplt_hsl(:,1) = (0:12)'/12;  % Color of hue plot
	hueplt_hsl(:,2) = 1;  
	
	mark_hsl = ones(nis,13,3);
	for i1=1:nis
       mark_hsl(i1,:,1) = (0:12)'/12;  % Color of hue plot
       mark_hsl(i1,:,2) = 1.08-.08*i1;
       mark_hsl(i1,:,3) = 0.5;  mark_hsl(i1,9:10,3) = [.58; .52];
       mark_hsl(i1,3:7,3) =  [.47; .47; .44; .45; .44];   % .45;
	end
	mark_rgb = hsl2rgb(mark_hsl);    % Color of marker
	
	% Use native size for LAB. 
	xvals = [xlims(1):xlims(2)];  lenx = length(xvals);
	yvals = [ylims(1):ylims(2)];  leny = length(yvals);
	labdata = ones(leny,lenx,3);
	labdata(:,:,2) = ones(leny,1)*xvals;   % a (x)
	labdata(:,:,3) = yvals'*ones(1,lenx);  % b (y)
   if mod(handles.lab2dv,2)==1  % Lighter
	   labdata(:,:,1) = linspace(76,92,leny)'*ones(1,lenx);  % 85;  % L for background.
      txclr = [.2 .2 .4];  legclr = [.7 .85 .95];  fw = 'Normal';  % Text, legend color
      hueplt_hsl(:,3) = 0.5;
	   hueplt_hsl(4:7,3) = [.4; .3; .3; .3];
   else
	   labdata(:,:,1) = linspace(36,56,leny)'*linspace(1,.7,lenx);  % L for background.
	   % labdata(:,:,1) = linspace(40,60,leny)'*ones(1,lenx);  % L for background.
      txclr = [1 1 1];  legclr = [.55 .82 .90];  fw = 'Bold';
      % hueplt_hsl(:,3) = 0.14;
	   % hueplt_hsl(3:7,3) = .10;  % [.2; .2; .2; .2; .2];
      hueplt_hsl(:,3) = 0.6;
	   hueplt_hsl(3:10,3) = [.36; .50; .52; .52; .42; .65; .8; .7];
   end
	hueplt_rgb = hsl2rgb(hueplt_hsl);
	
	rgbdata = lab2rgb(labdata,'sRGB');
	x20 = 20*fix(.98*xlims/20);  % x-limits for plotting '+' every 20 a*b* values.
	y20 = 20*fix(.98*ylims/20);  % y-limits for plotting '+' every 20 a*b* values.
   
	cla;  set(gca,'Visible','on');
   newpos = handles.axpos;  % L B W H
   newpos(1) = newpos(1)+.1*newpos(3);   newpos(3) =  .8*newpos(3);
   newpos(2) = newpos(2)+.15*newpos(4);  newpos(4) = .81*newpos(4);
   set(handles.axes1,'Position',newpos);
	
	image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)]);
	ax = axis;  % [xmin, xmax, ymin, ymax]
	set(gca,'YDir','normal');  % 'reverse' or 'normal'
	
	% This plot cannot be done with a single contour(...) because it is mult-valued.
	% No contourable surface. % But there could be tricks: Those contour plots look cool!
	% If we do multiple contours, numbers could overlap.
	hold on;
	axis(ax);
	% for i1=linspace(x20(1),x20(2),ceil((x20(2)-x20(1)+1)/20))  % Didn't help color opr warning.
	for i1=x20(1):20:x20(2)  % Plot '+' every 20 a*b* units vertically and horizontally.
      dy20 = y20(2)-y20(1);
      if dy20>eps
          for j1=y20(1):20:y20(2)
             if mod(handles.lab2dv,2)==1  % Color of + markers
                i2 = .65+.1*(j1-y20(1))/dy20;  % Lighten from bottom to top.
             else
                i2 = .35+.1*(j1-y20(1))/dy20;  % Lighten from bottom to top.
             end
             text(i1,j1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
          end
      end
	end
	
	plot(sslab(1,:,2),sslab(1,:,3),'Color',[.2 .2 .2],'LineWidth',1.5,'LineStyle',':');  % Ideal S=1.
   if mod(handles.lab2dv,2)==1
	   gcolors =  [0 0 0;    0 0 1;     0 .6 0;   .8 0 0;    .6 .4 0;    0 0 0;];  % heavy lines.
   else
	   gcolors =  [1 1 1; .8 .7 1;  .4 1 .4;   1 .6 .6;   .9 .9 0;    .8 .8 .8;];  % heavy lines.
   end
   
   %                                       OUTPUT DATA HERE!
   % llvl = .2*[0:nis-1];
   % y5 = round(1+llvl*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
   % sgamut = outarg(y5,257:512,:);  % Should be RGB. 6 rows.
	for i1=1:nis  % Look at cross-sections of outarg (was L5_crop).
       llvl(i1) = .2*(i1-1);  % 0-1.
       y5 = round(1+llvl(i1)*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
       sgamut = outarg(y5,xrange,:);  % Should be RGB.
       szg = size(sgamut);  sgamut = reshape(sgamut, szg(1)*szg(2), szg(3));
       szg = size(sgamut);  % 2D
       sgamut = [sgamut(szg(1)-3:szg(1),:); sgamut; sgamut(1:4,:)];  % Wrap: add 4 pts at each end.
       for ism=1:3  sgamut(:,ism) = smoothp(sgamut(:,ism),3);  end
       szg2 = size(sgamut);
       sgamut = sgamut(3:szg2(1)-2,:);  % Keep 1 extra pt at each end.
	    sglab(i1,:,:) = icctrans(sgamut, ['-t1 -i ' handles.outprof ...
          ' -o ' handles.labtmpr ]);
       sgvort(i1,:) = round(linspace(3,length(sgamut)-2,13));  % Vortex locations
       plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
       gideal(i1) = polyarea(sslab(i1,:,2),sslab(i1,:,3));
       garea(i1) =  polyarea(sglab(i1,:,2),sglab(i1,:,3));
	end
	
   handles.sz_harea = handles.axpos;  % Moved to get around axes problem.
   handles.sz_harea(2) = .12; handles.sz_harea(4) = .12;
	handles.harea = axes('Position',handles.sz_harea,'Visible','off');  % [L B W H]
	darea{1} = sprintf('S (HSL Sat @ L=%4.2f)%5.1f%7.1f%7.1f%7.1f%7.1f%7.1f', ...
       handles.lightvar,linspace(0,1,6));
	darea{2} = sprintf('Area (ideal)       %6.0f%7.0f%7.0f%7.0f%7.0f%7.0f', ...
       gideal(6),gideal(5),gideal(4),gideal(3),gideal(2),gideal(1));
	darea{3} = sprintf('Area (measured)    %6.0f%7.0f%7.0f%7.0f%7.0f%7.0f', ...
       garea(6),garea(5),garea(4),garea(3),garea(2),garea(1));
	text(0.05,.4, darea,'Fontsize',handles.dfz-2 ,'FontName','FixedWidth');
   axes(handles.axes1);  % Restore after handles.harea.
   
	set(gca,'Xlim',xlims,'Ylim',ylims);
	hleg = legend('Input','S=1.0','S=0.8','S=0.6','S=0.4','S=0.2','S=0.0',3);
	set(hleg,'Color',legclr);
	
	for i1=1:12
       plot(chue_lab(i1,:,2),chue_lab(i1,:,3),'Color',hueplt_rgb(i1,:), ...
          'LineStyle',':','LineWidth',1);
	end
	for i1=nis:-1:1
       plot(sslab(i1,:,2),sslab(i1,:,3),'Color',gcolors(i1,:), ...
          'LineStyle',':','LineWidth',1.5);  % Ideal original space.
	end
	for i1=nis-1:-1:1
       plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);  % to top
	end
   if handles.lab2dv<3
		for i1=nis-1:-1:1  % This generates the markers (colored circles).
         sgvort(i1,1) = mean(sgvort(i1,1),sgvort(i1,13));
         for j1=1:12
            plot(sglab(i1,sgvort(i1,j1),2),sglab(i1,sgvort(i1,j1),3),'o', ...   % Vortices.
               'MarkerEdgeColor',gcolors(i1,:),'MarkerFaceColor',mark_rgb(i1,j1,:),'MarkerSize',handles.dfz-4);
         end
		end
   end
   
   %              DRAW VECTORS USING QUIVER PLOTS (ARROWS)
	if handles.vectab> .02
      nquiv = 25;
	   xquiv = 832+round(linspace(1,256,nquiv));  % Hue coordinates of quiver plot. Was 256+
      y1 = 1+round(255*(1-handles.vectab));
      qdata = intarg(y1,xquiv,:);  qdatb = outarg(y1,xquiv,:);  % Input and output.
	   qlabdata  = icctrans(qdata, ['-t1 -i ' handles.inprof ...
         ' -o ' handles.labtmpr ]);  % File to LAB.
	   qlabdatb  = icctrans(qdatb, ['-t1 -i ' handles.outprof ...
         ' -o ' handles.labtmpr ]);  % File to LAB.
	   qsurfdata = icctrans(qdata, ['-t1 -i ' handles.inprof ' -o *sRGB']);    % File to sRGB.
		chue_hsl = ones(nquiv-1,1,3);
      chue_hsl(:,1,3) = .5;  % Value for display. Brightness increases.
		for i1=1:nquiv-1
         chue_hsl(i1,1,1) = (i1-1)/(nquiv-1);
		end
		chue_rgb = hsl2rgb(chue_hsl);  nh = floor(nquiv/2);
      for i1=1:nquiv-1
         qp = quiver(qlabdata(1,i1,2), qlabdata(1,i1,3), ...
            qlabdatb(1,i1,2)-qlabdata(1,i1,2), qlabdatb(1,i1,3)-qlabdata(1,i1,3), 0);
         if mod(handles.lab2dv,2)==1  qcolor = .4*chue_rgb(i1,1,:);
         else  qcolor = .8+.2*chue_rgb(i1,1,:);  end
         set(qp, 'Color',qcolor);  % 'LineWidth',1.5,
      end
   end
   
	text(.03*ax(1)+.97*ax(2),.03*ax(3)+.97*ax(4),['Input:  ' handles.iccname{mplt}], ...
       'FontSize',handles.dfz-2,'FontWeight',fw,'Color',txclr,'HorizontalAlignment', ...
       'right','Interpreter','none');
	text(.03*ax(1)+.97*ax(2),.06*ax(3)+.94*ax(4),['Output: ' handles.iccname{nplt}], ...
       'FontSize',handles.dfz-2,'FontWeight',fw,'Color',txclr,'HorizontalAlignment', ...
       'right','Interpreter','none');
	text(.64*ax(1)+.36*ax(2),.97*ax(3)+.03*ax(4), daterun, 'Fontsize',handles.dfz-2, ...
       'HorizontalAlignment','center','FontWeight',fw,'Color',txclr);  % Date
  	title(['a*b* Saturation map for L(HSL) = ' num2str(handles.lightvar,2) ';  S from 0 to 1'], ...
      'FontWeight','bold','Fontsize',handles.dfz-1);
	xlabel('a*','FontWeight','bold');
	ylabel('b*','FontWeight','bold');
   
   %      END L(HSL)=.5 a*b* SATURATION MAP FOR S FROM 0 TO 1 (L5 region)

   
elseif handles.pltype==5   % 2D a*b* COLOR DIFFERENCE MAP FOR L(HSL)=.5, S FROM 0 TO 1
   set(gcf, 'Renderer', 'painters');  rotate3d off;  % 'zbuffer' 'opengl' or 'painters'
	nis = 6;  nis1 = 1;  nis2 = nis;  % May admust nis1, nis2.
   y5 = round(1+linspace(0,1,6)*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
   if ~handles.printest.on  xrange = [833:1088];
   else                     xrange = [257:512];
   end
   temp = rgb2cmyk(intarg(y5,xrange,:),handles.cmyk(mplt));  % Convert to CMYK if needed.        
	sslab =  icctrans(temp,  ['-t1 -i ' handles.inprof ...
      ' -o ' handles.labtmpr]);  % Input  to LAB (Reference).
	sslab2 = icctrans(outarg(y5,xrange,:), ['-t1 -i ' handles.outprof ...
      ' -o ' handles.labtmpr]);  % Output to LAB (Sample).
	xbound = [min(min(sslab(1,:,2),[],2), min(sslab2(1,:,2),[],2)) ...
      max(max(sslab(1,:,2),[],2), max(sslab2(1,:,2),[],2))];  % min, max a (x) for Color space
	ybound = [min(min(sslab(1,:,3),[],2), min(sslab2(1,:,3),[],2)) ...
      max(max(sslab(1,:,3),[],2), max(sslab2(1,:,3),[],2))];  % min, max b (y) for Color space
	xlims =  [floor(xbound(1))-1 ceil(xbound(2))+1];  % Limits for plotting
	ylims =  [floor(ybound(1))-1 ceil(ybound(2))+1];
	xlims = [min([xlims,handles.lab2Daxis(1)]) max([xlims,handles.lab2Daxis(2)])];
	ylims = [min([ylims,handles.lab2Daxis(3)]) max([ylims,handles.lab2Daxis(4)])];
   handles.lab2Daxis = [xlims ylims];
	
	% Use native size for LAB. 
	xvals = [xlims(1):xlims(2)];  lenx = length(xvals);
	yvals = [ylims(1):ylims(2)];  leny = length(yvals);
	labdata = ones(leny,lenx,3);
	labdata(:,:,2) = ones(leny,1)*xvals;   % a (x)
	labdata(:,:,3) = yvals'*ones(1,lenx);  % b (y)
   if mod(handles.lab2dv,2)==1  % Lighter
	   labdata(:,:,1) = linspace(76,92,leny)'*ones(1,lenx);  % 85;  % L for background.
      txclr = [.2 .2 .4];  legclr = [.8 .8 .8];  fw = 'Normal';  % Text, legend color
   else
	   labdata(:,:,1) = linspace(36,56,leny)'*linspace(1,.7,lenx);  % L for background.
	   % labdata(:,:,1) = linspace(40,60,leny)'*ones(1,lenx);  % L for background.
      txclr = [1 1 1];  legclr = [.55 .82 .90];  fw = 'Bold';
   end
	
	rgbdata = lab2rgb(labdata,'sRGB');
	x20 = 20*fix(.98*xlims/20);  % x-limits for plotting '+' every 20 a*b* values.
	y20 = 20*fix(.98*ylims/20);  % y-limits for plotting '+' every 20 a*b* values.
	
	cla;  set(gca,'Visible','on');
   newpos = handles.axpos;  % L B W H
   newpos(1) = newpos(1)+.1*newpos(3);   newpos(3) =  .8*newpos(3);
   newpos(2) = newpos(2)+.15*newpos(4);  newpos(4) = .81*newpos(4);
   set(handles.axes1,'Position',newpos);
	
	image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)]);
	ax = axis;
	set(gca,'YDir','normal');  % 'reverse' or 'normal'
	
	% This plot cannot be done with a single contour(...) because it is mult-valued.
	% No contourable surface. % But there could be tricks: Those contour plots look cool!
	% If we do multiple contours, numbers could overlap.
	hold on;
	axis(ax);
	for i1=x20(1):20:x20(2)  % Plot '+' every 20 a*b* units vertically and horizontally.
      dy20 = y20(2)-y20(1);
      if dy20>eps
          for j1=y20(1):20:y20(2)
             if mod(handles.lab2dv,2)==1  % Color of + markers
                i2 = .65+.1*(j1-y20(1))/dy20;  % Lighten from bottom to top.
             else
                i2 = .35+.1*(j1-y20(1))/dy20;  % Lighten from bottom to top.
             end
             text(i1,j1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
          end
      end
	end
	
	plot(sslab(1,:,2),sslab(1,:,3),'Color',[.2 .2 .2],'LineWidth',1.5,'LineStyle',':');  % Ideal S=1.
   if mod(handles.lab2dv,2)==1  % Lighter background
	   gcolors =   [.68 .68 .68; .7 .7 .9;  .64 .8 .64; .8 .7 .7;   .85 .8 .75; .4 .4 .4;];  % heavy lines.
	   % gcolors = [0 0 0;      0 0 1;     0 .6 0;   .8 0 0;    .6 .4 0;    0 0 0;];  % heavy lines.
      ccolor = [0 0 .5];  % contour color
   else  % Darker background
	   gcolors =   [.3 .3 .3;    .4 .3 .6;  0 .4 0;   .5 .2 .2;   .4 .4 0;    .4 .4 .4;];  % heavy lines.
	   % gcolors = [1 1 1;    .8 .7 1;  .4 1 .4;   1 .6 .6;   .9 .9 0;    .8 .8 .8;];  % heavy lines.
      ccolor = [1 1 1];  % contour color
   end
   
   %                                       OUTPUT DATA HERE!
	for i1=nis1:nis2  % Look at cross-sections of outarg (was L5_crop).
       llvl(i1) = .2*(i1-1);  % 0-1.
       y5 = round(1+llvl(i1)*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
       sgamut = outarg(y5,xrange,:);  % Should be RGB.
       % y5 = round(1+llvl(i1)*(handles.sz_L5(1)-2));  % Avoid extremes.
       % sgamut = handles.L5_crop(y5,:,:);  % Should be RGB.
       szg = size(sgamut);  sgamut = reshape(sgamut, szg(1)*szg(2), szg(3));
       szg = size(sgamut);  % 2D
       sgamut = [sgamut(szg(1)-3:szg(1),:); sgamut; sgamut(1:4,:)];  % Wrap: add 4 pts at each end.
       for ism=1:3  sgamut(:,ism) = smoothp(sgamut(:,ism),3);  end
       szg2 = size(sgamut);
       sgamut = sgamut(3:szg2(1)-2,:);  % Keep 1 extra pt at each end.
	    sglab(i1,:,:) = icctrans(sgamut, ['-t1 -i ' handles.outprof ...
          ' -o ' handles.labtmpr]);
       % sglab(i1,:,:) = rgb2lab(sgamut,colorspace);
       sgvort(i1,:) = round(linspace(3,length(sgamut)-2,13));  % Vortex locations
       plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
       gideal(i1) = polyarea(sslab(i1,:,2),sslab(i1,:,3));
       garea(i1) =  polyarea(sglab(i1,:,2),sglab(i1,:,3));
	end
	set(gca,'Xlim',xlims,'Ylim',ylims);
	hleg = legend('Input','S=1.0','S=0.8','S=0.6','S=0.4','S=0.2','S=0.0',3);
	set(hleg,'Color',legclr);
	
	for i1=nis2:-1:nis1
       plot(sslab(i1,:,2),sslab(i1,:,3),'Color',gcolors(i1,:), ...
          'LineStyle',':','LineWidth',1.5);  % Ideal original space.
	end
   plot(sslab(1,:,2),sslab(1,:,3),'Color',ccolor, 'LineStyle',':','LineWidth',1.5);  % Outer.
	for i1=nis2-1:-1:nis1
       plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);  % to top
	end
   
   %                 COLOR DIFFERENCE CONTOURS
   temp = rgb2cmyk(intarg(:,xrange,:),handles.cmyk(mplt));  % Convert to CMYK if needed.
	reflab  =  icctrans(temp,  ['-t1 -i ' handles.inprof ...
      ' -o ' handles.labtmpr]);  % Input  to LAB (Reference).
   % Recall, outarg contains the bit sent to the printer. We will need a soft-proof!
   % The soft proof should be in the input color space(???) Use monitor for now.
   samplab = icctrans(outarg(:,xrange,:), ['-t1 -i ' handles.outprof ...
      ' -o ' handles.labtmpr ]);
   % pltdata = icctrans(outarg, ['-t1 -i ' handles.outprof ...
   %    ' -p *LabD65 -o ' handles.montemp]);  % WORKS!!! BIG improvement. *XYZ had color error.
	% samplab =  icctrans(outarg(:,xrange,:),  ['-t1 -i ' handles.inprof ...
   %    ' -o *LabD65']);  % Output to LAB D65 (Reference).
   contlines = [];  % Start out empty.
   if     handles.difplt==1  contlines = [1,2,4,7,10,15,20,30,40,50,60,70,80,90,100];
   elseif handles.difplt==2  contlines = [1,2,4,7,10,15,20,30,40,50,60,70,80,90,100];
   elseif handles.difplt==3  contlines = [1,2,4,7,10,15,20,30,40,50,60,70,80,90,100];
   elseif handles.difplt==4  contlines = [1,2,4,7,10,15,20,30,40,50,60,70,80,90,100];
   elseif handles.difplt==5  contlines = [1,2,4,7,10,15,20,30,40,50,60,70,80,90,100];
   elseif handles.difplt==6  contlines = [1,2,4,7,10,15,20,30,40,50,60,70,80,90,100];
   elseif handles.difplt==7  contlines = [1,2,4,7,10,15,20,30,40,50,60,70,80,90,100];
   elseif handles.difplt==8  contlines = [1,2,4,7,10,15,20,30,40,50,60,70,80,90,100];
   end
   
   [temp, pltitle] = finderr(samplab,reflab,handles.difplt,handles.pltype);
	hsm = [1 1; 1 1];  hsmk = hsm;  % Starting kernel.
	nkrnl = ceil(256/50);
	for i1=1:nkrnl  hsmk = conv2(hsmk,hsm);  end
	hsmk = hsmk/sum(sum(hsmk));  % Normalize it.
	s_smooth = smooth2(hsmk,temp);  % H
   if isempty(contlines)
      [C,h] = contour(reflab(:,:,2),reflab(:,:,3), s_smooth);
   else
      [C,h] = contour(reflab(:,:,2),reflab(:,:,3), s_smooth ,contlines);
   end
   if mod(handles.lab2dv,2)==1  colormap(0*white);
   else  colormap(white);  end
	if ~isempty(C) & ~isempty(h)  clabel(C,h,'Color',ccolor);  end  % OK if not empty.
   
	text(.03*ax(1)+.97*ax(2),.03*ax(3)+.97*ax(4),['Input:  ' handles.iccname{mplt}], ...
       'FontSize',handles.dfz-2,'FontWeight',fw,'Color',txclr,'HorizontalAlignment', ...
       'right','Interpreter','none');
	text(.03*ax(1)+.97*ax(2),.06*ax(3)+.94*ax(4),['Output: ' handles.iccname{nplt}], ...
       'FontSize',handles.dfz-2,'FontWeight',fw,'Color',txclr,'HorizontalAlignment', ...
       'right','Interpreter','none');
	text(.64*ax(1)+.36*ax(2),.97*ax(3)+.03*ax(4), daterun, 'Fontsize',handles.dfz-2, ...
       'HorizontalAlignment','center','FontWeight',fw,'Color',txclr);  % Date
  	title(['a*b* Color differences for L(HSL) = ' num2str(handles.lightvar,2) ';  S from 0 to 1'], ...
      'FontWeight','bold','Fontsize',handles.dfz-1);
	xlabel({'a*'; pltitle},'FontWeight','bold');  ylabel('b*','FontWeight','bold');
   %        END L(HSL)=.5 a*b* COLOR DIFFERENCES FOR S FROM 0 TO 1 (L5 region)
	
	
elseif handles.pltype==6   % 3D/2D S(HSL)=1 L*h* COLOR DIFFERENCE MAP FOR L(HSL) FROM 0 TO 1
   set(gcf, 'Renderer', 'zbuffer');  % 'zbuffer' 'opengl' or 'painters'
   % s1_cropin = imgrescale(intarg(1:2:256,[1:2:256 1],:), [128,128]);  % from 3D plot.
   % 1: 2D Hue-L;  2: 3D Hue-L;  3: 2D H*L*;  4: 3D H*L*;
   % Need the option of intarg and outarg with reduced saturation.
   if ~handles.printest.on  xrange = [577:832];
   else                     xrange = [1:256];
   end
   temp = rgb2cmyk(intarg(:,xrange,:),handles.cmyk(mplt));  % Convert to CMYK if needed.
   reflab  =  icctrans(temp,  ['-t1 -i ' handles.inprof ...
      ' -o ' handles.labtmpr]);  % Input  to LAB (Reference).
   samplab = icctrans(outarg(:,xrange,:), ['-t1 -i ' handles.outprof ...
      ' -o ' handles.labtmpr]);  % Sample (not reference)
   if handles.HLview>=3  %  L*H* background (2D or 3D)
      % Recall, outarg contains the bits sent to the printer. We will need a soft-proof!
      % The soft proof should be in the monitor color space.
      % Base L*c*h* on reflab.
      reflch = reflab;  % Reference value: to be used as independent axis.
      reflch(:,:,1) = min(reflch(:,:,1),100);  % Limit L* to 100.
      reflch(:,:,2) = sqrt(reflab(:,:,2).^2 + reflab(:,:,3).^2);  % Chroma C*
      % Sharma p. 33: corrected in errata! Want range to be 0-360.
	   temp = 3/pi*atan2(reflab(:,:,3),reflab(:,:,2));  % Hue: 180/pi --> 3/pi so it goes from 0-6.
      for i1=1:256  % Use discontinuity! Always near center.
         [dis, idis] = min(diff(temp(i1,:)));
         temp(i1,idis+1:256) = temp(i1,idis+1:256)+6;  % This works nicely. mod fails.
      end
      temp(1,:)   = 2*temp(2,:)  -temp(3,:);  
      temp(255,:) = 2*temp(254,:)-temp(253,:);
      temp(256,:) = 2*temp(255,:)-temp(254,:);  % Fix upper, lower bounds.
      reflch(:,:,3) = temp;  % Can exceed {0,6} boundaries. Surf location.
      
      for i1=1:256   % Correct shift of H* boundaries.
         na = find(temp(i1,:)>6);
         reflch(i1,na,3) = mod(reflch(i1,na,3),6); % Generally works well.
         if ~isempty(na)
            % if i1==5 | i1>253  nb = [min(na) max(na)],  end  %%%%%%%%%%%%%
            % reflch(i1,na,3) = reflch(i1,na,3)-6; 
            ng = length(na);
            tempa = reflch(i1,na,:);
            reflch(i1,1+ng:256,:) = reflch(i1,1:256-ng,:);
            reflch(i1,1:ng,:) = tempa;
            tempa = reflab(i1,na,:);  % Must do same for reflab, samplab.
            reflab(i1,1+ng:256,:) = reflab(i1,1:256-ng,:);
            reflab(i1,1:ng,:) = tempa;
            tempa = samplab(i1,na,:);
            samplab(i1,1+ng:256,:) = samplab(i1,1:256-ng,:);
            samplab(i1,1:ng,:) = tempa;
         end 
      end
      reflch(:,:,3) = min(reflch(:,:,3),6);  reflch(:,:,3) = max(reflch(:,:,3),0);  % Keep bounded
   end
	
	cla;  set(gca,'Visible','on');
   newpos = handles.axpos;  % L B W H
   newpos(1) = newpos(1)+.10*newpos(3);  newpos(3) = .85*newpos(3);
   newpos(2) = newpos(2)+.08*newpos(4);  newpos(4) = .84*newpos(4);
   set(handles.axes1,'Position',newpos);
	
   rgbdata = icctrans(samplab, ['-t' num2str(handles.mon_intent-1) ' -i ' handles.labtmpr  ...
             ' -o ' handles.montemp]);  % *sRGB']);        % Background RGB image
	rgbdata = handles.hslight+(1-handles.hslight)*rgbdata;  % Lighten the image if called for.
   
   [temp, pltitle] = finderr(samplab,reflab,handles.difplt,handles.pltype);  % Difference to display
	hsm = [1 1; 1 1];  hsmk = hsm;  % Starting kernel for smoothing.
	nkrnl = ceil(256/50);
	for i1=1:nkrnl  hsmk = conv2(hsmk,hsm);  end
	hsmk = hsmk/sum(sum(hsmk));  % Normalize it. The kernel looks good.
	tempsm = smooth2(hsmk,temp);  % Smoothed difference, for contours. NLK routine; calls filter2.
   if handles.printest.on  temp = tempsm;  end  % Plot smoothed output in this case.
   tempsmax = max(tempsm(:));  bumpup = .005*tempsmax;  % Maximum values to control scaling.
   
   if     handles.HLview==1  %    % 2D L(HSL)-Hue image
      set(gca,'YDir','reverse');  % 'reverse' or 'normal'
      image(uint8(255*rgbdata));  hold on;  view([0, 90]);
      for i1=1:5  % Plot '+' vertically and horizontally.
         for j1=10:10:90  % j1 (L*) and handles.hslight should affect brightness.
            i2 = .85*handles.hslight + .008*(1-handles.hslight)*(100-j1);  % Lighten from bottom to top.
            text(i1*255/6+1,j1*2.55+1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
         end
      end
      [C,h] = contour(tempsm+.1*bumpup,'Color','k');	clabel(C,h);
      set(gca,'YDir','reverse');  % 'reverse' or 'normal'  Repeat!!!
   elseif handles.HLview==2  % 3D LH
      set(gca,'YDir','reverse');  % 'reverse' or 'normal' WHY reverse??????
      fcol   = 'interp';  handles.flight = 'gouraud';  % smooth... 'phong' or 'gouraud'
      handles.lightsurf = surf(temp, rgbdata, 'FaceColor', fcol, ...
         'EdgeColor','none','FaceLighting',handles.flight,'AmbientStrength',.8, ...
         'SpecularStrength',0,'DiffuseStrength',.5,'SpecularExponent',25, ...
         'SpecularColorReflectance',.5);  %
      % camlight(-45,45);  % Try camlight instead of lightangle (very inconsistent)
      if ~get(handles.check_light,'Value')  % No lighting.
         set(handles.lightsurf,'Facelighting','none');
      end
      hold on;  rotate3d on; 
      if max(tempsm(:))-min(tempsm(:))>.0001
         [C,h] = contour3(min(tempsm+bumpup,tempsmax),'Color','k');	clabel(C,h);
      end
      set(gca,'YDir','reverse');  % 'reverse' or 'normal' Must repeat! WHY reverse??????
      if handles.difplt==13 | handles.difplt==14  % Plot constant H lines in L* plots.
         for i1=1:256/12:256
            i2 = round(i1);
            plot3(i2*ones(1,256), 1:256, min(tempsm(:,i2)+bumpup,tempsmax),'Color','k');  % Const. H
            % plot3(1:256, i2*ones(1,256), min(tempsm(i2,:)+bumpup,tempsmax),'Color',[.3 .3 .3]);  % Const. L
         end
      end
   elseif handles.HLview==3  % 2D L*H*
      % surf(reflch(:,:,3), reflch(:,:,1), zeros(size(reflch(:,:,1))), rgbdata, ...
      surf(reflch(:,:,3), reflch(:,:,1), 0*reflch(:,:,2), rgbdata, 'EdgeColor','none');  
      hold on;  view(2);
	   for i1=1:6  % Plot '+' vertically and horizontally.
         for j1=10:10:90  % j1 (L*) and handles.hslight should affect brightness.
            i2 = .85*handles.hslight + .008*(1-handles.hslight)*j1;  % Lighten from bottom to top.
            text(i1,j1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
         end
		end
      [C,h] = contour(reflch(:,:,3), reflch(:,:,1), tempsm+.1*bumpup,'Color','k');	clabel(C,h);
   elseif handles.HLview==4  % 3D L*H*
      fcol   = 'interp';  handles.flight = 'gouraud';  % smooth... 'phong' or 'gouraud'
      handles.lightsurf = surf(reflch(:,:,3), reflch(:,:,1), temp, rgbdata, 'FaceColor', fcol, ...
         'EdgeColor','none','FaceLighting',handles.flight,'AmbientStrength',.8, ...
         'SpecularStrength',0,'DiffuseStrength',.5,'SpecularExponent',25, ...
         'SpecularColorReflectance',.5);  %
      if ~get(handles.check_light,'Value')  % No lighting.
         set(handles.lightsurf,'Facelighting','none');
      end
      % surf(reflch(:,:,3), reflch(:,:,1), reflch(:,:,2), rgbdata, ...
      hold on;  rotate3d on;  % view([0, 90]);
      % Tempsm is the smoothed difference function whose contour is plotted. 
      if max(tempsm(:))-min(tempsm(:))>.0001
         [C,h] = contour3(reflch(:,:,3), reflch(:,:,1), min(tempsm+bumpup,tempsmax), 'Color','k');  clabel(C,h);
      end
      if handles.difplt==13 | handles.difplt==14  % Plot constant H* lines in L* plots.
         % We have linspace(0,6,17), i1=2:16 (10/0/06). Would (0,6,13), i1=2:12 be better???
         warning off MATLAB:griddata:DuplicateDataPoints
         % test for interp2  ...,1 is (L*) is y; ...,3 (h*) is x. reflch(1:10,1:10,1), etc.
         [xi,yi] = meshgrid(linspace(0,6,13),linspace(100,0,101));  % Use griddata instead of interp2.
         zi = griddata(reflch(:,:,3),reflch(:,:,1),min(tempsm+2*bumpup,tempsmax),xi,yi); 
         zi = min(zi,100);
         for i1 = 2:12  % 6:5:56 % for (0,6,61)
            plot3(xi(:,i1),yi(:,i1),zi(:,i1),'Color',[.1 .1 .1]);
         end
      end
   end
	set(gca,'Color',.9*handles.hslight+(1-handles.hslight)*[.6 .6 .6]);  % Background color.
   % pcolor(reflch(:,:,3), reflch(:,:,1), rgbdata);  % Doesn't work with full-color rgbdata.
   % image(uint8(255*rgbdata));  % Shows the right stuff in rgbdata!
   % hsurf = pcolor(reflch(:,:,3));  set(hsurf, 'EdgeColor','none');  hold on;
   % temp = reflch(:,:,2);  % Variable to plot.
   
   if handles.HLview<=2  % L(HSL)-H image
      % There is a less critical problem with using the axis properties.
      xtick = [0:6]*255/6;  % xlim([0 255]);  % was 1+...
      ytick = [0:5]*255/5;  % ylim([0 255]); 
      set(gca,'XTickLabel', {'R';'Y';'G';'C';'B';'M'}, 'XTicklabelmode','manual','Xlim',[1 256], ...
         'XTickmode','manual','XTick',xtick,'YTickLabel', {'100';'80';'60';'40';'20';'0'}, ...
         'YTicklabelmode','manual', 'YTickmode','manual','YTick',ytick,'Ylim',[1 256]);
      % set(gca,'XTickLabel', {'R';'Y';'G';'C';'B';'M'}, 'XTicklabelmode','manual', ...
      %    'XTickmode','manual','XTick',xtick);
     	title({['HL Color differences for S = ' num2str(handles.satvar,3) ...
         ';  L(HSL) from 0 to 1']; [pltitle '  [' ...
         num2str(mplt) ',' num2str(nplt) ']']}, 'FontWeight','bold','Fontsize',handles.dfz-1);
		xlabel('Hue','FontWeight','bold','Fontsize',handles.dfz-1);
      ylabel('L(HSL)','FontWeight','bold','Fontsize',handles.dfz-1);
   else   % 2D or 3D L*H* image
	   set(gca,'YDir','normal');  % 'reverse' or 'normal'
      xtick = [0:.75:6];
      set(gca,'XTickLabel', {'0(+a*)';'';'90(+b*)';'';'180(-a*)';'';'270(-b*)';''}, ...
         'XTicklabelmode','manual', 'XLimMode','auto','XTickmode','manual', ...
         'XTick',xtick,'YTicklabelMode','auto','YtickMode','auto','Ylim',[0 100],'Fontsize',handles.dfz-1);
      % set(gca, 'XTicklabelmode','auto','XTickmode','auto', ...
      %    'YTicklabelmode','auto','Ytickmode','auto');
     	title({['h*L* Color differences for S = ' num2str(handles.satvar,3) ...
         ';  L(HSL) from 0 to 1']; [pltitle '  [' ...
         num2str(mplt) ',' num2str(nplt) ']']}, 'FontWeight','bold','Fontsize',handles.dfz-1);
		xlabel('Hue h* (Angle)','FontWeight','bold','Fontsize',handles.dfz-1);
      ylabel('L*','FontWeight','bold','Fontsize',handles.dfz-1);
      ax = axis;  ax(1) = 0;  axis(ax);
   end
   
   if handles.HLview==2 | handles.HLview==4  % 3D plots
      % These plots work fine uncompiled, but don't quite come out right compiled. Try adding more...
      set(gca,'ZTicklabelmode','auto','ZTickmode','auto','ZlimMode','auto','Fontsize',handles.dfz-1);
      if handles.HLinvert  set(gca,'ZDir','reverse');
      else                 set(gca,'ZDir','normal');
      end
      ax = axis;  % Scaling: keep expanding...
      handles.hl3dax = [min([ax(5),handles.hl3dax(1)]),max([ax(6),handles.hl3dax(2)])];  % Scaling
      ax([5,6]) = handles.hl3dax;  axis(ax);
      view([handles.HL_azim, handles.HL_elev]);
      camlight(-45,45);  % Try at end.
      rotate3d on;  axis normal;  % for now...  (or equal, image, square, ...)
      zlabel(pltitle,'FontWeight','bold');
   end
   zoom reset;
   
   if handles.HLview==1 | handles.HLview==3  % 2D image
	   ax = axis;
      txclr = [.2 .2 .4];  % Text color
		text(.03*ax(1)+.97*ax(2),.03*ax(3)+.97*ax(4),['Input:  ' handles.iccname{mplt}], ...
         'FontSize',handles.dfz-2,'Color',txclr,'HorizontalAlignment', ...
         'right','Interpreter','none');
		text(.03*ax(1)+.97*ax(2),.06*ax(3)+.94*ax(4),['Output: ' handles.iccname{nplt}], ...
         'FontSize',handles.dfz-2,'Color',txclr,'HorizontalAlignment', ...
         'right','Interpreter','none');
		text(.64*ax(1)+.36*ax(2),.97*ax(3)+.03*ax(4), daterun, 'Fontsize',handles.dfz-2, ...
         'HorizontalAlignment','center','Color',txclr);  % Date
   end
   %        END S(HSL)=1 Lc*h* COLOR DIFFERENCES FOR L(HSL) FROM 0 TO 1 (S1 region)


elseif handles.pltype==7   %  L5 xy SATURATION MAP for L = 0.5; 0 <= S <= 1
   
   set(gcf, 'Renderer', 'painters');  rotate3d off;  % 'zbuffer' 'opengl' or 'painters'
	lambda = [380:700 380]'*1e-9;  % Spectrum locus. In CW direction on xy plane. Excessive bounds?
	xyz1931 = ccxyz(lambda);  % xyz1931 is a line of size [362 3]. Last entry (380) is purple locus.
   if handles.xybdry
      lam_bdry = [400 470:10:540 560:20:620 700]'*1e-9;  % Wavelengths for boundary plot.
      xyz_bdry = ccxyz(lam_bdry);  sz_bdry = length(lam_bdry);  % For boundary plot.
      rgb_bdry = xyz2rgb(xyz_bdry,'ECI');  % Was 'WideGamut' 'ECI' 'ColorMatch'
      rgb_bdry = max(rgb_bdry,0)/max(max(rgb_bdry));
   end
	[maxx, nmxx] = max(xyz1931(:,1));  [maxy, nmxy] = max(xyz1931(:,2));
	% maxx = 0.7347; nmxx = 323; maxy = 0.8341; nmxy = 142;
	[minx, mmxx] = min(xyz1931(:,1));  [miny, mmxy] = min(xyz1931(:,2));
   % minx = 0.0037; mmxx = 125; miny = 0.0048; mmxy = 34
   y5 = round(1+linspace(0,1,6)*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
	ssxy =  icctrans(intarg(y5,257:512,:), ['-t1 -i ' handles.inprof ' -o *XYZ']);  % Inpt to XYZ D50.
	ssxy = xyz2xyy(ssxy);  % xy values of triangle corners.
	
   xlims = [0 maxx+.01];  ylims = [0 maxy+.01];  % Plot limits.
	pltsize = 251;
	xvals = linspace(xlims(1),xlims(2),pltsize);
	yvals = linspace(ylims(1),ylims(2),pltsize);
	xyydata = ones(pltsize,pltsize,3);        % Will become background image.
	xyydata(:,:,1) = ones(pltsize,1)*xvals;   % x
	xyydata(:,:,2) = yvals'*ones(1,pltsize);  % y
	xyydata(:,:,3) = xyydata(:,:,2);  % Y = y. % Works very well with HSV.
   % sqrt(xyydata(:,:,2));  % sqrt works pretty well with HSL; it broadens the CYM bands.
	xyzdata = xyy2xyz(xyydata);
	rgbdata = xyz2rgb(xyzdata,'ECI');   % Low sat. 5000K WP. Use with D50 mapping.
	% rgbdata = xyz2rgb(xyzdata,'Adobe RGB (1998)');  % 6500K WP.
   % Try lightening rgbdata in HSL and HSV. HSV has much nicer boundaries.
   tempdata = rgb2hsv(rgbdata);  tempgrid = meshgrid(1:pltsize)'/pltsize;
   % xyydata, tempdata, etc. have size [251 251 3], where pltsize = 251.
   % tempdata(:,:,3) = .5*(1+tempdata(:,:,3));  % Worked OK with HSL.
   tempdata(:,:,3) = 1;  % .25*(3+tempdata(:,:,3));  % OK with HSV.
   % Reduce Saturation, especially near bottom. This lightens blues, reds.
   if mod(handles.xycolor,2)==1  % Lighten plot.
      tempdata(:,:,2) = .5*(tempdata(:,:,2) + tempgrid.*tempdata(:,:,2));
   end
   rgbdata = hsv2rgb(tempdata);
   
   % Gray out data outside the horseshoe.
   nyrange = find(yvals>=miny & yvals<maxy);  yrange = yvals(nyrange);
   xleft  = interp1(xyz1931([35:nmxy],2) ,xyz1931([35:nmxy],1) , yrange, 'linear');
   sz1931 = length(xyz1931);
   xright = interp1(xyz1931([nmxy:sz1931],2),xyz1931([nmxy:sz1931],1), yrange, 'linear');
   nleft = 1+xleft*pltsize/xlims(2);  nright = 1+xright*pltsize/xlims(2);
   grayval = .4;  % *ones(size(rgbdata));  % Light gray array.
   n1 = nyrange(1)-1;
   for i1=nyrange
      rgbdata(i1,1:floor(nleft(i1-n1)),:)        = grayval;
      rgbdata(i1,floor(nright(i1-n1)):pltsize,:) = grayval;
   end
   rgbdata(1:min(nyrange)-1,:,:)       = grayval;
   rgbdata(max(nyrange)+1:pltsize,:,:) = grayval;
   rgbdata(pltsize,:,:) = 0;  rgbdata(:, pltsize,:) = 0; 
   clear tempdata tempgrid;
   
   % Limits for plotting '+' every 0.1 xy values. Unlike a*b*, x>0 and y>0.
   x20(1) = .1*ceil(xlims(1)*9.8);  x20(2) = .1*fix(xlims(2)*9.8);
   y20(1) = .1*ceil(ylims(1)*9.8);  y20(2) = .1*fix(ylims(2)*9.8);

	cla;  set(gca,'Visible','on');
   pos2d = handles.axpos;  % L B W H
   newpos = pos2d;  
   newpos(1) = pos2d(1)+.1*pos2d(3);   newpos(3) = .82*newpos(3);
   newpos(2) = pos2d(2)+.07*pos2d(4);  newpos(4) = .89*newpos(4);
	% handles.ax2d = axes('Position',newpos);  % REPEAT!
   set(handles.axes1,'Position',newpos);

	image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)]);
	ax = axis;
	set(gca,'YDir','normal');  % 'reverse' or 'normal'
	
	hold on;  
	for i1=x20(1):.1:x20(2)  % Plot '+' every 0.1 xy units vertically and horizontally.
      j2 = max(y20(1),i1-0.3);  % Remove 'x's outside horseshoe.
      j3 = min(y20(2),1.0-i1);  % Remove 'x's outside horseshoe.
      for j1=j2:.1:j3  % y20(2)
         i2 = .55+.2*(j1-y20(1))/(y20(2)-y20(1));  % Lighten from bottom to top.
         text(i1,j1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
      end
	end
	plot(ssxy(1,:,1),ssxy(1,:,2),'Color',[.2 .2 .2],'LineWidth',1.5,'LineStyle',':');  % Color space .
	
	nis = 6;
   ninc = 1;  if handles.xycolor>2  ninc = 5;  end  % Gamut boundaries & white pt. only.
	gcolors = [0 0 0;  0 0 1;  0 .6 0;  .8 0 0;  .6 .4 0;  .4 .4 .4;];  % for heavy lines.
	for i1=1:ninc:nis  % Look at cross-sections of L5_crop.  Code modified from L*a*b*
       llvl(i1) = .2*(i1-1);  % 0-1.
       y5 = round(1+llvl(i1)*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
       sgamut = outarg(y5,257:512,:);  % Should be RGB.
       % y5 = round(1+llvl(i1)*(sz_L5(1)-2));  % Avoid extremes.
       % sgamut = L5_crop(y5,:,:);  % Should be RGB.
       szg = size(sgamut);  sgamut = reshape(sgamut, szg(1)*szg(2), szg(3));
       szg = size(sgamut);  % 2D
       sgamut = [sgamut(szg(1)-3:szg(1),:); sgamut; sgamut(1:4,:)];  % Wrap: add 4 pts at each end.
       for ism=1:3  sgamut(:,ism) = smoothp(sgamut(:,ism),3);  end
       szg2 = size(sgamut);
       sgamut = sgamut(3:szg2(1)-2,:);  % Keep 1 extra pt at each end.
       % ssx = rgb2xyz(sgamut,colorspace);   % XYZ
	    ssx = icctrans(sgamut, ['-t1 -i ' handles.outprof ' -o *XYZ']);
       ssx = xyz2xyy(ssx);      % xyY
       plot(ssx(:,1),ssx(:,2),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
       if i1==nis  % i1==nis (6) is white point. Plot fails if all points equal.
          ssmean = mean(ssx);  ssmax = max(ssx);  ssmin = min(ssx);
          if ssmax(1)==ssmin(1) & ssmax(2)==ssmin(2)
             line(ssmin(1),ssmin(2), 'Marker', '.', 'Color', [.4 .4 .4], ...
                'MarkerSize',handles.dfz+2);
          end
       end 
	end
	set(gca,'Xlim',xlims,'Ylim',ylims);  % 'reverse' or 'normal'
   if handles.xycolor<3
	   hleg = legend('Input','S=1.0','S=0.8','S=0.6','S=0.4','S=0.2','S=0.0',4);
   	set(hleg,'Color',[.9 .8 .9]);
   end
	% set(hleg,'Color',[.9 .8 .9],'Position',get(hleg,'Position')-[.04 0 0 0]);  % Fix Position BUG!
	% gcolors = [.2 .2 .2;  .2 .2 1;  .1 .7 .1;  .7 .1 .1;  .6 .4 .1;  .5 .5 .5;];  % for ideal
	plot(xyz1931(:,1),xyz1931(:,2),'Color',[.2 .2 .2],'LineWidth',1.5);  % 1931 Chromaticity locus.
   if handles.xybdry
      for i1=1:sz_bdry
 	     plot(xyz_bdry(i1,1),xyz_bdry(i1,2),'o','MarkerEdgeColor',[.5 .5 .5], ...
           'MarkerFaceColor', rgb_bdry(i1,:));  % 1931 Chromaticity boundary pts.
     end
     text(xyz_bdry(1,1)-.022,xyz_bdry(1,2)+.007,num2str(lam_bdry(1)*1e9,3),...
        'Color', [.9 .9 .9], 'HorizontalAlignment','Right', 'FontSize', handles.dfz-1);  % 400
     for i1=2:3
        text(xyz_bdry(i1,1)-.016,xyz_bdry(i1,2),num2str(lam_bdry(i1)*1e9,3), 'Color',[.9 .9 .9], ...
           'HorizontalAlignment','Right','FontSize', handles.dfz-1);  % 470,480
     end
     for i1=4:6
        text(xyz_bdry(i1,1)+.016,xyz_bdry(i1,2),num2str(lam_bdry(i1)*1e9,3), 'Color',[.2 .2 .2], ...
           'FontSize', handles.dfz-1);
     end
     text(xyz_bdry(7,1)-.022,xyz_bdry(7,2)-.004,num2str(lam_bdry(7)*1e9,3),...
        'Color', [.9 .9 .9],'HorizontalAlignment','Right', 'FontSize',handles.dfz-1);  % 520
     for i1=[8:sz_bdry-1]
        text(xyz_bdry(i1,1)+.016,xyz_bdry(i1,2),num2str(lam_bdry(i1)*1e9,3), 'Color',[.9 .9 .9], ...
           'FontSize',handles.dfz-1);
     end
     text(xyz_bdry(sz_bdry,1)-.018,xyz_bdry(sz_bdry,2)+.003,num2str(lam_bdry(sz_bdry)*1e9,3),...
        'Color', [.2 .2 .2], 'FontSize',handles.dfz-1, 'HorizontalAlignment','Right');  % 700
   end
   n1 = 2;  if handles.xycolor>2  n1 = nis;  end  % Gamut boundaries & white pt. only.
	for i1=n1:nis
       plot(ssxy(i1,:,1),ssxy(i1,:,2),'Color',gcolors(i1,:), ...
          'LineStyle',':','LineWidth',1.5);  % Ideal.
	end
	text(.03*ax(1)+.97*ax(2),.03*ax(3)+.97*ax(4),['Input:  ' handles.iccname{mplt}], ...
      'FontSize',handles.dfz-2, 'Color',[1 1 1],'HorizontalAlignment','right', ...
      'FontWeight','bold','Interpreter','none');
	text(.03*ax(1)+.97*ax(2),.06*ax(3)+.94*ax(4),['Output: ' handles.iccname{nplt}], ...
      'FontSize',handles.dfz-2, 'Color',[1 1 1],'HorizontalAlignment','right', ...
      'FontWeight','bold','Interpreter','none');
   text(.03*ax(1)+.97*ax(2),.09*ax(3)+.91*ax(4), ['White point:  x = ' ...
      num2str(ssmean(1),3) '  y = ' num2str(ssmean(2),3)], 'Fontsize',handles.dfz-2, ...
      'FontWeight','bold','HorizontalAlignment','right', 'Color',[1 1 1]);  % White point
   text(.03*ax(1)+.97*ax(2),.12*ax(3)+.88*ax(4), daterun, 'Fontsize',handles.dfz-2, ...
      'FontWeight','bold','HorizontalAlignment','right', 'Color',[1 1 1]);  % Date
   if handles.xycolor<3 
	   title('CIE 1931 xy Chromaticity diagram for L=0.5; S from 0 to 1', ...
         'FontWeight','bold','Fontsize',handles.dfz);
   else
	   title('CIE 1931 xy Chromaticity diagram','FontWeight','bold','Fontsize',handles.dfz);
   end
	xlabel('x','FontWeight','bold');  ylabel('y','FontWeight','bold');
   %              END L5 xy SATURATION MAP for L = 0.5; S from 0 to 1
   

elseif handles.pltype==8   %  L5 u'v' SATURATION MAP for L = 0.5; 0 <= S <= 1
   
   set(gcf, 'Renderer', 'painters');  rotate3d off;  % 'zbuffer' 'opengl' or 'painters'
	lambda = [380:700 380]'*1e-9;  % Spectrum locus. In CW direction on xy plane. Excessive bounds?
   % ccxyz gives XYZ with a maximum of 1 (not 100).
	xyz1931 = ccxyz(lambda);  % xyz1931 is a line of size [362 3]. Last entry (380) is purple locus.
   luv1976 = xyz2uv(xyz1931);  % Use 5000K white for now.
   if handles.xybdry
      lam_bdry = [400 460:10:500 520:20:620 700]'*1e-9;  % Wavelengths for boundary plot.
      xyz_bdry = ccxyz(lam_bdry);  sz_bdry = length(lam_bdry);  % For boundary plot.
      luv_bdry = xyz2uv(xyz_bdry);  % Use 5000K white for now.
      rgb_bdry = xyz2rgb(xyz_bdry,'ECI');  % Was 'WideGamut' 'ECI' 'ColorMatch'
      rgb_bdry =  max(rgb_bdry,0)/max(max(rgb_bdry));
   end
	[maxx, nmxx] = max(luv1976(:,2));  [maxy, nmxy] = max(luv1976(:,3));  % Different indices from xy.
	[minx, mmxx] = min(luv1976(:,2));  [miny, mmxy] = min(luv1976(:,3));
   y5 = round(1+linspace(0,1,6)*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
	ssxy =  icctrans(intarg(y5,257:512,:), ['-t1 -i ' handles.inprof ...
      ' -o *XYZ']);  % Inpt to XYZ D50.
	ssluv = xyz2uv(ssxy);  % (L)uv values of triangle corners.
	
   xlims = [0 .65];  ylims = [0 .65];  % Plot limits.
	pltsize = 251;
	xvals = linspace(xlims(1),xlims(2),pltsize);
	yvals = linspace(ylims(1),ylims(2),pltsize);
	uvdata        = ones(pltsize,pltsize,2);
   xyydata       = ones(pltsize,pltsize,3);  % Will become background image.
	uvdata(:,:,1) = ones(pltsize,1)*xvals;    % u (changed) NOT xyy!
	uvdata(:,:,2) = yvals'*ones(1,pltsize);   % v (changed)
   xyydata(:,:,1:2) = uv2xy(uvdata(:,:,1:2));  % Convert to xy(Y).
	xyydata(:,:,3) = xyydata(:,:,2);  % Y = y. % Works very well with HSV.
   % sqrt(xyydata(:,:,2));  % sqrt works pretty well with HSL; it broadens the CYM bands.
	xyzdata = xyy2xyz(xyydata);
	rgbdata = xyz2rgb(xyzdata,'ECI');   % Low sat. 5000K WP. Use with D50 mapping.
	% rgbdata = xyz2rgb(xyzdata,'Adobe RGB (1998)');  % 6500K WP.
   % Try lightening rgbdata in HSL and HSV. HSV has much nicer boundaries.
   tempdata = rgb2hsv(rgbdata);  tempgrid = meshgrid(1:pltsize)'/pltsize;
   % xyydata, tempdata, etc. have size [251 251 3], where pltsize = 251.
   % tempdata(:,:,3) = .5*(1+tempdata(:,:,3));  % Worked OK with HSL.
   tempdata(:,:,3) = 1;  % .25*(3+tempdata(:,:,3));  % OK with HSV.
   % Reduce Saturation, especially near bottom. This lightens blues, reds.
   if mod(handles.xycolor,2)==1  % Lighten plot.
      tempdata(:,:,2) = .5*(tempdata(:,:,2) + tempgrid.*tempdata(:,:,2));
   end
   rgbdata = hsv2rgb(tempdata);
   
   % Gray out data outside the horseshoe.
   nyrange = find(yvals>=miny & yvals<maxy);  yrange = yvals(nyrange);
   xleft  = interp1(luv1976([35:nmxy],3) ,luv1976([35:nmxy],2) , yrange, 'linear');
   sz1931 = length(luv1976);
   xright = interp1(luv1976([nmxy:sz1931],3),luv1976([nmxy:sz1931],2), yrange, 'linear');
   nleft = 1+xleft*pltsize/xlims(2);  nright = 1+xright*pltsize/xlims(2); 
   grayval = .4;  % *ones(size(rgbdata));  % Light gray array.
   n1 = nyrange(1)-1;
   for i1=nyrange
      rgbdata(i1,1:floor(nleft(i1-n1)),:)        = grayval;
      rgbdata(i1,floor(nright(i1-n1)):pltsize,:) = grayval;
   end
   rgbdata(1:min(nyrange)-1,:,:)       = grayval;
   rgbdata(max(nyrange)+1:pltsize,:,:) = grayval;
   rgbdata(pltsize,:,:) = 0;  rgbdata(:, pltsize,:) = 0; 
   clear tempdata tempgrid;       % End gray out...
   
   % Limits for plotting '+' every 0.1 xy values. Unlike a*b*, x>0 and y>0.
   x20(1) = .1;  x20(2) = .5;
   y20(1) = .1;  y20(2) = .5;

	cla;  set(gca,'Visible','on');
   pos2d = handles.axpos;  % L B W H
   newpos = pos2d;  
   newpos(1) = pos2d(1)+.1*pos2d(3);   newpos(3) = .86*newpos(3);
   newpos(2) = pos2d(2)+.07*pos2d(4);  newpos(4) = .88*newpos(4);
	% handles.ax2d = axes('Position',newpos);  % REPEAT!
   set(handles.axes1,'Position',newpos);

	image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)]);
	ax = axis;
	set(gca,'YDir','normal');  % 'reverse' or 'normal'
   if handles.xycolor<3 
	   title('CIE u''v'' Chromaticity diagram for L=0.5; S from 0 to 1', ...
         'FontWeight','bold','Fontsize',handles.dfz);
   else
	   title('CIE u''v'' Chromaticity diagram','FontWeight','bold','Fontsize',handles.dfz);
   end
	
	hold on;  
	for i1=x20(1):.1:x20(2)  % Plot '+' every 0.1 xy units vertically and horizontally.
      j2 = max(y20(1),i1-0.2);  % Remove 'x's outside horseshoe.
      j2 = max(j2,0.3-i1);  % Remove 'x's outside horseshoe.
      for j1=j2:.1:.5  % y20(2)
         i2 = .55+.2*(j1-y20(1))/(y20(2)-y20(1));  % Lighten from bottom to top.
         text(i1,j1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
      end
	end
	plot(ssluv(1,:,2),ssluv(1,:,3),'Color',[.2 .2 .2],'LineWidth',1.5,'LineStyle',':');  % Color space .
	
	nis = 6;
   ninc = 1;  if handles.xycolor>2  ninc = 5;  end  % Gamut boundaries & white pt. only.
	gcolors = [0 0 0;  0 0 1;  0 .6 0;  .8 0 0;  .6 .4 0;  .4 .4 .4;];  % for heavy lines.
	for i1=1:ninc:nis  % Look at cross-sections of L5_crop.  Code modified from L*a*b*
       llvl(i1) = .2*(i1-1);  % 0-1.
       y5 = round(1+llvl(i1)*(handles.sz_L5(1)-1));  % Extremes OK for simulation.
       sgamut = outarg(y5,257:512,:);  % Should be RGB.
       % y5 = round(1+llvl(i1)*(sz_L5(1)-2));  % Avoid extremes.
       % sgamut = L5_crop(y5,:,:);  % Should be RGB.
       szg = size(sgamut);  sgamut = reshape(sgamut, szg(1)*szg(2), szg(3));
       szg = size(sgamut);  % 2D
       sgamut = [sgamut(szg(1)-3:szg(1),:); sgamut; sgamut(1:4,:)];  % Wrap: add 4 pts at each end.
       for ism=1:3  sgamut(:,ism) = smoothp(sgamut(:,ism),3);  end
       szg2 = size(sgamut);
       sgamut = sgamut(3:szg2(1)-2,:);  % Keep 1 extra pt at each end.
       % ssx = rgb2xyz(sgamut,colorspace);   % XYZ
	    ssx = icctrans(sgamut, ['-t1 -i ' handles.outprof ' -o *XYZ']);
       ssx = xyz2uv(ssx);  % ssx = xyz2xyy(ssx);      % xyY
       plot(ssx(:,2),ssx(:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
       if i1==nis  % i1==nis (6) is white point. Plot fails if all points equal.
          ssmean = mean(ssx);  ssmax = max(ssx);  ssmin = min(ssx);
          if ssmax(1)==ssmin(1) & ssmax(2)==ssmin(2)
             line(ssmin(1),ssmin(2), 'Marker', '.', 'Color', [.4 .4 .4], ...
                'MarkerSize',handles.dfz+2);
          end
       end 
	end
	set(gca,'Xlim',xlims,'Ylim',ylims);  % 'reverse' or 'normal'
   if handles.xycolor<3
	   hleg = legend('Input','S=1.0','S=0.8','S=0.6','S=0.4','S=0.2','S=0.0',4);
   	set(hleg,'Color',[.9 .8 .9]);
   end
	% set(hleg,'Color',[.9 .8 .9],'Position',get(hleg,'Position')-[.04 0 0 0]);  % Fix Position BUG!
	% gcolors = [.2 .2 .2;  .2 .2 1;  .1 .7 .1;  .7 .1 .1;  .6 .4 .1;  .5 .5 .5;];  % for ideal
	plot(luv1976(:,2),luv1976(:,3),'Color',[.2 .2 .2],'LineWidth',1.5);  % 1931 Chromaticity locus.
   if handles.xybdry
      for i1=1:sz_bdry
 	     plot(luv_bdry(i1,2),luv_bdry(i1,3),'o','MarkerEdgeColor',[.5 .5 .5], ...
           'MarkerFaceColor', rgb_bdry(i1,:));  % 1931 Chromaticity boundary pts.
     end
     for i1=1:4
        text(luv_bdry(i1,2)-.012,luv_bdry(i1,3),num2str(lam_bdry(i1)*1e9,3), 'Color',[.9 .9 .9], ...
           'HorizontalAlignment','Right','FontSize', handles.dfz-1);  % 470,480
     end
     for i1=5:6
        text(luv_bdry(i1,2)+.012,luv_bdry(i1,3),num2str(lam_bdry(i1)*1e9,3), 'Color',[.2 .2 .2], ...
           'FontSize', handles.dfz-1);
     end
     text(luv_bdry(7,2)+.008,luv_bdry(7,3)+.016,num2str(lam_bdry(7)*1e9,3), 'Color',[.9 .9 .9], ...
        'FontSize',handles.dfz-1);
     for i1=[8:sz_bdry-1]
        text(luv_bdry(i1,2)+.010,luv_bdry(i1,3)+.010,num2str(lam_bdry(i1)*1e9,3), 'Color',[.9 .9 .9], ...
           'FontSize',handles.dfz-1);
     end
     text(luv_bdry(sz_bdry,2)-.018,luv_bdry(sz_bdry,3)-.010,num2str(lam_bdry(sz_bdry)*1e9,3),...
        'Color', [.2 .2 .2], 'FontSize',handles.dfz-1, 'HorizontalAlignment','Right');  % 700
   end
   n1 = 2;  if handles.xycolor>2  n1 = nis;  end  % Gamut boundaries & white pt. only.
	for i1=n1:nis
       plot(ssluv(i1,:,2),ssluv(i1,:,3),'Color',gcolors(i1,:), ...
          'LineStyle',':','LineWidth',1.5);  % Ideal.
	end
	text(.03*ax(1)+.97*ax(2),.03*ax(3)+.97*ax(4),['Input:  ' handles.iccname{mplt}], ...
      'FontSize',handles.dfz-2, 'Color',[1 1 1],'HorizontalAlignment','right', ...
      'FontWeight','bold','Interpreter','none');
	text(.03*ax(1)+.97*ax(2),.06*ax(3)+.94*ax(4),['Output: ' handles.iccname{nplt}], ...
      'FontSize',handles.dfz-2, 'Color',[1 1 1],'HorizontalAlignment','right', ...
      'FontWeight','bold','Interpreter','none');
   text(.03*ax(1)+.97*ax(2),.09*ax(3)+.91*ax(4), ['White point:  x = ' ...
      num2str(ssmean(1),3) '  y = ' num2str(ssmean(2),3)], 'Fontsize',handles.dfz-2, ...
      'FontWeight','bold','HorizontalAlignment','right', 'Color',[1 1 1]);  % White point
   text(.03*ax(1)+.97*ax(2),.12*ax(3)+.88*ax(4), daterun, 'Fontsize',handles.dfz-2, ...
      'FontWeight','bold','HorizontalAlignment','right', 'Color',[1 1 1]);  % Date
	xlabel('u''','FontWeight','bold');  ylabel('v''','FontWeight','bold');
   %              END L5 uv SATURATION MAP for L = 0.5; S from 0 to 1
   
   
elseif handles.pltype==9   %  2D HSL
	
   rgbdata = icctrans(outarg(:,handles.plotzone,:), ['-t1 -i ' handles.outprof ' -p ' ...
     handles.labtmpr ' -o ' handles.montemp ' -r' num2str(handles.mon_intent-1)] );
   s_hsl  = rgb2hsl(rgbdata);  % HSL array for s1 region.
	sz = size(s_hsl);
   % Fix hues-- remove discontinuity-- on left and right.
   stemp = s_hsl(:,1:round(.35*sz(2)),1);  temp = find(stemp>.7);
   stemp(temp) = stemp(temp)-1;  s_hsl(:,1:round(.35*sz(2)),1) = stemp;
   stemp = s_hsl(:,round(.65*sz(2)):sz(2),1);  temp = find(stemp<.3);
   stemp(temp) = stemp(temp)+1;  s_hsl(:,round(.65*sz(2)):sz(2),1) = stemp;
   
   if handles.hsldelta  % Plot difference
      s_nom = rgb2hsl(intarg(:,handles.plotzone,:));
      stemp = s_nom(:,1:round(.35*sz(2)),1);  temp = find(stemp>.7);
      stemp(temp) = stemp(temp)-1;  s_nom(:,1:round(.35*sz(2)),1) = stemp;
      stemp = s_nom(:,round(.65*sz(2)):sz(2),1);  temp = find(stemp<.3);
      stemp(temp) = stemp(temp)+1;  s_nom(:,round(.65*sz(2)):sz(2),1) = stemp;
	   s_hsl = s_hsl-s_nom;
   end
   clear stemp temp
   
	% MUST be smoothed for contour plots!
	s_smooth = s_hsl;
	hsm = [1 1; 1 1];  hsmk = hsm;  % Starting kernel.
	nkrnl = ceil(sz/50);
	for i1=1:nkrnl  hsmk = conv2(hsmk,hsm);  end
	hsmk = hsmk/sum(sum(hsmk));  % Normalize it.
	
	s_smooth(:,:,1) = smooth2(hsmk,s_hsl(:,:,1));  % H
	s_smooth(:,:,2) = smooth2(hsmk,s_hsl(:,:,2));  % S
	s_smooth(:,:,3) = smooth2(hsmk,s_hsl(:,:,3));  % L
	xtick = 1+round([0:6]*(sz(2)-1)/6.0001);      % Used later.
	ytick = 1+round([0:5]*(sz(1)-1)/5.0001);  

	cla;  set(gca,'Visible','on');
   pos2d = handles.axpos;  % L B W H
   newpos = pos2d;  
   newpos(1) = pos2d(1)+.10*pos2d(3);  newpos(3) = .85*newpos(3);
   newpos(2) = pos2d(2)+.11*pos2d(4);  newpos(4) = .84*newpos(4);
	% handles.ax2d = axes('Position',newpos);  % REPEAT!
   set(handles.axes1,'Position',newpos);
   
	image(uint8(255*(handles.hslight+(1-handles.hslight)*rgbdata)));
   xlims = [0 1];  ylims = [0 1];  % Plot limits.
   hold on;
	set(gca,'YDir','reverse');  % 'reverse' or 'normal'
	% set(gca,'YDir','reverse','Xlim',xlims,'Ylim',ylims);  % 'reverse' or 'normal'
   ax = axis;
   hslctp = 1+mod(handles.hslplot-1,3);  % HSL contour to plot.
	
	if hslctp==1  % Hue contours
	   set(gca,'XTickLabel', {'R(0)';'Y(1)';'G(2)';'C(3)';'B(4)';'M(5)';'R(6)'}, 'XTicklabelmode','manual', ...
         'XTickmode','manual','XTick',xtick,'YTickLabel', {'1.0';'0.8';'0.6';'0.4';'0.2';'0'}, ...
         'YTicklabelmode','manual', 'YTickmode','manual','YTick',ytick);
      if handles.hsldelta
	      [C,h] = contour(6*s_smooth(:,:,hslctp),[0:.1:1.5]);
      else
	      [C,h] = contour(6*s_smooth(:,:,hslctp),[0:.5:6]);
      end
   else          % Saturation or Lightness contours
	   set(gca,'XTickLabel', {'R';'Y';'G';'C';'B';'M'}, 'XTicklabelmode','manual', ...
         'XTickmode','manual','XTick',xtick,'YTickLabel', {'1.0';'0.8';'0.6';'0.4';'0.2';'0'}, ...
         'YTicklabelmode','manual', 'YTickmode','manual','YTick',ytick);
      if hslctp==3 & handles.hsldelta
	      [C,h] = contour(s_smooth(:,:,hslctp),[-.5:.05:.5]);
      else
	      [C,h] = contour(s_smooth(:,:,hslctp));  % Auto contour selection (usually 0.1 increments)
      end
   end
   C = round(1000*C)/1000;  % Avoide numbers like 1.0379e-17.
	clabel(C,h);
   ttl = pltlist{handles.hslplot};
   if handles.hsldelta
      ttl = ['Delta (difference from nominal): ' ttl];
   end
	title(ttl, 'FontWeight','bold', 'Fontsize',handles.dfz);
	xlabel('H (HSL Hue)','FontWeight','bold');
	ylabel('L (HSL Lightness)','FontWeight','bold');

   
elseif handles.pltype==10   %  B&W TONAL RESPONSE (DENSITY/DMAX PLOT)
	
   set(gcf, 'Renderer', 'painters');  rotate3d off;  % 'zbuffer' 'opengl' or 'painters'
	cla;  reset(gca);  set(gca,'Visible','on');
   pos2d = handles.axpos;  % L B W H
   newpos = pos2d;  newpos(1) = pos2d(1)+.11*pos2d(3);  newpos(3) = .8*newpos(3);
   newpos(2) = pos2d(2)+.11*pos2d(4);  newpos(4) = .82*newpos(4);
   set(handles.axes1,'Position',newpos);
	
	%                GRAY SCALE RESPONSE (LINEAR; LOWER LEFT).
   gr_in  = mean(intarg(:,545:576,:),2);  % 3D color input  for gray, averaged to 2D (still in color)
   gr_out = mean(outarg(:,545:576,:),2);  % 3D color output for gray, averaged to 2D
   col_in  = intarg(:,round(576+linspace(1,256,7)),:);  % Color  input: RYGCBMR.  Vary saturation.
   col_out = outarg(:,round(576+linspace(1,256,7)),:);  % Color output: RYGCBMR.
	gray_meot = .3*gr_out(:,:,1)+.59*gr_out(:,:,2)+.11*gr_out(:,:,3);  % mean(gr_out,3);
   gray_meot = max(gray_meot,.0001);  
   % col_out = max(col_out,.0001);
   
   if handles.printest.on & nplt==2  % Second region (different location on printed chart).
      gr_in2 =  mean(intarg(:,513:544,:),2);  % 3D color input,  averaged to 2D
      gr_out2 = mean(outarg(:,513:544,:),2);  % 3D color output, averaged to 2D
	   gray_meot2 = .3*gr_out2(:,:,1)+.59*gr_out2(:,:,2)+.11*gr_out2(:,:,3);  
      gray_meot2 = max(gray_meot2,.0001);  % 2D gray output
   end
	
	%               GRAY SCALE DENSITY RESPONSE (UPPER LEFT).
   xvals = linspace(1,0,256);  xvals = max(xvals, .001);  % Decreasing values.
   xyzdata  = icctrans(gr_in,   ['-t1 -i ' handles.inprof '  -o *XYZ']);
   xyzdatb  = icctrans(gr_out,  ['-t1 -i ' handles.outprof ' -o *XYZ']);  % size(xyzdatb)
   % xyzcol   = icctrans(col_out, ['-t1 -i ' handles.outprof ' -o *XYZ']);  % size(xyzcol)
   labdata = xyzdata(:,2);   labdata = max(labdata,.0001);  % Linear: input and output Y (luminance).
   labdatb = xyzdatb(:,2);   labdatb = max(labdatb,.0001);  % Note: is NOT L*a*b*.
   % labdatc = xyzcol(:,:,2);  labdatc = max(labdatc,.0001);  % Luminance for RYGCBMR.
   lincol = {[1 0 0]; [.9 .8 0]; [0 .85 0]; [0 .85 .85]; [.3 .3 1]; [1 0 1]; [1 0 0]};  % Line colors RYGCBMR.

   if handles.bwplot>3
	   laba    = icctrans(gr_in,   ['-t1 -i ' handles.inprof '  -o *Lab']);
	   labb    = icctrans(gr_out,  ['-t1 -i ' handles.outprof ' -o *Lab']);
	   labcola = icctrans(col_in,  ['-t1 -i ' handles.inprof '  -o *Lab']);
	   labcolb = icctrans(col_out, ['-t1 -i ' handles.outprof ' -o *Lab']);
	   % lab   = icctrans(col_out, ['-t1 -i ' handles.outprof ' -o *Lab']);
   end
	% plot(log10([2:lgm-1]/lgm), polyval(igam3,log10(gray_mean(3:lgm))),'k','LineWidth',1.5);
	hold on;
   % Use mplt (inp: 1-4) and nplt (out: 1-4) to determine plot details.
   if     handles.bwplot==1  % Density vs. log pixels. The mean slope of this curve is gamma.
      if mplt==1 | mplt==3  % Normal input profile
         plot(log10(xvals(1:end-2)), -log10(labdata(1:end-2)),'Color', [0 .9 0]);
      else  % Compare output profiles
         plot(log10(xvals(1:end-2)), -log10(labdata(1:end-2)),'Color', [0 .7 0],'Marker','.');
      end
      plot(log10(xvals(1:end-2)), -log10(gray_meot(1:end-2)),':','Color',[.5 .5 .5]);
      plot(log10(xvals(1:end-2)), -log10(labdatb(1:end-2)),'-k.');
	   legend('Input density','Output Log(pixels/255)','Output density',2);
      % for i2 =1:6  % Not ready for prime time!
      %    plot(log10(xvals(1:end-2)), -log10(labdatc(1:end-2,i2)),'Color',lincol{i2});
      % end
      % mlab = min(-log10(labdatb(1:end-2)));  mlab = max(mlab,0);
   elseif handles.bwplot==2  % Output vs. input density
      line([0 2.5],[0 2.5],'Color',[.8 .8 .5],'LineStyle',':');
      if (mplt==2 | mplt==4) & (nplt==2 | nplt==4)  % Compare output profiles
         gr_in3 =  mean(handles.ftarg(:,545:576,:),2);  % Input
		   xyzdata3  = icctrans(gr_in3, ['-t1 -i ' handles.inprof  ' -o *XYZ']);  % 10/07/06
		   xyzdatb3  = icctrans(gr_in3, ['-t1 -i ' handles.outprof ' -o *XYZ']);  % 10/07/06
         labdata3 = xyzdata3(:,2);  labdatb3 = xyzdatb3(:,2);  % Linear: input and output Y (luminance).
         labdata3 = max(labdata3,.0001);  labdatb3 = max(labdatb3,.0001);  % Note: is NOT L*a*b*.
  	      plot(-log10(labdata3(1:end-1)),-log10(labdata(1:end-1)),'Color',[0 .7 0],'Marker','.');
  	      plot(-log10(labdatb3(1:end-1)),-log10(labdatb(1:end-1)),'-k.');
      else
  	      plot(-log10(labdata(1:end-1)),-log10(labdatb(1:end-1)),'-k.');
      end
      % mlab = min(-log10(labdatb(1:end-1)));  mlab = max(mlab,0);
   elseif handles.bwplot==3  % Output vs. input luminance
  	   plot(labdata(1:end-1),labdatb(1:end-1),'-k.');  % 'Color', [0 0 0],'LineWidth',1.5);
      mlab = max(labdatb(1:end-1));  mlab = max(1,mlab);
   elseif handles.bwplot==4  % Output vs. input L*
      temp = 10*sqrt(labb(1:end-15,2).^2 + labb(1:end-15,3).^2);  % Chroma
  	   plot(laba(1:end-15,1),10*labb(1:end-15,2),':', 'Color', [0 .3 1],'LineWidth',1.5);  % a* blue-cyan
  	   plot(laba(1:end-15,1),10*labb(1:end-15,3),':', 'Color', [1 0 .5],'LineWidth',1.5);  % b* red-mag
  	   plot(laba(1:end-15,1),temp,':', 'Color', [0 .8 0],'LineWidth',1.5);  % Chroma c*  green
  	   plot(laba(1:end-1,1),labb(1:end-1,1),'-k.');  % 'Color', [0 0 0],'LineWidth',1.5);
      legend('10x a*','10x b*','10x c* (Chroma)','L*',2);
      for i2 =1:6 
         plot(labcola(1:end-1,i2),labcolb(1:end-1,i2),'Color',lincol{i2});
      end
  	   plot(laba(1:end-1,1),labb(1:end-1,1),'-k.');  % Repeat to put on top.
      % mlab = max(max(labb(1:end-15,:)));  mlab = max(128,mlab);
   end
   den_mean = max(-log10(labdatb(1:end-3)));  prtmean = '';
   
   if handles.printest.on & nplt==2
      prtmean = ' (mean)';  % Display mean for Print Test only.
		xyzdata = icctrans(gr_in2,  ['-t1 -i ' handles.inprof  ' -o *XYZ']);
		xyzdatb = icctrans(gr_out2, ['-t1 -i ' handles.outprof ' -o *XYZ']);
      labdata2 = xyzdata(:,2);  labdatb2 = xyzdatb(:,2);  % Linear: input and output Y (luminance).
      labdata2 = max(labdata2,.0001);  labdatb2 = max(labdatb2,.0001);
      if handles.bwplot>3
	      laba  = icctrans(gr_in2,  ['-t1 -i ' handles.inprof  ' -o *Lab']);
	      labb  = icctrans(gr_out2, ['-t1 -i ' handles.outprof ' -o *Lab']);
      end
      if     handles.bwplot==1 % Density vs. log pixels
         if mplt==1 | mplt==3  % Normal input profile
            plot(log10(xvals(1:end-2)), -log10(labdata2(1:end-2)),'Color', [0 .9 0]);
         else  % Compare output profiles
            plot(log10(xvals(1:end-2)), -log10(labdata2(1:end-2)),'Color', [0 .7 0],'Marker','.');
         end
		   plot(log10(xvals(1:end-2)), -log10(gray_meot2(1:end-2)),':','Color',[.5 .5 1]);
		   plot(log10(xvals(1:end-2)), -log10(labdatb2(1:end-2)),'Color',    [0 0 1],'LineWidth',1.5);
         % mlab = min(mlab, min(-log10(labdatb2(1:end-2))));
      elseif handles.bwplot==2  % Output vs. input density
  	      plot(-log10(labdata2(1:end-1)),-log10(labdatb2(1:end-1)),'Color', [0 0 1],'LineWidth',1.5);
         % mlab = min(mlab, min(-log10(labdatb2(1:end-1))));
      elseif handles.bwplot==3  % Output vs. input luminance
  	      plot(labdata2(1:end-1),labdatb2(1:end-1),'Color', [0 0 0],'LineWidth',1.5);
         mlab = max(mlab,max(labdatb2(1:end-1)));
      elseif handles.bwplot==4  % Output vs. input L*
         temp = 10*sqrt(labb(1:end-15,2).^2 + labb(1:end-15,3).^2);  % Chroma
     	   plot(laba(1:end-15,1),10*labb(1:end-15,2),':', 'Color', [0 .5 1]);  % a* blue-cyan
     	   plot(laba(1:end-15,1),10*labb(1:end-15,3),':', 'Color', [1 0 .5]);  % b* red-mag
     	   plot(laba(1:end-15,1),temp,':', 'Color', [0 .8 0],'LineWidth',1.5);  % Chroma c*  green
     	   plot(laba(1:end-1,1),labb(1:end-1,1),'-k');  % 'Color', [0 0 0],'LineWidth',1.5);
         % mlab = max(max(labb(1:end-15,:)));  mlab = max(128,mlab);
      end
      den_mean = (den_mean + max(-log10(labdatb2(1:end-3))))/2;
	  	title(['Print test: ' strrep(handles.prtitle,'_','\_')],'Color',[.2 .2 .2], ...
	      'FontWeight','bold')
   end
	% den_kr = polyval(igam3,log10(mean(kr_mean)));  den_r2k = polyval(igam3,log10(mean(r2k_mean)));
	% den_mean = (den_kr+den_r2k)/2;
	% line([-2 0],[den_kr den_kr],'Color',[0 0 0]);
	% line([-2 0],[den_r2k den_r2k],'Color',[0 0 .8]);
	lightgrid([.8 .8 .8],'k');  
	ax = axis;  % [XMIN XMAX YMIN YMAX]
	ylabel('Output Density', 'FontWeight','bold');
   if handles.bwplot==1 % Density vs. log pixels
	   xlabel('Log(Pixel level / 255)', 'FontWeight','bold');
	   ax = [-2 0 0 min(2.5,ax(4))];  axis(ax);  % Limit the axis.
      set(gca,'YDir','reverse');
      xt = .03*ax(1)+.97*ax(2);  yt = .07*ax(3)+.93*ax(4);
   elseif handles.bwplot==2 % Output vs. input density
	   xlabel('Input Density', 'FontWeight','bold');
	   ax = [0 4 0 max(2.5,ax(4))];  axis(ax);  % Limit the axis.
      set(gca,'XDir','reverse', 'YDir','reverse'); 
      xt = .97*ax(1)+.03*ax(2);  yt = .07*ax(3)+.93*ax(4);
   elseif handles.bwplot==3 % Output vs. input luminance
	   xlabel('Input Luminance ( Y_i_n )', 'FontWeight','bold');
	   ylabel('Output Luminance ( Y_o_u_t )', 'FontWeight','bold');
	   ax = [0 1 0 mlab];  axis(ax);  % Limit the axis.
      xt = .03*ax(1)+.97*ax(2);  yt = .93*ax(3)+.07*ax(4);
   elseif handles.bwplot==4 % Output vs. input La*b*
	   xlabel('Input L*', 'FontWeight','bold');
	   ylabel('Output L*, 10 a*, 10 b*, 10 c*', 'FontWeight','bold');
	   ax(4) = min(ax(4),100);  ax(2) = min(ax(2),100);  axis(ax);
      xt = .03*ax(1)+.97*ax(2);  yt = .66*ax(3)+.34*ax(4);
   end
   if handles.bwplot~=4
	   text(xt, yt, {daterun; ['Dmax =',  num2str(den_mean,3) prtmean]}, ...
         'Fontsize',handles.dfz-1, 'HorizontalAlignment','right')  % Date
   else
	   text(xt, yt, {daterun; ['Dmax =',  num2str(den_mean,3) prtmean]; ...
         'Thin solid lines are RYGCBM primaries';['for HSL saturation S = ' num2str(handles.satvar,2) ...
         '.']}, 'Fontsize',handles.dfz-1, 'HorizontalAlignment','right')  % Date
   end

   %                              END DENSITY/DMAX FIGURE
   
   
elseif handles.pltype==11 | handles.pltype==12   %  IMAGE COLOR DIFFERENCE OR COLORCHECKER
   
   set(gcf, 'Renderer', 'painters');  rotate3d off;  % 'zbuffer' 'opengl' or 'painters'
	cla;  set(gca,'Visible','off');
   newpos = handles.axpos;  % [L B W H]
   newpos(1) = newpos(1)+.02*newpos(3);  newpos(3) = .96*newpos(3);
   newpos(2) = newpos(2)+.06*newpos(4);  newpos(4) = .88*newpos(4);
   set(handles.axes1,'Position',newpos);
   
   if handles.imgstate(1)==0  % These variables have not yet been calculated.
      hmsg = waitbar(1,'Calculating Color differences');
      temp = rgb2cmyk(intarg,handles.cmyk(mplt));  % Convert to CMYK if needed. (:,:,:)?
      handles.reflab  =  icctrans(temp,  ['-t1 -i ' handles.inprof ...
         ' -o ' handles.labtmpr ]);  % Input  to LAB (Reference).
      handles.samplab = icctrans(outarg, ['-t1 -i ' handles.outprof ...
         ' -o ' handles.labtmpr ]);  % Sample (not reference) (:,:,:)?
              
      close(hmsg);
   end
   
   if handles.difplt>=19 & handles.gamdisp>1
       % Find ingam and outgam: the counterparts of intarg and outarg for the small gamut pattern.
		infind = 0;  outfind = 0;  % Input, output targets found.
		ingam = .8*ones(128,128,3);  outgam = ingam;  % Empty (light gray) arrays.
		if mplt==1 | mplt==3  % Input plot
            if mplt==3 & handles.profile(3)==8 & ~isempty(handles.outgam2)
               infind = 1;  ingam = double(handles.outgam2);  % Input to 3 is the output of 2.
            elseif ~isempty(handles.ftarg)
               infind = 1;  ingam = handles.ftarg(1:2:256,1:2:256,:);
            end
		elseif mplt==2
            if ~isempty(handles.outgam2)
               infind = 1;  ingam = double(handles.outgam2);
            end
		elseif mplt==4
            if ~isempty(handles.outgam4)
               infind = 1;  ingam = double(handles.outgam4);
            end
		end
		
		if nplt==1 | nplt==3  % Output plot
            if nplt==3 & handles.profile(3)==8 & ~isempty(handles.outgam2)
               outfind = 1;  outgam = double(handles.outgam2);  % Input to 3 is the output of 2.
            elseif ~isempty(handles.ftarg)
               % display('nplt = 3: no output target.');  handles.pltOK = 0;  return;
               outfind = 1;  outgam = handles.ftarg(1:2:256,1:2:256,:);
            end
		elseif nplt==2
            if ~isempty(handles.outgam2)
               outfind = 1;  outgam = double(handles.outgam2);
            end
		elseif nplt==4
            if ~isempty(handles.outgam4)
               outfind = 1;  outgam = double(handles.outgam4);
            end
		end
      temp = rgb2cmyk(ingam,handles.cmyk(mplt));  % Convert to CMYK if needed. (:,:,:)?
      refgam  =  icctrans(temp,  ['-t1 -i ' handles.inprof ...
         ' -o ' handles.labtmpr ]);  % Reference in LAB
      sampgam = icctrans(outgam, ['-t1 -i ' handles.outprof ...
         ' -o ' handles.labtmpr ]);  % Sample in LAB (not reference) (:,:,:)?
   end
   
   if handles.difplt<17  % Calculate color difference; otherwise use input or output mapped to monitor
      [temp, pltitle] = finderr(handles.samplab,handles.reflab,handles.difplt,handles.pltype);  % Difference to display
   elseif handles.difplt==17  % Input to monitor
      temp  = icctrans(handles.reflab, ['-t1 -i *LabD65 -o ' handles.montemp]);
      pltitle = 'Input > Monitor';
   elseif handles.difplt==18  % Output to monitor
      temp = icctrans(handles.samplab, ['-t1 -i *LabD65 -o ' handles.montemp]);
      pltitle = 'Output > Monitor';
   elseif handles.difplt>=19  % 3D pixel distribution (scatter) plots.
      if handles.OpenGL & handles.gamdisp>1
         set(gcf, 'Renderer', 'opengl');  % 'zbuffer' or 'opengl' here. 'painters' fails.
      else  % zbuffer rotates faster than opengl. use when transparency isn't needed.
         set(gcf, 'Renderer', 'zbuffer');  % 'zbuffer' or 'opengl' here. Faster than openGL.
      end
      anginc = 6;  nang = 180/anginc;  % Angle increment in degrees. Keep <= 6. Originally, 2 --> ft = 60/pi.
      ft = nang/pi;  % factor for converting from 0 to ft in phi or 0 to 2*ft in theta.
      % Convert to spherical. Initially, theta and phi are in radians. Center at L* = 50, a* = b* = 0.
      [ theta, phi, rad] = cart2sph(handles.reflab(:,:,2) ,handles.reflab(:,:,3) ,handles.reflab(:,:,1) -50);
      [stheta,sphi,srad] = cart2sph(handles.samplab(:,:,2),handles.samplab(:,:,3),handles.samplab(:,:,1)-50);
      % Rescale theta and phi and convert them into discrete (integer) values.
      % Original: -pi <= theta <= pi;  -pi/2 <= phi <= pi/2.
      phidis  = 1+round(ft.*(pi/2 + phi));  % 1-121 for anginc = 3: Discrete phi.
      % This value of thetdis works, but results in a few too many points near the bottom.
      % thetdis = 1+round(ft.*(pi + theta).*cos(phi));  % Discrete theta. Reduce for large phi.
      thetdis = 1+round(ft.*(pi + theta).*cos(phi)*(2/pi).*atan(2*(phi+pi/2)));  % 1-121: Discrete theta.
      % mnp = min(phidis(:)),  mxp = max(phidis(:)), mnt = min(thetdis(:)),  mxt = max(thetdis(:))
      radinv   = zeros(2*nang+1,nang+1);  % Radius: 1st index for theta; 2nd for phi
      thetinv  = zeros(2*nang+1,nang+1);  % Matrix for inverting phinv.
      phinv    = zeros(2*nang+1,nang+1);  % Matrix for inverting phidis.
      sradinv  = zeros(2*nang+1,nang+1);  % Radius: 1st index for theta; 2nd for phi
      sthetinv = zeros(2*nang+1,nang+1);  % Matrix for inverting phinv.
      sphinv   = zeros(2*nang+1,nang+1);  % Matrix for inverting phidis.
      radsum   = zeros(2*nang+1,nang+1);  % Weight of this region. Use for line thickness, etc.
      sz_all = size(theta);  % Size of arrays.
      for i1 = 1:sz_all(1);
         for j1 = 1:sz_all(2);  % Fill the radius array.  Rad has been defined l. 2228: Compile message in error?
            radsum(thetdis(i1,j1),phidis(i1,j1)) = radsum(thetdis(i1,j1),phidis(i1,j1)) + rad(i1,j1);
            if rad(i1,j1) > radinv(thetdis(i1,j1),phidis(i1,j1))
               radinv(thetdis(i1,j1),phidis(i1,j1))   = rad(i1,j1);   % For input
               thetinv(thetdis(i1,j1),phidis(i1,j1))  = theta(i1,j1);
               phinv(thetdis(i1,j1),phidis(i1,j1))    = phi(i1,j1);
               sradinv(thetdis(i1,j1),phidis(i1,j1))  = srad(i1,j1);  % For output
               sthetinv(thetdis(i1,j1),phidis(i1,j1)) = stheta(i1,j1);
               sphinv(thetdis(i1,j1),phidis(i1,j1))   = sphi(i1,j1);
            end
         end
      end
      radmax = max(radsum(:));
      clear rad theta phi srad stheta sphi
      if handles.pltype==11  % Normal input file
         frad = find(radinv>20);  % Could be variable; could use fraction radsum fraction of radmax...
      elseif handles.pltype==12
         frad = find(radinv>.001);  % Include all patches for ColorChecker
      end
      [ plta, pltb, pltL] = sph2cart( thetinv(frad), phinv(frad), radinv(frad));  % Values for scatter plot.
      [splta,spltb,spltL] = sph2cart(sthetinv(frad),sphinv(frad),sradinv(frad));  % Values for scatter plot.
      pltL = pltL+50;  spltL = spltL+50;  % Restore 50, removed for spherical conversion.
      sz_np = length(plta);
      clear thetinv phinv radinv sthetinv sphinv sradinv
      
      if handles.pltype==11  % Image color difference (not ColorChecker)
         msiz = handles.dfz*ones(sz_np,1);  linew = 0.5*ones(1,sz_np);
         for i1=1:sz_np  % msiz doesn't work (???)
            if     radsum(i1)>.5*radmax  % Maximum occurrences
               msiz(i1) = handles.dfz+12;  linew(i1) = 3;
            elseif radsum(i1)>.2*radmax 
               msiz(i1) = handles.dfz+8;  linew(i1) = 2;
            elseif radsum(i1)>.1*radmax 
               msiz(i1) = handles.dfz+4;  linew(i1) = 1.5;
            elseif radsum(i1)<.01*radmax  % Minimum occurrences
               msiz(i1) = handles.dfz-2;  linew(i1) = .5;
            end
         end
       elseif handles.pltype==12  % Must do because deep gray surround dominates ColorChecker.
         msiz = (handles.dfz+8)*ones(sz_np,1);  linew = 1.5*ones(1,sz_np);
       end
      
      % 3D plot is high after uncorrected 2D; left after corrected 2D. Z-out corrects. (?????)
	   view(3);  axis normal;  % From pushbutton_axis3d_Callback
      set3daxis(handles);  % axis vis3d is reliable.  Moving here may fix 2D color scaling!!!
      set(handles.axes1,'CameraViewAngleMode','auto', ... % 'CameraPositionMode','auto', ...
         'CameraTargetMode','auto');  % Two of three: attempted bug fix from push_zout.
      ax = newplot;  % RESTORES GRID: MISSING WITH PLOT3 OTHERWISE! Order important.
      
      hold on;  % hold on affects grid display: why? (Fixed with ax = newplot)
      
      if handles.gamdisp>1  % Plot the wireframe input or output gamut.
         % Moved from after to before lines/points. Order doesn't seem to matter.
         
         if     handles.gamdisp==2
		      gam_crop = imgrescale(ingam, [25,25]);  % was ingam
            temp = rgb2cmyk(gam_crop, handles.cmyk(mplt));  % Convert to CMYK if needed.
	         labdata  = icctrans(temp, ['-t1 -i ' handles.inprof ' -o ' handles.labtmpr]);  % To LAB.
	         surfdata = icctrans(temp, ['-t1 -i ' handles.inprof ' -o *sRGB']);    % File to sRGB.
            transp = 0;
         elseif handles.gamdisp==3
		      gam_crop = imgrescale(outgam,[25,25]);
            temp = rgb2cmyk(gam_crop, handles.cmyk(mplt));  % Convert to CMYK if needed.
	         labdata  = icctrans(temp, ['-t1 -i ' handles.outprof ' -o ' handles.labtmpr]);  % To LAB.
	         surfdata = icctrans(temp, ['-t1 -i ' handles.outprof ' -o *sRGB']);    % File to sRGB.
            transp = handles.transimg;
         % elseif handles.gamdisp==4
		      % gam_crop = outgam;
            % temp = rgb2cmyk(gam_crop, handles.cmyk(mplt));  % Convert to CMYK if needed.
	         % labdata  = icctrans(temp, ['-t1 -i ' handles.outprof ' -o ' handles.labtmpr]);  % To LAB.
	         % surfdata = icctrans(temp, ['-t1 -i ' handles.outprof ' -o *sRGB']);    % File to sRGB.
         end
         temp = surfdata;
         if handles.wire>1 & handles.gamdisp<4  % Other than Normal wireframe
            % Normal  Lighter  Darker  Max color Light  Dark  Black  White
            temp = rgb2hsl(temp);  temp(1,:,:) = temp(2,:,:);  % Correct for gray at end.
            if     handles.wire==2  % Lighter
               temp(:,:,3) = .6+.4*temp(:,:,3);
            elseif handles.wire==3  % Darker
               temp(:,:,3) = .4*temp(:,:,3);
            elseif handles.wire==4  % Max color
               temp(:,:,3) = .5;
            elseif handles.wire==5  % Light
               temp(:,:,3) = .8;
            elseif handles.wire==6  % Dark
               temp(:,:,3) = .2;
            elseif handles.wire==7  % Black
               temp(:,:,3) = 0;
            elseif handles.wire==8  % White
               temp(:,:,3) = 1;
            end
            temp = hsl2rgb(temp);
         end
         
         if handles.OpenGL
		      handles.wiresurf = surf(labdata(:,:,2), labdata(:,:,3), labdata(:,:,1), temp, ...
               'FaceColor',handles.transface*[1 1 1], 'EdgeColor','flat', 'FaceAlpha', transp, ...
               'FaceLighting','none');
         else
		      handles.wiresurf = mesh(labdata(:,:,2), labdata(:,:,3), labdata(:,:,1), temp);
            hidden off;
         end
      end
      
      if     handles.difplt==19  % Input (larger gamut)
         ptcolor  = lab2rgb( pltL, plta, pltb,'sRGB');  % sRGB colors for points.
         % scatter3mod( plta, pltb, pltL,msiz,ptcolor,'filled');  % Da KEY? Hangs up for too many points???
		   for i1=1:sz_np   % Measured color.
            plot3( plta(i1),  pltb(i1),  pltL(i1),'.', 'Color', ptcolor(i1,:), 'MarkerSize',msiz(i1));
         end
      elseif handles.difplt==20  % Output (smaller gamut)
         ptcolor  = lab2rgb(spltL,splta,spltb,'sRGB');  % sRGB colors for points.
         % scatter3mod(splta,spltb,spltL,msiz,ptcolor,'filled');
		   for i1=1:sz_np   % Measured color.
            plot3(splta(i1), spltb(i1), spltL(i1),'.', 'Color', ptcolor(i1,:), 'MarkerSize',msiz(i1));
         end
      elseif handles.difplt==21 | handles.difplt==22
         ptcolor  = lab2rgb( pltL, plta, pltb,'sRGB');  % sRGB colors for points.
         sptcolor = lab2rgb(spltL,splta,spltb,'sRGB');  % sRGB colors for points.
         % There may be bugs that need resetting after scatter3.
         % scatter3mod(splta,spltb,spltL,msiz,sptcolor,'filled');  % Must go before lines to get grid (???)
         if handles.difplt==21  % Dots on output (inner) points
		      for i1=1:sz_np   % Measured color.
               plot3(splta(i1), spltb(i1), spltL(i1),'.', 'Color', sptcolor(i1,:), 'MarkerSize',msiz(i1));
               line([splta(i1) plta(i1)], [spltb(i1) pltb(i1)], [spltL(i1) pltL(i1)], ...
                  'LineWidth',linew(i1),'Color', ptcolor(i1,:));
            end
         elseif handles.difplt==22  % Dots on input (outer) points
		      for i1=1:sz_np   % Measured color.
               line([splta(i1) plta(i1)], [spltb(i1) pltb(i1)], [spltL(i1) pltL(i1)], ...
                  'LineWidth',linew(i1),'Color', sptcolor(i1,:));
               plot3(plta(i1), pltb(i1), pltL(i1),'.', 'Color', ptcolor(i1,:), 'MarkerSize',msiz(i1));
            end
         end
      end
      clear msiz linew ptcolor
      
		set(gca,'Color',[handles.bk3d handles.bk3d handles.bk3d]);
      % Set axis color-- lighten for dark backgrounds.
      if handles.bk3d>.35  axclr = [.4*handles.bk3d-.14 .4*handles.bk3d-.14 .4*handles.bk3d-.14];
      else  axclr = [.5*handles.bk3d+.45 .5*handles.bk3d+.45 .5*handles.bk3d+.45];
      end
      set(gca,'Xcolor',axclr, 'Ycolor',axclr, 'Zcolor',axclr);
   
      if handles.hzoom  zoom on;   rotate3d off;
      else              zoom off;  rotate3d on;  end  % Switch for 3D plot
      
		mina = min(plta(:));  maxa = max(plta(:));  
		minb = min(pltb(:));  maxb = max(pltb(:));  
      if handles.gamdisp>1
         mina = min(mina,min(min(labdata(:,:,2))));
         maxa = max(maxa,max(max(labdata(:,:,2))));
         minb = min(minb,min(min(labdata(:,:,3))));
         maxb = max(maxb,max(max(labdata(:,:,3))));
      end
		axmina = floor(mina/10)*10;       axmaxa = ceil(maxa/10)*10;  
		axminb = floor(minb/10)*10;       axmaxb = ceil(maxb/10)*10;  
		axmina = min([axmina,handles.lab3Daxis(1)]);
		axmaxa = max([axmaxa,handles.lab3Daxis(2)]);  
		axminb = min([axminb,handles.lab3Daxis(3)]);
		axmaxb = max([axmaxb,handles.lab3Daxis(4)]);  
      ax = [-130, 130, -130, 130, 0, 100];
		ax(1) = max([ax(1),axmina]);	ax(2) = min([ax(2),axmaxa]);  
		ax(3) = max([ax(3),axminb]);	ax(4) = min([ax(4),axmaxb]);  
		handles.lab3Daxis = ax;  axis(ax);
      
	   % axis normal;  view(3);  % Try again! (This views things a little small... Zoom out is larger.)
      set3daxis(handles);  % axis vis3d is reliable.  Moving here may fix 2D color scaling!!!
      % [azim, elev] = view;  % Save view azimuth and angle.
      set(handles.axes1,'CameraViewAngleMode','auto', 'CameraTargetMode','auto');  % from push_zout.
      % view([azim, elev]);  % Reset view.  Tricky!
      view([handles.azim, handles.elev]);  % Saved view azimuth and angle.
		xlabel('a*');  ylabel('b*');  zlabel('L');
      grid on;
   end      %                                  END 3D LAB SCATTER PLOT
      
   if handles.difplt<19
      if handles.imgstate(2)>=19  % The last image was 3D. Attempt bug fix.
         ax = newplot;  % Try???
      end
      imagesc(temp);    % For regular plots (not scatter plots) image() doesn't work right.
      axis image;  % Debug???
      sz_temp = size(temp);  % OK
      % ax = axis  % Might need to do manual axis for this plot. ??? Always OK: 0.5, sz_temp+0.5
      xlabel([pltitle '  [' num2str(mplt) ',' num2str(nplt) ']    ' daterun], 'FontWeight','Bold');
      set(gca,'XTickLabel','','XTickLabelMode','manual','YTickLabel','','YTickLabelMode','manual');
      % if handles.imgstate(2)>=19  % The last image was 3D. Attempt bug fix.
      %    axis([.5 sz_temp(2)+.5 .5 sz_temp(1)+.5]);  % Yes, order is correct. x,y = cols, rows.
      % end
   end
   
   
   if handles.difplt<17  % 18 and 19 are input & output (not mapped)
      % Make color maps. Go from Y to B through either R or G (opponent theory).
      if handles.colormap<=2  % 1 or 2
         wrk = ones(64,3);  md = 5;  wrk(40-md:57,1) = linspace(1,0,18+md)';  wrk(58:64,1) = 0;
         wrk(8:25,2)  = linspace(1,0,18)';  wrk(25:64,2) = 0;  
         wrk(1:9,3)   = linspace(1,0,9)';   wrk(10:24,3) = 0;  wrk(24:40+md,3) = linspace(0,1,17+md)';
         wrk(56:64,3) = linspace(1,0,9)';   wrk = wrk.^(.6);
      end
      if     handles.colormap==2  wrk = [wrk(:,2),wrk(:,1),wrk(:,3)];
      elseif handles.colormap==3  wrk = jet(64);
      elseif handles.colormap==4  wrk = gray(64);
      end
      if handles.cmapinv  wrk = flipdim(wrk,1);  end  % flip color map.
      colormap(wrk);  % Use caxis to set colormap.
      % cax = caxis;  % should give min, max plot values.
      if ((handles.lastplot==11 | handles.lastplot==12) & handles.diflast>=19)
         caxis auto;
         % handlex.cax = caxis;  % handles.cax    = [1e6,-1e6];  % From Reset Plot. Mim, max (pseudo)color map.
      end
      % handles.cax = [min([cax(1),handles.cax(1)]),max([cax(2),handles.cax(2)])];  % Scaling
      % caxis(handles.cax);
      if sz_temp(2)>sz_temp(1)  colorbar('horiz');  % horizontal image
      else                      colorbar('vert');   % vertical image
      end
   end
   
   if     handles.pltype==11  tytle = handles.imgfull;
   elseif handles.pltype==12  tytle = 'Simulated GretagMacbeth ColorChecker';  end
   lttl = length(tytle);   % Length of file name for title.
   ttsz = handles.dfz-1;  if lttl>80  ttsz = handles.dfz-2;  end
   title(tytle,'FontSize',ttsz,'FontWeight','Bold','Interpreter','none');
   
   handles.imgstate = [1 handles.difplt];  % Image state: Plot completed, last plot type.
   
   
   
elseif handles.pltype==13   %  PROFILE INFO
	
   set(gca, 'Visible','off');
   text(.03,.95,['Profile ' num2str(mplt) '   ' handles.iccname{mplt}],'FontSize',handles.dfz, ...
      'FontWeight','Bold','Interpreter','none');
   text(.03,.74,cellstr(handles.iccdesc{mplt}),'FontSize',handles.dfz-2,'Interpreter','none', ...
      'FontName','FixedWidth');
   text(.03,.50,['Profile ' num2str(nplt) '   ' handles.iccname{nplt}],'FontSize',handles.dfz, ...
      'FontWeight','Bold','Interpreter','none');
	text(.03,.29,cellstr(handles.iccdesc{nplt}),'FontSize',handles.dfz-2,'Interpreter','none', ...
      'FontName','FixedWidth');
   cpytxt = { ...
      'Profile Info is derived from SampleICC, developed by the ICC (www.color.org).'; ...
      'Copyright © 2003-2005 The International Color Consortium (ICC). All rights reserved.'; ...
      'The ICC organization does not endorse or promote products derived from this software.' };
	text(.06,.05,cpytxt,'FontSize',handles.dfz-2,'Interpreter','none');
   
end                          % END pltype==n DISPLAYS

handles.lastplot = handles.pltype;  % Set at successful completion of plot.
handles.lastm    = mplt;
handles.lastn    = nplt;
handles.lastHL   = handles.HLview;  % Last view. 3D if 2 or 4.
handles.diflast  = handles.difplt;  % Difference type to plot.
handles.bwlast   = handles.bwplot;  % Difference type to plot.
if handles.outype==2  % Bug control? Nope. Looks like you must push the button!
   set(handles.out_mapped, 'BackgroundColor',[1 1 .8]);
end
if handles.plt3d     % 3D Plot
   if handles.hzoom  zoom on;   rotate3d off;
   else              zoom off;  rotate3d on;  end  % Switch for 3D plot
   set(handles.check_zoom,'Value',handles.hzoom,'Enable','on');
   camva_orig = get(handles.axes1,'CameraViewAngle');  % To detect zoom
   camta_orig = get(handles.axes1,'CameraTarget');     % ""
elseif handles.pltype~=12  % Image color difference: turn on or off. was ==11
   if handles.hzoom  zoom on;  else  zoom off;  end  % Use ginput(1) with zoom off.
   set(handles.check_zoom,'Value',handles.hzoom,'Enable','on');
   % elseif handles.pltype~=12
   %    zoom on;    set(handles.check_zoom,'Value',1,'Enable','off');  % 2D plots
else
   zoom off;  set(handles.check_zoom,'Value',0,'Enable','off');  % Profile data
end

% Restore zoom settings.
handles.zoomorig = [xlim, ylim];  % Same as axis; Original: use for Zoom out.
if handles.pltype==6 & handles.plt3d  axis normal;  end  % Perserve size. Move here to maintain zoom!!!
if pltsame  %  same plot type: keep zoom.
   if handles.plt3d  % Should be the same settings as Gamutvision push_zout_Callback.
      if ~isequal(camva_orig,camva)
         axes(handles.axes1);  % May remove legend in 2D plots; not a problem with 3D.
         set(handles.axes1,'CameraViewAngle', camva);  % Saves zoom but may shrink unzoomed image.
         set(handles.axes1,'CameraTarget',    camta);  % Keeps position
         set(handles.axes1,'CameraPositionMode',  'auto');  % 'CameraPosition', campo);  % Not needed? Messes up axes positions.
      end
   else
      xlim(zoomlims(1:2));  ylim(zoomlims(3:4));  % zlim(zoomlims(5:6));
   end
end

writeKeys = {'gamut','','pltres',  handles.pltres; ...
             'gamut','','light',   handles.radio_ltsave; ...
             'gamut','','pltype',  get(handles.popupmenu_pltype,  'Value'); ...
             'gamut','','transparency', num2str(handles.transp,3); ...
             'gamut','','transimg', num2str(handles.transimg,3); ...
             'gamut','','hslplot', handles.hslplot; ...
             'gamut','','hslight', handles.hslight; ...
             'gamut','','vector',  handles.vector };
inifile(handles.file_ini,'write',writeKeys,'plain');  % Save values.
guidata(gca, handles);  % Use gca for hObject. VERY much needed to save handles.lastplot, etc.
return;

%                                         END BIG PLOT


function handles = reset_outplot(handles)  % Repeated-- also in main file.
set(handles.inp_raw,           'BackgroundColor',[.8 .8 .8]);
set(handles.inp_mapped,        'BackgroundColor',[.8 .8 .8]);
set(handles.out_raw,           'BackgroundColor',[.8 .8 .8]);
set(handles.out_mapped,        'BackgroundColor',[.8 .8 .8]);
set(handles.inp_raw,           'FontWeight', 'normal');
set(handles.inp_mapped,        'FontWeight', 'normal');
set(handles.out_raw,           'FontWeight', 'normal');
set(handles.out_mapped,        'FontWeight', 'normal');


function set3daxis(handles)  % set the 3D axis
if     handles.axis3d==1  axis equal;
elseif handles.axis3d==2  axis image;
elseif handles.axis3d==3  axis square;
elseif handles.axis3d==4  axis vis3d;
elseif handles.axis3d==5  axis normal;
% elseif handles.axis3d==6  axis auto;
end


function [temp, pltitle] = finderr(samplab,reflab,difplt,pltype);
% 2/14/08: Add Delta-E 00 & Delta-C 00 (CIEDE2000 metrics) after CMC. Shift numbers!

if     difplt==1  % Delta-E*ab
   [dummy, temp] = colorerr(samplab,reflab,1);  % Color error.
   pltitle = '\DeltaE*_a_b';
elseif difplt==2  % Delta-C*ab
   [temp, dummy] = colorerr(samplab,reflab,1);  % Color error.
   pltitle = '\DeltaC*_a_b';
elseif difplt==3  % Delta-E*94
   [dummy, temp] = colorerr(samplab,reflab,2);  % Color error.
   pltitle = '\DeltaE*_9_4';
elseif difplt==4  % Delta-C*94
   [temp, dummy] = colorerr(samplab,reflab,2);  % Color error.
   pltitle = '\DeltaC*_9_4';
elseif difplt==5  % Delta-E*CMC
   [dummy, temp] = colorerr(samplab,reflab,3);  % Color error.
   pltitle = '\DeltaE*_C_M_C';
elseif difplt==6  % Delta-C*CMC
   [temp, dummy] = colorerr(samplab,reflab,3);  % Color error.
   pltitle = '\DeltaC*_C_M_C';
   
elseif difplt==7  % Delta-E 00
   [dummy, temp] = colorerr(samplab,reflab,4);  % Color error.
   pltitle = '\DeltaE_0_0';
elseif difplt==8  % Delta-C 00
   [temp, dummy] = colorerr(samplab,reflab,4);  % Color error.
   pltitle = '\DeltaC_0_0';
   
% Increment all numbers below by 2.   
elseif difplt==9   % 7  % Delta-L*
   temp = min(samplab(:,:,1),100)-min(reflab(:,:,1),100);
   pltitle = '\Delta L*';
elseif difplt==10  % 8  % Delta-Chroma (Delta-C*)
   temp = sqrt(samplab(:,:,2).^2 + samplab(:,:,3).^2) - ...
          sqrt(reflab(:,:,2).^2 + reflab(:,:,3).^2);
   % samplab(:,:,2)-reflab(:,:,2);
   pltitle = '\Delta Chroma';
elseif difplt==11  % 9  % Delta-|Hue distance| (Delta-H*)
   temp1 = sqrt(samplab(:,:,2).^2 + samplab(:,:,3).^2) - ...
           sqrt(reflab(:,:,2).^2  + reflab(:,:,3).^2);  % Delta-Chroma
   temp = (samplab(:,:,2)-reflab(:,:,2)).^2 + (samplab(:,:,3)-reflab(:,:,3)).^2 ...
      - temp1.^2 + 20*eps;  % Sharma (1.45) errata  20*eps makes it > 0 always.
   if min(min(temp))<0
      min(min(temp1)), min(min(temp))
   end
   temp = sqrt(temp);
   pltitle = '\Delta |Hue distance|';
elseif difplt==12  % 10  % Delta-Hue angle degrees
   temp  = 180/pi*atan2( reflab(:,:,3), reflab(:,:,2));  % Hue: 180/pi --> 3/pi so it goes from 0-6.
   temp1 = 180/pi*atan2(samplab(:,:,3),samplab(:,:,2));  % Hue: 180/pi --> 3/pi so it goes from 0-6.
   temp2 = find(reflab(:,:,1)<2 | samplab(:,:,1)<2 | max(reflab(:,:,2),reflab(:,:,3))<2 | ...
      max(samplab(:,:,2),samplab(:,:,3))<2 );  % 11/17/06
   temp(temp2) = 0;  temp1(temp2) = 0;  % Zero the error where value is near zero. 11/17/06
   if pltype<11
      for i1=1:256  % Use discontinuity! Always near center.
         [dis, idis] = min(diff(temp(i1,:)));
         temp(i1,idis+1:256) = temp(i1,idis+1:256)+360;  % This works nicely.
      end
      for i1=1:256  % Use discontinuity! Always near center.
         [dis, idis] = min(diff(temp1(i1,:)));
         temp1(i1,idis+1:256) = temp1(i1,idis+1:256)+360;  % This works nicely.
      end
      temp = temp-temp1;
      % Zero extremes where large errors occur.
      temp(1:6,:,:) = 0;  temp(233:256,:,:) = 0;
   else  % External image. Use a rough correction to keep angle between ~ -180 and 180 degrees.
      temp = temp-temp1;
      temp(find(temp>200))  = temp(find(temp>200)) -360;
      temp(find(temp<-200)) = temp(find(temp<-200))+360;
   end
   pltitle = '\Delta Hue (degrees)';
elseif difplt==13  % 11  % L* reference (input) (not difference!)
   temp = min(reflab(:,:,1),100);
   % temp = diff(reflab(:,:,1),1,1);  temp(256,:)= temp(255,:);  % WEIRD !!!
   pltitle = 'L* (input)';
elseif difplt==14  % 12  % L* (output) (not difference!)
   temp = min(samplab(:,:,1),100);
   pltitle = 'L* (output)';
elseif difplt==15  % 13  % Chroma reference (input) (not difference!)
   temp = sqrt(reflab(:,:,2).^2  + reflab(:,:,3).^2);
   pltitle = 'Chroma (input)';
elseif difplt==16  % 14  % Chroma (output) (not difference!)
   temp = sqrt(samplab(:,:,2).^2 + samplab(:,:,3).^2);
   pltitle = 'Chroma (output)';
elseif difplt> 17  % 15  % Dummy.
   temp =samplab(:,:,1);  % Arbitrary-- no real use
   pltitle = 'Image';
end
return;
