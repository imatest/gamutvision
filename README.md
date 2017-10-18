# Gamutvision

Gamutvision™ is a gamut viewer and much more. It is a powerful tool for learning color management, exploring its functions, and proofing color workflows. With Gamutvision you can

## With Gamutvision you can
– View gamuts of color spaces, displays, and printers. 
– Visualize gamut mappings and rendering intents. 
– View color response for ANY saturation and lightness level, not just the gamut surface.   
– Evaluate ICC profile quality. 
– Preview printer, paper, and photo lab performance using downloaded profiles.  
– Analyze the performance of your printer using scanned test prints.   
– See precisely how image colors will change when printed.

## Who needs Gamutvision?
– Photographers: professional and prosumer
– Manufacturers and reviewers of printers, papers, and profiles
– Graphic arts studios and print shops
– Students of photography and color management

Please vision the [Gamutvision documentation page](http://www.imatest.com/gamutvision/) for more information.

# Important files

- source\gamutvision.m/.fig - main function for Gamutvision
- source\gamake.m - The function used to compile Gamutvision
- gamutvision_14.nsi - The NSIS installer script used to build the full installer for NSIS
- Gamutvision-1.4.exe - A precompiled version of Gamutvision wrapped into an NSIS installer.

# Notes

This version was built with MATLAB 6.5.1 (R13 SP1) with only 32-bit *.dll libraries with the licensing system removed. It was tested with 32-bit MATLAB 2015a, but there is a bit of work needed in order to get Gamutvision running on a more modern version of MATLAB and hence Windows.