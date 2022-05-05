##
##
programGo='work_eastUSA' ## ～tag，新建文件需要修改～
Usage: bannerSimple "my title" "*"
function bannerSimple() {
    local msg="${2} ${1} ${2}"
    local edge
    edge=${msg//?/$2}
    echo "${edge}"
    echo "$(tput bold)${msg}$(tput sgr0)"
    echo "${edge}"
    echo
}
bannerSimple "${programGo}" "*" # Usage: bannerSimple "my title" "*"
# path
pth_OceanForecast='/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/' ## ～tag，新建文件需要修改～
pth_matlab='/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/matlab'
# blank
blank="----step."
echo '----step.0 新建program或者修改program时，①根据《～tag，新建文件需要修改～》检索需要修改的位置；' \
    '②VSC的整个文件的浏览拖动在修改时也很好用，但是需要绿色行；' \
    '③调试时，每一步的0/1（不运行/运行）设置需要打断点，这样很清晰的知道整个流程，起到了类似大纲的作用，而且提醒了哪些部分不许运行，nice~；'

# 整型
declare -i step #声明是整型
step=0

##########################################################################################################
###########################################################################################################
bannerSimple "grid create - Gridgen" "*"
pth_Gridgen=${pth_OceanForecast}'TUTORIAL_GRIDGEN/'
pth_WW3_regtest=${pth_OceanForecast}'WW3-6.07.1/regtests/'${programGo}
mkdir -p ${pth_WW3_regtest}
parm_WW3_input='input' ## ～tag，新建文件需要修改～，input2?
pth_WW3_regtest_input=${pth_WW3_regtest}"/${parm_WW3_input}/"
mkdir -p ${pth_WW3_regtest_input}
echo pth_Gridgen
declare -i Gridgen
Gridgen=0                           ## ～tag，新建文件需要修改～
gridgen_objectGrid='east-USA_P25_3' ## ～tag，新建文件需要修改～
gridgen_objectGrid_nml="gridgen.${gridgen_objectGrid}.nml"
gridgen_m=${programGo}".m"
gridgen_baseGrid='east-USA_P25_4' ## ～tag，新建文件需要修改～
gridgen_baseGrid_nml="gridgen.${gridgen_baseGrid}.nml"
##
if ((Gridgen == 1)); then
    step=step+1
    echo "${blank}${step} 使用Gridgen进行网格的预处理，①Ggidgen项目在TUTORIAL_GRIDGEN文件夹，" \
        "②整体制作看，https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-107，" \
        "③具体参数看，https://liu-jincan.github.io/2021/12/28/yan-jiu-sheng-justtry-function/wavewatch3/06-gridgen-tutorial-wang-ge-sheng-cheng/#toc-heading-9，"
    ########################################################
    echo "----${blank}${step}.1 create_grid()，"
    ########################################################
    echo "--------${blank}${step}.1.1 在namelist文件夹下创建，目标网格对应的gridgen_objectGrid_nml，" ##(～tag，新建文件需要修改～)
    cd ${pth_Gridgen}'namelist'
    cat >${gridgen_objectGrid_nml} <<EOF
$ a. Path to directories and file names-----------------------------------$

$ BIN_DIR : location of matlab scripts
$
$ REF_DIR : location of reference data
$
$ DATA_DIR : input/output grid directory
$
$ FNAME_POLY （？？？）:
$ File with switches for using user-defined polygons.
$ An example file has been provided with the reference data
$ for an existing user-defined polygon database.
$ 0: ignores the polygon | 1: accounts for the polygon.
$ 带有使用用户定义的多边形的开关（switch）的文件。
$ 已经提供了一个示例文件，其中包含现有用户定义的多边形数据库的参考数据。
$ 0：忽略多边形|1：核算多边形。
$
$ FNAME : File name prefix: the routine will create output files
$ fname.bot, fname.mask_rank1, etc.
$
$ FNAMEB : Name of base grid for modmask (if needed)
$
$ BOUND_SELECT（Ⅳ） : Boundary selection :
$ 0 -> manually on the plot
$ 1 -> automatically around the borders
$ 2 -> from a .poly file

&GRID_INIT
BIN_DIR = '../bin'
REF_DIR = '../reference'
DATA_DIR = '../data'
FNAME_POLY = 'user_polygons.flag'      %不知道干什么用的，
FNAME = 'east-USA_P25_3'               %与namelist文件夹下的nml对应的，
FNAMEB = 'east-USA_P25_4'
BOUND_SELECT = 1
/



$ b. Information on bathymetry file--------------------------------------$

$ Grid Definition

$ Gridgen is designed to work with curvilinear and/or rectilinear grids. In
$ both cases it expects a 2D array defining the Longitudes (x values) and
$ Latitudes (y values). For curvilinear grids, the user will have to use
$ alternative software to determine these arrays. For rectilinear grids
$ these are determined by the grid domain and desired resolution as shown
$ below
$Gridgen被设计用于处理曲线型和/或直线型网格。
$在这两种情况下，它都希望有一个定义经度（x值）和纬度（y值）的二维数组。
$对于曲线型网格，用户将不得不使用其他软件来确定这些数组(???)。
$对于直线型网格，这些阵列由网格域和所需的分辨率决定，如下图所示。

$ REF_GRID : reference grid source = name of the bathy source file
$ (without '.nc' extension)
$ ref_grid = 'etopo1' -> Etopo1 grid
$ ref_grid = 'etopo2' -> Etopo2 grid
$ ref_grid = 'xyz' -> ASCII .log grid
$ ref_grid = ??? -> user-defined bathymetry file (must match etopo format)
$
$ LONFROM : origin of longitudes
$ lonfrom = -180 -> longitudes from -180 to 180 (etopo2)
$ lonfrom = 0 -> longitudes from 0 to 360 (etopo1)
$
$ XVAR : name of variable defining longitudes in bathy file
$ xvar = 'x' if etopo1
$ xvar = 'lon' if etopo2
$ YVAR : name of variable defining latitudes in bathy file
$ yvar = 'y' if etopo1
$ yvar = 'lat' if etopo2
$ ZVAR : name of variable defining depths in bathy file
$ zvar = 'z' for etopo1 & etopo2 (can be other for user-defined file)

&BATHY_FILE
REF_GRID = 'gebco'
XVAR = 'lon'
YVAR = 'lat'
ZVAR = 'elevation'
LONFROM = -180
/


$ c. Required grid resolution and boundaries---------------------------------$

$ TYPE : rectangular grid 'rect' or curvilinear grid 'curv'
$ DX : resolution in longitudes (°)
$ DY : resolution in latitudes (°)
$ LON_WEST : western boundary
$ LON_EAST : eastern boundary
$
$ if lonfrom = 0 : lon_west & lon_east in [0 ; 360]
$ with possibly lon_west > lon_east
$ if the Greenwich meridian is crossed
$ if lonfrom = -180 : lon_west & lon_east in [-180 ; 180]
$
$ LAT_SOUTH : southern boundary
$ LAT_NORTH : northern boundary
$ lon_south & lon_north in [-90 ; 90]
$
$ IS_GLOBAL（Ⅱ（6）） : set to 1 if the grid is global, else 0
$
$ IS_GLOBALB（Ⅳ）: set to 1 if the base grid is global, else 0
$

&OUTGRID
TYPE = 'rect'
DX = 0.25
DY = 0.25
LON_WEST = -75
LON_EAST = -58
LAT_SOUTH = 36
LAT_NORTH = 46
IS_GLOBAL = 0
IS_GLOBALB = 0
/



$ d. Boundary options-------------------------------------------------------$

$ BOUNDARY : Option to determine which GSHHS
$ .mat file to load:
$ full = full resolution
$ high = 0.2 km
$ inter = 1 km
$ low = 5 km
$ coarse = 25 km
$
$ READ_BOUNDARY（？？？） : [0|1] flag to determine if input boundary information
$ needs to be read; boundary data files can be
$ significantly large and need to be read only the first
$ time. So when making multiple grids, the flag can be set
$ to 0 for subsequent grids.
$ (Note : If the workspace is cleared, the boundary data
$ will have to be read again)
$
$ OPT_POLY : [0|1] flag for reading the optional user-defined
$ polygons. Set to 0 if you do not wish to use this option
$
$ MIN_DIST（Ⅱ（3））??? : Used in compute_boundary and in split_boudnary;
$ threshold defining the minimum distance (in °) between
$ the edge of a polygon and the inside/outside boundary.
$ A low value reduces computation time but can raise
$ errors if the grid is too coarse. If the script crashes,
$ consider increasing the value.
$ (Default value in function used to be min_dist = 4)

&GRID_BOUND
BOUNDARY = 'full'    
READ_BOUNDARY = 1
OPT_POLY = 0
MIN_DIST = 4
/



$ e. Parameter values used in the software-------------------------------------$

$ DRY_VAL : Depth value set for dry cells (can change as desired)
$ Used in 'generate_grid' and in the making of initial mask
$
$ CUT_OFF : Cut-off depth to distinguish between dry and wet cells.
$ All depths below the cut_off depth are marked wet
$ Used in 'generate_grid'
$ NOTE : If you have accurate boundary polygons, then it is
$ better to have a low value for CUT_OFF, which will make the
$ target bathymetry cell wet even when there are only few wet
$ cells in the base bathymetry. This will then be cleaned up
$ by the polygons in the 'mask cleanup' section. If, on the
$ other, hand you do not intend to use the polygons to define
$ the coastal domains, then you are better off with CUT_OFF = 0.5
$注意：如果你有精确的边界多边形，那么最好将CUT_OFF的值调低，
$这样会使目标测深单元变湿，即使在基本测深中只有少数湿单元。
$然后，这将被 "掩膜清理 "部分中的多边形清理掉。
$另一方面，如果你不打算用多边形来定义沿岸域，那么你最好使用 CUT_OFF = 0.5(???)。
$
$ LIM_BATHY(Ⅱ（2）)（？？？） : Proportion of base bathymetry cells that need to be wet for
$ the target cell to be considered wet.
$需要湿润的基础水深单元的比例，以使目标单元被认为是湿润的。
$
$ LIM_VAL（Ⅱ（5））（？？？） : Fraction of cell that has to be inside a polygon for the
$ cell to be marked dry
$
$ SPLIT_LIM（Ⅱ（4））（？？？） : Limit for splitting the polygons; used in split_boundary
$ Rule of thumbs: from 5 to 10 times max(dx,dy)
$
$
$ OFFSET : Additional buffer around the boundary to check if cell is
$ crossing boundary. Should be set to largest grid resolution
$ ie OFFSET = max([dx dy])
$ Used in 'clean_mask'
$
$ LAKE_TOL : Tolerance value that determines if all the wet cells
$ corresponding to a particular wet body should be flagged
$ dry or not.
$ Used in 'remove_lake'
$ if LAKE_TOL > 0 : all water bodies having less than this
$ value of total wet cells will be flagged 
$ dry    $例如，如果为100，则弱湖泊（小水体）的单元输为60，则被认为是陆地，即dry
$ if LAKE_TOL = 0 : the output and input masks are unchanged.
$ if LAKE_TOL < 0 : all but the largest water body is flagged
$ dry
$
$ OBSTR_OFFSET : Flag to determine if neighbours should be considered.
$ (0/1 = no/yes)
$ Used in 'create_obstr'

&GRID_PARAM
DRY_VAL = 999999
CUT_OFF = 0
LIM_BATHY = 0.4                  
LIM_VAL = 0.5
SPLIT_LIM = 1.25                 %from 5 to 10 times max(dx,dy)
OFFSET = 0.25                    %OFFSET = max([dx dy])
LAKE_TOL = 100
OBSTR_OFFSET = 1
/
EOF
    ########################################################
    echo "--------${blank}${step}.1.2 在area文件夹下创建program在gridgen对应的gridgen_m，并运行该m文件，" \
        "运行完成后，create_grid()会在data文件夹生成5个文件（.bot、.mask_nobound、.meta、.obst、.nml），" \
        "个人使用sh附加在data文件夹生成.out文件记录m文件运行过程，"
    cd ${pth_Gridgen}'area'
    cat >${gridgen_m} <<EOF
% disp('hello, world!')
% disp(argument1)
create_grid(pth_gridgen_objectGrid_nml)
EOF
    ${pth_matlab} -nodisplay -r \
        "argument1=10010; pth_gridgen_objectGrid_nml='${pth_Gridgen}namelist/${gridgen_objectGrid_nml}'; ${programGo}; exit;"
    #    >${pth_Gridgen}'data/'${gridgen_objectGrid}'.out' 2>&1
    ########################################################
    echo "--------${blank}${step}.1.3 在namelist文件夹下创建，基础网格对应的gridgen_baseGrid_nml，(～tag，新建文件需要修改～)，" \
        "（为了在海陆掩码上增加活动边界，还需创建一个基础网格）。" ##(～tag，新建文件需要修改～)
    cd ${pth_Gridgen}'namelist'
    cat >${gridgen_baseGrid_nml} <<EOF
$ a. Path to directories and file names-----------------------------------$

&GRID_INIT
BIN_DIR = '../bin'
REF_DIR = '../reference'
DATA_DIR = '../data'
FNAME_POLY = 'user_polygons.flag'      %不知道干什么用的
FNAME = 'east-USA_P25_4'
FNAMEB = 'none'                        
BOUND_SELECT = 1
/



$ b. Information on bathymetry file--------------------------------------$

&BATHY_FILE
REF_GRID = 'gebco'
XVAR = 'lon'
YVAR = 'lat'
ZVAR = 'elevation'
LONFROM = -180
/


$ c. Required grid resolution and boundaries---------------------------------$

&OUTGRID
TYPE = 'rect'
DX = 0.25
DY = 0.25
LON_WEST = -80
LON_EAST = -50
LAT_SOUTH = 33
LAT_NORTH = 50
IS_GLOBAL = 0
IS_GLOBALB = 0
/



$ d. Boundary options-------------------------------------------------------$

&GRID_BOUND
BOUNDARY = 'full'    
READ_BOUNDARY = 1
OPT_POLY = 0
MIN_DIST = 4
/



$ e. Parameter values used in the software-------------------------------------$

&GRID_PARAM
DRY_VAL = 999999
CUT_OFF = 0
LIM_BATHY = 0.4                  
LIM_VAL = 0.5
SPLIT_LIM = 1.25                 %from 5 to 10 times max(dx,dy)
OFFSET = 0.25                    %OFFSET = max([dx dy])
LAKE_TOL = 100
OBSTR_OFFSET = 1
/
EOF
    ####################################################
    echo "--------${blank}${step}.1.4 重置在area文件夹下program对应的gridgen_m，基础网格，运行该m文件，" \
        "运行完成后，create_grid()会在data文件夹生成5个文件（.bot、.mask_nobound、.meta、.obst、.nml），" \
        "个人使用sh附加在data文件夹生成.out文件记录m文件运行过程，"
    cd ${pth_Gridgen}'area'
    cat >${gridgen_m} <<EOF
create_grid(pth_gridgen_baseGrid_nml)
EOF
    ${pth_matlab} -nodisplay -r \
        "pth_gridgen_baseGrid_nml='${pth_Gridgen}namelist/${gridgen_baseGrid_nml}'; ${programGo}; exit;" \
        >${pth_Gridgen}'data/'${gridgen_baseGrid}'.out' 2>&1
    ####################################################
    echo "----${blank}${step}.2 create_boundary()，重置在area文件夹下program对应的gridgen_m，运行该m文件，" \
        "运行完成后，create_boundary()会在data文件夹生成3个文件（.fullbound、.bound、.mask），" \
        "个人使用sh附加在data文件夹生成.out.create_boundary文件记录m文件运行过程，"
    cd ${pth_Gridgen}'area'
    cat >${gridgen_m} <<EOF
create_boundary(pth_gridgen_objectGrid_nml)
EOF
    ${pth_matlab} -nodisplay -r \
        "pth_gridgen_objectGrid_nml='${pth_Gridgen}namelist/${gridgen_objectGrid_nml}'; ${programGo}; exit;" \
        >${pth_Gridgen}'data/'${gridgen_objectGrid}'.out.create_boundary' 2>&1

    ####################################################
    echo "----${blank}${step}.3 转移gridgen的data下生成的关于目标网格的重要文件至WW3的test的input文件夹，"
    cp ${pth_Gridgen}'data/'${gridgen_objectGrid}'.bot' ${pth_WW3_regtest_input}
    cp ${pth_Gridgen}'data/'${gridgen_objectGrid}'.mask' ${pth_WW3_regtest_input}
    cp ${pth_Gridgen}'data/'${gridgen_objectGrid}'.obst' ${pth_WW3_regtest_input}
    cp ${pth_Gridgen}'data/namelists_'${gridgen_objectGrid}'.nml' ${pth_WW3_regtest_input}
    ########################################################
fi

##########################################################################################################
###########################################################################################################
bannerSimple "ww3 run_test" "*"
declare -i run_test
run_test=0                          ## ～tag，新建文件需要修改～
if ((run_test == 1)); then
    step=step+1
    ######################################################
    echo "${blank}${step} ①复制run_test脚本到本项目，控制整个项目的ww3运行，只能复制一次，cp -i 防止覆盖，" \
        "②复制switch文件到input文件夹，run_test运行需要，comp和link不需要复制～"
    cd ${pth_WW3_regtest_input} && cd '..'
    cp -i '../east-USA/run_test' . # -i 参数是为了防止已存在并修改的run_test文件被覆盖，
    chmod +x 'run_test'
fi

##########################################################################################################
###########################################################################################################
bannerSimple "grid preprocessor - ww3_grid_nml" "*"
declare -i ww3_grid_nml
ww3_grid_nml=0              ## ～tag，新建文件需要修改～
parm_WW3_work='work' ## ～tag，新建文件需要修改～
pth_WW3_regtest_work=${pth_WW3_regtest}"/${parm_WW3_work}/"
mkdir -p ${pth_WW3_regtest_work}
parm_WW3_comp='Gnu'        ## ～tag，新建文件需要修改～，实际文件为comp.Gnu，位于model，
parm_WW3_switch='Ifremer1' ## ～tag，新建文件需要修改～，实际文件为switch_Ifremer1，位于input，
##
if ((ww3_grid_nml == 1)); then
    step=step+1
    echo "${blank}${step} ww3_grid.nml，①整体制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-116"
    ######################################################
    echo "----${blank}${step}.1 创建ww3_grid.nml文件，①ww3_grid.nml的名称定了，" \
        "觉得某个ww3_grid.nml文件有价值，就在input文件夹中另存，" ## ～tag，新建文件需要修改～
    cd ${pth_WW3_regtest_input}
    cat >'ww3_grid.nml' <<EOF
! -------------------------------------------------------------------- !
! Define the spectrum parameterization via SPECTRUM_NML namelist
!
! * namelist must be terminated with /
! * definitions & defaults:
!     SPECTRUM%XFR         = 0.            ! frequency increment
!     SPECTRUM%FREQ1       = 0.            ! first frequency (Hz)
!     SPECTRUM%NK          = 0             ! number of frequencies (wavenumbers)
!     SPECTRUM%NTH         = 0             ! number of direction bins
!     SPECTRUM%THOFF       = 0.            ! relative offset of first direction [-0.5,0.5]
! -------------------------------------------------------------------- !
&SPECTRUM_NML
  SPECTRUM%XFR           =  1.1
  SPECTRUM%FREQ1         =  0.04118
  SPECTRUM%NK            =  32
  SPECTRUM%NTH           =  24
/



! -------------------------------------------------------------------- !
! Define the run parameterization via RUN_NML namelist
!
! * namelist must be terminated with /
! * definitions & defaults:
!     RUN%FLDRY            = F             ! dry run (I/O only, no calculation)
!     RUN%FLCX             = F             ! x-component of propagation
!     RUN%FLCY             = F             ! y-component of propagation
!     RUN%FLCTH            = F             ! direction shift
!     RUN%FLCK             = F             ! wavenumber shift
!     RUN%FLSOU            = F             ! source terms
! -------------------------------------------------------------------- !
&RUN_NML
  RUN%FLCX            = T
  RUN%FLCY            = T
  RUN%FLCTH           = T
  RUN%FLSOU           = T
/



! -------------------------------------------------------------------- !
! Define the timesteps parameterization via TIMESTEPS_NML namelist
!
! * It is highly recommended to set up time steps which are multiple 
!   between them. 
!
! * The first time step to calculate is the maximum CFL time step
!   which depend on the lowest frequency FREQ1 previously set up and the
!   lowest spatial grid resolution in meters DXY.
!   reminder : 1 degree=60minutes // 1minute=1mile // 1mile=1.852km
!   The formula for the CFL time is :
!   Tcfl = DXY / (G / (FREQ1*4*Pi) ) with the constants Pi=3,14 and G=9.8m/s²;
!   DTXY  ~= 90% Tcfl
!   DTMAX ~= 3 * DTXY   (maximum global time step limit)
！  在这个例子中：
!   DXY=min(reslon * cosd(maxlat)*1852*60, reslon * cosd(minlat)*1852*60)
!      其中，reslon=0.25, maxlat=46, minlat=36
!      gridgen教程中附录算的是错的？？？
!   Tcfl ~= 1000
!   DTXY ~= 900
！
! * The refraction time step depends on how strong can be the current velocities
!   on your grid :
!   DTKTH ~= DTMAX / 2   ! in case of no or light current velocities
!   DTKTH ~= DTMAX / 10  ! in case of strong current velocities
!
! * The source terms time step is usually defined between 5s and 60s.
!   A common value is 10s.
!   DTMIN ~= 10
!
! * namelist must be terminated with /
! * definitions & defaults:
!     TIMESTEPS%DTMAX      = 0.         ! maximum global time step (s)
!     TIMESTEPS%DTXY       = 0.         ! maximum CFL time step for x-y (s)
!     TIMESTEPS%DTKTH      = 0.         ! maximum CFL time step for k-th (s)
!     TIMESTEPS%DTMIN      = 0.         ! minimum source term time step (s)
! -------------------------------------------------------------------- !
&TIMESTEPS_NML
  TIMESTEPS%DTMAX         =   600.
  TIMESTEPS%DTXY          =   200.
  TIMESTEPS%DTKTH         =   300.
  TIMESTEPS%DTMIN         =   10.
/



! -------------------------------------------------------------------- !
! Define the grid to preprocess via GRID_NML namelist
!
! * the tunable parameters for source terms, propagation schemes, and 
!    numerics are read using namelists. 
! * Any namelist found in the folowing sections is temporarily written
!   to param.scratch, and read from there if necessary. 
! * The order of the namelists is immaterial.
! * Namelists not needed for the given switch settings will be skipped
!   automatically
!
! * grid type can be : 
!    'RECT' : rectilinear
!    'CURV' : curvilinear
!    'UNST' : unstructured (triangle-based)
!
! * coordinate system can be : 
!    'SPHE' : Spherical (degrees)
!    'CART' : Cartesian (meters)
!
! * grid closure can only be applied in spherical coordinates
!
! * grid closure can be : 
!    'NONE' : No closure is applied
!    'SMPL' : Simple grid closure. Grid is periodic in the
!           : i-index and wraps at i=NX+1. In other words,
!           : (NX+1,J) => (1,J). A grid with simple closure
!           : may be rectilinear or curvilinear.
!    'TRPL' : Tripole grid closure : Grid is periodic in the
!           : i-index and wraps at i=NX+1 and has closure at
!           : j=NY+1. In other words, (NX+1,J<=NY) => (1,J)
!           : and (I,NY+1) => (NX-I+1,NY). Tripole
!           : grid closure requires that NX be even. A grid
!           : with tripole closure must be curvilinear.
!
! * The coastline limit depth is the value which distinguish the sea 
!   points to the land points. All the points with depth values (ZBIN)
!   greater than this limit (ZLIM) will be considered as excluded points
!   and will never be wet points, even if the water level grows over.
!   It can only overwrite the status of a sea point to a land point.
!   The value must have a negative value under the mean sea level
!
! * The minimum water depth allowed to compute the model is the absolute
!   depth value (DMIN) used in the model if the input depth is lower to 
!   avoid the model to blow up.
!
! * namelist must be terminated with /
! * definitions & defaults:
!     GRID%NAME             = 'unset'            ! grid name (30 char)
!     GRID%NML              = 'namelists.nml'    ! namelists filename
!     GRID%TYPE             = 'unset'            ! grid type
!     GRID%COORD            = 'unset'            ! coordinate system
!     GRID%CLOS             = 'unset'            ! grid closure
!
!     GRID%ZLIM             = 0.        ! coastline limit depth (m)
!     GRID%DMIN             = 0.        ! abs. minimum water depth (m)
!
!  下面所有项，在gridgen中生成.meta中有，全部复制过来。
! -------------------------------------------------------------------- !
&GRID_NML
  GRID%NAME              =  'east-USA_P25_3'
  GRID%NML               =  'namelists_east-USA_P25_3.nml'
  GRID%TYPE              =  'RECT'
  GRID%COORD             =  'SPHE'
  GRID%CLOS              =  'NONE'
  GRID%ZLIM              =  -0.10
  GRID%DMIN              =   2.50
/


&RECT_NML
  RECT%NX                =  69
  RECT%NY                =  41
!
  RECT%SX                =   0.250000000000
  RECT%SY                =   0.250000000000
  RECT%X0                =  -75.0000
  RECT%Y0                =   36.0000
/



! -------------------------------------------------------------------- !
! Define the depth to preprocess via DEPTH_NML namelist
! - for RECT and CURV grids -
!
! * if no obstruction subgrid, need to set &MISC FLAGTR = 0
!
! * The depth value must have negative values under the mean sea level
!
! * value <= value_read * scale_fac
!
! * IDLA : Layout indicator :
!                  1   : Read line-by-line bottom to top.  (default)
!                  2   : Like 1, single read statement.
!                  3   : Read line-by-line top to bottom.
!                  4   : Like 3, single read statement.
! * IDFM : format indicator :
!                  1   : Free format.  (default)
!                  2   : Fixed format.
!                  3   : Unformatted.
! * FORMAT : element format to read :
!               '(....)'  : auto detected  (default)
!               '(f10.6)' : float type
!
! * Example :
!      IDF  SF     IDLA  IDFM   FORMAT    FILENAME
!      50   0.001  1     1     '(....)'  'GLOB-30M.bot'
!
! * namelist must be terminated with /
! * definitions & defaults:
!     DEPTH%SF             = 1.       ! scale factor
!     DEPTH%FILENAME       = 'unset'  ! filename
!     DEPTH%IDF            = 50       ! file unit number
!     DEPTH%IDLA           = 1        ! layout indicator
!     DEPTH%IDFM           = 1        ! format indicator
!     DEPTH%FORMAT         = '(....)' ! formatted read format
!  下面所有项，在gridgen中生成.meta中有，全部复制过来。
! -------------------------------------------------------------------- !

&DEPTH_NML
  DEPTH%SF             =  0.00
  DEPTH%FILENAME       = 'east-USA_P25_3.bot'
/

&MASK_NML
  MASK%FILENAME         = 'east-USA_P25_3.mask'
/

&OBST_NML
  OBST%SF              =  0.01
  OBST%FILENAME        = 'east-USA_P25_3.obst'
/
EOF
    ######################################################
    echo "----${blank}${step}.2 根据执行ww3_grid的run_test命令，配置相关文件并执行，" \
        "运行完成后，会在work文件夹下生成或更新mapsta.ww3,mask.ww3,mod_def.ww3,ww3_grid.out等文件，"
    cd ${pth_WW3_regtest_input} && cd '../../'
    ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
        -N -r ww3_grid -w ${parm_WW3_work} ../model ${programGo} \
        >/dev/null
    ######################################################
fi

##########################################################################################################
###########################################################################################################
bannerSimple "wind nc create - CCMP" "*"
declare -i CCMP
CCMP=0                               ## ～tag，新建文件需要修改～
pth_CCMP=${pth_OceanForecast}'CCMP/'
pth_CCMP_work=${pth_CCMP}${programGo}'/' && mkdir -p ${pth_CCMP_work}
parm_CCMP_mergeBegin='20110901' ## ～tag，新建文件需要修改～
parm_CCMP_mergeEnd='20110930'   ## ～tag，新建文件需要修改～
# parm_CCMP_mergeName='ww3_ccmp_'${parm_CCMP_mergeBegin}'_'${parm_CCMP_mergeEnd}'.nc'
parm_CCMP_mergeName='wind.nc'   ## 不能更改名称，否则ww3_prnc会出问题～

if ((CCMP == 1)); then
    step=step+1
    echo "${blank}${step} CCMP，①整体制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-20，"
    ######################################################
    echo "----${blank}${step}.1 生成下载CCMP数据的download_ccmp.m文件，运行.m文件，生成的nc文件放在专门存储数据的大存储文件夹下，" \
        "①下载的速度很慢呀，>30分钟才下了14Mb，去对应下载地方可以看到单个文件下载时，文件大小的变化；猜测是外网很弱，晚上重启看看，" \
        "②Windows 小飞机下载的相对较快，但也需要3分半一个文件～25Mb，用WPS云文档进行同步吧～～，" \
        "③此部分的matlab运行代码一般注释了，能忍受那种10kb的下载速度，就解除注释吧～，提前下好就行～" ## ～tag，新建文件需要修改～
    cd ${pth_CCMP_work}
    cat >'download_ccmp.m' <<EOF
%% 说明
% ccmp v02.0 数据下载网址：https://data.remss.com/ccmp/v02.0/
%% L3.0数据下载
filepath='/1t/ccmp/data_L3/'; %创建相应文件夹，下载的数据保存到此文件夹；(注意，路径的最后面必须为 / )；
mkdir(filepath);   %权限不允许，修改文件夹的权限即可，
% system(['echo 123456 | sudo -S mkdir -p','/1t/ccmp']);
% system(['echo 123456 | sudo -S mkdir -p',filepath]);

% url特点：需要3个通配符
% https://data.remss.com/ccmp/v02.0/Y1990/M02/CCMP_Wind_Analysis_19900201_V02.0_L3.0_RSS.nc
%                                    1987:1:2019
%                                          01:1:12
%                                                                          01:1:31

% 最全的通配符
% year = num2str([1987:1:2019]');  year(2,:); size(year);%通配符 year；
% month = num2str([1:1:12]','%02d'); month(2,:); %通配符 month；
% day = num2str([1:1:31]','%02d'); day(2,:); %通配符 day；

% 应用中的通配符
year = num2str([2011]'); %通配符 year；
month = num2str([9:10]','%02d'); %通配符 month；
day = num2str([1:31]','%02d'); %通配符 day；

for i=1:1:size(year,1)
    for j=1:1:size(month,1)
        for k=1:1:size(day,1)
            % 判断日期存不存在
            ts = [year(i,:),'-',month(j,:),'-',day(k,:)];
            try
                tf = isdatetime(datetime(ts)); %不用try，这一行会报错。
            catch
                tf = 0;
            end
            
            if(tf==1) %日期存在
                %https://data.remss.com/ccmp/v02.0/Y1990/M02/CCMP_Wind_Analysis_19900201_V02.0_L3.0_RSS.nc
                fullURL=['https://data.remss.com/ccmp/v02.0/Y',year(i,:), ...
                    '/M',month(j,:), ...
                    '/CCMP_Wind_Analysis_',year(i,:),month(j,:),day(k,:),'_V02.0_L3.0_RSS.nc']; %下载所需要的url
                filename=[filepath,'CCMP_Wind_Analysis_',year(i,:),month(j,:),day(k,:),'_V02.0_L3.0_RSS.nc']; %保存的文件名
                
                tic % 记录下载的时间
                [f,status]=urlwrite(fullURL,filename);%下载命令
                if status==1 %下载成功
                    t=toc;
                    lst=dir(filename); %了解文件的大小
                    xi=lst.bytes;
                    disp(['CCMP_Wind_Analysis_',year(i,:),month(j,:),day(k,:),'_V02.0_L3.0_RSS.nc',...
                        '下载成功，','文件大小为',num2str(xi/1024/1024),'M，',' 花费',num2str(t/60),'分钟。']);
                else
                    disp(['CCMP_Wind_Analysis_',year(i,:),month(j,:),day(k,:),'_V02.0_L3.0_RSS.nc','下载失败。']);
                end
            else
                disp([ts,'日期不存在。']);
            end
            
        end
    end
end

%% L3.5数据下载
% ...
EOF
    cd ${pth_CCMP_work}
    #${pth_matlab} -nodisplay -r "download_ccmp; exit;" \
    #    >${pth_CCMP_work}'download_ccmp.out' 2>&1  ## ～tag，新建文件需要修改～，建议不要重定向～～算了反正这么慢，
    ########################################################
    echo "----${blank}${step}.2 用merge_ccmp_ww3.m融合已下载的CCMP数据为一个文件，运行.m文件，" \
        "①需输入三个参数，融合的开始时间和结束时间，字符串形式19900101转换成数比大小即可，融合后的名称，为什么传递不了？clc,clear all了，呜呜～" \
        "②融合后的nc文件所占内存变大了几乎2倍（相较于各个单个文件之和），不知道是为什么，解决方法，风场用完后删掉，" \
        "③博客上的代码关于v10m保存类型出错，不能用NC_float，坑死我了～"
    cd ${pth_CCMP_work}
    cat >'merge_ccmp_ww3.m' <<EOF
%%
% desciption: merge multiple netcdf files for sepcific domain

% usage:
%    1. filenumber is up to the number of your netcdf file to be processed.
%    2. for different domain you want to process, you can change the number
% in the latitude0, longitude0, uwind0, vwind0.

% author:
%    huang xue zhi, dalian university of technology
%    liu jin can, UPC

% revison history
%    2018-09-25 first verison.
%    2022-02-10 ww3.

%%
%% clear;clc;  %在shell传递参数时，必须注释掉～～

%% input, define the data path and filelist
filename
parm_CCMP_mergeBegin
parm_CCMP_mergeEnd
%filename='1.nc'
%parm_CCMP_mergeBegin='20110905'
%parm_CCMP_mergeEnd='20110920'
datadir='/1t/ccmp/data_L3/';
tmp=dir([datadir,'*.nc']); 
filelist=[];
for i=1:size(tmp,1)
    str=[tmp(i).name];
    str(20:27);
    condition1=str2num(str(20:27)) >= str2num(parm_CCMP_mergeBegin);
    condition2=str2num(str(20:27)) <= str2num(parm_CCMP_mergeEnd);
    if ( condition1 && condition2 )
        filelist=[filelist;tmp(i)];
    end
end
% the total numbers of netcdf files to be processed.
filenumber=size(filelist,1); %全部nc文件的数量
clear parm_CCMP_mergeEnd parm_CCMP_mergeBegin tmp str condition1 condition2



%% batch reading from the netcdf file
for i=1:filenumber
    % 查阅nc相关信息
    %ncdisp(strcat(datadir,filelist(i).name),'/','min')
    %ncdisp(strcat(datadir,filelist(i).name),'/','full')
    
    % batch reading the variable to another arrays.
    ncid=[datadir,filelist(i).name];
    
    latitude0=ncread(ncid,'latitude'); %0.25间隔
    longitude0=ncread(ncid,'longitude'); %0.25间隔
    time(:,i)=ncread(ncid,'time');       % 增加了数组维数，保留信息。
    uwind0(:,:,:,i)=ncread(ncid,'uwnd'); % 增加了数组维数，保留信息。
    vwind0(:,:,:,i)=ncread(ncid,'vwnd'); % 增加了数组维数，保留信息。
    
    %区域纬度的选择
    %latitude=latitude0(74:435);
    %longitude=longitude0(80:481);
    %uwind(:,:,:,i)=uwind0(80:481,74:435,:,i);
    %vwind(:,:,:,i)=vwind0(80:481,74:435,:,i);
    latitude=latitude0;
    longitude=longitude0;
    uwind=uwind0;
    vwind=vwind0;
end

%% create the merged netcdf file to store the result.
%filename = 'wind10.nc'; %合成的nc文件名称

% cmode 选择，help netcdf.create
%cid=netcdf.create(filename,'clobber'); 
cid=netcdf.create(filename,'64BIT_OFFSET'); % 64BIT_OFFSET


%define global attributes
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'Conventions','CF-1.6'); % help netcdf.putAtt
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'data_structure','grid');
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lat_min','-78.375 degrees');
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lat_max','78.375 degrees');
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lon_min','0.125 degrees');
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lon_max','359.875 degrees');
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'institution','Remote Sensing Systems (RSS)');

% define the variable dimension
dimlon=netcdf.defDim(cid,'longitude',size(longitude,1));
dimlat=netcdf.defDim(cid,'latitude',size(latitude,1));
dimtime=netcdf.defDim(cid,'time',filenumber*4); %每天有4个时间结点


% define the variable and their attributes
varid1=netcdf.defVar(cid,'time','NC_DOUBLE',dimtime); % help netcdf.defVar
netcdf.putAtt(cid,varid1,'standard_name','time');
netcdf.putAtt(cid,varid1,'long_name','Time of analysis');
netcdf.putAtt(cid,varid1,'units','hours since 1987-01-01 00:00:00');
netcdf.putAtt(cid,varid1,'delta_t','0000-00-00 06:00:00');
netcdf.putAtt(cid,varid1,'calendar','standard');
netcdf.putAtt(cid,varid1,'valid_min',min(time));
netcdf.putAtt(cid,varid1,'valid_max',max(time));
netcdf.putAtt(cid,varid1,'axis','T');

%varid2=netcdf.defVar(cid,'latitude','NC_FLOAT',dimlat);
varid2=netcdf.defVar(cid,'latitude','NC_DOUBLE',dimlat); % NC_DOUBLE 要求的内存，基本是 NC_FLOAT 的2倍
netcdf.putAtt(cid,varid2,'standard_name','latitude');
netcdf.putAtt(cid,varid2,'units','degrees_north');
netcdf.putAtt(cid,varid2,'long_name','Latitude in degrees north');
netcdf.putAtt(cid,varid2,'valid_min',min(latitude));
netcdf.putAtt(cid,varid2,'valid_max',max(latitude));
netcdf.putAtt(cid,varid2,'axis','Y');


%varid3=netcdf.defVar(cid,'longitude','NC_FLOAT',dimlon);
varid3=netcdf.defVar(cid,'longitude','NC_DOUBLE',dimlon);
netcdf.putAtt(cid,varid3,'standard_name','longitude');
netcdf.putAtt(cid,varid3,'units','degrees_east');
netcdf.putAtt(cid,varid3,'long_name','Longitude in degrees east');
netcdf.putAtt(cid,varid3,'valid_min',min(longitude));
netcdf.putAtt(cid,varid3,'valid_max',max(longitude));
netcdf.putAtt(cid,varid3,'axis','X');


%varid4=netcdf.defVar(cid,'u10m','NC_FLOAT',[dimlon dimlat dimtime]);
varid4=netcdf.defVar(cid,'u10m','NC_DOUBLE',[dimlon dimlat dimtime]);
netcdf.putAtt(cid,varid4,'standard_name','eastward_wind');
netcdf.putAtt(cid,varid4,'long_name','u-wind vector component at 10 meters');
netcdf.putAtt(cid,varid4,'units','m s-1');
netcdf.putAtt(cid,varid4,'_FillValue',-9999);
%netcdf.putAtt(cid,varid4,'_Fillvalue',-9999);
netcdf.putAtt(cid,varid4,'coordinates','time latitude longitude')
netcdf.putAtt(cid,varid4,'valid_min',min(uwind(:)));
netcdf.putAtt(cid,varid4,'valid_max',max(uwind(:)));


%varid5=netcdf.defVar(cid,'v10m','NC_FLOAT',[dimlon dimlat dimtime]);
varid5=netcdf.defVar(cid,'v10m','NC_DOUBLE',[dimlon dimlat dimtime]);  
netcdf.putAtt(cid,varid5,'standard_name','northward_wind');
netcdf.putAtt(cid,varid5,'long_name','v-wind vector component at 10 meters');
netcdf.putAtt(cid,varid5,'units','m s-1');
netcdf.putAtt(cid,varid5,'_FillValue',-9999);
netcdf.putAtt(cid,varid5,'coordinates','time latitude longitude')
netcdf.putAtt(cid,varid5,'valid_min',min(vwind(:)));
netcdf.putAtt(cid,varid5,'valid_max',max(vwind(:)));

% nobs 变量未加进去;

netcdf.endDef(cid);
% end define the varible and attributes


%% write variables value to merged netcdf file
netcdf.putVar(cid,varid1,time);
netcdf.putVar(cid,varid2,latitude);
netcdf.putVar(cid,varid3,longitude);
netcdf.putVar(cid,varid4,uwind);
netcdf.putVar(cid,varid5,vwind);

% 添加存储空间属性
netcdf.reDef(cid); %data mode 不能进行使用 putAtt，故进入 def mode；
lst=dir(filename); xi=lst.bytes;
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'space size',strcat(num2str(xi/1024/1024),'Mb'));
%ncdisp(filename,'/','full');

netcdf.close(cid);
EOF
    # echo ${parm_CCMP_mergeName}
    cd ${pth_CCMP_work}
    ${pth_matlab} -nodisplay -r \
        "parm_CCMP_mergeBegin='${parm_CCMP_mergeBegin}';parm_CCMP_mergeEnd='${parm_CCMP_mergeEnd}';filename = '${parm_CCMP_mergeName}'; merge_ccmp_ww3; exit;" \
        >${pth_CCMP_work}'merge_ccmp_ww3.out' 2>&1
    ######################################################
    ####################################################
    echo "----${blank}${step}.3 转移CCMP的program下生成的某一时间段风场的nc文件，至WW3的test的input文件夹，ln -snf，"
    ln -snf ${pth_CCMP_work}'wind.nc' ${pth_WW3_regtest_input}
    # mv ${pth_CCMP_work}'wind.nc' ${pth_WW3_regtest_input}
    ####################################################
fi

##########################################################################################################
###########################################################################################################
bannerSimple "wind nc preprocessor - ww3_prnc_nml" "*"
declare -i ww3_prnc_nml
ww3_prnc_nml=0             ## ～tag，新建文件需要修改～

##
if ((ww3_prnc_nml == 1)); then
    step=step+1
    echo "${blank}${step} ww3_prnc.nml，①整体制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-116"
    ######################################################
    echo "----${blank}${step}.1 创建ww3_prnc.nml文件，①ww3_prnc.nml的名称定了，" \
        "觉得某个ww3_prnc.nml文件有价值，就在input文件夹中另存，" ## ～tag，新建文件需要修改～
    cd ${pth_WW3_regtest_input}
    cat >'ww3_prnc.nml' <<EOF
   ! -------------------------------------------------------------------- !
   ! WAVEWATCH III ww3_prnc.nml - Field preprocessor                      !
   ! -------------------------------------------------------------------- !
   
   
   ! -------------------------------------------------------------------- !
   ! Define the forcing fields to preprocess via FORCING_NML namelist
   !
   ! * only one FORCING%FIELD can be set at true
   ! * only one FORCING%grid can be set at true
   ! * tidal constituents FORCING%tidal is only available on grid%asis with FIELD%level or FIELD%current
   !
   ! * namelist must be terminated with /
   ! * definitions & defaults:
   !     FORCING%TIMESTART            = '19000101 000000'  ! Start date for the forcing field
   !     FORCING%TIMESTOP             = '29001231 000000'  ! Stop date for the forcing field
   !
   !     FORCING%FIELD%ICE_PARAM1     = F           ! Ice thickness                      (1-component)
   !     FORCING%FIELD%ICE_PARAM2     = F           ! Ice viscosity                      (1-component)
   !     FORCING%FIELD%ICE_PARAM3     = F           ! Ice density                        (1-component)
   !     FORCING%FIELD%ICE_PARAM4     = F           ! Ice modulus                        (1-component)
   !     FORCING%FIELD%ICE_PARAM5     = F           ! Ice floe mean diameter             (1-component)
   !     FORCING%FIELD%MUD_DENSITY    = F           ! Mud density                        (1-component)
   !     FORCING%FIELD%MUD_THICKNESS  = F           ! Mud thickness                      (1-component)
   !     FORCING%FIELD%MUD_VISCOSITY  = F           ! Mud viscosity                      (1-component)
   !     FORCING%FIELD%WATER_LEVELS   = F           ! Level                              (1-component)
   !     FORCING%FIELD%CURRENTS       = F           ! Current                            (2-components)
   !     FORCING%FIELD%WINDS          = F           ! Wind                               (2-components)
   !     FORCING%FIELD%WIND_AST       = F           ! Wind and air-sea temp. dif.        (3-components)
   !     FORCING%FIELD%ICE_CONC       = F           ! Ice concentration                  (1-component)
   !     FORCING%FIELD%ICE_BERG       = F           ! Icebergs and sea ice concentration (2-components)
   !     FORCING%FIELD%DATA_ASSIM     = F           ! Data for assimilation              (1-component)
   !
   !     FORCING%GRID%ASIS            = F           ! Transfert field 'as is' on the model grid
   !     FORCING%GRID%LATLON          = F           ! Define field on regular lat/lon or cartesian grid
   !
   !     FORCING%TIDAL                = 'unset'     ! Set the tidal constituents [FAST | VFAST | 'M2 S2 N2']
   ! -------------------------------------------------------------------- !
   &FORCING_NML
     FORCING%FIELD%WINDS          = T
     FORCING%GRID%LATLON          = T
   /
   
   ! -------------------------------------------------------------------- !
   ! Define the content of the input file via FILE_NML namelist
   !
   ! * input file must respect netCDF format and CF conventions
   ! * input file must contain :
   !      -dimension : time, name expected to be called time
   !      -dimension : longitude/latitude, names can defined in the namelist
   !      -variable : time defined along time dimension
   !      -attribute : time with attributes units written as ISO8601 convention
   !      -attribute : time with attributes calendar set to standard as CF convention
   !      -variable : longitude defined along longitude dimension
   !      -variable : latitude defined along latitude dimension
   !      -variable : field defined along time,latitude,longitude dimensions
   ! * FILE%VAR(I) must be set for each field component
   !
   ! * namelist must be terminated with /
   ! * definitions & defaults:
   !     FILE%FILENAME      = 'unset'           ! relative path input file name
   !     FILE%LONGITUDE     = 'unset'           ! longitude/x dimension name
   !     FILE%LATITUDE      = 'unset'           ! latitude/y dimension name
   !     FILE%VAR(I)        = 'unset'           ! field component
   !     FILE%TIMESHIFT     = '00000000 000000' ! shift the time value to 'YYYYMMDD HHMMSS'
   ! -------------------------------------------------------------------- !
   &FILE_NML
     FILE%FILENAME      = 'wind.nc'
     FILE%LONGITUDE     = 'longitude'
     FILE%LATITUDE      = 'latitude'
     FILE%VAR(1)        = 'u10m'
     FILE%VAR(2)        = 'v10m'
   /
   
   
   ! -------------------------------------------------------------------- !
   ! WAVEWATCH III - end of namelist                                      !
! -------------------------------------------------------------------- !
EOF
    ######################################################
    echo "----${blank}${step}.2 根据执行ww3_prnc的run_test命令，配置相关文件并执行，" \
        "运行完成后，会在work文件夹下生成或更新wind.ww3,ww3_prnc.out,ww3_prnc.nml.log等文件，"
    cd ${pth_WW3_regtest_input} && cd '../../'
    ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
        -N -r ww3_prnc -w ${parm_WW3_work} ../model ${programGo} \
        >/dev/null
    # echo "`pwd`"
   
    ######################################################
fi

############################################################################################################
############################################################################################################
bannerSimple "data assimilation" "*"
pth_DA_Code=${pth_OceanForecast}'DA-Code/build/apps/'
declare -i DA_cycle_NoWW3 DA_cycle_NoWW3_ENOI
DA_cycle_NoWW3=0
DA_cycle_NoWW3_ENOI=0       ## ～tag，新建文件需要修改～

##
if ((DA_cycle_NoWW3 == 1)); then
    step=step+1
    echo "${blank}${step} 使用DA_cycle_NoWW3进行同化"
    cd ${pth_DA_Code}
    chmod +x 'DA_cycle_NoWW3'
    ./'DA_cycle_NoWW3'
fi

##
if ((DA_cycle_NoWW3_ENOI == 1)); then
    step=step+1
    echo "${blank}${step} 使用DA_cycle_NoWW3_ENOI进行同化"
    cd ${pth_DA_Code}
    chmod +x 'DA_cycle_NoWW3_ENOI'
    ./'DA_cycle_NoWW3_ENOI' '----'${blank}${step}'.'
fi

##
echo '├──「FAQ，完成，大纲」VScode书写shell，语法提示，格式化，错误提示，大纲，'
# https://blog.csdn.net/csdn_huzeliang/article/details/105321420 【vs code】shell 语法提示，检查，运行调试，
#       1、shellman: 语法提示，2、shell-format: 格式化，3、shellcheck: 语法错误检查
#       https://marketplace.visualstudio.com/items?itemName=Remisa.shellman     shellman的market
# for item in {a..z}; do
#     echo "${item}"
# done

# result=$(echo "scale=0;sqrt(num)" | bc)
# echo "${result}"

# # Usage: bannerSimple "my title" "*"
# function bannerSimple() {
#     local msg="${2} ${1} ${2}"
#     local edge
#     edge=${msg//?/$2}
#     echo "${edge}"
#     echo "$(tput bold)${msg}$(tput sgr0)"
#     echo "${edge}"
#     echo
# }
# # Usage: bannerSimple "my title" "*"
# bannerSimple "1" "*"
#       https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck    shellcheck的quickstart，
# https://zhuanlan.zhihu.com/p/199187317?ivk_sa=1024320u    VS code 打造 shell脚本 IDE
#
# 大纲用书签替代～～，bookmarks，
#       1、书签貌似不能同步？
#       2、复制粘贴的文件，没有书签，所以书签不是针对具体某个文件的属性？
#       3、书签内容不能自动更新吗？

##
echo '├──「FAQ，成功」将变量从Shell脚本传递到Fortran 90程序 '
# https://www.it1352.com/2197746.html   将变量从Shell脚本传递到Fortran 90程序
# https://gcc.gnu.org/onlinedocs/gfortran/GET_005fCOMMAND_005fARGUMENT.html#GET_005fCOMMAND_005fARGUMENT    Get command line arguments
echo '              fortran程序仍然能够进行调试！！！nice~'

##
echo '├──「FAQ，OK」Shell字符串定义'
# https://blog.csdn.net/qq_39147299/article/details/109001239   【shell】字符串（定义、拼接、长度、子串）、数组（定义、取值、赋值、长度）
#       1、定义字符串
#       2、拼接字符串
#       3、截取字符串
#       4、获取字符串长度（字符个数）
#       5、定义数组、取值、赋值、数组长度、

##
echo '├──「FAQ，OK」Shell整型定义'
# https://blog.csdn.net/jacklinping/article/details/84772558    shell 整型变量定义

##
echo '├──「FAQ，OK」Shell相对路径运行脚本'
# https://blog.csdn.net/succing/article/details/122450831   Shell编程： shell脚本5种执行方式 | 脚本不同的执行方法和区别

##
echo '├──「FAQ，OK」VScode shell 调试，'
# https://blog.csdn.net/babytiger/article/details/119937537     如何使用vscode优雅的可视化的调试shell脚本
echo '              调试时对文件代码的更改，不会起作用；断点不能打在空白或者注释的行～～，这样的断点不起作用'

##
echo '├──「FAQ，OK」shell脚本一行太长，'
# https://www.csdn.net/tags/OtTacg3sOTAxMC1ibG9n.html   shell脚本一行太长，使用\换行

##
echo '├──「FAQ，艰难解决」git上传超过50Mb怎么解决？，删除仓库大文件，新建分支，分支只包含重要的代码；以后一次别添加太多文件到github；'
# 放弃git托管大型项目，
# 只用一个.gitignore吧，太多就太烦了，
# https://blog.csdn.net/weixin_45574815/article/details/115231162   github如何删除项目中的文件
# https://blog.csdn.net/qq_36551991/article/details/110405561   .gitignore文件怎么写
# https://www.jianshu.com/p/82bbcfbb0ec9?from=singlemessage     git .ignore忽略文件夹中除了指定的文件外的其他所有文件
#       1、.gitignore写起来很费劲
# https://liu-jincan.github.io/2022/03/29/yan-jiu-sheng-justtry-function/fortran/02-win10-vscode-msys2-gfortran-fpm-git/#toc-heading-54
#       1、介绍了新建分支
#       2、https://www.it1352.com/2007198.html   git commit错误：pathspec'commit'与git已知的任何文件都不匹配

##
echo '├──「FAQ，失败」linux上wps能云同步文件夹吗？，'
# 不能

##
echo '├──「FAQ，成功」shell运行Matlab脚本？，'
# https://www.jianshu.com/p/a8d807949b7d    Linux shell 运行 matlab脚本参数
# https://blog.csdn.net/dx01259/article/details/104568764/      shell调用Matlab脚本

##
echo '├──「FAQ，成功」shell重定向到文件，'
# https://blog.csdn.net/phone1126/article/details/118524677，

##
echo '├──「FAQ，成功」matlab调用shell，'
# https://www.jianshu.com/p/d639893a6769    matlab传参调用shell
# https://blog.csdn.net/weixin_34910922/article/details/120753957   shell指令自带sudo密码

##
echo '├──「FAQ，成功」ubuntu更改文件夹的所有者，'
# http://t.zoukankan.com/jsdy-p-12762409.html   ubuntu 更改文件夹权限所有者，
#       sudo chown -R  user:user  filename


##
echo '├──「FAQ，成功」ubuntu todesk，'
# https://www.todesk.com/linux.html     官方安装，官方群，
#


##
echo '├──「FAQ，成功」ww3_prnc问题，'
# error，
#        --------------------------------------------------------------------------
#        MPI_ABORT was invoked on rank 0 in communicator MPI_COMM_WORLD
#        with errorcode 27.
#
#        NOTE: invoking MPI_ABORT causes Open MPI to kill all MPI processes.
#        You may or may not see output from other processes, depending on
#        exactly when Open MPI kills them.
#        --------------------------------------------------------------------------
# 思考，east-USA进行这个配置是没问题的，ww3_prnc无问题，
#       1、将east-USA的wind.nc移动本项目，使用ifremer1的switch，成功运行ww3_prnc，
#       2、比较east-USA和本项目的wind.nc文件的差异～，matlab，ncdisp,
#           * _FillValue ?，变量只能是NC_double，不能是NC_float，否则只能用_Fillvalue，不能用_FillValue
#               成功～～～
#       3、nc版本的问题？去虚拟机上看看能不能进行合成，


##
echo '├──「FAQ，？？？」如何防止脚本运行另一个却没提醒错误，其实已经错了，～～'
# 为了避免下一次的运行用的上一次的风场，需要用完风长后，在work删掉， ？？？