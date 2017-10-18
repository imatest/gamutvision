tic  % Start timer
disp(['Start Gamutvision compile in ' pwd]);  % We seem to be starting in Matlab.
binfolder = '..\..\gamutvision\installation\bin';
outfolder = '..\..\gamutvision\installation';
disp(['outfolder = ' outfolder]);
cd('..\matlab')  % Back to original
copyfile('g*.fig', binfolder);  %    '..\gvinstall\bin');
% copyfile('register_imatest.fig',    binfolder); 
% copyfile('manual_activation.fig',   binfolder); 
copyfile('about_imatest.fig',       binfolder); 
% copyfile('imatest_renewal.fig',     binfolder); 
copyfile('save_screen_generic.fig', binfolder); 
copyfile('readrecent.fig',          binfolder); 
copyfile('roi_try_again.fig',       binfolder); 
copyfile('FigureToolBar.fig',       binfolder); 
copyfile('FigureMenuBar.fig',       binfolder); 
% Be sure to add any additional .fig files: so far only g* needed.
copyfile('*.dll', outfolder);  %    '..\gvinstall');
% murphy  % Get current checksums for status.dll and register.dll, and put in m-file.
% type('murphsurf.m');
mcc -m gamutvision -B sgl   % Build gamutvision  -v makes it verbose (remove normally)
copyfile('gamutvision.exe',outfolder);
movefile('*.c','..\build');
movefile('*.h','..\build');
time_elapsed = toc;  
disp(['End Gamutvision compilation: ' datestr(now) ': elapsed = ' num2str(time_elapsed)]);
beep
