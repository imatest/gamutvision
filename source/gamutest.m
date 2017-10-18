function gamutest
% Test file for Gamutviewer.
% Printarg generates a file with a printer target for testing color and Dmax.
% Modified 02/24/04: add one pixel to top, bottom, L, R of the two color sections & grayscales.
% This is for safety margin: it will improve overall accuracy.

format compact;  % for testing
screen = get(0, 'ScreenSize');  % L B W H array; L=B=1.
dfz = 10;  evalver = 0;  expandplt = 0;  % Defaults (for test)
daterun = datestr(now);  datesort = datestr(now,31);  % Date and time of run. datesort is sortable.
rootdir = '..\installation\';   % Interpreted Mablab only-- make an argument.
imdotcom = [rootdir 'images' filesep 'Imatest_ital_Logo_66W.png'];
imlogo =  imread(imdotcom,'png');             % DISPLAY LOGO
imlogf =  imfinfo(imdotcom);

close all;

% prtarg = uint8(zeros(900,578,3));  % Target. rows, cols. 514+258+128 = 900; 514+64 = 578.
prtarg = uint8(false(256,512,3));  % Target. rows, cols.
ftarg = zeros(256,512,3);

% ftarg is a temporary array for calculating arrays to be moved to prtarg for printing.
% Maximum S, varying H and L.  (S1 region)
ftarg(:,1:256,1) = ones(1,256)'*(0:1/255:1);  % H
ftarg(:,1:256,2) = ones(256,256);             % S
ftarg(:,1:256,3) = (1:-1/255:0)'*ones(1,256); % L

% L = .5, varying H and S.
ftarg(:,257:512,1) = ones(1,256)'*(0:1/255:1);  % H
ftarg(:,257:512,2) = (1:-1/255:0)'*ones(1,256); % S
ftarg(:,257:512,3) = .5*ones(256,256);          % L

ftarg = hsl2rgb(ftarg);
prtarg = uint8(ftarg*255);

figure; image(prtarg);  axis image;

L5_crop = ftarg(:,257:512,:);  % Image for gamut plot.
sz_L5 = size(L5_crop);
s1_crop = ftarg(:,1:256,:);  % HSL array for s1 region.
sz_s1 = size(s1_crop);


% Produce the two maps based on printest.

colorig    = 'sRGB';
colorspace = 'sRGB';


% No luck getting Windows version (XP, ...) from ver or anything.
iccfolder = 'C:\Windows\System32\Spool\Drivers\Color\';
path_ui = [iccfolder '*.*'];
[fn1, pn1] = uigetfile(path_ui,'Select ICC profile.');  % Save this as default (later)...
if (isequal(fn1,0) | isequal(pn1,0))  return;  end
profname = fn1;  pathname = pn1;  % pathname has trailing filesep.
fullname=[pathname profname];  fulltemp = fullname;  % Full path name of input file.
if findstr(fullname, ' ')
   proftemp = strrep(profname,' ','_');  fulltemp = [tempdir proftemp];
   disp([profname '  -->  ' proftemp]);
   dos(['copy  "' fullname '"  "' fulltemp '"']);
end

% Now convert prtarg (the whole image). Later add options.
% Doesn't like spaces in name. Try ""  or ' ' around fullname. Nope. Use tempdir.
outarg = icctrans(prtarg, ['-t1 -o ' fulltemp]);  sz_2 = size(outarg);
pcptarg = icctrans(prtarg, ['-t0 -o ' fulltemp]);
if sz_2(end) == 3  % RGB color (NOT CMYK)
   figure; image(outarg);  axis image;  title('Colorimetric');
   figure; image(pcptarg);  axis image;  title('Perceptual');
end


%                                       S1 La*b* GAMUT MAP for S=1; 0.1 <= L <= 0.9

%             NOTE:  L in this plot is HSL L (not La*b* L).
nis = 5;  % Number of steps
sshsl = ones(nis,121,3);
for i1=1:nis           % Vary L from .1 to .9 in steps of .2.
   sshsl(i1,:,1) = linspace(0,1,121)';  sshsl(i1,:,2) = 1;  % H and S
   llvl(i1) = .1+.8*(nis-i1)/(nis-1);  % 0.9-0.1.  % L (HSL); lightest first.
   sshsl(i1,:,3) = llvl(i1);
end
ssrgb = hsl2rgb(sshsl);
sslab = rgb2lab(ssrgb,colorig);  % Gamut of selected color space. (Original file)
xbound = [min(min(sslab(:,:,2))) max(max(sslab(:,:,2)))];  % min, max a (x) for Color space
ybound = [min(min(sslab(:,:,3))) max(max(sslab(:,:,3)))];  % min, max b (y) for Color space
xlims =  [floor(xbound(1))-1 ceil(xbound(2))+1];  % Limits for plotting
ylims =  [floor(ybound(1))-1 ceil(ybound(2))+1];

% Calculate lines of constant hue.
chue_hsl = ones(13,41,3);
for i1=1:13
   chue_hsl(i1,:,1) = (i1-1)/12;
   chue_hsl(i1,:,3) = linspace(0,1,41);  % Brightness increases.
end
chue_hsl(:,:,2) = 1;
chue_rgb = hsl2rgb(chue_hsl);
chue_lab = rgb2lab(chue_rgb,colorig);
hueplt_hsl = ones(13,3);  hueplt_hsl(:,1) = (0:12)'/12;  % Color of hue plot
hueplt_hsl(:,2) = 1;  % hueplt_hsl(:,3) = .5;
hueplt_hsl(:,3) = [.46; .36; .50; .28; .28;   .27; .32; .37; .5; .45;   .40; .40; .5];
hueplt_rgb = hsl2rgb(hueplt_hsl);
huept2_hsl = hueplt_hsl;  huept2_hsl(:,3) = 1.3*hueplt_hsl(:,3);
huept2_rgb = hsl2rgb(huept2_hsl);

mark_hsl = ones(3,13,3);  mark_L = [.65 .5 .4];
for i1=1:3
   mark_hsl(i1,:,1) = (0:12)'/12;  % Color of hue plot
   mark_hsl(i1,:,2) = 1;  mark_hsl(i1,:,3) = mark_L(i1);
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

figure;               % Plot S1 La*b* GAMUT MAP for S=1; 0.1 <= L <= 0.9
figsz = [560,610];  % x and y-figure size. Was [560,560]
if (expandplt & screen(4)>1024) figsz = figsz*1.25;  end
p1 = [round(max(screen(3)/2-figsz(1)/2,screen(3)/6)) (screen(4)-figsz(2))/2 figsz(1) figsz(2)];  % L B W H
set(gcf,'Position',p1,'PaperPositionMode','auto','Name','S=1 La*b* Saturation map');
if (screen(4)<750) movegui(gcf,'center');  end  % Keep fig on 800x600 screen.

hlab = axes('Position',[.10 .14 .85 .785]);  % [L B W H]  was [.10 .15 .85 .85]
set(gca,'FontSize',dfz);

image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)]);
ax = axis;
set(gca,'YDir','normal');  % 'reverse' or 'normal'
title({'La*b* Gamut map for S(HSL)=1; L from 0.1 to 0.9'; 'Test image'}, ...
   'FontWeight','bold','Fontsize',dfz);
xlabel('a*','FontWeight','bold');
ylabel('b*','FontWeight','bold');

% The second axes solves the problem of plots disappearing with the legend is moved.
% This plot cannot be done with a single contour(...) because it is mult-valued.
% No contourable surface. % But there could be tricks: Those contour plots look cool!
% If we do multiple contours, numbers could overlap.
hrpt = axes('Position',get(hlab,'Position'));  % REPEAT!
set(hrpt,'Visible','off','Xlim',get(hlab,'Xlim'),'Ylim',get(hlab,'Ylim'),'FontSize',dfz);
hold on;
image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)],'Visible','off');
% axis image;
axis(ax);
for i1=x20(1):20:x20(2)  % Plot '+' every 20 points vertically and horizontally.
   for j1=y20(1):20:y20(2)
      i2 = .55+.15*(j1-y20(1))/(y20(2)-y20(1));  % Lighten from bottom to top.
      text(i1,j1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
   end
end
if evalver                      % EVALUATION VERSION
   text((ax(1)+ax(2))/2, .48*ax(3)+.52*ax(4), {'Evaluation version';''; ...
      'Purchase at www.imatest.com'}, 'HorizontalAlignment','center','Color', ...
      [.80 .80 .80],'FontWeight','bold','Fontsize',dfz+6);
end

plot(sslab(3,:,2),sslab(3,:,3),'Color',[.7 .7 .7], ...
   'LineWidth',1.5,'LineStyle',':');  % Ideal L=0.5.  Repeat to emphasize
gcolors = [.99 .99 .99;  .86 .86 .86;  .7 .7 .7;  .44 .44 .44;  0 0 0;];  % for heavy lines.
for i1=1:nis  % Look at cross-sections of s1_crop (cropped S1 area image; light on top).
   i2 = .1+.8*(i1-1)/(nis-1);  % 1-L: 0.1-0.9  (Inverse order from L).
   y5 = round(1+llvl(i1)*(sz_s1(1)-2));  % Avoid extremes.
   sgamut = s1_crop(y5,:,:);  % Should be RGB.
   szg = size(sgamut);  sgamut = reshape(sgamut, szg(1)*szg(2), szg(3));
   szg = size(sgamut);  % 2D
   sgamut = [sgamut(szg-3:szg,:); sgamut; sgamut(1:4,:)];  % Wrap: 4 pts extra each end.
   for ism=1:3  sgamut(:,ism) = smoothp(sgamut(:,ism),3);  end
   szg2 = size(sgamut);
   sgamut = sgamut(4:szg2-3,:);  % Keep 1 extra point at each end.
   % sglab = rgb2lab(sgamut,colorspace);
   % plot(sglab(:,2),sglab(:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
   sglab(i1,:,:) = rgb2lab(sgamut,colorspace);  % Measured data
   sgvort(i1,:) = round(linspace(3,length(sgamut)-2,13));  % Vortex locations
   plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
   % if i1==3  sglab3 = sglab;  end  % Save to replot for clarity.
   gideal(i1) = polyarea(sslab(i1,:,2),sslab(i1,:,3));
   garea(i1) =  polyarea(sglab(i1,:,2),sglab(i1,:,3));
end
set(gca,'Xlim',xlims,'Ylim',ylims);
hleg = legend('Color space','L=0.9','L=0.7','L=0.5','L=0.3','L=0.1',3);
set(hleg,'Color',[.7 .85 .95]);  % ,'Position',get(hleg,'Position')+[.04 0 0 0]);  % Fix Position BUG!

line([0 0], [.92*ax(3)+.08*ax(4) .03*ax(3)+.97*ax(4)],'Color',[.5 .5 .5],'LineStyle',':');
line([.97*ax(1)+.03*ax(2) .03*ax(1)+.97*ax(2)], [0 0],'Color',[.5 .5 .5],'LineStyle',':');
for i1=1:12
   plot(chue_lab(i1, 1:20,2),chue_lab(i1, 1:20,3),'Color',hueplt_rgb(i1,:),'LineStyle',':');
   plot(chue_lab(i1,21:41,2),chue_lab(i1,21:41,3),'Color',huept2_rgb(i1,:),'LineStyle',':');
end
plot(sslab(3,:,2),sslab(3,:,3),'Color',[.5 .5 .5], ...
   'LineWidth',2.5,'LineStyle','-');  % Ideal L=0.5.  Background for emphasis.
for i1=1:nis
   plot(sslab(i1,:,2),sslab(i1,:,3),'Color',gcolors(i1,:), ...
      'LineWidth',1.5,'LineStyle',':');  % Ideal.
end
ggcolors = gcolors;  ggcolors(3,:) = [.5 .5 .5];  % Darken outline for L=0.5.
for i1=2:4
   sgvort(i1,1) = mean(sgvort(i1,1),sgvort(i1,13));
   if i1==3
      plot(sglab(i1,:,2),sglab(i1,:,3),'Color',[.5 .5 .5],'LineStyle','-','LineWidth',3.0);
   end
   plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
   for j1=1:12
      plot(sslab(i1,10*j1-9,2),sslab(i1,10*j1-9,3),'s', ...  % Ideal data
         'MarkerEdgeColor',ggcolors(i1,:),'MarkerFaceColor',mark_rgb(i1-1,j1,:),'MarkerSize',5)
      plot(sglab(i1,sgvort(i1,j1),2),sglab(i1,sgvort(i1,j1),3),'o', ...   % Vortices.
         'MarkerEdgeColor',ggcolors(i1,:),'MarkerFaceColor',mark_rgb(i1-1,j1,:),'MarkerSize',6)
   end
end
text(.03*ax(1)+.97*ax(2),.04*ax(3)+.96*ax(4),['Original: ' colorig], ...
   'FontSize',dfz,'Color',[.2 .2 .4],'HorizontalAlignment','right');
text(.03*ax(1)+.97*ax(2),.08*ax(3)+.92*ax(4),['Scanner: ' colorspace], ...
   'FontSize',dfz,'Color',[.2 .2 .4],'HorizontalAlignment','right');
text(.60*ax(1)+.40*ax(2),.96*ax(3)+.04*ax(4), daterun, 'Fontsize',dfz-2, ...
   'HorizontalAlignment','center');  % Date
clear sglab

harea = axes('Position',[.06 .02 .88 .12],'Visible','off');  % [L B W H]
darea{1} = sprintf('L (HSL lightness)%7.1f %7.1f %7.1f %7.1f %7.1f', ...
   llvl(5),llvl(4),llvl(3),llvl(2),llvl(1));
darea{2} = sprintf('Area (ideal)     %7.0f %7.0f %7.0f %7.0f %7.0f', ...
   gideal(5),gideal(4),gideal(3),gideal(2),gideal(1));
darea{3} = sprintf('Area (measured)  %7.0f %7.0f %7.0f %7.0f %7.0f', ...
   garea(5),garea(4),garea(3),garea(2),garea(1));
text(.05,.2, darea,'Fontsize',dfz,'FontName','FixedWidth');

% For plot [L B W H]                     LOGO TEMPLATE.   Works on top of images.
imdotcom = [rootdir 'images' filesep 'Imatest_ital_Logo_56W.png'];
imlogo =  imread(imdotcom,'png');  imlogf =  imfinfo(imdotcom);  % DISPLAY LOGO
poslab = get(hlab,'Position');                   % LOGO
pos = [poslab(1)+.02*poslab(3) poslab(2)+.25*poslab(4) ...
   imlogf.Width/figsz(1), imlogf.Height/figsz(2)];   % [L B W H];
hlgo = axes('Position',pos,'Visible','off');
image(imlogo);  axis off;  axis image; 

%                             END S1 La*b* GAMUT MAP for S=1; 0.1 <= L <= 0.9


%                                       S1 3D PLOT

if 1  % 3D plot: much potential!
   % Need to resize down s1_crop (nearest neighbor?). A multiple of 6 is important for hue.
   huesp = linspace(1,257,37);  huesp = [round(huesp(1:36)) 1];  % Hue spacing.
   s1_cropsm = s1_crop([1:8:end],huesp,:);  % RGB image. second (x) dim is cyclic
   s1_cropsb =  outarg([1:8:end],huesp,:);  % Second file (from printer, etc.)
   s1_cropsb = double(s1_cropsb(:,:,1:3))/255;  % ??? Must improve for CMYK.
   % Two ways to convert to LAB.
   % labdata = rgb2lab(s1_cropsm);  % Tried & true technique
   % Order may be reversed.
   labdatb = icctrans(s1_cropsm, '-t1 -o *LabD65');  % SRGB to LAB D65.
   labdata = icctrans(s1_cropsb, ['-t1 -i ' fulltemp ' -o *LabD65']);  % File to LAB 65.
   
   figure;                     % 3D S=1 La*b* SATURATION MAP
   figsz = [560,560];  % x and y-figure size.
   p1 = [round(max(screen(3)/2-figsz(1)/2,screen(3)/6)) (screen(4)-figsz(2))/2 ...
      figsz(1) figsz(2)];  % L B W H
   set(gcf,'Position',p1,'PaperPositionMode','auto','Name','S=1 La*b* Saturation map');
   if (screen(4)<750) movegui(gcf,'center');  end  % Keep fig on 800x600 screen.

   % 'FaceColor' should be 'interp' or 'flat' (Chromix is 'flat').
   surfc(labdata(:,:,2), labdata(:,:,3), labdata(:,:,1), s1_cropsm, 'FaceColor', 'flat', ...
      'EdgeColor','none','FaceLighting','gouraud');  % [.6 .6 .6]);  % );
   % shading faceted;
   ccmap = zeros(64,3);  % Colormap for the contours. Start in HSL, then convert to RGB.
   ccmap(:,1) = 2/3;  ccmap(:,2) = .6;  ccmap(:,3) = linspace(0,1,64)';  % linspace(0,.9,64)';
   % Play with ccmap(:,3) (L) to get good display tones. Increasing kc makes mid-tones darker.
   kc = .8;  ccmap(:,3) = .82*(kc*ccmap(:,3) + (1-kc)*sqrt(ccmap(:,3)));
   ccmap = hsl2rgb(ccmap);  ccmap = brighten(ccmap, .5);
   colormap(ccmap);  % was hot;
   % origpos = campos;    % We might vary camera position???
   % campos(origpos/5);  % Enlarged things a bit much. Not so good!
   hold on;
   contour3(labdata(:,:,2), labdata(:,:,3), labdata(:,:,1), [10:10:90 95]);
   
   surfc(labdatb(:,:,2), labdatb(:,:,3), labdatb(:,:,1), s1_cropsb, 'FaceColor', 'none', ...
      'EdgeColor','flat');  % [.6 .6 .6]);  % );
   % shading faceted;
   
   set(gca,'Color',[.4 .4 .4]);
   % camlight left;
   rotate3d on;  axis vis3d;  % vis3d should be interesting!
   xlabel('a*');  ylabel('b*');  zlabel('L');
   title(['sRGB (wire), ' profname ' (solid)'],'Interpreter','none');
   maxa = max(max(labdata(:,:,2))); mina = min(min(labdata(:,:,2)));
   maxb = max(max(labdata(:,:,3))); minb = min(min(labdata(:,:,3)));
   axmaxa = ceil(maxa/10)*10;  axmina = floor(mina/10)*10;
   axmaxb = ceil(maxb/10)*10;  axminb = floor(minb/10)*10;
   maxc = max(max(labdatb(:,:,2))); minc = min(min(labdatb(:,:,2)));
   maxd = max(max(labdatb(:,:,3))); mind = min(min(labdatb(:,:,3)));
   axmaxc = ceil(maxc/10)*10;  axminc = floor(minc/10)*10;
   axmaxd = ceil(maxd/10)*10;  axmind = floor(mind/10)*10;
   axmaxa = max(axmaxa,axmaxc);  axmina = min(axmina,axminc);
   axmaxb = max(axmaxb,axmaxd);  axminb = min(axminb,axmind);
   ax = axis;
   ax(1) = max([ax(1),-128,axmina,axminc]);
   ax(2) = min([ax(2), 128,axmaxa,axmaxc]);  % Limits of ICCTrans.
   ax(3) = max([ax(3),-128,axminb,axmind]);
   ax(4) = min([ax(4), 128,axmaxb,axmaxd]);
   ax(5) = 0;  ax(6) = 100;  axis(ax);
   clear labdata;
end  % if 1/0


return;  %  Test 3D plot, so don't need to display L5.  %%%%%%%%%%%%%%%%%%


%                                  L5 La*b* GAMUT MAP for S from 0 to 1

nis = 6;
sshsl = ones(nis,121,3);  % Number of steps
for i1=1:nis           % Vary S from 0 to 1.
   sshsl(i1,:,1) = linspace(0,1,121)';
   sshsl(i1,:,2) = (nis-i1)/(nis-1);  % 1-0.
end
sshsl(:,:,3) = 0.5;
ssrgb = hsl2rgb(sshsl);
sslab = rgb2lab(ssrgb,colorig);  % Use selected color space.
sslab2 = rgb2lab(ssrgb,colorspace);  % For displaying scanner color space.
xbound = [min(sslab(1,:,2),[],2) max(sslab(1,:,2),[],2)];  % min, max a (x) for Color space
ybound = [min(sslab(1,:,3),[],2) max(sslab(1,:,3),[],2)];  % min, max b (y) for Color space
xlims =  [floor(xbound(1))-1 ceil(xbound(2))+1];  % Limits for plotting
ylims =  [floor(ybound(1))-1 ceil(ybound(2))+1];

% Calculate lines of constant hue.
chue_hsl = ones(13,41,3);
for i1=1:13
   chue_hsl(i1,:,1) = (i1-1)/12;
   chue_hsl(i1,:,2) = linspace(0,1,41);
end
chue_hsl(:,:,3) = 0.5;
chue_rgb = hsl2rgb(chue_hsl);
chue_lab = rgb2lab(chue_rgb,colorig);
hueplt_hsl = ones(13,3);  hueplt_hsl(:,1) = (0:12)'/12;  % Color of hue plot
hueplt_hsl(:,2) = 1;  hueplt_hsl(:,3) = 0.5;
hueplt_hsl(4:7,3) = [.4; .3; .3; .3];
hueplt_rgb = hsl2rgb(hueplt_hsl);

mark_hsl = ones(nis,13,3);  % hueplt_hsl;
for i1=1:nis
   mark_hsl(i1,:,1) = (0:12)'/12;  % Color of hue plot
   mark_hsl(i1,:,2) = 1.08-.08*i1;  mark_hsl(i1,:,3) = 0.5;
   mark_hsl(i1,3:7,3) =  [.47; .47; .44; .45; .44];   % .45;
   mark_hsl(i1,9:10,3) = [.58; .52];
end
mark_rgb = hsl2rgb(mark_hsl);    % Color of marker

% Use native size for LAB. 
xvals = [xlims(1):xlims(2)];  lenx = length(xvals);
yvals = [ylims(1):ylims(2)];  leny = length(yvals);
labdata = ones(leny,lenx,3);
labdata(:,:,2) = ones(leny,1)*xvals;   % a (x)
labdata(:,:,3) = yvals'*ones(1,lenx);  % b (y)
labdata(:,:,1) = linspace(76,92,leny)'*ones(1,lenx);  % 85;  % L.

rgbdata = lab2rgb(labdata,'sRGB');
x20 = 20*fix(.98*xlims/20);  % x-limits for plotting '+' every 20 a*b* values.
y20 = 20*fix(.98*ylims/20);  % y-limits for plotting '+' every 20 a*b* values.

pltfile(7) = figure;                     % Plot L5 La*b* GAMUT MAP
figsz = [560,610];  % x and y-figure size. Was [560,560].
if (expandplt & screen(4)>1024) figsz = figsz*1.25;  end
p1 = [round(max(screen(3)/2-figsz(1)/2,screen(3)/6)) (screen(4)-figsz(2))/2 figsz(1) figsz(2)];  % L B W H
set(gcf,'Position',p1,'PaperPositionMode','auto','Name','L=0.5 La*b* Gamut map');
if (screen(4)<750) movegui(gcf,'center');  end  % Keep fig on 800x600 screen.

hlab = axes('Position',[.10 .14 .85 .785]);  % [L B W H]  was [.10 .07 .85 .85]
% set(gca,'FontSize',dfz);

image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)]);
% axis image;
ax = axis;
set(gca,'YDir','normal');  % 'reverse' or 'normal'
title({'La*b* Gamut map for L(HSL)=0.5; S from 0 to 1'; 'Test image'}, ...
   'FontWeight','bold','Fontsize',dfz);
xlabel('a*','FontWeight','bold');
ylabel('b*','FontWeight','bold');

% The second axes solves the problem of plots disappearing with the legend is moved.
% This plot cannot be done with a single contour(...) because it is mult-valued.
% No contourable surface. % But there could be tricks: Those contour plots look cool!
% If we do multiple contours, numbers could overlap.
hrpt = axes('Position',get(hlab,'Position'));  % REPEAT!
set(hrpt,'Visible','off','Xlim',get(hlab,'Xlim'),'Ylim',get(hlab,'Ylim'),'FontSize',dfz);
hold on;
image(uint8(255*rgbdata),'Xdata',[xlims(1),xlims(2)],'Ydata',[ylims(1),ylims(2)],'Visible','off');
% axis image;
axis(ax);
for i1=x20(1):20:x20(2)  % Plot '+' every 20 a*b* units vertically and horizontally.
   for j1=y20(1):20:y20(2)
      i2 = .65+.1*(j1-y20(1))/(y20(2)-y20(1));  % Lighten from bottom to top.
      text(i1,j1,'+','Color',[i2 i2 i2],'HorizontalAlignment','center');
   end
end
if evalver                      % EVALUATION VERSION
   text((ax(1)+ax(2))/2, .48*ax(3)+.52*ax(4), {'Evaluation version';''; ...
      'Purchase at www.imatest.com'}, 'HorizontalAlignment','center','Color', ...
      [.7 .7 .7],'FontWeight','bold','Fontsize',dfz+6);
end

plot(sslab(1,:,2),sslab(1,:,3),'Color',[.2 .2 .2],'LineWidth',1.5,'LineStyle',':');  % Ideal S=1.
gcolors =  [0 0 0;    0 0 1;     0 .6 0;   .8 0 0;    .6 .4 0;    .4 .4 .4;];  % for heavy lines.
ltcolors = [.8 .8 .8;  .8 .8 1;  .6 1 .6;  1 .85 .85;  1 .9 .8;   .8 .8 .8;];  % Light colors.
for i1=1:nis  % Look at cross-sections of L5_crop.
   llvl(i1) = .2*(i1-1);  % 0-1.
   y5 = round(1+llvl(i1)*(sz_L5(1)-2));  % Avoid extremes.
   sgamut = L5_crop(y5,:,:);  % Should be RGB.
   szg = size(sgamut);  sgamut = reshape(sgamut, szg(1)*szg(2), szg(3));
   szg = size(sgamut);  % 2D
   sgamut = [sgamut(szg-3:szg,:); sgamut; sgamut(1:4,:)];  % Wrap: add 4 pts at each end.
   for ism=1:3  sgamut(:,ism) = smoothp(sgamut(:,ism),3);  end
   szg2 = size(sgamut);
   sgamut = sgamut(3:szg2-2,:);  % Keep 1 extra pt at each end.
   sglab(i1,:,:) = rgb2lab(sgamut,colorspace);
   sgvort(i1,:) = round(linspace(3,length(sgamut)-2,13));  % Vortex locations
   plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);
   gideal(i1) = polyarea(sslab(i1,:,2),sslab(i1,:,3));
   garea(i1) =  polyarea(sglab(i1,:,2),sglab(i1,:,3));
end
set(gca,'Xlim',xlims,'Ylim',ylims);
hleg = legend('Color space','S=1.0','S=0.8','S=0.6','S=0.4','S=0.2','S=0.0',3);
set(hleg,'Color',[.7 .85 .95]);

line([0 0], [.92*ax(3)+.08*ax(4) .03*ax(3)+.97*ax(4)],'Color',[.6 .6 .6],'LineStyle',':');
line([.97*ax(1)+.03*ax(2) .03*ax(1)+.97*ax(2)], [0 0],'Color',[.6 .6 .6],'LineStyle',':');
for i1=1:12
   plot(chue_lab(i1,:,2),chue_lab(i1,:,3),'Color',hueplt_rgb(i1,:),'LineStyle',':');
end
for i1=nis:-1:1
   if ~isequal(colorspace,colorig)
      plot(sslab2(i1,:,2),sslab2(i1,:,3),'Color',ltcolors(i1,:),'LineStyle',':');  % Scanner space.
   end
   plot(sslab(i1,:,2),sslab(i1,:,3),'Color',gcolors(i1,:),'LineStyle',':');  % Ideal original space.
end
for i1=nis-1:-1:1
   plot(sglab(i1,:,2),sglab(i1,:,3),'Color',gcolors(i1,:),'LineStyle','-','LineWidth',1.5);  % to top
   sgvort(i1,1) = mean(sgvort(i1,1),sgvort(i1,13));
   for j1=1:12
      plot(sglab(i1,sgvort(i1,j1),2),sglab(i1,sgvort(i1,j1),3),'o', ...   % Vortices.
         'MarkerEdgeColor',gcolors(i1,:),'MarkerFaceColor',mark_rgb(i1,j1,:),'MarkerSize',dfz-4)
   end
end

text(.03*ax(1)+.97*ax(2),.04*ax(3)+.96*ax(4),['Original: ' colorig], ...
   'FontSize',dfz,'Color',[.2 .2 .4],'HorizontalAlignment','right');
text(.03*ax(1)+.97*ax(2),.08*ax(3)+.92*ax(4),['Scanner: ' colorspace], ...
   'FontSize',dfz,'Color',[.2 .2 .4],'HorizontalAlignment','right');
text(.60*ax(1)+.40*ax(2),.96*ax(3)+.04*ax(4), daterun, 'Fontsize',dfz-2, ...
   'HorizontalAlignment','center');  % Date

harea = axes('Position',[.06 .02 .88 .12],'Visible','off');  % [L B W H]
darea{1} = sprintf('S (HSL Sat @ L=0.5)%6.1f%7.1f%7.1f%7.1f%7.1f%7.1f', ...
   sshsl(6,1,2),sshsl(5,1,2),sshsl(4,1,2),sshsl(3,1,2),sshsl(2,1,2),sshsl(1,1,2));
darea{2} = sprintf('Area (ideal)       %6.0f%7.0f%7.0f%7.0f%7.0f%7.0f', ...
   gideal(6),gideal(5),gideal(4),gideal(3),gideal(2),gideal(1));
darea{3} = sprintf('Area (measured)    %6.0f%7.0f%7.0f%7.0f%7.0f%7.0f', ...
   garea(6),garea(5),garea(4),garea(3),garea(2),garea(1));
text(0,.2, darea,'Fontsize',dfz,'FontName','FixedWidth');

% For plot [L B W H]                 LOGO TEMPLATE.   Works on top of images.
poslab = get(hlab,'Position');                   % LOGO
pos = [poslab(1)+.02*poslab(3) poslab(2)+.28*poslab(4) ...
   imlogf.Width/figsz(1), imlogf.Height/figsz(2)];   % [L B W H];
hlgo = axes('Position',pos,'Visible','off');
image(imlogo);  axis off;  axis image;
%                           END  L5 La*b* GAMUT MAP for S from 0 to 1



return;
