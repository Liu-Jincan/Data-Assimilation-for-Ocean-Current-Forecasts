function create_grid(fname_nml)

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
%| Create a grid based on a rectilinear digital model elevation           |
%|                                                                        |
%| create_grid(fname_nml)                                                 |
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
outgrid_nml = read_namelist(fname_nml,'OUTGRID');
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
fnameb = init_nml.fnameb;               % file name prefix
fnameb(fnameb=='''') = [];
fnamefig = strrep(fname,'_','\_');         % file name for figures

% 0.b Information on bathymetry file

ref_grid = bathy_nml.ref_grid;      % name of reference bathymetry file
lonfrom  = bathy_nml.lonfrom;       % origin of longitudes [ -180 | 0]
xvar     = bathy_nml.xvar;          % variable name for longitudes in file
yvar     = bathy_nml.yvar;          % variable name for latitudes in file
zvar     = bathy_nml.zvar;          % variable name for depths in file

% 0.c Required grid resolution and boundaries
type = outgrid_nml.type;              % grid type 'rect' or 'curv'
dx = outgrid_nml.dx;                  % resolution in longitudes (°)
dy = outgrid_nml.dy;                  % resolution in latitudes (°)

lon_west  = outgrid_nml.lon_west;     % western boundary for grid
lon_east  = outgrid_nml.lon_east;     % eastern boundary for grid
lat_south = outgrid_nml.lat_south;    % southern boundary for grid
lat_north = outgrid_nml.lat_north;    % northern boundary for grid
IS_GLOBAL = outgrid_nml.is_global;    % Set to 1 for global grids

% 0.e Boundary options
boundary = gridbound_nml.boundary;     % Determine which GSHHS .mat file to load
read_boundary = gridbound_nml.read_boundary; % flag: input boundary information to read ?
opt_poly = gridbound_nml.opt_poly;     % flag: user-defined polygons or not
MIN_DIST = gridbound_nml.min_dist;

% 0.f Parameter values used in the software

DRY_VAL = gridparam_nml.dry_val;       % Depth value for dry cells
CUT_OFF = gridparam_nml.cut_off;       % Cut_off depth to distinguish between
% dry and wet cells.
% All depths < CUT_OFF are marked wet
LIM_BATHY = gridparam_nml.lim_bathy;   % Proportion of base bathymetry cells
% that need to be wet for the target cell
% to be considered wet.
LIM_VAL = gridparam_nml.lim_val;       % Fraction of cell that has to be inside
% a polygon for cell to be marked dry;
SPLIT_LIM = gridparam_nml.split_lim;   % Limit for splitting the polygons;
% used in split_boundary
OFFSET = gridparam_nml.offset;         % Additional buffer around the boundary
% to check if cell is crossing boundary.
LAKE_TOL = gridparam_nml.lake_tol;     % Tolerance value for 'remove_lake'

OBSTR_OFFSET = gridparam_nml.obstr_offset;
% Flag: neighbours to consider when
% creating obstruction?
% Used in create_obstr

% 0.g Setting the paths for subroutines

addpath(bin_dir,'-END');
fprintf('.........Create grid for %s..................\n',fname);

% Reading input data
if (read_boundary == 1)
    fprintf(1,'.........Reading Boundaries..................\n');
    
    load([ref_dir,'/coastal_bound_',boundary,'.mat']);
    
    N = length(bound);
    Nu = 0;
    if (opt_poly == 1)
        [bound_user,Nu] = optional_bound(ref_dir,fname_poly);
    end;
    if (Nu == 0)
        opt_poly = 0;
    end;
end;


%
% 1. Define type of run
%

% check lonfrom
% also check that boundaries are correctly defined
if (strcmp(ref_grid,'etopo1'))
    lonfrom = 0;
    if (lon_west < 0)
        error('ERROR: lonfrom=0 so lon_west should be >= 0')
    end
elseif (strcmp(ref_grid,'etopo2'))
    lonfrom = -180;
    if (lon_east > 180)
        error('ERROR: lonfrom=-180 so lon_east should be <= 180')
    end
end


% test if longitudes cross Greenwich:
if (lonfrom == 0)
    % longitudes are all positive: it crosses 0° meridian if lon_west >
    % lon_east
    gridsplit = (lon_west > lon_east);
    %       gridsplit = false(1);
elseif (lonfrom == -180)
    % longitudes range from -180° to 180°: they cross 0° if there is a
    % change of sign in longitudes array
    gridsplit = (lon_west * lon_east < 0);
else
    fprintf('ERROR: value of lonfrom not recognized:')
    fprintf(lonfrom)
end


if (strcmp(type,'rect'))
    
    %
    % Calculate the offset around the longitude 0
    %
    fname_bathy = [ref_dir,'/',ref_grid,'.nc'];
    f = netcdf.open(fname_bathy,'nowrite');
    dimid_lon = netcdf.inqDimID(f,xvar);
    [~,Nx_base]=netcdf.inqDim(f,dimid_lon);
    varid_lon = netcdf.inqVarID(f,xvar);
    lon_range= netcdf.getAtt(f,varid_lon,'actual_range');
    lons_base=lon_range(1);
    dx_base = diff(lon_range)/(Nx_base-1);
    rest=rem((lons_base-0)/dx_base,1);
    offset=rest*dx_base;
    
    
    %
    % All the rest of the computation depends on whether the grids must be
    % splitted or not
    %
    if (gridsplit)
        fprintf('*** Split the computation into two parts ***\n')
        
        % Define "sub-arrays" for longitude
        if (lonfrom == 0) % etopo1 convention
            fprintf('Note : we assume that the bathy file starts exactly at longitude 0\n')
            lon1d1 = (0:dx:lon_east); % 180° will be removed later
            lon1d2 = (lon_west:dx:360-dx); % lon_west supposed to be positive (e.g. 350° and not -10°)
        elseif (lonfrom == -180) % etopo2 convention
            % then initially lon_west supposed to be < 0 and lon_east > 0
            % BUT: longitudes need to be shifted later to positive values
            % only, because  the compute_boundary function works with polygons
            % defined from 0° to 360°
            if (offset ~= 0)
                fprintf('Note : we assume that the bathy file has a longitude range centered on 0\n')
                lon1d1 = (abs(offset):dx:lon_east);
                lon1d2 = (lon_west:dx:offset);
            else
                fprintf('Note : we assume that the bathy file has a longitude exactly at 0\n')
                lon1d1 = (0:dx:lon_east);
                lon1d2 = (lon_west:dx:0-dx);
            end
        end
        
        % latitude defined independently from longitude convention
        lat1d = (lat_south:dy:lat_north);
        
        [lon1,lat1] = meshgrid(lon1d1,lat1d);
        [lon2,lat2] = meshgrid(lon1d2,lat1d);
        
        
    else
        fprintf('*** No splitting of computation ***\n')
        % from lon,lat min,max: define the longitudes & latitudes arrays
        lon1d = (lon_west:dx:lon_east);
        lat1d = (lat_south:dy:lat_north);
        [lon,lat] = meshgrid(lon1d,lat1d);
    end
    
    % curvilinear grid
elseif (strcmp(type,'curv'))
    fname_lat = [ref_dir, '/', fname, '.lat'];
    fname_lon = [ref_dir, '/', fname, '.lon'];
    lat=load(fname_lat);
    lon=load(fname_lon);
    gridsplit=0;
    
    % lambert conformal conic grid
elseif (strcmp(type,'lamb'))
    fname_bathy = [ref_dir,'/',ref_grid,'.nc'];
    f = netcdf.open(fname_bathy,'nowrite');
    dimid_lat = netcdf.inqDimID(f,'y');
    [~,Ny_base]=netcdf.inqDim(f,dimid_lat);
    varid_lat = netcdf.inqVarID(f,yvar);
    lat=(netcdf.getVar(f,varid_lat))';
    dimid_lon = netcdf.inqDimID(f,'x');
    [~,Nx_base]=netcdf.inqDim(f,dimid_lon);
    varid_lon = netcdf.inqVarID(f,xvar);
    lon=(netcdf.getVar(f,varid_lon))';
    gridsplit=0;
end

% 2. Generate the grid

fprintf(1,'.........Creating Bathymetry..................\n');

if (gridsplit)
    depth1 = generate_grid(type,lon1,lat1,ref_dir,ref_grid,LIM_BATHY,CUT_OFF,DRY_VAL,xvar,yvar,zvar);
    depth2 = generate_grid(type,lon2,lat2,ref_dir,ref_grid,LIM_BATHY,CUT_OFF,DRY_VAL,xvar,yvar,zvar);
else
    depth = generate_grid(type,lon,lat,ref_dir,ref_grid,LIM_BATHY,CUT_OFF,DRY_VAL,xvar,yvar,zvar);
end


% 3. Computing boundaries within the domain

fprintf(1,'.........Computing Boundaries..................\n');

% 3.a Set the domain big enough to include the cells along the edges of the grid
% /!\ The coordinates need to be defined so that they work with the coastal
% boundaries structure, which accepts only longitudes from 0° to 360°

if (gridsplit)
    % No problem for lat
    lat_start = min(min(lat1))-dy;
    lat_end = max(max(lat1))+dy;
    % No problem for 1st subgrid: by definition, all lon >= 0
    lon_start1 = max(0,min(min(lon1))-dx);
    lon_end1 = max(max(lon1))+dx;
    % When the grid is split, the question of shifting is only for lon2 when lonfrom=-180
    lon_start2 = mod(min(min(lon2))+360,360)-dx;
    lon_end2   = mod(max(max(lon2))+360,360)+dx;
    %      same thing as:
    %       if (lonfrom == 0) %etopo1
    %           lon_start2 = min(min(lon2))-dx;
    %           lon_end2 = max(max(lon2))+dx;
    %       else
    %           lon_start2 = min(min(lon2))-dx +360;
    %           lon_end2 = max(max(lon2))+dx + 360;
    %       end
else
    % No problem for lat
    lat_start = min(min(lat))-dy;
    lat_end = max(max(lat))+dy;
    % Shift only if lon2<0
    lon_start = mod(min(min(lon))+360,360)-dx;
    lon_end   = mod(max(max(lon))+360,360)+dx;
    %       % Same thing as:
    %       % Lon: shift only if lonfrom=-180 and negative lon
    %       if (lonfrom==0) || (min(min(lon))>=0)
    %           lon_start = max(0,min(min(lon))-dx);
    %           lon_end = max(max(lon))+dx;
    %       else
    %           lon_start = min(min(lon))-dx + 360; % do not impose a minimum threshold to 0 here
    %           lon_end = max(max(lon))+dx + 360 ;
    %       end
    
end


% 3.b Extract the boundaries from the GSHHS and the optional databases
%     The subset of polygons within the grid domain are stored in b and b_opt
%     for GSHHS and user defined polygons respectively

% to avoid for some errors in compute_boundaries function, duplicate
% shoreline polygon that cross Greenwitch meridian with lon = lon+360
% Only needed in some specific case
Nin = numel(bound); Nout = Nin;
DUPLICATED_BOUND = false;
for i = 1:Nin
    if any(bound(i).x < 0)
        Nout = Nout + 1;
        bound(Nout).level   = bound(i).level;
        bound(Nout).x       = bound(i).x + 360;
        bound(Nout).y       = bound(i).y;
        bound(Nout).n       = bound(i).n;
        bound(Nout).west    = bound(i).west + 360;
        bound(Nout).east    = bound(i).east + 360;
        bound(Nout).south   = bound(i).south;
        bound(Nout).north   = bound(i).north;
        DUPLICATED_BOUND = true;
    end
end

coastbound=1;

if (gridsplit)
    coord1 = [lat_start lon_start1 lat_end lon_end1];
    coord2 = [lat_start lon_start2 lat_end lon_end2];
    [b1,N11] = compute_boundary(coord1,bound,MIN_DIST);
    [b2,N12] = compute_boundary(coord2,bound,MIN_DIST);
    if (N11 == 0 || N12 == 0)
        fprintf(1,'[WARNING] no coastal boundaries found for this grid\n');
        coastbound=0;
    end
    if (opt_poly == 1)
        [b_opt1,N21] = compute_boundary(coord1,bound_user,MIN_DIST);
        [b_opt2,N22] = compute_boundary(coord2,bound_user,MIN_DIST);
    end
else
    coord = [lat_start lon_start lat_end lon_end];
    [b,N1] = compute_boundary(coord,bound, MIN_DIST);
    if (N1 == 0)
        fprintf(1,'[WARNING] no coastal boundaries found for this grid\n');
        coastbound=0;
    end
    if (opt_poly == 1)
        [b_opt,N2] = compute_boundary(coord,bound_user);
    end
end

% test to check if the duplication of the boundaries done before
% compute_boundary function doesn't lead to duplicated polygon in computed
% boundaries
if DUPLICATED_BOUND
    if (gridsplit)
        for i = 1:N11
            for j = i+1:N11
                if isequal(b1(i).x,b1(j).x) && isequal(b1(i).y,b1(j).y)
                    error('BUG')
                end
            end
        end
        for i = 1:N12
            for j = i+1:N12
                if isequal(b2(i).x,b2(j).x) && isequal(b2(i).y,b2(j).y)
                    error('BUG')
                end
            end
        end
    else
        for i = 1:N1
            for j = i+1:N1
                if isequal(b(i).x,b(j).x) && isequal(b(i).y,b(j).y)
                    error('BUG')
                end
            end
        end
    end
end

% debug plot (WARNING : don't plot optionnal boundaries)
if DUPLICATED_BOUND
    figure(9999); clf
    if (gridsplit)
        for i = 1:N11
            plot(b1(i).x,b1(i).y,'-'); hold on
        end
        for i = 1:N12
            plot(b2(i).x,b2(i).y,'-'); hold on
        end
    else
        for i = 1:N1
            plot(b(i).x,b(i).y,'-'); hold on
        end
    end
    %    pause
end

% 4. Set up Land - Sea Mask

% 4.a Set up initial land sea mask. The cells can either all be set to wet
%      or to make the code more efficient the cells marked as dry in
%      'generate_grid' can be marked as dry cells

if (gridsplit)
    m11 = ones(size(depth1));
    m12 = ones(size(depth2));
    m11(depth1 == DRY_VAL) = 0;
    m12(depth2 == DRY_VAL) = 0;
else
    m1 = ones(size(depth));
    m1(depth == DRY_VAL) = 0;
end

% 4.b Split the larger GSHHS polygons for efficient computation of the
%     land sea mask. This step is optional  but recommended as it
%     significantly speeds up the computational time. Rule of thumb is to
%     set the limit for splitting the polygons at least 4-5 times dx,dy

fprintf(1,'.........Splitting Boundaries..................\n');

if (coastbound)
if (gridsplit)
        b_split1 = split_boundary(b1,SPLIT_LIM,MIN_DIST);
        b_split2 = split_boundary(b2,SPLIT_LIM,MIN_DIST);
else
        b_split = split_boundary(b,SPLIT_LIM,MIN_DIST);
end
end

% debug plot
if (coastbound)
    if DUPLICATED_BOUND
        figure(9999); clf
        if (gridsplit)
            for i = 1:numel(b_split1)
                plot(b_split1(i).x,b_split1(i).y,'-'); hold on
            end
            for i = 1:numel(b_split2)
                plot(b_split2(i).x,b_split2(i).y,'-'); hold on
            end
        else
            for i = 1:numel(b_split)
                plot(b_split(i).x,b_split(i).y,'-'); hold on
            end
        end
        %    pause
    end
end

% 4.c Get a better estimate of the land sea mask using the polygon data sets.
%     (NOTE : This part will have to be commented out if cells above the
%      MSL are being marked as wet, like in inundation studies)

fprintf(1,'.........Cleaning Mask..................\n');

% GSHHS Polygons. If 'split_boundary' routine is not used then replace
% b_split with b

if (gridsplit)
    if (coastbound)
        m21 = clean_mask(lon1,lat1,m11,b_split1,LIM_VAL,OFFSET);
        m22 = clean_mask(lon2,lat2,m12,b_split2,LIM_VAL,OFFSET);
        % Masking out regions defined by optional polygons
        if (opt_poly == 1 && N12 ~= 0)
            m31 = clean_mask(lon1,lat1,m21,b_opt1,LIM_VAL,OFFSET);
        else
            m31 = m21;
        end
        if (opt_poly == 1 && N22 ~= 0)
            m32 = clean_mask(lon2,lat2,m22,b_opt2,LIM_VAL,OFFSET);
        else
            m32 = m22;
        end
    else
        m21=m11;
        m22=m12;
        m31=m21;
        m32=m22;
    end
else
    if (coastbound)
        m2 = clean_mask(lon,lat,m1,b_split,LIM_VAL,OFFSET);
        % Masking out regions defined by optional polygons
        if (opt_poly == 1 && N12 ~= 0)
            m3 = clean_mask(lon,lat,m2,b_opt,LIM_VAL,OFFSET);
        else
            m3 = m2;
        end
    else
        m2=m1;
        m3=m2;
    end
end



% 4.d If global grid: get the Caspian Sea back

lonmin_Casp = 43;
lonmax_Casp = 62;
latmin_Casp = 35;
latmax_Casp = 52;
if (gridsplit)
    [row, col] = find((lon1 >= lonmin_Casp) & (lon1<=lonmax_Casp) & (lat1>= latmin_Casp) & (lat1<= latmax_Casp));
    if (~isempty(row) && ~isempty(col))
        for i=1:numel(row)
            for j=1:numel(col)
                indI=row(i);
                indJ=col(j);
                if depth1(indI,indJ) < -28
                    m31(indI,indJ) = 1; % mean sea level for the Caspian Sea
                end
            end
        end
    end
else
    [row, col] = find((lon >= lonmin_Casp) & (lon<=lonmax_Casp) & (lat>= latmin_Casp) & (lat<= latmax_Casp));
    if (~isempty(row) && ~isempty(col))
        for i=1:numel(row)
            for j=1:numel(col)
                indI=row(i);
                indJ=col(j);
                if depth(indI,indJ) < -28  % mean sea level for the Caspian Sea
                    m3(indI,indJ) = 1;
                end
            end
        end
    end
end


% 4.e Remove lakes and other minor water bodies

fprintf(1,'.........Separating Water Bodies..................\n');

% Need to re-unite mask n°3 to look for lakes
if (gridsplit)
    m3 = cat(2,m32,m31(:,1:end));
end

[m4,mask_map] = remove_lake(m3,LAKE_TOL,IS_GLOBAL);

% Then, re-split if needed
if (gridsplit)
    % /!\ m31 & m32 have been concatenated with m32 BEFORE m31, so re-do
    % it this way
    m41 = m4(:,size(lon2,2)+1:end);
    m42 = m4(:,1:size(lon2,2));
    
    figure(60)
    pcolor(m41)
    shading flat
    title('m41 after re-split')
    
    figure(61)
    pcolor(m42)
    shading flat
    title('m42 after re-split')
end



% 5. Generate sub - grid obstruction sets in x and y direction, based on
%    the final land/sea mask and the coastal boundaries

fprintf(1,'.........Creating Obstructions..................\n');

% The create_obstr function uses boundary structure with longitudes
% ranging from 0° to 360° -> need to shift the longitudes
if (coastbound)
    if (gridsplit)
        [sx1_1,sy1_1] = create_obstr(lon1,lat1,b1,m41,OBSTR_OFFSET,OBSTR_OFFSET);
        lon2_obstr = mod(lon2+360,360);
        [sx1_2,sy1_2] = create_obstr(lon2_obstr,lat2,b2,m42,OBSTR_OFFSET,OBSTR_OFFSET);
    else
        lon_obstr = mod(lon+360,360);
        [sx1,sy1] = create_obstr(lon_obstr,lat,b,m4,OBSTR_OFFSET,OBSTR_OFFSET);
    end
    
    % 6. Output to ascii files for WAVEWATCH III
    
    % 6.a Re-arrange the longitudes to go from -180° to 180°
    
    if (gridsplit)
        % for lon there is another test to run
        if (lonfrom == 0)
            lon = cat(2,lon2-360,lon1(:,1:end));
        else
            lon = cat(2,lon2,lon1(:,1:end));
        end
        depth = cat(2,depth2,depth1(:,1:end));
        lat = cat(2,lat2,lat1(:,1:end));
        m1 =cat(2,m12,m11(:,1:end));
        m2 = cat(2,m22,m21(:,1:end));
        m3 = cat(2,m32,m31(:,1:end));
        m4 = cat(2,m42,m41(:,1:end));
        %       mask_map = cat(2,mask_map2,mask_map1(:,1:end));
        sx1 = cat(2,sx1_2,sx1_1(:,1:end));
        sy1 = cat(2,sy1_2,sy1_1(:,1:end));
    end
end


%figure(200)
%pcolor(lon,lat,depth)
%shading flat
%title('Bathymetry')

%figure(300)
%pcolor(lon,lat,m1)
%shading flat
%title('Initial Land-Sea Mask')

%%%%%%

depth_scale = 1000;
obstr_scale = 100;

% write bot file
d = round((depth)*depth_scale);
write_ww3file([data_dir,'/',fname,'.bot'],d);

% write mask file
write_ww3file([data_dir,'/',fname,'.mask_nobound'],m4);

% write obst file
if (coastbound)
    d1 = round((sx1)*obstr_scale);
    d2 = round((sy1)*obstr_scale);
    write_ww3obstr([data_dir,'/',fname,'.obst'],d1,d2);
end

% write meta file
if (strcmp(type,'rect'))
    write_ww3meta([data_dir,'/',fname],fname_nml,'RECT',lon,lat,1/depth_scale,...
        1/obstr_scale,1.0);
else
    write_ww3meta([data_dir,'/',fname],fname_nml,'CURV',lon,lat,1/depth_scale,...
        1/obstr_scale,1.0);
end;

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


% 6. Vizualization (this part can be commented out if resources are limited)

%
%   Figures for tutorial
%
%   fig_dir=strrep(data_dir,'data','figures')
%   figure(1);
%   clf;
%   d=depth; d(d==DRY_VAL)=NaN;
%   pcolor(lon,lat,d); shading flat; colorbar
%   title('Bathymetry after generate\_grid function')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.bathymetry.png' ];
%   saveas(gcf, oname, 'png')
%
%   figure(1);clf;
%   for i = 1:numel(b)
%   plot(b(i).x,b(i).y);
%   hold on;
%   end;
%   title('Boundary polygons before splitting')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.boundary_polygons.png' ];
%   saveas(gcf, oname, 'png')
%
%   figure(1);clf;
%   pcolor(lon,lat,m1);shading flat;caxis([0 3]);colorbar
%   title('Initial Land-Sea Mask')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.initial_mask.png' ];
%   saveas(gcf, oname, 'png')
%
%   figure(1);clf;
%   for i = 1:numel(b_split)
%   plot(b_split(i).x,b_split(i).y);
%   hold on;
%   end;
%   title('Boundary polygons after splitting')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.boundary_polygons_split.png' ];
%   saveas(gcf, oname, 'png')
%
%   figure(1);clf;
%   pcolor(lon,lat,m2);shading flat;caxis([0 3]);colorbar
%   title('Mask after clean\_mask function')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.mask_after_cleaning.png' ];
%   saveas(gcf, oname, 'png')
%
%   figure(1);clf;
%   pcolor(lon,lat,m4);shading flat;caxis([0 3]);colorbar
%   title('Mask after remove\_lake')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.mask_after_remove_lake.png' ];
%   saveas(gcf, oname, 'png')
%
%   figure(1);clf;
%   pcolor(lon,lat,mask_map);shading flat;caxis([-1 6]);colorbar
%   title('Mask\_map')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.mask_map.png' ];
%   saveas(gcf, oname, 'png')
%
%   sx1(find(m4==0))=NaN;
%   sy1(find(m4==0))=NaN;
%   figure(1);clf;
%   pcolor(lon,lat,sx1);shading flat;caxis([0 1]);colorbar
%   title('Sx obstruction grid')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.Sx.png' ];
%   saveas(gcf, oname, 'png')
%
%   figure(2);clf;
%   pcolor(lon,lat,sy1);shading flat;caxis([0 1]);colorbar
%   title('Sy obstruction grid')
%   set(gca,'fontsize',14);
%   oname=[fig_dir '/' fname '.Sy.png' ];
%   saveas(gcf, oname, 'png')



%
% figure 1
%
figure(1);clf;subplot(2,1,1);
loc = find(m4 == 0);
d2 = depth;
d2(loc) = NaN;
if (strcmp(type,'rect'))
    pcolor(lon,lat,d2);
elseif (strcmp(type,'curv'))
    axesm('stereo');pcolorm(lon,lat,d2);
end
shading interp;colorbar;axis square;
title(['Bathymetry for ',fnamefig, ' from m4'],'fontsize',14);
set(gca,'fontsize',14);
clear d2;

%
% figure 2
%
subplot(2,1,2);
if (strcmp(type,'rect'))
    pcolor(lon,lat,m1);
elseif (strcmp(type,'curv'))
    axesm('stereo');pcolorm(lon,lat,m1);
end
shading flat;colorbar;axis square;
title(['Bathymetry mask for ',fnamefig],'fontsize',14);
set(gca,'fontsize',14);

%
% figure 3
%
figure(3);clf;subplot(2,1,1);
if (strcmp(type,'rect'))
    pcolor(lon,lat,m2);
elseif (strcmp(type,'curv'))
    axesm('stereo');pcolorm(lon,lat,m2);
end
shading flat;colorbar;axis square;
title(['Land-Sea Mask m2 : after b\_split ',fnamefig],'fontsize',14);
set(gca,'fontsize',14);

%
% figure 4
%
subplot(2,1,2);
d2 = mask_map;
loc2 = find(mask_map == -1);
d2(loc2) = NaN;
if (strcmp(type,'rect'))
    pcolor(lon,lat,d2);
elseif (strcmp(type,'curv'))
    axesm('stereo');pcolorm(lon,lat,d2);
end
shading flat;colorbar;axis square;
title(['Different water bodies for ',fnamefig],'fontsize',14);
caxis([-1 46])
set(gca,'fontsize',14);
clear d2;


%
% figure 5
%
figure(5);clf;subplot(2,1,1);
if (strcmp(type,'rect'))
    pcolor(lon,lat,m3);
elseif (strcmp(type,'curv'))
    axesm('stereo');pcolorm(lon,lat,m3);
end
shading flat;colorbar;axis square;
title(['Land-Sea Mask m3 : before removing lakes ',fnamefig],'fontsize',14);
set(gca,'fontsize',14);

%
% figure 6
%
subplot(2,1,2);
if (strcmp(type,'rect'))
    pcolor(lon,lat,m4);
elseif (strcmp(type,'curv'))
    axesm('stereo');pcolorm(lon,lat,m4);
end
shading flat;colorbar;axis square;
title(['Final Land-Sea Mask ',fnamefig],'fontsize',14);
set(gca,'fontsize',14);

%
% figure 7
%
if (coastbound)
    figure(7);clf;subplot(2,1,1);
    d2 = sx1;
    d2(loc) = NaN;
    
    if (strcmp(type,'rect'))
        pcolor(lon,lat,d2);
    elseif (strcmp(type,'curv'))
        axesm('stereo');pcolorm(lon,lat,d2);
    end
    shading flat;colorbar;axis square;
    title(['Sx obstruction for ',fnamefig],'fontsize',14);
    set(gca,'fontsize',14);
    clear d2;
    
    %
    % figure 8
    %
    subplot(2,1,2);
    d2 = sy1;
    d2(loc) = NaN;
    
    if (strcmp(type,'rect'))
        pcolor(lon,lat,d2);
    elseif (strcmp(type,'curv'))
        axesm('stereo');pcolorm(lon,lat,d2);
    end
    shading flat;colorbar;axis square;
    title(['Sy obstruction for ',fnamefig],'fontsize',14);
    set(gca,'fontsize',14);
    clear d2;
end

toc
end

