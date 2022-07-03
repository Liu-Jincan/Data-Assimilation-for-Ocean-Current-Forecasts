##
##
programGo='work_eastUSA_2' ## ～tag，新建文件需要修改～
parm_WW3_input='input_multi' ## ～tag，新建文件需要修改～，input2?
parm_WW3_work='work_b'        ## ～tag，新建文件需要修改～           ## 测试时需要更换名字，
parm_WW3_comp='Gnu'        ## ～tag，新建文件需要修改～，实际文件为comp.Gnu，位于model，
parm_WW3_switch='Ifremer1' ## ～tag，新建文件需要修改～，实际文件为switch_Ifremer1，位于input，




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
pth_OceanForecast='/1t/Data-Assimilation-for-Ocean-Current-Forecasts/' ## ～tag，新建文件需要修改～
pth_matlab='/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/matlab'
# blank
blank="----step."
echo '----step.0 新建program或者修改program时，①根据《～tag，新建文件需要修改～》检索需要修改的位置；' \
    '②VSC的整个文件的浏览拖动在修改时也很好用，但是需要绿色行；' \
    '③调试时，每一步的0/1（不运行/运行）设置需要打断点，这样很清晰的知道整个流程，起到了类似大纲的作用，而且提醒了哪些部分不许运行，nice~；' \
    "④bookmarks插件不错～～"

# 整型
declare -i step #声明是整型
step=0


# structure1:  矩形网格+CCMP风场+WW3
#   1. Gridgen
#   2. run_test
#   3. ww3_grid.nml
#   4. CCMP
#   5. ww3_prnc.nml
#   6. ww3_shel.nml
#   7. ww3_ounf.nml
#   8. ndbc
##########################################################################################################
###########################################################################################################
bannerSimple "grid create - Gridgen" "*"
pth_Gridgen=${pth_OceanForecast}'TUTORIAL_GRIDGEN/'
pth_WW3_regtest=${pth_OceanForecast}'WW3-6.07.1/regtests/'${programGo}
mkdir -p ${pth_WW3_regtest}
pth_WW3_regtest_input=${pth_WW3_regtest}"/${parm_WW3_input}/"
mkdir -p ${pth_WW3_regtest_input}
echo pth_Gridgen
declare -i Gridgen
Gridgen=0                           ## ～tag，新建文件需要修改～
gridgen_objectGrid='wind' ## ～tag，新建文件需要修改～
gridgen_objectGrid_nml="gridgen.${gridgen_objectGrid}.nml"
gridgen_m=${programGo}".m"
gridgen_baseGrid='grd0' ## ～tag，新建文件需要修改～
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
FNAME = 'wind'               %与namelist文件夹下的nml对应的，
FNAMEB = 'grd0'
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
LON_WEST = -77
LON_EAST = -57
LAT_SOUTH = 33
LAT_NORTH = 48
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
SPLIT_LIM = 2.5                 %from 5 to 10 times max(dx,dy)
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
FNAME = 'grd0'
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
DX = 0.5
DY = 0.5
LON_WEST = -77
LON_EAST = -57
LAT_SOUTH = 33
LAT_NORTH = 48
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
SPLIT_LIM = 2.5                 %from 5 to 10 times max(dx,dy)
OFFSET = 0.5                    %OFFSET = max([dx dy])
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
pth_WW3_regtest_work=${pth_WW3_regtest}"/${parm_WW3_work}/"
mkdir -p ${pth_WW3_regtest_work}
ww3_grid_name='wind'
ww3_grid_nml_name="ww3_grid_"${ww3_grid_name}'.nml'

##
if ((ww3_grid_nml == 1)); then
    step=step+1
    echo "${blank}${step} ww3_grid.nml，①整体制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-116"
    ######################################################
    echo "----${blank}${step}.1 创建ww3_grid.nml文件，①ww3_grid.nml的名称定了，" \
        "觉得某个ww3_grid.nml文件有价值，就在input文件夹中另存，" ## ～tag，新建文件需要修改～
    cd ${pth_WW3_regtest_input}
    cat >$ww3_grid_nml_name << EOF
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
  TIMESTEPS%DTMAX         =   1500.
  TIMESTEPS%DTXY          =   700.
  TIMESTEPS%DTKTH         =   800.
  TIMESTEPS%DTMIN         =   30.
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
  GRID%NAME              =  '${ww3_grid_name}'
  GRID%NML               =  '../${parm_WW3_input}/namelists_${ww3_grid_name}.nml'
  GRID%TYPE              =  'RECT'
  GRID%COORD             =  'SPHE'
  GRID%CLOS              =  'NONE'
  GRID%ZLIM              =  -0.10
  GRID%DMIN              =   2.50
/

&RECT_NML
  RECT%NX                =  81
  RECT%NY                =  61
!
  RECT%SX                =   0.250000000000
  RECT%SY                =   0.250000000000
  RECT%X0                =  -77.0000
  RECT%Y0                =   33.0000
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
  DEPTH%FILENAME       = '../${parm_WW3_input}/${ww3_grid_name}.bot'
/

&MASK_NML
  MASK%FILENAME         = '../${parm_WW3_input}/${ww3_grid_name}.mask'
/

&OBST_NML
  OBST%SF              =  0.01
  OBST%FILENAME        = '../${parm_WW3_input}/${ww3_grid_name}.obst'
/
EOF
    ######################################################
    echo "----${blank}${step}.2 根据执行ww3_grid的run_test命令，配置相关文件并执行，" \
        "运行完成后，会在work文件夹下生成或更新mapsta.ww3,mask.ww3,mod_def.ww3,ww3_grid.out等文件，"
    cd ${pth_WW3_regtest_input} && cd '../../'
    #./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
    #    -N -r ww3_grid -w ${parm_WW3_work} ../model ${programGo} \
    #    >/dev/null
    ######################################################
fi
















##########################################################################################################
###########################################################################################################
bannerSimple "wind nc create - CCMP" "*"
declare -i CCMP
CCMP=0                               ## ～tag，新建文件需要修改～
pth_CCMP=${pth_OceanForecast}'CCMP/'
pth_CCMP_work=${pth_CCMP}${programGo}'/' && mkdir -p ${pth_CCMP_work}
parm_CCMP_mergeBegin='20180901' ## ～tag，新建文件需要修改～，只能是年月日，在ww3_shel.nml中会用到
parm_CCMP_mergeEnd='20180915'   ## ～tag，新建文件需要修改～，只能是年月日，在ww3_shel.nml中会用到  ## 测试时Begin和End的时间相同即可，
# parm_CCMP_mergeName='ww3_ccmp_'${parm_CCMP_mergeBegin}'_'${parm_CCMP_mergeEnd}'.nc'
parm_CCMP_mergeName='wind.nc'   ## 不能更改名称，否则ww3_prnc会出问题～

if ((CCMP == 1)); then
    step=step+1
    echo "${blank}${step} CCMP，①整体制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-20，"
    ######################################################
    echo "----${blank}${step}.1 生成下载CCMP数据的download_ccmp.m文件，运行.m文件，生成的nc文件放在专门存储数据的大存储文件夹下，" \
        "①下载的速度很慢呀，>30分钟才下了14Mb，去对应下载地方可以看到单个文件下载时，文件大小的变化；猜测是外网很弱，晚上重启看看，" \
        "②Windows 小飞机下载的相对较快, 切换默认浏览器为google浏，用WPS云文档进行同步吧～～，" \
        "Window 下载CCMP的程序与这部分程序类似，但是\需要变成/。" \
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
year = num2str([2018]'); %通配符 year；
month = num2str([9]','%02d'); %通配符 month；
day = num2str([1:15]','%02d'); %通配符 day；

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
    #ln -snf ${pth_CCMP_work}'wind.nc' ${pth_WW3_regtest_input}
    mv ${pth_CCMP_work}'wind.nc' ${pth_WW3_regtest_input}
    ####################################################
fi




##########################################################################################################
###########################################################################################################
bannerSimple "wind nc preprocessor - ww3_prnc_nml" "*"
declare -i ww3_prnc_nml
ww3_prnc_nml=0             ## ～tag，新建文件需要修改～
ww3_prnc_name='wind'
ww3_prnc_nml_name="ww3_prnc_"${ww3_prnc_name}'.nml'

##
if ((ww3_prnc_nml == 1)); then
    step=step+1
    echo "${blank}${step} ww3_prnc.nml，①整体制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-116"
    ######################################################
    echo "----${blank}${step}.1 创建ww3_prnc.nml文件，①ww3_prnc.nml的名称定了，" \
        "觉得某个ww3_prnc.nml文件有价值，就在input文件夹中另存，" ## ～tag，新建文件需要修改～
    cd ${pth_WW3_regtest_input}
    cat >$ww3_prnc_nml_name <<EOF
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
     FILE%FILENAME      = '../${parm_WW3_input}/wind.nc'
     FILE%LONGITUDE     = 'longitude'
     FILE%LATITUDE      = 'latitude'
     FILE%VAR(1)        = 'u10'
     FILE%VAR(2)        = 'v10'
   /
   
   
   ! -------------------------------------------------------------------- !
   ! WAVEWATCH III - end of namelist                                      !
! -------------------------------------------------------------------- !
EOF
    ######################################################
    echo "----${blank}${step}.2 根据执行ww3_prnc的run_test命令，配置相关文件并执行，" \
        "运行完成后，会在work文件夹下生成或更新wind.ww3,ww3_prnc.out,ww3_prnc.nml.log等文件，"
    cd ${pth_WW3_regtest_input} && cd '../../'
    #./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
    #    -N -r ww3_prnc -w ${parm_WW3_work} ../model ${programGo} \
    #    >/dev/null
    # echo "`pwd`"
   
    ######################################################
fi







##########################################################################################################
###########################################################################################################
bannerSimple "WAVEWATCH3 Running - ww3_shel_nml" "*"
declare -i ww3_shel_nml
ww3_shel_nml=0             ## ～tag，新建文件需要修改～
parm_shel_start='20200729'
parm_shel_end='20200815'

##
if ((ww3_shel_nml == 1)); then
    step=step+1
    echo "${blank}${step} ww3_shel_nml，①整体制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-116"
    ######################################################
    echo "----${blank}${step}.1 创建ww3_shel.nml文件，①ww3_shel.nml的名称定了，" \
        "觉得某个ww3_shel.nml文件有价值，就在input文件夹中另存，" \
        "②为什么结束时间的小时是18，因为得到的融合的nc文件的结束时间就是18，实际上，CCMP每天有4个数据，分别是0、6、12、18," \
        "③带来了一个的问题，几个同化的时间点可能在一个wind.ww3中，「怎么切分同化？」，" \
        "④ww3_shel的中间运行计算时间可以在.log和.out中查看，这个是在nml中&OUTPUT_DATE_NML设置的，「猜测这一个设置不会影响计算结果？」，" \
        "⑤「restart.ww3文件是不是也是在这个过程创建的？」" \
        "⑥运行一个月的时间 3092.47 s，"  ## ～tag，新建文件需要修改～
    cd ${pth_WW3_regtest_input}
    cat >'ww3_shel.nml' <<EOF
! -------------------------------------------------------------------- !
! WAVEWATCH III ww3_shel.nml - single-grid model                       !
! -------------------------------------------------------------------- !


! -------------------------------------------------------------------- !
! Define top-level model parameters via DOMAIN_NML namelist
!
! * IOSTYP defines the output server mode for parallel implementation.
!             0 : No data server processes, direct access output from
!                 each process (requires true parallel file system).
!             1 : No data server process. All output for each type 
!                 performed by process that performs computations too.
!             2 : Last process is reserved for all output, and does no
!                 computing.
!             3 : Multiple dedicated output processes.
!
! * namelist must be terminated with /
! * definitions & defaults:
!     DOMAIN%IOSTYP =  1                 ! Output server type
!     DOMAIN%START  = '19680606 000000'  ! Start date for the entire model 
!     DOMAIN%STOP   = '19680607 000000'  ! Stop date for the entire model
!
! &DOMAIN_NML
! DOMAIN%START   = '20110902 000000'
! DOMAIN%STOP    = '20110902 060000'
! /
! -------------------------------------------------------------------- !
EOF
    #############################################
    echo "&DOMAIN_NML" >>'ww3_shel.nml'
    echo "DOMAIN%START   = '${parm_shel_start} 000000'" >>'ww3_shel.nml'
    echo "DOMAIN%STOP   = '${parm_shel_end} 180000'" >>'ww3_shel.nml'  ##18就18吧～～
    echo "/" >>'ww3_shel.nml'
    ############################################
    cat >>'ww3_shel.nml' <<EOF
! -------------------------------------------------------------------- !
! Define each forcing via the INPUT_NML namelist
!
! * The FORCING flag can be  : F for "no forcing"
!                              T for "external forcing file"
!                              H for "homogenous forcing input"
!                              C for "coupled forcing field"
!
! * homogeneous forcing is not available for ICE_CONC
!
! * The ASSIM flag can :  F for "no forcing"
!                         T for "external forcing file"
!
! * namelist must be terminated with /
! * definitions & defaults:
!     INPUT%FORCING%WATER_LEVELS  = F
!     INPUT%FORCING%CURRENTS      = F
!     INPUT%FORCING%WINDS         = F
!     INPUT%FORCING%ICE_CONC      = F
!     INPUT%FORCING%ICE_PARAM1    = F
!     INPUT%FORCING%ICE_PARAM2    = F
!     INPUT%FORCING%ICE_PARAM3    = F
!     INPUT%FORCING%ICE_PARAM4    = F
!     INPUT%FORCING%ICE_PARAM5    = F
!     INPUT%FORCING%MUD_DENSITY   = F
!     INPUT%FORCING%MUD_THICKNESS = F
!     INPUT%FORCING%MUD_VISCOSITY = F
!     INPUT%ASSIM%MEAN            = F
!     INPUT%ASSIM%SPEC1D          = F
!     INPUT%ASSIM%SPEC2D          = F
! -------------------------------------------------------------------- !
&INPUT_NML
INPUT%FORCING%WINDS = 'T' 
/

! -------------------------------------------------------------------- !
! Define the output types point parameters via OUTPUT_TYPE_NML namelist
!
! * the point file is a space separated values per line : lon lat 'name'
!
! * the full list of field names is : 
!  DPT CUR WND AST WLV ICE IBG D50 IC1 IC5 HS LM T02 T0M1 T01 FP DIR SPR
!  DP HIG EF TH1M STH1M TH2M STH2M WN PHS PTP PLP PDIR PSPR PWS TWS PNR
!  UST CHA CGE FAW TAW TWA WCC WCF WCH WCM SXY TWO BHD FOC TUS USS P2S
!  USF P2L TWI FIC ABR UBR BED FBB TBB MSS MSC DTD FC CFX CFD CFK U1 U2 
!
! * output track file formatted (T) or unformated (F)
!
! * coupling fields exchanged list is :
!   - Sent fields by ww3:
!       - Ocean model : T0M1 OCHA OHS DIR BHD TWO UBR FOC TAW TUS USS LM DRY
!       - Atmospheric model : ACHA AHS TP (or FP) FWS
!       - Ice model : IC5 TWI
!   - Received fields by ww3:
!       - Ocean model : SSH CUR
!       - Atmospheric model : WND
!       - Ice model : ICE IC1 IC5
!
! * namelist must be terminated with /
! * definitions & defaults:
!     TYPE%FIELD%LIST         =  'unset'
!     TYPE%POINT%FILE         =  'points.list'
!     TYPE%TRACK%FORMAT       =  T
!     TYPE%PARTITION%X0       =  0
!     TYPE%PARTITION%XN       =  0
!     TYPE%PARTITION%NX       =  0
!     TYPE%PARTITION%Y0       =  0
!     TYPE%PARTITION%YN       =  0
!     TYPE%PARTITION%NY       =  0
!     TYPE%PARTITION%FORMAT   =  T
!     TYPE%COUPLING%SENT      = 'unset'
!     TYPE%COUPLING%RECEIVED  = 'unset'
!
! TYPE%FIELD%LIST          = 'HS FP DIR DP CHA UST DPT CUR WND'
! -------------------------------------------------------------------- !
&OUTPUT_TYPE_NML
TYPE%FIELD%LIST          = 'HS'
/

! -------------------------------------------------------------------- !
! Define output dates via OUTPUT_DATE_NML namelist
!
! * start and stop times are with format 'yyyymmdd hhmmss'
! * if time stride is equal '0', then output is disabled
! * time stride is given in seconds
!
! * namelist must be terminated with /
! * definitions & defaults:
!     DATE%FIELD%START         =  '19680606 000000'
!     DATE%FIELD%STRIDE        =  '0'
!     DATE%FIELD%STOP          =  '19680607 000000'
!     DATE%POINT%START         =  '19680606 000000'
!     DATE%POINT%STRIDE        =  '0'
!     DATE%POINT%STOP          =  '19680607 000000'
!     DATE%TRACK%START         =  '19680606 000000'
!     DATE%TRACK%STRIDE        =  '0'
!     DATE%TRACK%STOP          =  '19680607 000000'
!     DATE%RESTART%START       =  '19680606 000000'
!     DATE%RESTART%STRIDE      =  '0'
!     DATE%RESTART%STOP        =  '19680607 000000'
!     DATE%BOUNDARY%START      =  '19680606 000000'
!     DATE%BOUNDARY%STRIDE     =  '0'
!     DATE%BOUNDARY%STOP       =  '19680607 000000'
!     DATE%PARTITION%START     =  '19680606 000000'
!     DATE%PARTITION%STRIDE    =  '0'
!     DATE%PARTITION%STOP      =  '19680607 000000'
!     DATE%COUPLING%START      =  '19680606 000000'
!     DATE%COUPLING%STRIDE     =  '0'
!     DATE%COUPLING%STOP       =  '19680607 000000'
!
!     DATE%RESTART             =  '19680606 000000' '0' '19680607 000000'
! &OUTPUT_DATE_NML
! DATE%FIELD          = '20110902 000000' '3600' '20110902 060000'
! /
! -------------------------------------------------------------------- !
EOF
    #############################################
    echo "&OUTPUT_DATE_NML" >>'ww3_shel.nml'
    echo "DATE%FIELD          = '${parm_shel_start} 000000' '3600' '${parm_shel_end} 180000'" >>'ww3_shel.nml'
    echo "/" >>'ww3_shel.nml'
    ############################################
    cat >>'ww3_shel.nml' <<EOF
! -------------------------------------------------------------------- !
! Define homogeneous input via HOMOG_COUNT_NML and HOMOG_INPUT_NML namelist
!
! * the number of each homogeneous input is defined by HOMOG_COUNT
! * the total number of homogeneous input is automatically calculated
! * the homogeneous input must start from index 1 to N
! * if VALUE1 is equal 0, then the homogeneous input is desactivated
! * NAME can be IC1, IC2, IC3, IC4, IC5, MDN, MTH, MVS, LEV, CUR, WND, ICE, MOV
! * each homogeneous input is defined over a maximum of 3 values detailled below :
!     - IC1 is defined by thickness
!     - IC2 is defined by viscosity
!     - IC3 is defined by density
!     - IC4 is defined by modulus
!     - IC5 is defined by floe diameter
!     - MDN is defined by density
!     - MTH is defined by thickness
!     - MVS is defined by viscosity
!     - LEV is defined by height
!     - CUR is defined by speed and direction
!     - WND is defined by speed, direction and airseatemp
!     - ICE is defined by concentration
!     - MOV is defined by speed and direction
!
! * namelist must be terminated with /
! * definitions & defaults:
!     HOMOG_COUNT%N_IC1            =  0
!     HOMOG_COUNT%N_IC2            =  0
!     HOMOG_COUNT%N_IC3            =  0
!     HOMOG_COUNT%N_IC4            =  0
!     HOMOG_COUNT%N_IC5            =  0
!     HOMOG_COUNT%N_MDN            =  0
!     HOMOG_COUNT%N_MTH            =  0
!     HOMOG_COUNT%N_MVS            =  0
!     HOMOG_COUNT%N_LEV            =  0
!     HOMOG_COUNT%N_CUR            =  0
!     HOMOG_COUNT%N_WND            =  0
!     HOMOG_COUNT%N_ICE            =  0
!     HOMOG_COUNT%N_MOV            =  0
!
!     HOMOG_INPUT(I)%NAME           =  'unset'
!     HOMOG_INPUT(I)%DATE           =  '19680606 000000'
!     HOMOG_INPUT(I)%VALUE1         =  0
!     HOMOG_INPUT(I)%VALUE2         =  0
!     HOMOG_INPUT(I)%VALUE3         =  0
! -------------------------------------------------------------------- !
&HOMOG_COUNT_NML
/

&HOMOG_INPUT_NML
/


! -------------------------------------------------------------------- !
! WAVEWATCH III - end of namelist                                      !
! -------------------------------------------------------------------- !
EOF
    ######################################################
    echo "----${blank}${step}.2 根据执行ww3_shel的run_test命令，配置相关文件并执行，" \
        "运行完成后，会在work文件夹下生成或更新out_grd.ww3,ww3_shel.out,ww3_shel.nml.log,log.ww3等文件，"
    cd ${pth_WW3_regtest_input} && cd '../../'
    ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
        -N -r ww3_shel -w ${parm_WW3_work} ../model ${programGo} \
    #    >/dev/null
    ######################################################
fi



##
echo '├──「FAQ，？？？」MPI并行话运行，50分钟1个月，运行的 有点久～～'




##########################################################################################################
###########################################################################################################
bannerSimple "Grid output post-processing - ww3_ounf_nml" "*"
declare -i ww3_ounf_nml
ww3_ounf_nml=0             ## ～tag，新建文件需要修改～

##
if ((ww3_ounf_nml == 1)); then
    step=step+1
    echo "${blank}${step} ww3_ounf.nml，①整体制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-116"
    ######################################################
    echo "----${blank}${step}.1 创建ww3_ounf.nml文件，①ww3_ounf.nml的名称定了，" \
        "觉得某个ww3_ounf.nml文件有价值，就在input文件夹中另存，" ## ～tag，新建文件需要修改～
    cd ${pth_WW3_regtest_input}
    cat >'ww3_ounf.nml' <<EOF
! -------------------------------------------------------------------- !
! WAVEWATCH III ww3_ounf.nml - Grid output post-processing             !
! -------------------------------------------------------------------- !

! -------------------------------------------------------------------- !
! Define the output fields to postprocess via FIELD_NML namelist
!
! * the full list of field names FIELD%LIST is : 
!  DPT CUR WND AST WLV ICE IBG D50 IC1 IC5 HS LM T02 T0M1 T01 FP DIR SPR
!  DP HIG EF TH1M STH1M TH2M STH2M WN PHS PTP PLP PDIR PSPR PWS TWS PNR
!  UST CHA CGE FAW TAW TWA WCC WCF WCH WCM SXY TWO BHD FOC TUS USS P2S
!  USF P2L TWI FIC ABR UBR BED FBB TBB MSS MSC DTD FC CFX CFD CFK U1 U2 
!
! * namelist must be terminated with /
! * definitions & defaults:
!     FIELD%TIMESTART            = '19000101 000000'  ! Stop date for the output field
!     FIELD%TIMESTRIDE           = '0'                ! Time stride for the output field
!     FIELD%TIMESTOP             = '29001231 000000'  ! Stop date for the output field
!     FIELD%TIMECOUNT            = '1000000000'       ! Number of time steps
!     FIELD%TIMESPLIT            = 6                  ! [4(yearly),6(monthly),8(daily),10(hourly)]
!     FIELD%LIST                 = 'unset'            ! List of output fields
!     FIELD%PARTITION            = '0 1 2 3'          ! List of wave partitions ['0 1 2 3 4 5']
!     FIELD%SAMEFILE             = T                  ! All the variables in the same file [T|F]
!     FIELD%TYPE                 = 3                  ! [2 = SHORT, 3 = it depends , 4 = REAL]
!
!&FIELD_NML
!  FIELD%TIMESTART        =  '20080310 000000'
!  FIELD%TIMESTRIDE       =  '180'
!  FIELD%TIMECOUNT        =  '100'
!  FIELD%LIST             =  'HS FP DIR DP CHA UST DPT CUR WND'
!  FIELD%PARTITION        =  '0'
!/
! -------------------------------------------------------------------- !
&FIELD_NML
  FIELD%TIMESTRIDE       =  '3600'
  FIELD%LIST             =  'HS'
  FIELD%TIMESPLIT        =   4
/

! -------------------------------------------------------------------- !
! Define the content of the input file via FILE_NML namelist
!
! * namelist must be terminated with /
! * definitions & defaults:
!     FILE%PREFIX        = 'ww3.'            ! Prefix for output file name
!     FILE%NETCDF        = 3                 ! Netcdf version [3|4]
!     FILE%IX0           = 1                 ! First X-axis or node index
!     FILE%IXN           = 1000000000        ! Last X-axis or node index
!     FILE%IY0           = 1                 ! First Y-axis index
!     FILE%IYN           = 1000000000        ! Last Y-axis index
! -------------------------------------------------------------------- !
&FILE_NML
/


! -------------------------------------------------------------------- !
! Define the content of the output file via SMC_NML namelist
!
! * For SMC grids, IX0, IXN, IY0 and IYN from FILE_NML are not used.
!   Two types of output are available:
! *   TYPE=1: Flat 1D "seapoint" array of grid cells.
! *   TYPE=2: Re-gridded regular grid with cell sizes being an integer
! *           multiple of the smallest SMC grid cells size.
!
! * Note that the first/last longitudes and latitudes will be adjusted
!  to snap to the underlying SMC grid edges. CELFAC is only used for
!  type 2 output and defines the output cell sizes as an integer
!  multiple of the smallest SMC Grid cell size. CELFAC should be a
!  power of 2, e.g: 1,2,4,8,16, etc...
!
! * namelist must be terminated with /
! * definitions & defaults:
!     SMC%TYPE          = 1              ! SMC Grid type (1 or 2)
!     SMC%SXO           = -999.9         ! First longitude
!     SMC%EXO           = -999.9         ! Last longitude
!     SMC%SYO           = -999.9         ! First latitude
!     SMC%EYO           = -999.9         ! Last latitude
!     SMC%CELFAC        = 1              ! Cell size factor (SMCTYPE=2 only)
!     SMC%NOVAL         = UNDEF          ! Fill value for wet cells with no data
! -------------------------------------------------------------------- !
&SMC_NML
/

! -------------------------------------------------------------------- !
! WAVEWATCH III - end of namelist                                      !
! -------------------------------------------------------------------- !

EOF
    ######################################################
    echo "----${blank}${step}.2 根据执行ww3_ounf的run_test命令，配置相关文件并执行，" \
        "运行完成后，会在work文件夹下生成或更新ww3_ounf.out,ww3_ounf.nml.log,ww3..nc等文件，"
    cd ${pth_WW3_regtest_input} && cd '../../'
    #./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
    #    -N -r ww3_ounf -w ${parm_WW3_work} -o netcdf ../model ${programGo} \
    #    >/dev/null
    # echo "`pwd`"
   
    ######################################################
fi






##########################################################################################################
###########################################################################################################
bannerSimple "Data assimilation preparing && Background analysis - ndbc" "*"
declare -i ndbc
ndbc=0                                ## ～tag，新建文件需要修改～  ，一般设置为1,后面的程序会用到这里的.m程序，
pth_ndbc=${pth_OceanForecast}'ndbc/'
pth_ndbc_source=${pth_ndbc}'source/'
pth_ndbc_mmap=${pth_ndbc}'m_map/'
pth_ndbc_work=${pth_ndbc}${programGo}'/'  && mkdir -p ${pth_ndbc_work}

##
if ((ndbc == 1)); then
    parm_ndbc_station_downloadFlag=0      ## 优先级1 ～tag，新建文件需要修改～
    parm_ndbc_create_new_work_table=0     ## 优先级1 ～tag，新建文件需要修改～      
    parm_ndbc_num2buoynum=0               ## 优先级2 ～tag，新建文件需要修改～ 
    parm_ndbc_buoynum2num=0               ## 优先级2 ～tag，新建文件需要修改～ 
    parm_ndbc_Index1_yo=0                 ## 优先级3 ～tag，新建文件需要修改～      用于同化  
                                            ##（自己在程序重新低效率match，还需要调参数，运行很慢，不建议）
    parm_ndbc_match=0                     ## 优先级3 ～tag，新建文件需要修改～      用于浮标与背景场的比较
    parm_ndbc_match_spinup=1              ## 优先级4 ～tag，新建文件需要修改～ 
    parm_ndbc_match_Index1_yo=0           ## 优先级4 ～tag，新建文件需要修改～
                                            ## 建议用此方法实现Index1_yo的同化，运行很快，
    
    #####################################################
    step=step+1
    echo "${blank}${step} ndbc，①部分制作看https://liu-jincan.github.io/2022/01/17/yan-jiu-sheng-justtry-target/yan-yi-shang-han-jia-gei-ding-qu-yu-ww3-shi-yan-2022-han-jia-an-pai/#toc-heading-116" \
        "②在ENOI项目的实现的过程中，添加了关于H观测算子的索引Index1，及其对应的观测yo，"
    ######################################################
    echo "----${blank}${step}.1 在ndbc项目创建关于program的文件夹，批量导入并重命名背景场nc文件到program文件夹下的nc/文件夹，①会删除nc/文件夹" ## ～tag，新建文件需要修改～
    # rm -rf ${pth_ndbc_work}'nc/'
    # mkdir -p ${pth_ndbc_work}'nc/'
    # for tmp in `cd ${pth_WW3_regtest_work} && ls ww3.*.nc`; do
    #     cp ${pth_WW3_regtest_work}${tmp} ${pth_ndbc_work}'nc/'
    # done
    # cd ${pth_ndbc_work}'nc/'
    # rename -v 's/ww3./ww3_/g' *.nc  ## nice~~  （可选操作）
    
    
    ######################################################
    echo "----${blank}${step}.2 创建该项目的.m文件，" ## ～tag，新建文件需要修改～
    cd ${pth_ndbc_work}
    cat >${programGo}'.m' <<EOF
% author:
%    liu jin can, UPC
%
% revison history
%    2022-02-19 first verison.
%
% reference:
%    https://blog.csdn.net/qq_35166974/article/details/96007377:警告: 未保存变量 'work_table'。对于大于 2GB 的变量，请使用 MAT 文件版本 7.3 或更高版本。 

% begin~~~~
fprintf('work_eastUSA.m \n')
% path_save = '/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA/'; %work工作目录路径，最后必须是'/'
path_save
cd(path_save)
fprintf('   「添加路径」source， \n')
path_source
% addpath '/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/source'
addpath(path_source)
path_mmap
addpath(path_mmap)


%%
create_new_work_table
if(create_new_work_table==1)
    fprintf('├──「创建work_table.mat，」\n')
    work_table = table;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['       ├──Step1.从网站上爬取ndbc浮标站的信息，①会在table中生成station_ID、station_lat、station_lon、' ...
        'station_historyYear_SM信息，②想爬取其他关于浮标的信息，需修改源代码，' ...
        '③爬取的时间有些久，10点27开始...等不了了...，已爬取的站点信息可以保存在source文件下ndbc_station_info.mat以备用，' ...
        '④运行完成后会在program文件夹下创建ndbc_station_info.mat，\n' ])
    %[work_table] = ndbc_station_info('',path_save); %运行需要时间比较久；
    [work_table] = ndbc_station_info('default',path_save); %调用之前已保存的ndbc_station_info.mat数据；
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['       ├──Step2.选取特定区域需要的站点，剔除年份为nan的站点，在program文件夹下创建ndbc_station_info_needed.mat，\n' ])
    lat_max = 48;  % 纬度为负数，表示南纬
    lat_min = 33;
    lon_max = -57; % 经度为负数，表示西经
    lon_min = -77;
    [work_table] = ndbc_station_info_needed(work_table,lat_max,lat_min,lon_max,lon_min,path_save);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['       ├──Step3.特定区域站点的plot，在program/fig文件夹下创建<区域ndbc浮标图.fig>，table生成对应fig的打开命令，\n' ])
    [work_table] = ndbc_station_info_needed_plot(work_table,lat_max,lat_min,lon_max,lon_min,path_save);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['       ├──Step4.特定区域站点的水深，在table中生成，\n' ])
    [work_table] = ndbc_station_info_needed_etopo1(work_table,path_save);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd(path_save)
    save work_table work_table
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ndbc_station_downloadFlag
    if(ndbc_station_downloadFlag==1)
        fprintf('       ├──Step5.「函数」下载特定区域的ndbc浮标数据，更改work_table中的station_historyData_SM属性，下载完数据此步骤可省略，\n')
        station_tf_download = [1:size(work_table,1)];                                                 %要下载的浮标在work_table的索引
        path_station_historyData_SM = strcat(path_save,'station_historyData_SM/');
        mkdir(path_station_historyData_SM);

        fileFolder=fullfile(path_station_historyData_SM);
        dirOutput=dir(fullfile(fileFolder,'*.mat'));
        fileNames={dirOutput.name};
        fileNames = string(fileNames);
        
        tmp=[];
        for i=1:1:length(station_tf_download) 
            str=strcat(mat2str(i),'.mat');
            if( length( find(strcmp(str,fileNames)) ) == 1 )
                tmp=[tmp 0];
            else
                tmp=[tmp 1];
            end
        end
        tmp = logical(tmp);
        station_tf_download = station_tf_download(tmp);

        [work_table] = ndbc_station_download(work_table,station_tf_download,path_save);%运行需要时间比较久；第一次是必须运行的； %%
        clear station_tf_download path_station_historyData_SM;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%%
match
if(match==1)  
    fprintf('├──「加载work_table.mat」\n')
    load work_table.mat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('       ├──Step*. 循环nc文件，为同化做准备，且能对背景场数据和nc进行简单对比分析，\n')
    fprintf('           ├──Step1. 循环nc，\n')
    path_nc = strcat(path_save,'nc/');
    fileFolder = fullfile(path_nc);
    dirOutput = dir(fullfile(fileFolder,'*.nc'));
    fileNames = {dirOutput.name}'; % 20x1 cell, relative path, 
    wildcards = strcat(path_nc,fileNames); % 20x1 cell, wildcards, absolute path,
    clear fileFolder dirOutput path_nc; 
    for i=1:length(fileNames)
        tic
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('           ├──Step2 「重要参数」，\n')
        % 
        station_tf_download = [1:size(work_table,1)];           %work_table中的，选取需要添加数据的浮标索引，
        ncNameInTable = strcat(fileNames{i}(1:end-3),'_nc');    %work_table中的，显示的关于此nc文件的属性名称前缀，不能有. 
                                                                %'ww3_2011_nc';
        %
        ncid = wildcards{i};                                    %'ww3_2011.nc'; %绝对路径，
        nclat = ncread(ncid,'latitude');                        %填写纬度名称
        nclon = ncread(ncid,'longitude');                       %填写经度名称
        nctime = ncread(ncid,'time');                           %填写时间名称
        nc_WVHT = ncread(ncid,'hs');                            %填写有效波高名称
        % clear ncid;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('           ├──Step3「函数」每个浮标与网格点匹配，\n')
        fprintf('                            每个浮标在H观测矩阵的索引，\n')
        fprintf('                            每个浮标在nc文件的时间-HS数据，保存至.mat文件，\n')
        path_Nc_time_Hs = strcat(path_save,ncNameInTable,'_Nc_time_Hs/');
        mkdir(path_Nc_time_Hs);
        
        [work_table] = ndbc_station_download_NC(work_table,station_tf_download,ncid,nclat,nclon,nctime,nc_WVHT,...
            path_save,ncNameInTable,...
            path_Nc_time_Hs);
        % clear path_Nc_time_Hs;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % station_tf_download = [55:211];
        fprintf('           ├──Step4「函数」在work_table中的添加$(ncNameInT)_ndbc_nc_match_WVHT,\n')
        path_Ndbc_nc_match_Hs_Fig = strcat(path_save,ncNameInTable,'_Ndbc_nc_match_Hs_Fig/');
        path_Ndbc_nc_match_Hs = strcat(path_save,ncNameInTable,'_Ndbc_nc_match_Hs/');
        mkdir(path_Ndbc_nc_match_Hs_Fig);
        mkdir(path_Ndbc_nc_match_Hs);

        ndbc_start_datetime=datetime('2020-07-29 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss');
        ndbc_end_datetime=datetime('2020-08-15 18:00:00','InputFormat','yyyy-MM-dd HH:mm:ss');

        [work_table] = analyse_HS(path_Ndbc_nc_match_Hs_Fig,path_Ndbc_nc_match_Hs,...
            path_Nc_time_Hs,work_table,station_tf_download,path_save,ncNameInTable,...
            ndbc_start_datetime,ndbc_end_datetime);  %很早被定义过的...
        clear path_Ndbc_nc_match_Hs_Fig;
        path_Ndbc_nc_match = path_Ndbc_nc_match_Hs;
        clear path_Ndbc_nc_match_Hs;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %fprintf('           ├──Step5「函数」根据$(path_Ndbc_nc_match) 下的所有文件生成每个所需同化时刻的Index1和yo文件txt,\n')
        %path_Index1 = strcat(path_save,ncNameInTable,'_Index1/');
        %path_yo = strcat(path_save,ncNameInTable,'_yo/');
        %mkdir(path_Index1); % rmdir(path_Index1,'s')
        %mkdir(path_yo); % rmdir(path_yo,'s')
        %[work_table] = Index1_And_yo(path_Index1,path_yo,...
        %    path_Ndbc_nc_match,path_save,work_table,ncNameInTable); %很早被定义过的...
        %clear path_Index1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % toc
        %fprintf('           ├──Step6「函数」根据$(path_yo) 下的所有文件的名称，得到所有需要同化的时刻，求出所有时刻在nc的索引，保存在Index.txt,\n')
        %path_Index = strcat(path_save,ncNameInTable,'_Index/');
        %mkdir(path_Index);
        %[work_table] = Index(path_Index,...
        %    work_table,nctime,path_yo); %很早被定义过的...
        %clear path_Index;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end 
%%
Index1_yo
if(Index1_yo==1)
    cd(path_save)
    system('rm -rf Index1')
    system('rm -rf yo')
    mkdir('Index1')
    mkdir('yo')
    fprintf('├──「加载work_table.mat」\n')
    load work_table.mat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('           ├──Step1「函数」每个浮标与网格点匹配，\n')
    fprintf('                         每个浮标在H观测矩阵的索引，\n')
    path_nc = strcat(path_save,'nc/');
    fileFolder = fullfile(path_nc);
    dirOutput = dir(fullfile(fileFolder,'*.nc'));
    fileNames = {dirOutput.name}'; % 20x1 cell, relative path, 
    wildcards = strcat(path_nc,fileNames); % 20x1 cell, wildcards, absolute path,
    clear fileFolder dirOutput path_nc fileNames; 
    ncid = wildcards{1};                                    %'ww3_2011.nc'; %绝对路径，
    nclat = ncread(ncid,'latitude');                        %填写纬度名称
    nclon = ncread(ncid,'longitude');                       %填写经度名称
    for i=1:1:size(work_table,1)
        % lat 最近网格点经纬度
        [~,temp1] = min(abs(nclat(:)-work_table.lat(i,1))); 
        work_table.matchNC_lat{i,1} = nclat(temp1);
        work_table.matchNC_lat{i,2} = temp1; %索引位置

        % lon 最近网格点经纬度
        [~,temp2] = min(abs(nclon(:)-work_table.lon(i,1))); % 
        work_table.matchNC_lon{i,1} = nclon(temp2);
        work_table.matchNC_lon{i,2} = temp2; %索引位置
        
        % 在H矩阵的索引
        work_table.IndexInHmatrix{i,1} = (temp1-1)*length(nclon)+temp2;
    end
    clear ncid nclat nclon wildcards;
    %%
    cd(path_save)
    save work_table work_table
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('           ├──Step2 循环每个浮标的.mat，实现每个浮标一个小时一个Hs，是有效的Hs，就生成每个所需同化时刻的Index1和yo文件txt，\n')
    cd(path_save)
    
    for i=1:1:size(work_table,1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 实现每个浮标一个小时一个Hs
        %% 去除ndbc数据table无效数据所在行
        temp = strcat(path_save,'station_historyData_SM/',num2str(i),'.mat');
        load(temp); % temp 中仅有 buoy_table_All 变量；
        ndbc_table = buoy_table_All;
        ndbc_WVHT1 = cell2mat(ndbc_table.WVHT(:)); %double
        ndbc_time1 = ndbc_table.YY_MM_DD_hh_mm; % datetime
        tf1 = find( ndbc_WVHT1>=0 & ndbc_WVHT1<99 );
        
        ndbc_time2 = ndbc_time1(tf1);
        ndbc_WVHT2 = ndbc_WVHT1(tf1);
        disp(strcat('                       已去除ndbc数据table无效数据所在行；'));
        %% ndbc数据，一个小时一个数据
        % 超过30分钟，进一个小时
        tf2 = find( ndbc_time2.Minute>=30 & ndbc_time2.Minute<60 ); % case1, 秒数都是0，因为ndbc不包含秒数信息；
        temp = ndbc_time2(tf2); temp.Minute = 0; temp.Hour = temp.Hour+1;
        ndbc_time2(tf2) = temp;
        % 少于30分钟，小时不变
        tf3 = find( ndbc_time2.Minute>0 & ndbc_time2.Minute<30 ); % case2；
        temp = ndbc_time2(tf3); temp.Minute = 0;
        ndbc_time2(tf3) = temp;
        % 年、月、日、时相等的datetime处理：
        count = tabulate(ndbc_time2); % 统计数列中每个元素出现的次数
        tf4 = find(cell2mat(count(:,2))>1); % 元素次数超过1次
        for j=1:1:size(tf4,1) %元素次数超过1次的元素进行平均化处理
            temp = datetime(count{tf4(j),1});
            tf5 = find(ndbc_time2==temp);
            ndbc_WVHT2(tf5(1)) = mean(ndbc_WVHT2(tf5)); %平均化处理
            ndbc_WVHT2(tf5(2:end)) = 99; %无效数据
            % ndbc_WVHT2(tf5)
        end
        tf6 = find( ndbc_WVHT2>=0 & ndbc_WVHT2<99 );
        ndbc_time3 = ndbc_time2(tf6); % unique(ndbc_time3); %通过维数不变，发现每一个元素都是唯一的;
        ndbc_WVHT3 = ndbc_WVHT2(tf6);
        disp(strcat('                     已实现ndbc数据，一个小时一个数据，（通过了unique(ndbc_time3)的检验）；'));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 是有效的Hs，就生成每个所需同化时刻的Index1和yo文件txt
        for j=1:1:size(ndbc_time3,1)
            %
            time = ndbc_time3(j);
            time_str = datestr(time,'yyyymmddTHHMMSS');
            if(str2num(time_str(1:4))>2010 && str2num(time_str(1:4))<2012)
                Index1_filename = strcat(path_save,'Index1/',time_str,'.txt');
                yo_filename = strcat(path_save,'yo/',time_str,'.txt');
                if ~exist(Index1_filename)
                    f = fopen(Index1_filename,'w');
                    fclose(f);
                    f = fopen(yo_filename,'w');
                    fclose(f);
                    clear f;
                end
                clear time time_str;
                %
                Index1 = work_table.IndexInHmatrix(i); Index1 = cell2mat(Index1);
                f = fopen(Index1_filename,'a');
                fprintf(f,'%d\n',Index1);
                fclose(f);
                clear str f;
                yo = ndbc_WVHT3(j);
                f = fopen(yo_filename,'a');
                fprintf(f,'%f\n',yo);
                fclose(f);
                clear f;
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
end
%%
mat_num2buoynum
if(mat_num2buoynum==1)
    inputArg1='num2buoynum';
    %path_save = '/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA2/';
    ndbc_station_mat_num2buoynum(inputArg1,path_save);
end
%%
mat_buoynum2num
if(mat_buoynum2num==1)
    inputArg1='buoynum2num';
    %path_save = '/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA_2/';
    ndbc_station_mat_buoynum2num(inputArg1,path_save);
end
%%
match_spinup
if(match_spinup==1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputArg1=24; %24个小时？
    % ndbc_start_datetime=datetime('2018-09-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss');
    % path_save = '/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA_2/';
    ndbc_spinup_datetime=datetime('2020-08-02 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss'); %一般更改2018-09-03 00:00:00即可
    ndbc_spinup_endtime=datetime('2020-08-15 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss'); %一般更改2018-09-03 00:00:00即可
    ndbc_spinup_selectedbuoy= [11;12;13;20;21;23;25;29;30;119];
    
    HS_matchnameINtable='ww3_2020_grd3_ST6_nc_ndbc_nc_match_WVHT'; %一般更改ww3_2018_nc即可，前提是work_table必须有HS_matchnameINtable的属性
    path_Ndbc_nc_match_Hs_Fig_spinup = strcat(path_save,'ww3_2020_grd3_ST6_nc_Ndbc_nc_match_Hs_Fig_spinup/'); %一般更改ww3_2018_nc即可
    mkdir(path_Ndbc_nc_match_Hs_Fig_spinup);
    analyse_HS_spinup(ndbc_spinup_datetime,HS_matchnameINtable,ndbc_spinup_endtime,ndbc_spinup_selectedbuoy,path_save,path_Ndbc_nc_match_Hs_Fig_spinup);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%

Match_Index_yo
if(Match_Index_yo==1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ndbc_start_datetime=datetime('2018-09-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss');
    % path_save = '/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA_2/';
    cd(path_save)
    system('rm -rf Index1')
    system('rm -rf yo')
    mkdir('Index1')
    mkdir('yo')
    path_Ndbc_nc_match = strcat(path_save,'ww3_2018_nc_Ndbc_nc_match_Hs/'); %一般更改ww3_2018_nc即可
    HindexINtable = 'ww3_2018_nc_IndexInHmatrix'; %一般更改ww3_2018_nc即可
    buoynumNeededForDA = [9 12 18]; %一般更改[]中buoy在work_table对应的num数字即可。
    match_Index1_yo(HindexINtable,buoynumNeededForDA,path_save,path_Ndbc_nc_match);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%
EOF
    ######################################################
    echo "----${blank}${step}.3 运行该m文件，①matlab需要安装Text Analytics Toolbox，②create_new_work_table=1运行会在program文件夹下" \
        "创建ndbc_station_info.mat、ndbc_station_info_needed.mat、" \
        "、work_table.mat、fig/区域ndbc浮标图，work_table.mat包含所需浮标ID、经纬度、SM数据年份、区域浮标fig命令、etopo1水深属性，" \
        "③ndbc_station_downloadFlag=1运行会在program文件夹下创建station_historyData_SM/*.mat，table中还会记录每个浮标数据导入.mat失败对应的txt，" \
        "这个创建耗费时间很长，如果已经创建，需设置为0，" \
        "④match=1运行会对nc/中的每个nc创建_Index1,_Nc_time_Hs,Ndbc_nc_match_Hs,Ndbc_nc_match_Hs_Fig,_yo文件夹，耗费时间长，建议放弃～～，加入一个时间参数，减少match时间，可行，不用放弃，" \
        "⑤Index1_yo=1运行，生成Index1和yo文件夹，(测试年2011年),时间长了，也很耗时间，不建议使用～～" \
        "六、mat_num2buoynum=1，将在station_historyData_SM文件夹下载的浮标文件名称，从work_table的数字索引，变成work_table的ID索引。" \
        "七、mat_buoynum2num=1，将浮标文件从work_table的ID索引，变成work_table的数字索引。用于外部浮标文件的导入。" \
        "八、match_spinup=，将匹配的数据，考虑模式的spinup的时间，重新比较。" \
        "九、Match_Index_yo=，从匹配的数据（*_Ndbc_nc_match_Hs文件夹下），输出同化所需的数据。"
    cd ${pth_ndbc_work} 
    ${pth_matlab} -nodisplay -r "path_save='${pth_ndbc_work}'; path_source='${pth_ndbc_source}'; path_mmap='${pth_ndbc_mmap}'; create_new_work_table=${parm_ndbc_create_new_work_table};ndbc_station_downloadFlag=${parm_ndbc_station_downloadFlag};match=${parm_ndbc_match};Index1_yo=${parm_ndbc_Index1_yo};mat_num2buoynum=${parm_ndbc_num2buoynum};mat_buoynum2num=${parm_ndbc_buoynum2num};match_spinup=${parm_ndbc_match_spinup};Match_Index_yo=${parm_ndbc_match_Index1_yo};${programGo};exit;" \ 
    #    >${pth_ndbc_work}'.out.create_work_table' 2>&1
    ######################################################

fi


##
echo '├──「FAQ，OK」另一个角度来看ndbc中创建的match_Index1_yo，Index1_yo一定需要match才能生成？' \
    '不是的，可以按浮标一个一个来，例如，对于某个浮标A，其某一个数据时刻Hs数据有效，则在Index1和yo文件夹下对应小时时刻的文件添加数据即可，' \
    "哇塞诶，感觉这样不需要浪费很多时间进行配对～～～配对的目的是进行浮标数据的对比，同化不需要这么配对～～～" \
    "开干～"


##
echo '├──「FAQ，？？？」nc文件的样式改变，则ndbc必须重新运行一遍？work_table一定需要覆盖～～'


##
echo '├──「FAQ，bug，解决了」Index1和yo中30分钟的数据没有处理，～～'
# =30分钟的按照+1 hour来看吧



# structure2: 矩形网格+NDBC观测+ENOI同化


############################################################################################################
############################################################################################################
bannerSimple "Data assimilation without WavaWatch3 - NoWW3_ENOI" "*"
declare -i DA_cycle_NoWW3_ENOI
DA_cycle_NoWW3_ENOI=0       ## ～tag，新建文件需要修改～

##
if ((DA_cycle_NoWW3_ENOI == 1)); then
    pth_DA_Code_src=${pth_OceanForecast}'DA-Code/src_NoWW3_ENOI/'       ## ～tag，新建文件需要修改～
    pth_DA_Code_build=${pth_OceanForecast}'DA-Code/build/'              ## ～tag，新建文件需要修改～
    pth_DA_Code_apps=${pth_DA_Code_build}'apps3/'                       ## ～tag，新建文件需要修改～
    pth_DA_Code_objs=${pth_DA_Code_build}'objs3/'                       ## ～tag，新建文件需要修改～
    pth_DA_Code_mods=${pth_DA_Code_build}'mods3/'                       ## ～tag，新建文件需要修改～
    parm_DA_Code_ww3InputNc='nc_30days'                  ## ～tag，新建文件需要修改～，所需同化背景场nc所在的文件夹名称，不能为nc
    parm_DA_Code_daOuputNc='nc_NoWW3_ENOI_30days'        ## ～tag，新建文件需要修改～，同化后nc所在的文件夹名称和文件前缀，
    #####################################################
    step=step+1
    echo "${blank}${step} 使用DA_cycle_NoWW3_ENOI进行同化，源码在src_NoWW3_ENOI,"
    #####################################################
    echo "----${blank}${step}.1 ①创建所需同化背景场nc的nc.txt，nc文件数目，②创建ENOI中形成A的nc/nc_ENOI_Amatrix.txt，" ## ～tag，新建文件需要修改～
    rm -rf ${pth_ndbc_work}'nc'
    cp -r ${pth_ndbc_work}${parm_DA_Code_ww3InputNc}  ${pth_ndbc_work}'nc'  #
    cd ${pth_ndbc_work}'nc/'
    ls -1 *.nc >'nc.txt'  ##重定向，-1按列，
    nc_fileNameNum=`ls -l *.nc|grep "^-"|wc -l`   ##最少要求2个？ WithWW3只需要1个nc，这里需要额外判断。
    ls -1 *.nc >'nc_ENOI_Amatrix.txt'  ##重定向，-1按列，
    ######################################################
    echo "----${blank}${step}.2 mod_params.f90的设置，"   ## ～tag，新建文件需要修改～
    cd ${pth_DA_Code_src}
    cat >'mod_params.f90' <<EOF
module mod_params
    implicit none
    !********************************* Path setting  *********************************
    ! 生成的可执行文件位于，$pth_DA_Code_apps
    character(len=*), parameter :: programs = '$programGo'              ! 数据同化的区域项目名称
    character(len=*), parameter :: ndbc_pth = '$pth_ndbc' 
    
    !********************************* ENOI Step Options *********************************
    integer, parameter :: ENOI = 1      ! 使用ENOI同化方法，1为使用, 0为不使用
    integer :: NN = 0       ! size of ensemble，这个需要运行完                                     
    integer, parameter :: DN = 10       ! step interval to sample the ensemble pool, hour       
    real, parameter    :: alpha = 1     ! scaling parameter of matrix B
    integer :: generateAmatriax = 1     ! 1表示生成，0表示不生成，


    !*********************************** Info on input NetCdf file *************************************
    character(len=*), parameter :: nc_pth = programs//'/nc/'              ! 背景场数据所在文件夹
    character(len=*), parameter :: nc_fileNameTxt = nc_pth//'nc.txt'      ! 背景场数据所在文件夹包含的文件名称，按时间顺序从先到后，
    integer, parameter :: nc_fileNameNum = $nc_fileNameNum                ! nc_fileNameTxt的行数，即需要同化的背景场nc文件个数，
    character(len=*), parameter :: nc_AttTimeName = 'time'                ! nc文件中时间属性的名称，
    character(len=*), parameter :: LAT_NAME = 'latitude'                    ! 
    character(len=*), parameter :: LON_NAME = 'longitude'                   ! 
    character(len=*), parameter :: TMP_NAME = 'hs'                          ! readdata会用到


    !*********************************** Info on output NetCdf file *************************************
    character(len=*), parameter :: nc_daOut = '$parm_DA_Code_daOuputNc'     ! 输出同化nc文件所在文件夹名称

    !************************************* DA Subdomain Setting ***************************************
    integer, parameter :: sub_xy(4) = (/1, 1, 69, 41/)                      ! readdata会用到,
    integer, parameter :: sub_x = 69, sub_y = 41                            ! x 对应的经度，y 对应的是纬度，readdata会用到,
    integer, parameter :: N = 41*69                                         ! number of model grid points , NLATS * NLONS
    integer, parameter :: NLATS = 41, NLONS = 69                            ! 
end module mod_params

EOF
    ######################################################
    echo "----${blank}${step}.3 编译的makefile设置，然后make,①makefile中的有$()，EOF需要加上双引号，"   ## ～tag，新建文件需要修改～
    cd ${pth_DA_Code_src}
    cat >'Makefile' << EOF
Build = $pth_DA_Code_build#../build 不能用相对路径# 当前路径为 makefile 所在路径, 一般不改变
OBJ_dir = $pth_DA_Code_objs##
APP_dir = $pth_DA_Code_apps## 一般不改变，
MOD_dir = $pth_DA_Code_mods#
SRC_dir = $pth_DA_Code_src#
EOF
    cat >>'Makefile' <<"EOF"
EXEC = DA_cycle_NoWW3_ENOI#生成的可执行文件的名称，
RUN = DA_cycle_NoWW3_ENOI#所需跑的项目文件的名称，不包含.f90的扩展名

all : comp link trans clean apps_makefile # depend 

# Portland Group Compiler
#FC = pgf90
#FFLAGS = -g -C

# GNU Compiler
#FC = gfortran
#FFLAGS = -g -C -mcmodel=medium -fbackslash -fconvert=big-endian
#FFLAGS = -g -C

# Intel Compiler
FC = gfortran
#FFLAGS = -g -C -shared-intel -convert big_endian -I${NFDIR}/include -L${NFDIR}/lib -lnetcdff
#FFLAGS = -g -C -O3 -mcmodel=medium -convert big_endian -I${NCDF_INC} -L${NCDF_LIB} -lnetcdf -lnetcdff
#FFLAGS = -g -C -O3 -L/usr/lib/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu/hdf5/serial -lnetcdf -lnetcdff -I /usr/include
#FFLAGS = -g -C -O3
gdb_debug = -g
netcdf = -I/usr/include  -L/usr/lib/x86_64-linux-gnu -lnetcdff
Matlab_mat_h = -I/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/extern/include -L/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/glnxa64 -L/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/ -cpp 
Matlab_mat_h2 = -lmat -lmx -lmex -lm -Wl,-rpath /home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/glnxa64
FFLAGS = $(gdb_debug) $(netcdf) #$(Matlab_mat_h) $(Matlab_mat_h2)
#FFLAGS = -g -C -convert big_endian
#FFLAGS = -g -check bounds -fpe0 -ftrapuv -debug semantic_stepping -debug variable_locations -fpp
#FFLAGS = -O3 -ipo -no-prec-div

#SOURCES = mod_params.f90 mod_date.f90  mod_namelist.f90 mod_matrix_read.f90 mod_matrix_write.f90 mod_matrix_H.f90 mod_matrix_R.f90 mod_matrix_inverse.f90 mod_matrix_W.f90 mod_analysis.f90 DA_cycle.f90

#runOBJS = mod_params.o mod_date.o  mod_namelist.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o mod_matrix_W.o mod_analysis.o DA_cycle.o

runOBJS = $(RUN).o 
comp: $(runOBJS)

# mod_obs_superobing.o: mod_params.o

# mod_obs_sorting.o: mod_params.o mod_obs_superobing.o

mod_nctime2date.o: 

mod_write_data.o: 

mod_matrix_read.o: mod_params.o 

mod_inIndex_flag.o: mod_params.o 

mod_read_data.o: mod_params.o

mod_write_data.o: mod_params.o

mod_matrix_A.o: mod_read_coor.o mod_read_data.o mod_matrix_write.o 

mod_namelist.o: mod_params.o 

# mod_read_coor.o: mod_params.o  

mod_matrix_H.o: mod_params.o mod_matrix_read.o mod_matrix_write.o

# mod_matrix_L.o: mod_params.o mod_matrix_write.o mod_matrix_read.o

# mod_matrix_R.o: mod_params.o mod_matrix_write.o

mod_matrix_W.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o

mod_analysis.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_W.o mod_matrix_A.o  # mod_obs_sorting.o

DA_cycle_NoWW3_ENOI.o: mod_params.o mod_analysis.o mod_read_coor.o mod_inIndex_flag.o mod_nctime2date.o mod_read_data.o mod_write_data.o

%.o:%.f90
	$(FC) $(Matlab_mat_h) -c  $(FFLAGS) $<


link:*.o
	@echo "编译完成"
	@#$(FC) $(FFLAGS) $(runOBJS) -o run
	$(FC) *.o $(Matlab_mat_h) -o $(EXEC) $(FFLAGS) $(Matlab_mat_h2)
	@echo "链接完成"

clean:
	@#rm  ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
	rm -f *.mod *.o $(EXEC) *.d
	@echo "清理完毕" 

trans:
	@-mkdir -p $(OBJ_dir) $(MOD_dir) $(APP_dir)  #在 mkdir 命令前加一个减号，可以避免文件夹已生成而报错。
	@-mv -f *.o $(OBJ_dir)						#在 mv 命令前加一个减号，可以避免无文件而报错。
	@-mv -f *.mod $(MOD_dir)
	@-mv -f $(EXEC) $(APP_dir)/
	@#-cp -f * $(APP_dir)/						# 为了在$(APP_dir)调试(废弃了)
	@#-cp -f $(OBJ_dir)/* $(APP_dir)/				# 为了在$(APP_dir)调试（废弃了）
	@echo "「目标文件转移到了$(OBJ_dir) ，可执行文件转移到了$(APP_dir)，MOD文件转移到了$(MOD_dir)」"

apps_makefile:
	-rm -f $(APP_dir)/Makefile && touch -f $(APP_dir)/Makefile 
	@-echo "all: clean run #gdb-debug" >> $(APP_dir)/Makefile
	@-echo "clean:" >> $(APP_dir)/Makefile 
	@-echo "	rm -f data/namelist.txt ensemble/coordinate.dta ensemble/ensemble_mean_tmp.dta ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*" >> $(APP_dir)/Makefile
	@-echo "	rm -f ensemble/Amatrix.txt" >> $(APP_dir)/Makefile  
	@-echo "run:" >> $(APP_dir)/Makefile  
	@-echo "	./$(EXEC)" >> $(APP_dir)/Makefile 
	@-echo ".PHONY: clean run" >> $(APP_dir)/Makefile

	@-echo "gdb-debug-launch:" >> $(APP_dir)/Makefile
	@-echo "		{" >> $(APP_dir)/Makefile
	@-echo '			"type": "cppdbg",' >> $(APP_dir)/Makefile
	@-echo '			"request": "launch",' >> $(APP_dir)/Makefile
	@-echo '			"name": "$(EXEC)",' >> $(APP_dir)/Makefile
	@-echo '			"program": "$(APP_dir)/DA_cycle",' >> $(APP_dir)/Makefile
	@-echo '			"args": [' >> $(APP_dir)/Makefile
	@-echo '				"$(OBJ_dir)/*.o"' >> $(APP_dir)/Makefile
	@-echo '				"$(SRC_dir)/*.f90"' >> $(APP_dir)/Makefile
	@-echo '			],' >> $(APP_dir)/Makefile
	@-echo '			"cwd": "$(APP_dir)/"' >> $(APP_dir)/Makefile
	@-echo "		}," >> $(APP_dir)/Makefile

	@-echo "debug-gdb:" >> $(APP_dir)/Makefile
	@-echo "	@make clean" >> $(APP_dir)/Makefile
	@-echo "	@cd $(SRC_dir) && make" >> $(APP_dir)/Makefile  # 为了方便调试
	@-echo "	# 在选择对应的调试项目，F5" >> $(APP_dir)/Makefile
	@echo "「已为apps生成makefile」"



.PHONY: clean trans 
# depend:
# 	sfmakedepend $(SOURCES)

# DO NOT DELETE THIS LINE - used by make depend

mod_namelist.o: mod_params.o 

mod_read_coor.o: mod_params.o  

mod_matrix_H.o: mod_params.o mod_matrix_read.o mod_matrix_write.o

mod_matrix_L.o: mod_params.o mod_matrix_write.o mod_matrix_read.o

mod_matrix_R.o: mod_params.o mod_matrix_write.o

mod_matrix_W.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o

mod_analysis.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_W.o

DA_cycle.o: mod_params.o mod_analysis.o
EOF
    ######################################################
    make
    ######################################################
    echo "----${blank}${step}.4 执行可执行文件，"   ## ～tag，新建文件需要修改～
    cd ${pth_DA_Code_apps}
    chmod +x 'DA_cycle_NoWW3_ENOI'
    ./'DA_cycle_NoWW3_ENOI' '--------'${blank}${step}'.4.'
    ######################################################
fi



############################################
##
echo '├──「FAQ，bug，已解决」work_eastUSA/yo/20110831T240000.txt应该是20110901T000000，导致未同化，'
# 源程序



############################################
##
echo '├──「FAQ，bug，已解决」Amatrix的生成问题，NN打断点都不出来，NN怎么变化？'


############################################
##
echo '├──「FAQ，bug，解决」Netcdf的陆点数据的波高应该是缺失的，不能是具体数值，负数也不行，实际影响不大，'
# 思路，nf_copy_var()



############################################
##
echo '├──「FAQ，bug」Netcdf同化后的wet grid波高可能是负数，重新赋值为0吧，NO，不改变～'


############################################
##
echo '├──「FAQ，转移」把整个项目放到1t，大的存储空间位置～'


############################################
##
echo '├──「FAQ，bug，已解决，出问题了」fortran创建新的Netcdf，与原来Netcdf时间对应不上呀，How to solve?使用nf_copy_var()'
# https://blog.csdn.net/qwe123oo/article/details/121553212      创建一个nc文件并添加其他nc文件的数据
# https://docs.unidata.ucar.edu/netcdf-fortran/current/f90-attributes.html#f90-copy-attribute-from-one-netcdf-to-another-nf90_copy_att
# mod_write_data.f90, call check(nf_copy_var(ncid,tmp_varid,new_ncid))
#           思路1：nc 文件的问题？，NO
#           思路2：https://www.unidata.ucar.edu/mailing_lists/archives/netcdfgroup/2012/msg00357.html，解决
#                   1、需放在enddef后
#                   2、需要定义dim，但是不能定义var，
#                   3、check(nf90_def_dim(new_ncid,"hs",NF90_UNLIMITED,hs_dimid))？？？
# scale_factor,


############################################
##
echo '├──「FAQ，增加设置」WW3InputNc，daOutputNc～'
# VSC 右键，find all references，good ？？NO，无法实现～
# 只能调试更改～～



############################################
##
echo '├──「FAQ，？？？」VSC不同src相同程序，如何不会乱跳转？～'



############################################################################################################
############################################################################################################
bannerSimple "Data assimilation analysis - ndbc_NoWW3_ENOI " "*"
declare -i ndbc_NoWW3_ENOI_ana
ndbc_NoWW3_ENOI_ana=0       ## ～tag，新建文件需要修改～

if (( ndbc_NoWW3_ENOI_ana == 1 )); then
    parm_DA_Code_daOuputNc='nc_NoWW3_ENOI_30days'  ## ～tag，新建文件需要修改～
    parm_ndbc_station_downloadFlag=0      ## ～tag，新建文件需要修改～
    parm_ndbc_Index1_yo=0                 ## ～tag，新建文件需要修改～      用于同化
    parm_ndbc_create_new_work_table=0     ## ～tag，新建文件需要修改～      
    parm_ndbc_match=1                     ## ～tag，新建文件需要修改～      用于浮标与背景场的比较
    #########################################################
    rm -rf ${pth_ndbc_work}'nc/'
    cp -r ${pth_ndbc_work}${parm_DA_Code_daOuputNc}  ${pth_ndbc_work}'nc'
    ##########################################################
    cd ${pth_ndbc_work}
    ##########################################################
    cd ${pth_ndbc_work} 
    ${pth_matlab} -nodisplay -r "path_save='${pth_ndbc_work}'; path_source='${pth_ndbc_source}'; path_mmap='${pth_ndbc_mmap}'; create_new_work_table=${parm_ndbc_create_new_work_table};ndbc_station_downloadFlag=${parm_ndbc_station_downloadFlag};match_Index1_yo=${parm_ndbc_match};Index1_yo=${parm_ndbc_Index1_yo};${programGo};exit;" \
    
fi



##
echo '├──「FAQ，bug，解决了？」VSC在/1t下运行ndbc乱码，导致时序图没了'
# 在matlab运行完一次这个后，怎么突然又不乱码了？奇怪

##
echo '├──「FAQ，bug，解决了」ndbc_station_download_NC_analyse_HS函数太长，导致无法被调用，创建了个analyse_HS和它一样，'







# structure3: 矩形网格+CCMP风场+WW3+NDBC观测+ENOI同化
#    IO
#    删除work中的文档
#    1.
#       a. 明确背景场时间段，制作对应时间段的CCMP风场，生成wind.ww3；
#       b. 明确时间段内所需同化的时刻保存至da_time.txt；
#       c. 明确生成ENOI中的A矩阵所需的背景场数据nc文件夹；
#    2. 循环da_time.txt
#       2.1 ww3_shel.nml
#       2.2 ww3_ounf.nml
#       2.3 mod_params.f90               「仅在第一次循环生成」
#       2.4 同化src文件夹下的Makefile       「仅在第一次循环生成」
#       2.5 make, 运行同化可执行文件
#       2.6 ww3_uprstr.inp
#    3. merge_ndbc.m
#    4. ndbc
############################################################################################################
############################################################################################################
bannerSimple "Data assimilation with WavaWatch3 - WithWW3_ENOI" "*"
declare -i DA_cycle_WithWW3_ENOI
DA_cycle_WithWW3_ENOI=0       ## ～tag，新建文件需要修改～

##
if (( DA_cycle_WithWW3_ENOI == 1 )); then 
    ########################################################  IO
    pth_DA_Code_src=${pth_OceanForecast}'DA-Code/src_WithWW3_ENOI/'       ## ～tag，新建文件需要修改～
    pth_DA_Code_build=${pth_OceanForecast}'DA-Code/build/'              ## ～tag，新建文件需要修改～
    pth_DA_Code_apps=${pth_DA_Code_build}'apps4/'                       ## ～tag，新建文件需要修改～
    pth_DA_Code_objs=${pth_DA_Code_build}'objs4/'                       ## ～tag，新建文件需要修改～
    pth_DA_Code_mods=${pth_DA_Code_build}'mods4/'                       ## ～tag，新建文件需要修改～
    parm_DA_Code_ww3InputNc='nc_Backg_WW3_P125_16days_2020'                  ## ～tag，新建文件需要修改～，所需同化背景场nc所在的文件夹名称，不能为nc；用于A的生成，
    parm_DA_Code_daOuputNc='nc_WithWW3_ENOI_WW3_P125_16days_2020'        ## ～tag，新建文件需要修改～，同化后nc所在的文件夹名称和文件前缀，
    parm_DA_cycle_WithWW3_Begin='20200729'       ## ～tag，新建文件需要修改～
    parm_DA_cycle_WithWW3_End='20200815'        ## ～tag，新建文件需要修改～
    parm_DA_cycle_timeTxt='da_time.txt'                    ## ～tag，新建文件需要修改～
    ######################################################## 删除work中的文档
    cd ${pth_WW3_regtest_work}
    rm `ls restart*`
    rm `ls *.nc`
    rm `ls out_grd.ww3`
    #########################################################
    step=step+1
    echo "${blank}${step} 使用DA_cycle_WithWW3_ENOI进行同化，源码在src_WithWW3_ENOI，" \
    ######################################################### 1.
    echo "----${blank}${step}.1 明确背景场时间段，制作对应时间段的CCMP风场，生成wind.ww3；明确时间段内所需同化的时刻保存至da_time.txt；" \
         "明确生成ENOI中的A矩阵所需的背景场数据nc文件夹；"
    ## CCMP=1 运行一次，会生成wind.nc，并ln -snf，至WW3的test的input文件夹，
    ## ww3_prnc_nml=1 运行一次，生成wind.ww3，
    ## 
    #
    # FAQ：第一个同化时刻是ww3_shel.nml的开始时刻可以吗？不可以～～，
    #
    ##
    rm -rf ${pth_ndbc_work}'nc'
    cp -r ${pth_ndbc_work}${parm_DA_Code_ww3InputNc}  ${pth_ndbc_work}'nc'  #
    cd ${pth_ndbc_work}'nc/'
    ls -1 *.nc >'nc.txt'  ##重定向，-1按列，
    nc_fileNameNum=`ls -l *.nc|grep "^-"|wc -l`   ##最少要求1个。
                                                  ##之前以为至少要求2个，可是只有一个也能运行。
                                                  ##可能WithoutWW3需要2个？
    ls -1 *.nc >'nc_ENOI_Amatrix.txt'  ##重定向，-1按列，
    ##
    cd ${pth_WW3_regtest_input}
    ls -1 ${pth_ndbc_work}'yo/' > ${parm_DA_cycle_timeTxt}   # https://blog.csdn.net/u014046192/article/details/50414606/     cut函数截取文件   
    sed -i '1d' ${parm_DA_cycle_timeTxt} # 删除第一个同化的时刻，因为第一个同化时刻不可以是ww3_shel.nml的开始时刻
    #cat >${parm_DA_cycle_timeTxt} <<EOF
#20180901T010000.txt
#20180901T020000.txt
#20180901T030000.txt
#20180901T040000.txt
#20180901T050000.txt
#EOF
                    # 最后一个时刻没有同化数据怎么办？，最后得到的数据会比背景数据短一些；
                    # 可以自己手动根据restart文件再重启运行，cdo合并小时文件和最后的时间段数据；

    ######################################################### 2. 循环da_time.txt
    echo "----${blank}${step}.2 循环da_time.txt，对于每一个同化时刻，①制作ww3_shell.nml文件，" \
        "运行得到同化时刻的restart001.ww3，②制作ww3_ounf_nml文件，运行得到nc小时文件；" \
        "③读取同化时刻的背景场nc小时信息，配合观测进行同化，输出分析场信息，Xb.grbtxt；"\
        "④制作ww3_uprstr.inp，运行得到restart001.ww3，重命名为restart.ww3文件，"
    LastTime="${parm_DA_cycle_WithWW3_Begin} 000000"
    declare -i DA_tmp
    DA_tmp=1          #编译执行一次，A矩阵的生成执行一次，
    while read -r line
    do
        # echo $line
        ThisTime="`echo $line | cut -b 1-8`"" ""`echo $line | cut -b 10-15`"
        ThisNCfile="ww3.""`echo $line | cut -b 1-8`""T""`echo $line | cut -b 10-11`""Z.nc"
        # echo $ThisNCfile
        ######################################################ww3_shel.nml，生成restart001.ww3，
        cd ${pth_WW3_regtest_input}
        cat >'ww3_shel.nml' <<EOF
! -------------------------------------------------------------------- !
&DOMAIN_NML
DOMAIN%START   = '$LastTime'
DOMAIN%STOP    = '$ThisTime'
/

&INPUT_NML
INPUT%FORCING%WINDS = 'T' 
/

&OUTPUT_TYPE_NML
TYPE%FIELD%LIST          = 'HS'
/


&OUTPUT_DATE_NML
DATE%FIELD          = '$LastTime' '3600' '$ThisTime'
DATE%RESTART = '$ThisTime' '3600' '$ThisTime'
/
! -------------------------------------------------------------------- !
EOF
        cd ${pth_WW3_regtest_input} && cd '../../'
        ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
            -N -r ww3_shel -w ${parm_WW3_work} ../model ${programGo} \
        #
        cd ${pth_WW3_regtest_work}
        mv restart001.ww3 restart.ww3  #这里可以不用换名字，run_test中的www3_uprstrt中会换名，但还是建议加上这一句
        #########################################################ww3_ounf.nml
        cd ${pth_WW3_regtest_input}
        cat >'ww3_ounf.nml' <<EOF
&FIELD_NML
  FIELD%TIMESTRIDE       =  '3600'
  FIELD%LIST             =  'HS'
  FIELD%TIMESPLIT        =   10
/

! -------------------------------------------------------------------- !
! Define the content of the input file via FILE_NML namelist
!
! * namelist must be terminated with /
! * definitions & defaults:
!     FILE%PREFIX        = 'ww3.'            ! Prefix for output file name
!     FILE%NETCDF        = 3                 ! Netcdf version [3|4]
!     FILE%IX0           = 1                 ! First X-axis or node index
!     FILE%IXN           = 1000000000        ! Last X-axis or node index
!     FILE%IY0           = 1                 ! First Y-axis index
!     FILE%IYN           = 1000000000        ! Last Y-axis index
! -------------------------------------------------------------------- !
&FILE_NML
/

&SMC_NML
/
EOF
        cd ${pth_WW3_regtest_input} && cd '../../'
        ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
            -N -r ww3_ounf -w ${parm_WW3_work} -o netcdf ../model ${programGo} \
        
        #########################################################单一时刻同化的nc.txt，nc_ENOI_Amatrix.txt，mod_params.f90
        ls -1
        if (( DA_tmp == 1 )); then
            rm -rf ${pth_ndbc_work}'nc'
            cp -r ${pth_ndbc_work}${parm_DA_Code_ww3InputNc}  ${pth_ndbc_work}'nc'  #
            cd ${pth_ndbc_work}'nc/'
            ls -1 *.nc >'nc.txt'  ##重定向，-1按列，
            nc_fileNameNum=`ls -l *.nc|grep "^-"|wc -l`   ##最少要求2个？ 1个就可以  
            ls -1 *.nc >'nc_ENOI_Amatrix.txt'  ##重定向，-1按列，
            cd ${pth_DA_Code_src} 
            cat >'mod_params.f90' <<EOF       
module mod_params
    implicit none
    !********************************* Path setting  *********************************
    ! 生成的可执行文件位于，$pth_DA_Code_apps
    character(len=*), parameter :: programs = '$programGo'              ! 数据同化的区域项目名称
    character(len=*), parameter :: ndbc_pth = '$pth_ndbc' 
    
    !********************************* ENOI Step Options *********************************
    integer, parameter :: ENOI = 1      ! 使用ENOI同化方法，1为使用, 0为不使用  （废弃）
    integer :: NN = 0                 ! size of ensemble，这个运行完会自动更新，全局变量，                                     
    integer, parameter :: DN = 10       ! step interval to sample the ensemble pool, hour       
    real, parameter    :: alpha = 1     ! scaling parameter of matrix B
    integer :: generateAmatriax = 1     ! 1表示生成，0表示不生成，(废弃)


    !*********************************** Info on input NetCdf file *************************************
    character(len=*), parameter :: nc_pth = programs//'/nc/'              ! 背景场数据所在文件夹
    character(len=*), parameter :: nc_fileNameTxt = nc_pth//'nc.txt'      ! 背景场数据所在文件夹包含的文件名称，按时间顺序从先到后，
    integer, parameter :: nc_fileNameNum = $nc_fileNameNum                ! nc_fileNameTxt的行数，即需要同化的背景场nc文件个数，
    character(len=*), parameter :: nc_AttTimeName = 'time'                ! nc文件中时间属性的名称，
    character(len=*), parameter :: LAT_NAME = 'latitude'                    ! 
    character(len=*), parameter :: LON_NAME = 'longitude'                   ! 
    character(len=*), parameter :: TMP_NAME = 'hs'                          ! readdata会用到



    !*********************************** Info on output NetCdf file *************************************
    character(len=*), parameter :: nc_daOut = '$parm_DA_Code_daOuputNc'     ! 输出同化nc文件所在文件夹名称

    !************************************* DA Subdomain Setting ***************************************
    integer, parameter :: sub_xy(4) = (/1, 1, 161, 121/)                      ! readdata会用到,
    integer, parameter :: sub_x = 161, sub_y = 121                            ! x 对应的经度，y 对应的是纬度，readdata会用到,
    integer, parameter :: N = 121*161                                         ! number of model grid points , NLATS * NLONS
    integer, parameter :: NLATS = 121, NLONS = 161                            ! 
end module mod_params
EOF
        fi
        ########################################################单一时刻同化的Makefile，编译
        ls -1
        if (( DA_tmp == 1 )); then
            cd ${pth_DA_Code_src}
            cat >'Makefile' << EOF
Build = $pth_DA_Code_build#../build 不能用相对路径# 当前路径为 makefile 所在路径, 一般不改变
OBJ_dir = $pth_DA_Code_objs##
APP_dir = $pth_DA_Code_apps## 一般不改变，
MOD_dir = $pth_DA_Code_mods#
SRC_dir = $pth_DA_Code_src#
EOF
        ##
            cat >> 'Makefile' << "EOF"
EXEC = DA_cycle_WithWW3_ENOI#生成的可执行文件的名称，
RUN = DA_cycle_WithWW3_ENOI#所需跑的项目文件的名称，不包含.f90的扩展名

all : comp link trans clean apps_makefile # depend 

# Portland Group Compiler
#FC = pgf90
#FFLAGS = -g -C

# GNU Compiler
#FC = gfortran
#FFLAGS = -g -C -mcmodel=medium -fbackslash -fconvert=big-endian
#FFLAGS = -g -C

# Intel Compiler
FC = gfortran
#FFLAGS = -g -C -shared-intel -convert big_endian -I${NFDIR}/include -L${NFDIR}/lib -lnetcdff
#FFLAGS = -g -C -O3 -mcmodel=medium -convert big_endian -I${NCDF_INC} -L${NCDF_LIB} -lnetcdf -lnetcdff
#FFLAGS = -g -C -O3 -L/usr/lib/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu/hdf5/serial -lnetcdf -lnetcdff -I /usr/include
#FFLAGS = -g -C -O3
gdb_debug = -g
netcdf = -I/usr/include  -L/usr/lib/x86_64-linux-gnu -lnetcdff
Matlab_mat_h = -I/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/extern/include -L/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/glnxa64 -L/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/ -cpp 
Matlab_mat_h2 = -lmat -lmx -lmex -lm -Wl,-rpath /home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/glnxa64
FFLAGS = $(gdb_debug) $(netcdf) #$(Matlab_mat_h) $(Matlab_mat_h2)
#FFLAGS = -g -C -convert big_endian
#FFLAGS = -g -check bounds -fpe0 -ftrapuv -debug semantic_stepping -debug variable_locations -fpp
#FFLAGS = -O3 -ipo -no-prec-div

#SOURCES = mod_params.f90 mod_date.f90  mod_namelist.f90 mod_matrix_read.f90 mod_matrix_write.f90 mod_matrix_H.f90 mod_matrix_R.f90 mod_matrix_inverse.f90 mod_matrix_W.f90 mod_analysis.f90 DA_cycle.f90

#runOBJS = mod_params.o mod_date.o  mod_namelist.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o mod_matrix_W.o mod_analysis.o DA_cycle.o

runOBJS = $(RUN).o 
comp: $(runOBJS)

# mod_obs_superobing.o: mod_params.o

# mod_obs_sorting.o: mod_params.o mod_obs_superobing.o

mod_nctime2date.o: 

mod_write_data.o: 

mod_matrix_read.o: mod_params.o 

mod_inIndex_flag.o: mod_params.o 

mod_read_data.o: mod_params.o

mod_write_data.o: mod_params.o

mod_matrix_A.o: mod_read_data.o mod_matrix_write.o 

mod_namelist.o: mod_params.o 

# mod_read_coor.o: mod_params.o  

mod_matrix_H.o: mod_params.o mod_matrix_read.o mod_matrix_write.o

# mod_matrix_L.o: mod_params.o mod_matrix_write.o mod_matrix_read.o

# mod_matrix_R.o: mod_params.o mod_matrix_write.o

mod_matrix_W.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_inverse.o

mod_analysis.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_W.o mod_matrix_A.o  # mod_obs_sorting.o

DA_cycle_WithWW3_ENOI.o: mod_params.o mod_analysis.o mod_inIndex_flag.o mod_nctime2date.o mod_read_data.o mod_write_data.o

%.o:%.f90
	$(FC) $(Matlab_mat_h) -c  $(FFLAGS) $<


link:*.o
	@echo "编译完成"
	@#$(FC) $(FFLAGS) $(runOBJS) -o run
	$(FC) *.o $(Matlab_mat_h) -o $(EXEC) $(FFLAGS) $(Matlab_mat_h2)
	@echo "链接完成"

clean:
	@#rm  ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
	rm -f *.mod *.o $(EXEC) *.d
	@echo "清理完毕" 

trans:
	@-mkdir -p $(OBJ_dir) $(MOD_dir) $(APP_dir)  #在 mkdir 命令前加一个减号，可以避免文件夹已生成而报错。
	@-mv -f *.o $(OBJ_dir)						#在 mv 命令前加一个减号，可以避免无文件而报错。
	@-mv -f *.mod $(MOD_dir)
	@-mv -f $(EXEC) $(APP_dir)/
	@#-cp -f * $(APP_dir)/						# 为了在$(APP_dir)调试(废弃了)
	@#-cp -f $(OBJ_dir)/* $(APP_dir)/				# 为了在$(APP_dir)调试（废弃了）
	@echo "「目标文件转移到了$(OBJ_dir) ，可执行文件转移到了$(APP_dir)，MOD文件转移到了$(MOD_dir)」"

apps_makefile:
	-rm -f $(APP_dir)/Makefile && touch -f $(APP_dir)/Makefile 
	@-echo "all: clean run #gdb-debug" >> $(APP_dir)/Makefile
	@-echo "clean:" >> $(APP_dir)/Makefile 
	@-echo "	rm -f data/namelist.txt ensemble/coordinate.dta ensemble/ensemble_mean_tmp.dta ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*" >> $(APP_dir)/Makefile
	@-echo "	rm -f ensemble/Amatrix.txt" >> $(APP_dir)/Makefile  
	@-echo "run:" >> $(APP_dir)/Makefile  
	@-echo "	./$(EXEC)" >> $(APP_dir)/Makefile 
	@-echo ".PHONY: clean run" >> $(APP_dir)/Makefile

	@-echo "gdb-debug-launch:" >> $(APP_dir)/Makefile
	@-echo "		{" >> $(APP_dir)/Makefile
	@-echo '			"type": "cppdbg",' >> $(APP_dir)/Makefile
	@-echo '			"request": "launch",' >> $(APP_dir)/Makefile
	@-echo '			"name": "$(EXEC)",' >> $(APP_dir)/Makefile
	@-echo '			"program": "$(APP_dir)/DA_cycle",' >> $(APP_dir)/Makefile
	@-echo '			"args": [' >> $(APP_dir)/Makefile
	@-echo '				"$(OBJ_dir)/*.o"' >> $(APP_dir)/Makefile
	@-echo '				"$(SRC_dir)/*.f90"' >> $(APP_dir)/Makefile
	@-echo '			],' >> $(APP_dir)/Makefile
	@-echo '			"cwd": "$(APP_dir)/"' >> $(APP_dir)/Makefile
	@-echo "		}," >> $(APP_dir)/Makefile

	@-echo "debug-gdb:" >> $(APP_dir)/Makefile
	@-echo "	@make clean" >> $(APP_dir)/Makefile
	@-echo "	@cd $(SRC_dir) && make" >> $(APP_dir)/Makefile  # 为了方便调试
	@-echo "	# 在选择对应的调试项目，F5" >> $(APP_dir)/Makefile
	@echo "「已为apps生成makefile」"



.PHONY: clean trans 
# depend:
# 	sfmakedepend $(SOURCES)
EOF
            make
        fi
        ######################################################单一时刻同化执行，在regtest的input中生成grbtxt，
        cd ${pth_DA_Code_apps}
        chmod +x 'DA_cycle_WithWW3_ENOI'
        ./'DA_cycle_WithWW3_ENOI' '------------'${blank}${step}'.2.*.' $ThisNCfile $DA_tmp  $pth_WW3_regtest_work $line $pth_WW3_regtest_input
        ######################################################ww3_uprstr.inp，原先的restart001.ww3转换为restart.ww3，生成新的restart001.ww3，
        cd ${pth_WW3_regtest_input}
        cat >'ww3_uprstr.inp' <<"EOF"
$ -------------------------------------------------------------------- $
$ WAVEWATCH III Update Restart input file                              $
$ -------------------------------------------------------------------- $
$
$ Time of Assimilation ----------------------------------------------- $
$ - Starting time in yyyymmdd hhmmss format.
$
$ This is the assimilation starting time and has to be the same with
$ the time at the restart.ww3.
$    19680607 120000 
EOF
        echo $ThisTime >>'ww3_uprstr.inp'
        cat >>'ww3_uprstr.inp' <<"EOF"
$
$ Choose algorithm to update restart file
$  UPDN for the Nth approach
$  The UPDN*, with N<2 the same correction factor is applied at all the grid points
$   UPD0C:: ELIMINATED
$   UPDOF:: Option 0F  All the spectra are updated with a constant
$           fac=HsAnl/HsBckg.
$           Expected input: PRCNTG, as defined at fac
$   UPD1 :: ELIMINATED
$   UPDN, with N>1 each gridpoint has its own update factor.
$   UPD2 :: Option 2   The fac(x,y,frq,theta), is calculated at each grid point
$           according to HsBckg and HsAnl
$           Expected input the Analysis field, grbtxt format
$   UPD3 :: Option 3   The update factor is a surface with the shape of
$           the background spectrum.
$           Expected input the Analysis field, grbtxt format
$   UPD4 :: [NOT INCLUDED in this Version, Just keeping the spot]
$           Option 4  The generalization of the UPD3. The update factor
$           is the sum of surfaces which are applied on the background
$           spectrum. 
$           The algorithm requires the mapping of each partition on the
$           individual spectra; the map is used to determine the weighting
$           surfaces.
$           Expected input: the Analysis field, grbtxt format and the
$           functions(frq,theta) of the update to be applied.
   UPD2
$
$ PRCNTG is input for option 1 and it is the percentage of correction
$applied  to all the gridpoints (e.g. 1.)
$
   1
$
$ PRCNTG_CAP is global input for option UPD2 and UPD3 and it is a cap on the 
$ maximun correction applied to all the gridpoints (e.g. 0.5)
$ 0.5, 0, 0.001
   100
$
$ Name of the file with the SWH analysis from the DA system            $
$ suffix .grbtxt for text out of grib2 file.                           $
$
   anl.grbtxt
$
$ -------------------------------------------------------------------- $
$ WAVEWATCH III EoF ww3_uprstr.inp
$ -------------------------------------------------------------------- $
EOF
        cd ${pth_WW3_regtest_input} && cd '../../'
        ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s  ${parm_WW3_switch} \
            -r ww3_uprstr -w ${parm_WW3_work} ../model ${programGo} \
        #
        cd ${pth_WW3_regtest_work}
        mv restart001.ww3 restart.ww3
        ######################################################（废弃）uprstr.f90
        #（废弃的原因：此makefile是为了调试ww3_uprstr.ftn的程序，我已经找到了比这个更好的调试方法，记录在uprstr.xmind中）
        cd ${pth_WW3_regtest_input}
        cat >'Makefile' << "EOF"
FC = gfortran
gdb_debug = -g
FFLAGS = $(gdb_debug)
EXEC = MYuprstr

all: comp link clean

comp: MYuprstr.o

MYuprstr.o:

%.o:%.f90
	$(FC) -c  $(FFLAGS) $<


link:*.o
	$(FC) *.o -o $(EXEC) $(FFLAGS)

clean:
	rm -f *.mod *.o 

debug_ww3UPRSTR: 
	###################################
	#ls
	#cd ../ && ls
	#/1t/Data-Assimilation-for-Ocean-Current-Forecasts/WW3-6.07.1/regtests/work_eastUSA/run_test -i input -c Gnu -s Ifremer1 -r ww3_uprstr -w work /1t/Data-Assimilation-for-Ocean-Current-Forecasts/WW3-6.07.1/model work_eastUSA
	#cp /1t/Data-Assimilation-for-Ocean-Current-Forecasts/WW3-6.07.1/model/exe/ww3_uprstr /1t/Data-Assimilation-for-Ocean-Current-Forecasts/WW3-6.07.1/regtests/work_eastUSA/input/
	#cd ../../ && ./work_eastUSA/run_test -i input -c Gnu -s Ifremer1 -r ww3_uprstr -w work ../model work_eastUSA
	#cp ../../../model/exe/ww3_uprstr .
	# 去launch.json中添加调试的信息
	###################################
	cd ../ && rm -rf debug_ww3UPRSTR && mkdir -p debug_ww3UPRSTR 
	## program
	# 下面这一句使用 run_test 是为了进行编译ww3_uprstr，但是run_test还会对work中的restart进行更新，需要删除restart
	cd ../../ && ./work_eastUSA/run_test -i input -c Gnu -s Ifremer1 -r ww3_uprstr -w work ../model work_eastUSA
	cd ../work && rm -rf restart*
	# 可能会报缺少restart.ww3的错，但不影响编译和链接，故没事～～
	cp ../../../model/exe/ww3_uprstr ../debug_ww3UPRSTR
	## input
	cp ww3_uprstr.inp  ../debug_ww3UPRSTR
	cp anl.grbtxt  ../debug_ww3UPRSTR
	cp mod_def.ww3  ../debug_ww3UPRSTR
	cp restart001.ww3 ../debug_ww3UPRSTR/restart.ww3   ## 这里的restart001.ww3是20110901T010000.txt时刻ww3_shel生产的，还没有同化

EOF
        # make
        # chmod +x 'MYuprstr'
        # ./'MYuprstr' 
        ######################################################更新参数
        LastTime="${ThisTime}"
        DA_tmp=DA_tmp+1
        #########################################################
    done < ${parm_DA_cycle_timeTxt}
    #########################################################
    echo "----${blank}${step}.3 将生成的nc小时文件移动至ndbc，融合成一个大文件，"
    cd ${pth_ndbc_work}
    rm -rf ${parm_DA_Code_daOuputNc}
    mkdir -p ${parm_DA_Code_daOuputNc}
    mv `ls $pth_WW3_regtest_work*.nc `  ${pth_ndbc_work}${parm_DA_Code_daOuputNc}
    ##
    cd ${pth_ndbc_work}${parm_DA_Code_daOuputNc}
    ## merge_ndbc.m 文件已废弃，使用cdo即可，
    cat >'merge_ndbc.m' <<EOF
clc, clear all

filename='$pth_ndbc_work$parm_DA_Code_daOuputNc/DA.nc';

% clc, clear all
% datadir='/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA/nc_WithWW3_ENOI_30days/';
% filename='/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA/nc_WithWW3_ENOI_30days/ww3.2011.nc';
str = strcat('rm',32,filename)
system(str)
datadir='$pth_ndbc_work$parm_DA_Code_daOuputNc/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filelist=dir([datadir,'*.nc']); 
% the total numbers of netcdf files to be processed.
filenumber=size(filelist,1); %全部nc文件的数量

% batch reading from the netcdf file
for i=1:filenumber
    % 查阅nc相关信息
    %ncdisp(strcat(datadir,filelist(i).name),'/','min')
    %ncdisp(strcat(datadir,filelist(i).name),'/','full')
    
    % batch reading the variable to another arrays.
    ncid2=[datadir,filelist(i).name];
    
    latitude0=ncread(ncid2,'latitude'); %0.25间隔
    longitude0=ncread(ncid2,'longitude'); %0.25间隔
    tmp=ncread(ncid2,'time');
    time(i)=ncread(ncid2,'time');       % 增加了数组维数，保留信息
    tmp=ncread(ncid2,'hs'); 
    hs0(:,:,i)=ncread(ncid2,'hs'); % 增加了数组维数，保留信息。
    
    %区域纬度的选择
    latitude=latitude0;
    longitude=longitude0;
    hs=hs0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = strcat('cp',32,ncid2,32,filename)
system(str)
cid=netcdf.open(filename,'WRITE');
netcdf.reDef(cid)

%define global attributes
% netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'WAVEWATCH_III_version_number','6.07'); 


%define the variable dimension
% dimlon=netcdf.defDim(cid,'longitude',size(longitude,1));
dimlon=netcdf.inqDimID(cid,'longitude');
% dimlat=netcdf.defDim(cid,'latitude',size(latitude,1));
dimlat=netcdf.inqDimID(cid,'latitude');
% dimtime=netcdf.defDim(cid,'time',filenumber); 
tmp=netcdf.inqDimID(cid,'time');
netcdf.renameDim(cid,tmp,'time_nouse'); netcdf.inqDim(cid,tmp)
tmp=netcdf.inqVarID(cid,'time');
netcdf.renameVar(cid,tmp,'time_nouse'); netcdf.inqVar(cid,tmp)
dimtime=netcdf.defDim(cid,'time',filenumber); 
%
tmp=netcdf.inqVarID(cid,'hs');
netcdf.renameVar(cid,tmp,'hs_nouse'); netcdf.inqVar(cid,tmp)


%define the variable tybe
cid_varid_time=netcdf.defVar(cid,'time','NC_DOUBLE',dimtime); % help netcdf.defVar
% cid_varid_latitude=netcdf.defVar(cid,'latitude','NC_DOUBLE',dimlat); % NC_DOUBLE 要求的内存，基本是 NC_FLOAT 的2倍
% cid_varid_longitude=netcdf.defVar(cid,'longitude','NC_DOUBLE',dimlon);
cid_varid_hs=netcdf.defVar(cid,'hs','NC_DOUBLE',[dimlon dimlat dimtime]);

%define the variable attributes
netcdf.putAtt(cid,cid_varid_time,'long_name','julian day (UT)');
netcdf.putAtt(cid,cid_varid_time,'standard_name','time');
netcdf.putAtt(cid,cid_varid_time,'calendar','standard');
netcdf.putAtt(cid,cid_varid_time,'units','days since 1990-01-01 00:00:00');
netcdf.putAtt(cid,cid_varid_time,'conventions','relative julian days with decimal part (as parts of the day )');
netcdf.putAtt(cid,cid_varid_time,'axis','T');

% netcdf.putAtt(cid,cid_varid_latitude,'units','degree_north');
% netcdf.putAtt(cid,cid_varid_latitude,'long_name','latitude');
% netcdf.putAtt(cid,cid_varid_latitude,'standard_name','latitude');
% netcdf.putAtt(cid,cid_varid_latitude,'axis','Y');

% netcdf.putAtt(cid,cid_varid_longitude,'units','degree_east');
% netcdf.putAtt(cid,cid_varid_longitude,'long_name','longitude');
% netcdf.putAtt(cid,cid_varid_longitude,'standard_name','longitude');
% netcdf.putAtt(cid,cid_varid_longitude,'axis','X');

netcdf.putAtt(cid,cid_varid_hs,'units','m');
netcdf.putAtt(cid,cid_varid_hs,'long_name','significant height of wind and swell waves');
netcdf.putAtt(cid,cid_varid_hs,'standard_name','sea_surface_wave_significant_height');
netcdf.putAtt(cid,cid_varid_hs,'globwave_name','significant_wave_height');
netcdf.putAtt(cid,cid_varid_hs,'_FillValue',-32767);
% netcdf.putAtt(cid,cid_varid_hs,'scale_factor',0.002);
netcdf.putAtt(cid,cid_varid_hs,'add_offset',0);
netcdf.putAtt(cid,cid_varid_hs,'valid_min',min(hs(:)));
netcdf.putAtt(cid,cid_varid_hs,'valid_max',max(hs(:)));





%end define the varible and attributes
netcdf.endDef(cid);


%write variables value to merged netcdf file
netcdf.putVar(cid,cid_varid_time,time);
% netcdf.putVar(cid,cid_varid_latitude,latitude);
% netcdf.putVar(cid,cid_varid_longitude,longitude);
% netcdf.putVar(cid,cid_varid_hs,hs*0.002);
netcdf.putVar(cid,cid_varid_hs,hs);


% 添加存储空间属性
netcdf.reDef(cid); %data mode 不能进行使用 putAtt，故进入 def mode；
lst=dir(filename); xi=lst.bytes;
netcdf.putAtt(cid,netcdf.getConstant('NC_GLOBAL'),'space size',strcat(num2str(xi/1024/1024),'Mb'));
%ncdisp(filename,'/','full');

% end %%%%%%%%%%
netcdf.close(cid);



%%%%
% a=ncread('ww3.2011.nc','hs')
% b=ncread('ww3.20110901T00Z.nc','hs')
% c=ncread('ww3.20110901T01Z.nc','hs')

EOF
    # ${pth_matlab} -nodisplay -r "merge_ndbc; exit;" \

    #########################################################
fi

## 假设restart.ww3文件包含背景场信息，？

##
echo '├──「FAQ，解决，手册上的」WDA流程，'


##
echo '├──「FAQ，？？？」怎么写ww3_uprstr.inp？'
# 手册
#       1、WDA流程图，
# 看老师的文件，看不了，是2进制文件；
# 看regtest，
#       1、进regtest，搜索ww3_uprstr.inp，ok！！，位于ww3_ta1，
#       2、run_test中有吗？有～
#       3、寻求解决05-10，已经对其中的每个input文件生成了对应的work文件夹，SWITCH选择了T，可查看ang,back,in～～
#          失败，；
# 验证方法，NOWW3和WithWW3有一个同化时刻是相同的～
#       2、ww3_uprstr.inp？后得到的第二时刻nc文件，与Xb.grbtxt数据相差很多～～？？？？？？？？？？？？？？？？？？？？？
#               原因可能是还需要再运行下一次同化的shel，这样改变的restart.ww3才能生成同化后的nc，
#       1、以第二时刻为同化时刻，Xb.grbtxt数据和NOWW3得到的第二时刻数据极其相近，通过此验证，


##
echo '├──「FAQ，解决，txt存储」ENOI的NN怎么搞？？'


## 
echo '├──「FAQ，解决」WW3小时nc 文件合并，？？'
# 思路1：从原来文件复制粘贴，改变维度？失败
# 思路2：完全重新，超界限，NAN导致的？..，ok

##
echo '├──「FAQ，？？？读取和输入restrat，老师提供的.f90'
# 1、读取生成的MAPSTA，和MATLAB读取NC文件中的MAPSTA怎么不一致？
# 2、参数的意思不知道～～


##
echo '├──「FAQ，？？？修改uprstrt的ftn源代码怎么样？？'
# 0、可以先保存一个副本。(OK，copy版本)
# 1、很多参数不知道。（需要调试进行输出，write查看）
# 2、不知道怎么调试代码，涉及到整个WW3的代码。（makefile添加调试目标，再创建一个ww3_uprstrt调试文件夹，
#                                        可设置gdb调试，但断点没用呀，write进行查看吧，
#                                        至少设置的gdb调试F5就可以很快运行～～）
# 3、.ftn文件fortran的语法高亮怎么解决？（解决，原来VSC右下角可以自己设置）
# 4、生成的BCKG_UPD2.txt的矩阵和nc文件的背景场矩阵不一样？（WHY？？？？？？？？？？？？？？）
#       ww3_ounf中找到突破点，(建立调试环境《makefile，run_test，ww3_ounf，WPS-PDF明确需要文件，VSC的cppdg.》)

 ##
echo '├──「FAQ，？？？」format格式化？？'





############################################################################################################
############################################################################################################
bannerSimple "Data assimilation analysis - ndbc_WithWW3_ENOI " "*"
declare -i ndbc_WithWW3_ENOI_ana
ndbc_WithWW3_ENOI_ana=0       ## ～tag，新建文件需要修改～
# 在进行这一步之前需要将此同化生成的文件夹内的相关文件放在nc文件夹，重命名，
#   1、删除每个小时的nc文件 （可选）
#   2、删除.m文件  （可选）
#   3、nc 文件夹中的nc名称只能有一个点，且不能与worktable中的属性相同（否则会覆盖信息） （保留）
#   4、文件夹中的nc至少是2个；  （废弃）

if (( ndbc_WithWW3_ENOI_ana == 1 )); then
    # parm_DA_Code_daOuputNc='nc_WithWW3_ENOI_30days'  ## ～tag，新建文件需要修改～
    parm_ndbc_station_downloadFlag=0      ## 优先级1 ～tag，新建文件需要修改～
    parm_ndbc_create_new_work_table=0     ## 优先级1 ～tag，新建文件需要修改～      
    parm_ndbc_num2buoynum=0               ## 优先级2 ～tag，新建文件需要修改～ 
    parm_ndbc_buoynum2num=0               ## 优先级2 ～tag，新建文件需要修改～ 
    parm_ndbc_Index1_yo=0                 ## 优先级3 ～tag，新建文件需要修改～      用于同化  
                                            ##（自己在程序重新低效率match，还需要调参数，运行很慢，不建议）
    parm_ndbc_match=0                     ## 优先级3 ～tag，新建文件需要修改～      用于浮标与背景场的比较
    parm_ndbc_match_spinup=1              ## 优先级4 ～tag，新建文件需要修改～ 
    parm_ndbc_match_Index1_yo=0           ## 优先级4 ～tag，新建文件需要修改～
                                            ## 建议用此方法实现Index1_yo的同化，运行很快，
    #########################################################
    # rm -rf ${pth_ndbc_work}'nc/'
    # cp -r ${pth_ndbc_work}${parm_DA_Code_daOuputNc}  ${pth_ndbc_work}'nc'
    # cd ${pth_ndbc_work}'nc/'
    ##########################################################
    # cd ${pth_ndbc_work}
    ##########################################################
    # cd ${pth_ndbc_work} 
    # ${pth_matlab} -nodisplay -r "path_save='${pth_ndbc_work}'; path_source='${pth_ndbc_source}'; path_mmap='${pth_ndbc_mmap}'; create_new_work_table=${parm_ndbc_create_new_work_table};ndbc_station_downloadFlag=${parm_ndbc_station_downloadFlag};match_Index1_yo=${parm_ndbc_match};Index1_yo=${parm_ndbc_Index1_yo};${programGo};exit;" \
    cd ${pth_ndbc_work} 
    ${pth_matlab} -nodisplay -r "path_save='${pth_ndbc_work}'; path_source='${pth_ndbc_source}'; path_mmap='${pth_ndbc_mmap}'; create_new_work_table=${parm_ndbc_create_new_work_table};ndbc_station_downloadFlag=${parm_ndbc_station_downloadFlag};match=${parm_ndbc_match};Index1_yo=${parm_ndbc_Index1_yo};mat_num2buoynum=${parm_ndbc_num2buoynum};mat_buoynum2num=${parm_ndbc_buoynum2num};match_spinup=${parm_ndbc_match_spinup};Match_Index_yo=${parm_ndbc_match_Index1_yo};${programGo};exit;" \ 
    
fi





# structure4: 矩形网格+ERA5风场+WW3+cfosat+ENOI同化
############################################################################################################
############################################################################################################
bannerSimple "Data assimilation preparing && Background analysis - cfosat" "*"
declare -i cfosat
cfosat=0                               ## ～tag，新建文件需要修改～  ，一般设置为1,后面的程序会用到这里的.m程序，
pth_cfosat=${pth_OceanForecast}'CFOSAT/'
pth_cfosat_source=${pth_cfosat}'source/'
pth_cfosat_work=${pth_cfosat}${programGo}'/'  && mkdir -p ${pth_cfosat_work}

if (( cfosat == 1 )); then
    #################################3
    parm_cfosat_match=0      ## 优先级1 ～tag，新建文件需要修改～
        ## cfosat_oper_swi_l2_*.nc 中 nadir_swh_box 时间序列与矩形格点时空匹配，
            ## % 去除value 为 nan 的数据
            ## % 去除lat, lon 不在区域的数据
            ## % lat 匹配的 nclat， % lon 匹配的 nclon   (空间匹配)
            ## % 在H矩阵的索引
            ## % time 匹配的 nctime     （时间匹配）
            ## % 经过错位的时间和空间，很可能会出现多个数据时空一致但值不同的情况，可采取均一化处理
        ## 保存在一个.mat 中，变量名称为 newTable 
    parm_cfosat_match_Index1_yo=0           ## 优先级2 ～tag，新建文件需要修改～
        ## 将 parm_cfosat_match=1 生成的.mat文件相关数据输出到Index1和yo文件夹；
            ## 生成的文件夹需要放在ndbc文件部分，再进行同化；
    #################################3
    cd ${pth_cfosat_work}
    cat >${programGo}'.m' <<EOF
% author:
%    liu jin can, UPC

% path_save = '/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/cfosat/work_eastUSA/'; %work工作目录路径，最后必须是'/'
path_save
cd(path_save)
path_source
% addpath '/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/cfosat/source'
addpath(path_source)

match
if(match==1) 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    path_CFO_OPER_SWI_L2 = strcat(path_save,'swim_l2_op05/');  %%放入的nc数据应该是所想研究时间段内的数据
    lat_max = 48;  % 纬度为负数，表示南纬
    lat_min = 33;
    lon_max = -57; % 经度为负数，表示西经
    lon_min = -77;
    lat = lat_min:0.125:lat_max;
    lon = lon_min:0.125:lon_max;
    match_CFO_OPER_SWI_L2(path_save,path_CFO_OPER_SWI_L2,lat,lon,'swim_l2_op05_nadir_swh_box'...  % .mat 名称
        ,'nadir_swh_box','time_nadir_l2',...  % 用到的变量
        'lat_nadir_l2','lon_nadir_l2','2009-01-01 00:00:00');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%
Match_Index_yo
if(Match_Index_yo==1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ndbc_start_datetime=datetime('2018-09-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss');
    % path_save = '/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA_2/';
    cd(path_save)
    system('rm -rf Index1')
    system('rm -rf yo')
    mkdir('Index1')
    mkdir('yo')
    cfosat_match_Index1_yo(path_save,...
        'swim_l2_op05_nadir_swh_box'... % .mat文件名称
        );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%
EOF
    #################################3
    cd ${pth_cfosat_work} 
    ${pth_matlab} -nodisplay -r "path_save='${pth_cfosat_work}'; path_source='${pth_cfosat_source}'; match=${parm_cfosat_match};Match_Index_yo=${parm_cfosat_match_Index1_yo};${programGo};exit;" 
    
fi







############################################################################################################
############################################################################################################
bannerSimple "wind nc create  - era5_wind" "*"
declare -i era5_wind
era5_wind=0                               ## ～tag，新建文件需要修改～  ，一般设置为1,后面的程序会用到这里的.m程序，


if (( era5_wind == 1 )); then
    #################################
    parm_era5_wind_download=0   ## 优先级1 ～tag，新建文件需要修改～
        ## 从ECMWF, CDS, 下载相关数据，
            ## 注册
        ## 网页下载nc，single level, 
        ## python程序下载nc，
            ## 程序有两个，位于ERA5/source，download_era5_China_nanhai_1979_2020.py 和 download_era5_China_nanhai_1958_1978.py
            ## anaconda（环境搭建、包管理）+pycharm (运行、调试)， 
            ##        包管理，需要科学上网。
            ##              Linux、Ubuntu中nohup的使用和关闭  https://blog.csdn.net/qq_36079986/article/details/110294300
            ##              pip install cdsapi
            ##              pip install python-dateutil     https://blog.csdn.net/m0_52625549/article/details/124599093
            ##              软件和更新的源更换？
            ##              Exception: Missing/incomplete configuration file: /home/jincanliu/.cdsapirc    https://blog.csdn.net/hulihutudewo/article/details/123020199
            ##        运行程序时，一定要知道在哪个环境运行的，pycharm中会显示～
            ##
            ##        「OK」将anaconda虚拟环境打包并移动到不同的服务器上，https://blog.csdn.net/Lcz971209/article/details/124164138
            ##              1、本地环境迁移（要求二者的操作系统一致）：py-ev-ERA5 的本地环境，放在了 ERA5/py-ev-ERA5， 接下来的操作看 https://blog.csdn.net/Lcz971209/article/details/124164138
            ##                      source activate py-ev-ERA5 出错，用conda activate py-ev-ERA5
            ##              2、在线环境迁移：提供一个安装列表，这些列表包含了原环境中所有的包。
            ##                      详细过程看 https://blog.csdn.net/Lcz971209/article/details/124164138
            ##
        ## 「OK」pycharm debug
            ##        pycharm下debug详解， https://blog.csdn.net/weixin_42375937/article/details/122946695

    parm_era5_wind_merge=0    ## 优先级2 ～tag，新建文件需要修改～
        ## 使用cdo命令， cdo -b F32  mergetime ERA5_202007.nc ERA5_202008.nc wind.nc  （推荐）
        ##            
        ## 
        ## 自己编写的*merge.mc命令，（又要重新编写一次，因为ERA5和CCMP下载的数据是不一样的），很麻烦～ （不建议）
    
    #parm_wind_ww3=0     ## 优先级？ （已废弃） ～tag，新建文件需要修改～
        ## 将wind.nc转换成可以让ww3_prnc.nml正常运行的文件，

    parm_era5_wind_latitude_reversed=0  ##优先级3, ～tag，新建文件需要修改～
        ## 合并后，ww3_prnc.nml 运行会出错，因为ERA5（ECMWF）的latitude需要reversed；
        ## nco解决;
        ##      ncpdq -h -O -a -latitude （纬度变量） wind.nc （原文件） wind_ndpdh.nc （新文件）

        ## 运行ww3_prnc时需修改为u10, v10


    #################################
fi






############################################################################################################
############################################################################################################
bannerSimple "wind nc ww3" "*"
declare -i wind_to_ww3
wind_to_ww3=0             ##（废弃，原文件夹wind_to_ww3仍然保留） ～tag，新建文件需要修改～ 
    ## 将wind.nc转换成可以让ww3_prnc.nml正常运行的文件，
    ## 废弃原因，对于ERA5风场，具体分析了ww3_prnc失败原因，是latitude需要reversed，nco解决；

pth_wind_to_ww3=${pth_OceanForecast}'wind_to_ww3/'
if (( wind_to_ww3 == 1 )); then
    #####################################
    ## 优先级1, 将wind.nc放进wind_to_ww3/文件夹
    
    #####################################
    cd ${pth_wind_to_ww3}

fi



# structure5: 矩形网格嵌套 =1
##########################################################################################################
###########################################################################################################
bannerSimple "grid preprocessor - ww3_multi_nml" "*"
declare -i ww3_multi_nml
ww3_multi_nml=0              ## ～tag，新建文件需要修改～

if (( ww3_multi_nml == 1 )); then
    ###################################################
    cd ${pth_WW3_regtest_input}
    cat >'ww3_multi.nml' <<EOF
! -------------------------------------------------------------------- !
! WAVEWATCH III - ww3_multi.nml - multi-grid model                     !
! -------------------------------------------------------------------- !
! 默认设置位于model/nml;
! regtests/mww3_test_03 有参考的例子；
!
! -------------------------------------------------------------------- !
! Define top-level model parameters via DOMAIN_NML namelist
!
! * IOSTYP defines the output server mode for parallel implementation.
!             0 : No data server processes, direct access output from
!                 each process (requires true parallel file system).
!             1 : No data server process. All output for each type 
!                 performed by process that performs computations too.
!             2 : Last process is reserved for all output, and does no
!                 computing.
!             3 : Multiple dedicated output processes.
!
! * namelist must be terminated with /
! * definitions & defaults:
!     DOMAIN%NRINP  =  0  ! Number of grids defining input fields.
!     DOMAIN%NRGRD  =  1  ! Number of wave model grids.
!     DOMAIN%UNIPTS =  F  ! Flag for using unified point output file.
!     DOMAIN%IOSTYP =  1  ! Output server type
!     DOMAIN%UPPROC =  F  ! Flag for dedicated process for unified point output.
!     DOMAIN%PSHARE =  F  ! Flag for grids sharing dedicated output processes.
!     DOMAIN%FLGHG1 =  F  ! Flag for masking computation in two-way nesting
!     DOMAIN%FLGHG2 =  F  ! Flag for masking at printout time
!     DOMAIN%START  = '19680606 000000'  ! Start date for the entire model 
!     DOMAIN%STOP   = '19680607 000000'  ! Stop date for the entire model
!
! -------------------------------------------------------------------- !
&DOMAIN_NML
  DOMAIN%NRINP  =  1
  DOMAIN%NRGRD  =  3
  DOMAIN%UNIPTS =  T
  DOMAIN%PSHARE =  T
  DOMAIN%FLGHG1 =  T
  DOMAIN%FLGHG2 =  T
  DOMAIN%START  = '20200728 000000'
  DOMAIN%STOP   = '20200816 000000'
/



! -------------------------------------------------------------------- !
! Define each input grid via the INPUT_GRID_NML namelist
!
! * index I must match indexes from 1 to DOMAIN%NRINP
! * INPUT(I)%NAME must be set for each active input grid I
！  
!
! * namelist must be terminated with /
! * definitions & defaults:
!     INPUT(I)%NAME                  = 'unset'
!     INPUT(I)%FORCING%WATER_LEVELS  = F
!     INPUT(I)%FORCING%CURRENTS      = F
!     INPUT(I)%FORCING%WINDS         = F
!     INPUT(I)%FORCING%ATM_MOMENTUM  = F
!     INPUT(I)%FORCING%AIR_DENSITY   = F
!     INPUT(I)%FORCING%ICE_CONC      = F
!     INPUT(I)%FORCING%ICE_PARAM1    = F
!     INPUT(I)%FORCING%ICE_PARAM2    = F
!     INPUT(I)%FORCING%ICE_PARAM3    = F
!     INPUT(I)%FORCING%ICE_PARAM4    = F
!     INPUT(I)%FORCING%ICE_PARAM5    = F
!     INPUT(I)%FORCING%MUD_DENSITY   = F
!     INPUT(I)%FORCING%MUD_THICKNESS = F
!     INPUT(I)%FORCING%MUD_VISCOSITY = F
!     INPUT(I)%ASSIM%MEAN            = F
!     INPUT(I)%ASSIM%SPEC1D          = F
!     INPUT(I)%ASSIM%SPEC2D          = F
!
!
! -------------------------------------------------------------------- !
&INPUT_GRID_NML
  INPUT(1)%NAME                  = 'wind'
  INPUT(1)%FORCING%WINDS         = T
/



! -------------------------------------------------------------------- !
! Define each model grid via the MODEL_GRID_NML namelist
!
! * index I must match indexes from 1 to DOMAIN%NRGRD
! * MODEL(I)%NAME must be set for each active model grid I
! * FORCING can be set as : 
!    - 'no'          : This input is not used.
!    - 'native'      : This grid has its own input files, e.g. grid
!                      grdX (mod_def.grdX) uses ice.grdX.
!    - 'INPUT%NAME'  : Take input from the grid identified by
!                      INPUT%NAME.
! * RESOURCE%RANK_ID : Rank number of grid (internally sorted and reassigned).
! * RESOURCE%GROUP_ID : Group number (internally reassigned so that different
!                                     ranks result in different group numbers).
! * RESOURCE%COMM_FRAC : Fraction of communicator (processes) used for this grid.
! * RESOURCE%BOUND_FLAG : Flag identifying dumping of boundary data used by this
!                         grid. If true, the file nest.MODID is generated.
!
! * Limitations relevant to irregular (curvilinear) grids:
!   1) Equal rank is not supported when one or more is an irregular
!       grid. Use non-equal rank instead. (see wmgridmd.ftn)
!   2) Non-native input grids: feature is not supported when either
!      an input grid or computational grids is irregular.
!      (see wmupdtmd.ftn)
!   3) Irregular grids with unified point output: This is supported
!      but the feature has not been verified for accuracy.
!      (see wmiopomd.ftn)
!
! * namelist must be terminated with /
! * definitions & defaults:
!     MODEL(I)%NAME                  = 'unset'
!     MODEL(I)%FORCING%WATER_LEVELS  = 'no'
!     MODEL(I)%FORCING%CURRENTS      = 'no'
!     MODEL(I)%FORCING%WINDS         = 'no'
!     MODEL(I)%FORCING%ATM_MOMENTUM  = 'no'
!     MODEL(I)%FORCING%AIR_DENSITY   = 'no'
!     MODEL(I)%FORCING%ICE_CONC      = 'no'
!     MODEL(I)%FORCING%ICE_PARAM1    = 'no'
!     MODEL(I)%FORCING%ICE_PARAM2    = 'no'
!     MODEL(I)%FORCING%ICE_PARAM3    = 'no'
!     MODEL(I)%FORCING%ICE_PARAM4    = 'no'
!     MODEL(I)%FORCING%ICE_PARAM5    = 'no'
!     MODEL(I)%FORCING%MUD_DENSITY   = 'no'
!     MODEL(I)%FORCING%MUD_THICKNESS = 'no'
!     MODEL(I)%FORCING%MUD_VISCOSITY = 'no'
!     MODEL(I)%ASSIM%MEAN            = 'no'
!     MODEL(I)%ASSIM%SPEC1d          = 'no'
!     MODEL(I)%ASSIM%SPEC2d          = 'no'
!     MODEL(I)%RESOURCE%RANK_ID      = I
!     MODEL(I)%RESOURCE%GROUP_ID     = 1
!     MODEL(I)%RESOURCE%COMM_FRAC    = 0.00,1.00
!     MODEL(I)%RESOURCE%BOUND_FLAG   = F
!
!     MODEL(4)%FORCING = 'no' 'no' 'no' 'no' 'no' 'no'
!
!     MODEL(2)%RESOURCE = 1 1 0.00 1.00 F
! -------------------------------------------------------------------- !
&MODEL_GRID_NML

  MODEL(1)%NAME                  = 'grd1'
  MODEL(1)%FORCING%WINDS         = 'wind'
  MODEL(1)%RESOURCE%RANK_ID      = 1

  MODEL(2)%NAME                  = 'grd2'
  MODEL(2)%FORCING%WINDS         = 'wind'
  MODEL(2)%RESOURCE%RANK_ID      = 2


  MODEL(3)%NAME                  = 'grd3'
  MODEL(3)%FORCING%WINDS         = 'wind'
  MODEL(3)%RESOURCE%RANK_ID      = 3
/


! -------------------------------------------------------------------- !
! Define the output types point parameters via OUTPUT_TYPE_NML namelist
!
! * index I must match indexes from 1 to DOMAIN%NRGRD
!
! * ALLTYPE will apply the output types for all the model grids
!
! * ITYPE(I) will apply the output types for the model grid number I
!
! * need DOMAIN%UNIPTS equal true to use a unified point output file
!
! * the point file is a space separated values per line :
!   longitude latitude 'name' (C*40)
!
! * the detailed list of field names is given in model/nml/ww3_shel.nml :
!  DPT CUR WND AST WLV ICE IBG TAU RHO D50 IC1 IC5
!  HS LM T02 T0M1 T01 FP DIR SPR DP HIG
!  EF TH1M STH1M TH2M STH2M WN
!  PHS PTP PLP PDIR PSPR PWS PDP PQP PPE PGW PSW PTM10 PT01 PT02 PEP TWS PNR
!  UST CHA CGE FAW TAW TWA WCC WCF WCH WCM FWS
!  SXY TWO BHD FOC TUS USS P2S USF P2L TWI FIC USP TOC
!  ABR UBR BED FBB TBB
!  MSS MSC WL02 AXT AYT AXY
!  DTD FC CFX CFD CFK
!  U1 U2 
!
! * output track file formatted (T) or unformated (F)
!
! * namelist must be terminated with /
! * definitions & defaults:
!     ALLTYPE%FIELD%LIST         =  'unset'
!     ALLTYPE%POINT%NAME         =  'unset'
!     ALLTYPE%POINT%FILE         =  'points.list'
!     ALLTYPE%TRACK%FORMAT       =  T
!     ALLTYPE%PARTITION%X0       =  0
!     ALLTYPE%PARTITION%XN       =  0
!     ALLTYPE%PARTITION%NX       =  0
!     ALLTYPE%PARTITION%Y0       =  0
!     ALLTYPE%PARTITION%YN       =  0
!     ALLTYPE%PARTITION%NY       =  0
!     ALLTYPE%PARTITION%FORMAT   =  T
!
!     ITYPE(3)%TRACK%FORMAT      =  F
! -------------------------------------------------------------------- !
&OUTPUT_TYPE_NML
  ALLTYPE%FIELD%LIST     = 'HS'
/



! -------------------------------------------------------------------- !
! Define output dates via OUTPUT_DATE_NML namelist
!
! * index I must match indexes from 1 to DOMAIN%NRGRD
! * ALLDATE will apply the output dates for all the model grids
! * IDATE(I) will apply the output dates for the model grid number i
! * start and stop times are with format 'yyyymmdd hhmmss'
! * if time stride is equal '0', then output is disabled
! * time stride is given in seconds
! * it is possible to overwrite a global output date for a given grid
!
! * namelist must be terminated with /
! * definitions & defaults:
!     ALLDATE%FIELD%START         =  '19680606 000000'
!     ALLDATE%FIELD%STRIDE        =  '0'
!     ALLDATE%FIELD%STOP          =  '19680607 000000'
!     ALLDATE%POINT%START         =  '19680606 000000'
!     ALLDATE%POINT%STRIDE        =  '0'
!     ALLDATE%POINT%STOP          =  '19680607 000000'
!     ALLDATE%TRACK%START         =  '19680606 000000'
!     ALLDATE%TRACK%STRIDE        =  '0'
!     ALLDATE%TRACK%STOP          =  '19680607 000000'
!     ALLDATE%RESTART%START       =  '19680606 000000'
!     ALLDATE%RESTART%STRIDE      =  '0'
!     ALLDATE%RESTART%STOP        =  '19680607 000000'
!     ALLDATE%BOUNDARY%START      =  '19680606 000000'
!     ALLDATE%BOUNDARY%STRIDE     =  '0'
!     ALLDATE%BOUNDARY%STOP       =  '19680607 000000'
!     ALLDATE%PARTITION%START     =  '19680606 000000'
!     ALLDATE%PARTITION%STRIDE    =  '0'
!     ALLDATE%PARTITION%STOP      =  '19680607 000000'
!     
!     ALLDATE%RESTART             =  '19680606 000000' '0' '19680607 000000'
!
!     IDATE(3)%PARTITION%START    =  '19680606 000000' 
! -------------------------------------------------------------------- !
&OUTPUT_DATE_NML
  ALLDATE%FIELD%START         = '20200729 000000'
  ALLDATE%FIELD%STRIDE        = '3600'
  ALLDATE%FIELD%STOP          = '20200815 180000'
/



! -------------------------------------------------------------------- !
! Define homogeneous input via HOMOG_COUNT_NML and HOMOG_INPUT_NML namelist
!
! * the number of each homogeneous input is defined by HOMOG_COUNT
! * the total number of homogeneous input is automatically calculated
! * the homogeneous input must start from index 1 to N
! * if VALUE1 is equal 0, then the homogeneous input is desactivated
! * NAME can only be MOV
! * each homogeneous input is defined over a maximum of 3 values detailled below :
!     - MOV is defined by speed and direction
!
! * namelist must be terminated with /
! * definitions & defaults:
!     HOMOG_COUNT%N_MOV             =  0
!
!     HOMOG_INPUT(I)%NAME           =  'unset'
!     HOMOG_INPUT(I)%DATE           =  '19680606 000000'
!     HOMOG_INPUT(I)%VALUE1         =  0
!     HOMOG_INPUT(I)%VALUE2         =  0
!     HOMOG_INPUT(I)%VALUE3         =  0
! -------------------------------------------------------------------- !
&HOMOG_COUNT_NML

/

&HOMOG_INPUT_NML

/


! -------------------------------------------------------------------- !
! WAVEWATCH III - end of namelist                                      !
! -------------------------------------------------------------------- !
EOF
    ###################################################
fi




############################################################################################################
############################################################################################################
bannerSimple "FAQ" "*"
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
#       4、优点，很方便对模块是否运行1/0进行修改～～，

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
# 软链接原文件名称改变，软链接失效，出现另一个名称相同的文件代替，软链接仍有效，～～


##
echo '├──「FAQ，？？？」restart.ww3在哪里生成的，～～'

##
echo '├──「FAQ，？？？」手册中的ww3_*你真的了解作用是什么了吗？，～～'

##
echo '├──「FAQ，？？？」手册模式的并行？，～～'

##
echo '├──「FAQ，？？？」ndbc work.m 过程碰到的问题'
# fprintf('work_eastUSA.m \n')
# fprintf('├──「FAQ」VScode中编辑matlab（代码高亮、语言检查、代码补全），运行matlab， \n')
# fprintf('   「解决方法一」在VSCode中编写和运行Matlab脚本VScode中关于matlab的扩展， https://zhuanlan.zhihu.com/p/409708835 \n')
# fprintf('           ├──「安装扩展Matlab」完全按照操作，成功，setting.json设置的是R2021b的版本 \n')
# fprintf('              「FAQ」每次保存.m文件，VScode会跳出来一个MATLAB图像 \n')
# fprintf('           ├──「安装扩展Matlab Interactive Terminal 」完全按照操作，成功， \n')
# fprintf('              「FAQ」运行很久的程序，在运行过程中交互终端一直不显示输出，不会是在最后统一输出吗？ \n')
# fprintf('   「解决方法二」使用vscode编辑并运行matlab脚本， https://zhuanlan.zhihu.com/p/395486395 \n')
# fprintf('           ├──「安装扩展Matlab formatter」，\n')
# fprintf('├──「FAQ，失败」Fortran读取mat文件， \n')
# fprintf('   「解决方法？，难搞」帮助中心，外部语言接口，https://ww2.mathworks.cn/help/matlab/external-language-interfaces.html?s_tid=CRUX_lftnav，\n')
# fprintf('               从 Fortran 调用 MATLAB, https://ww2.mathworks.cn/help/matlab/matlab-api-for-fortran.html ,\n ')
# fprintf('               用于读取 MAT 文件数据的 MATLAB Fortran API, https://ww2.mathworks.cn/help/matlab/Fortran-applications-to-read-mat-file-data.html ,\n ')
# fprintf('               一个例子，http://matlab.izmiran.ru/help/techdoc/matlab_external/ch01in12.html')
# fprintf('   「解决方法？」matlab 文件打开方式,mex文件和mat文件打开方式，https://blog.csdn.net/weixin_42527178/article/details/116437390?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~aggregatepage~first_rank_ecpm_v1~rank_v31_ecpm-11-116437390.pc_agg_new_rank&utm_term=fortran%E8%AF%BB%E5%8F%96mat%E6%95%B0%E6%8D%AE%E7%B1%BB%E5%9E%8B&spm=1000.2123.3001.4430')
# fprintf('   「解决方法？」大型数据，用netcdf格式传递数据，https://tieba.baidu.com/p/2751695821,\n')
# fprintf('   「解决方法？」C++读写.mat文件, https://blog.csdn.net/left_la/article/details/8206645  ,\n')
# fprintf('              C程序读取.mat格式的Matlab数据文件,https://blog.csdn.net/CGeorge003/article/details/52415101  ,\n')
# % http://www.uwenku.com/question/p-uwaunarh-xc.html
# fprintf('├──「工作目录」/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA/\n')
# fprintf('├──「FAQ」H矩阵的生成，背景场数据，观测数据怎么作为输入给到ENOI？ \n')


##
echo '├──「FAQ，OK」Shell编程--通配符[ * ? () [] {} \]'
# https://blog.csdn.net/qq_26129413/article/details/111334369?spm=1001.2101.3001.6650.4&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-4-111334369-blog-106429247.pc_relevant_default&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-4-111334369-blog-106429247.pc_relevant_default&utm_relevant_index=5    ,,
# 

##
echo '├──「FAQ，成功」Shell编程--批处理转移重新命名'
# https://blog.csdn.net/mrqingyu/article/details/112626802      shell命令行下批量重命名文件, 批量修改文件名, 批量替换文件名, command（推荐第三种）
# https://blog.csdn.net/weixin_34792402/article/details/116883926       linux shell rename
# https://blog.csdn.net/weixin_33695450/article/details/85671341?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-0.pc_relevant_antiscanv2&spm=1001.2101.3001.4242.1&utm_relevant_index=3,       


##
echo '├──「FAQ，成功」Linux：结合cat和EOF输出到文本文件'
# https://blog.csdn.net/liangbilin/article/details/108585395
# https://www.cnblogs.com/sanduzxcvbnm/p/14638070.html,  shell下cat EOF中变量$处理

##
echo '├──「FAQ，成功」linux一列的形式查看文件,linux shell ls -1 列显示文件'
# https://blog.csdn.net/weixin_30358181/article/details/116690773   -1


##
echo '├──「FAQ，成功」shell统计当前文件夹下的文件个数、目录个数'
# https://blog.csdn.net/W_E_DAY/article/details/122140364