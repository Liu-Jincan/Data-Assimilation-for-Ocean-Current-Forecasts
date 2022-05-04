%% 1) Define basic parameters for the desired grid
set(groot,'DefaultFigureColormap',jet)

bin_dir = '../bin';
ref_dir = '../reference';
nml_dir = '../namelist';
data_dir = '../data';

dx = 0.125; dy = 0.125;
lon_west = 12;
lon_east = 23;
lat_south = -38.9;
lat_north = -27.2;
lon1d = (lon_west:dx:lon_east);
lat1d = (lat_south:dy:lat_north);
[lon,lat] = meshgrid(lon1d,lat1d);
addpath(bin_dir,'-END');    

load([ref_dir,'/coastal_bound_full.mat']);
bound

figure(1);clf;
for i = 1:1000
plot(bound(i).x,bound(i).y,'.','MarkerSize',0.5);
hold all;
end;

%% 2) Create a bathymetry grid

CUT_OFF = 0.0;
% Cut-off depth to distinguish between dry & wet cells
LIM_BATHY = 0.4; % Base bathymetry cells needing to be wet for the target cell to be considered wet.
DRY_VAL = 999999; % Depth value set for fry cells

ref_grid = 'gebco'; % Name of the file without the '.nc' extension
xvar = 'lon'; % Name of the variable defining longitudes in file
yvar = 'lat'; % Name of the variable defining latitudes in file
zvar = 'elevation'; % Name of the variable defining depths in file

depth = generate_grid('rect',lon,lat,ref_dir,ref_grid,LIM_BATHY,CUT_OFF,DRY_VAL,xvar,yvar,zvar);
figure(1);clf;
d=depth;d(d==DRY_VAL)=nan; pcolor(lon,lat,d); shading flat; colorbar

m1 = ones(size(depth));
m1(depth == DRY_VAL) = 0;

figure(1);clf;
pcolor(lon,lat,m1);shading flat;caxis([0 3]);colorbar

%% 3) Compute boundaries
lon_start = min(min(lon))-dx;
lon_end = max(max(lon))+dx;
lat_start = min(min(lat))-dy;
lat_end = max(max(lat))+dy;
coord = [lat_start lon_start lat_end lon_end];
MIN_DIST = 4; % minimum distance between edge of polygon and boundary

[b,N] = compute_boundary(coord,bound);

figure(1);clf;
for i = 1:N
plot(b(i).x,b(i).y);
hold on;
end;

%% 4) Split up boundary polygons
SPLIT_LIM = 0.5;
b_split = split_boundary(b,SPLIT_LIM,MIN_DIST);

Nb = length(b_split);
figure(1);clf;
for i = 1:Nb
plot(b_split(i).x,b_split(i).y);
hold on;
end;


%% 5) Clean up the initial mask 
LIM_VAL = 0.5;
OFFSET = 0.125; % max([dx dy])
m2 = clean_mask(lon,lat,m1,b_split,LIM_VAL,OFFSET);

figure(1);clf;
pcolor(lon,lat,m2);shading flat;caxis([0 3]);colorbar

%% 6) Remove artificially generated lakes
LAKE_TOL = 100;
IS_GLOBAL = 0;
[m4,mask_map] = remove_lake(m2,LAKE_TOL,IS_GLOBAL);

figure(1);clf;
pcolor(lon,lat,m4);shading flat;caxis([0 3]);colorbar

figure(1);clf;
pcolor(lon,lat,mask_map);shading flat;caxis([-1 6]);colorbar

%% 7) Generating obstruction grids
OBSTR_OFFSET = 1;
[sx1,sy1] = create_obstr(lon,lat,b,m4,OBSTR_OFFSET,OBSTR_OFFSET);

sx1(find(m4==0))=NaN;
sy1(find(m4==0))=NaN;
figure(1);clf;
pcolor(lon,lat,sx1);shading flat;caxis([0 1]); colorbar
figure(2);clf;
pcolor(lon,lat,sy1);shading flat;caxis([0 1]); colorbar

%% 8) save file
fname='ZA-7M';
depth_scale = 1000;
obstr_scale = 100;
d = round((depth)*depth_scale);
write_ww3file([data_dir,'/',fname,'.bot'],d);
write_ww3file([data_dir,'/',fname,'.mask_nobound'],m4);
d1 = round((sx1)*obstr_scale);
d2 = round((sy1)*obstr_scale);
write_ww3obstr([data_dir,'/',fname,'.obst'],d1,d2);
write_ww3meta ([data_dir,'/',fname],[nml_dir,'/gridgen.',fname,'.nml'],'RECT',lon,lat,1/depth_scale,1/obstr_scale,1.0);


%% 9） create_grid
create_grid('../namelist/gridgen.BENG-3M.nml');

%% 10) Set up boundary conditions for multiple grids
create_boundary('../namelist/gridgen.BENG-3M.nml');

create_boundary('../namelist/gridgen.ZA-7M.nml');



