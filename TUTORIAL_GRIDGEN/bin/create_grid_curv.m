function create_grid_curv(fname_nml)

% -------------------------------------------------------------------------
%|                                                                        |
%|                    +----------------------------+                      |
%|                    | GRIDGEN          NOAA/NCEP |                      |
%|                    |                            |                      |
%|                    | Last Update :  18-Jan-2017 |                      |
%|                    +----------------------------+                      |
%|                     Distributed with WAVEWATCH III                     |
%|                                                                        |
%|                 Copyright 2009 National Weather Service (NWS),         |
%|  National Oceanic and Atmospheric Administration.  All rights reserved.|
%|                                                                        |
%| DESCRIPTION                                                            |
%| Create a grid based on a curvilinear digital model elevation           |
%|                                                                        |
%| create_grid_curv(fname_nml)                                            |
%|                                                                        |
%| INPUT                                                                  |
%|  fname_nml   : Input namelist file name                                |
% -------------------------------------------------------------------------

% 0. Initialization
tic
fname_nml
set(groot,'DefaultFigureColormap',jet);
close all;

% Load namelist
init_nml    = read_namelist(fname_nml,'GRID_INIT');
bathy_nml   = read_namelist(fname_nml,'BATHY_FILE');
gridbound_nml =  read_namelist(fname_nml,'GRID_BOUND');
gridparam_nml =  read_namelist(fname_nml,'GRID_PARAM');


% Read namelist variables

% 0.a Path to directories and file names
bin_dir = init_nml.bin_dir;     % matlab scripts location
ref_dir = init_nml.ref_dir;     % reference data location
data_dir = init_nml.data_dir;   % output grid directory

fnamep = init_nml.fname_poly;         % file for user-defined polygons
fname_poly = [ref_dir, '/', fnamep];  % complete file name
fname = init_nml.fname;               % file name prefix
fname(fname=='''') = [];
fnamefig = strrep(fname,'_','\_');         % file name for figures

% 0.b Information on bathymetry file

ref_grid = bathy_nml.ref_grid;      % name of reference bathymetry file
xvar     = bathy_nml.xvar;          % variable name for longitudes in file
yvar     = bathy_nml.yvar;          % variable name for latitudes in file
zvar     = bathy_nml.zvar;          % variable name for depths in file

% 0.e Boundary options
boundary = gridbound_nml.boundary;     % Determine which GSHHS .mat file to load

% 0.f Parameter values used in the software

DRY_VAL = gridparam_nml.dry_val;       % Depth value for dry cells
LIM_VAL = gridparam_nml.lim_val;       % Fraction of cell that has to be inside
% a polygon for cell to be marked dry;
SPLIT_LIM = gridparam_nml.split_lim;    % Limit for splitting the polygons;
% used in split_boundary
OFFSET = gridparam_nml.offset;         % Additional buffer around the boundary
% to check if cell is crossing boundary.

% generate grid

fname_base = [ref_dir,'/',ref_grid,'.nc'];
f = netcdf.open(fname_base,'nowrite');

varid_lon = netcdf.inqVarID(f,xvar);
varid_lat = netcdf.inqVarID(f,yvar);
%varid_mask = netcdf.inqVarID(f,'mask_rho');
varid_z = netcdf.inqVarID(f,zvar);

lon = transpose(netcdf.getVar(f,varid_lon));
lat = transpose(netcdf.getVar(f,varid_lat));
%m = (netcdf.getVar(f,varid_mask))';
depth = transpose(netcdf.getVar(f,varid_z));


% mask

%$ The legend for the input map is :
%$
%$    0 : Land point.
%$    1 : Regular sea point.
%$    2 : Active boundary point.
%$    3 : Point excluded from grid.


% set to sea point (1)
m1 = ones(size(depth));
% set to active boundary point (2)
ny=size(m1,1);
nx=size(m1,2);
m1(1,:) = 2;
m1(ny,:) = 2;
m1(:,1) = 2;
m1(:,nx) = 2;
% set to land point (0)
m1(depth == DRY_VAL) = 0;
% set to land point (0)
m1(depth~=depth)=0;
% set to land point (0)
try
	fillvalue = netcdf.getAtt(f,varid_z,'_FillValue');
  m1(depth == fillvalue) = 0;
catch
	warning('No _FillValue attribute for the depth variable');
end

% force depth to 10m
depth(depth == DRY_VAL) = 0;
depth(depth~=depth) = 0;
depth(depth==fillvalue) = 0;

figure(1);
%pcolor(lon,lat,depth); shading flat;
pcolor(double(depth)); shading flat;
colorbar;
title(['Final Bathymetry ',fnamefig],'fontsize',14);
set(gca,'fontsize',14);

figure(2);
%contour(lon,lat,m1);
contour(m1);
colorbar;
title(['Final Land-Sea Mask Contour ',fnamefig],'fontsize',14);
set(gca,'fontsize',14);

figure(3);
%pcolor(lon,lat,m1); shading interp;
pcolor(double(m1)); shading interp;
colorbar;
title(['Final Land-Sea Mask ',fnamefig],'fontsize',14);
set(gca,'fontsize',14);

m2=m1;
%load([ref_dir,'/coastal_bound_',boundary,'.mat']);
%coord = [lat_start lon_start lat_end lon_end];
%[b,N1] = compute_boundary(coord,bound, MIN_DIST);
%m2 = clean_mask(lon,lat,m1,b,LIM_VAL,OFFSET);


% obstruction
%sx1=zeros(size(depth));
%sy1=zeros(size(depth));
obstr_scale = 100;
%d1 = round((sx1)*obstr_scale);
%d2 = round((sy1)*obstr_scale);
%write_ww3obstr([data_dir,'/',fname,'.obst'],d1,d2);

% write bot file
depth_scale = 1000;
d = round((depth)*depth_scale);
write_ww3file([data_dir,'/',fname,'.bot'],d);

% write mask lat lon files
write_ww3file([data_dir,'/',fname,'.mask'],m2);
write_ww3file([data_dir,'/',fname,'.lon'],lon);
write_ww3file([data_dir,'/',fname,'.lat'],lat);

% write meta file
write_ww3meta([data_dir,'/',fname],fname_nml,'CURV',lon,lat,1/depth_scale,...
  1/obstr_scale,1.0);


% write namelists file
fid = fopen([data_dir,'/','namelists_',fname,'.nml'],'w');
[messg,errno] = ferror(fid);
if (errno ~= 0)
    fprintf(1,'!!ERROR!!: %s \n',messg);
    fclose(fid);
    return;
end;
fprintf(fid,'%s\n','END OF NAMELISTS');
fclose(fid);

