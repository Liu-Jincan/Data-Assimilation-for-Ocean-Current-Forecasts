## 
## 
programGo='work_eastUSA'   ## ～tag，新建文件需要修改～
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
pth_OceanForecast='/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/'  ## ～tag，新建文件需要修改～
pth_matlab='/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/matlab'
# blank
blank="----step."
echo '----step.0 新建program或者修改program时，根据《～tag，新建文件需要修改～》检索需要修改的位置；VSC的整个文件的浏览拖动在修改时也很好用，但是需要绿色行；'

# 整型
declare -i step #声明是整型
step=0

##########################################################################################################
###########################################################################################################
bannerSimple "grid create - Gridgen" "*"
pth_Gridgen=${pth_OceanForecast}'TUTORIAL_GRIDGEN/'
echo pth_Gridgen
declare -i Gridgen
Gridgen=1  ## ～tag，新建文件需要修改～
gridgen_objectGrid='east-USA_P25_3'   ## ～tag，新建文件需要修改～
gridgen_objectGrid_nml="gridgen.${gridgen_objectGrid}.nml"
gridgen_m=${programGo}".m"
gridgen_baseGrid='east-USA_P25_4'   ## ～tag，新建文件需要修改～
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
    echo "--------${blank}${step}.1.2 在area文件夹下创建program在gridgen对应的gridgen_m，并运行该m文件，"\
        "运行完成后，create_grid()会在data文件夹生成5个文件（.bot、.mask_nobound、.meta、.obst、.nml），"\
        "个人使用sh附加在data文件夹生成.out文件记录m文件运行过程，"
    cd ${pth_Gridgen}'area'
    cat >${gridgen_m} <<EOF
% disp('hello, world!')
% disp(argument1)
create_grid(pth_gridgen_objectGrid_nml)
EOF
    ${pth_matlab} -nodisplay -r  \
        "argument1=10010; pth_gridgen_objectGrid_nml='${pth_Gridgen}namelist/${gridgen_objectGrid_nml}'; ${programGo}; exit;" \
        >${pth_Gridgen}'data/'${gridgen_objectGrid}'.out' 2>&1
    ########################################################
    echo "--------${blank}${step}.1.3 在namelist文件夹下创建，基础网格对应的gridgen_baseGrid_nml，(～tag，新建文件需要修改～)，"\
        "（为了在海陆掩码上增加活动边界，还需创建一个基础网格）。"  ##(～tag，新建文件需要修改～)
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
    echo "--------${blank}${step}.1.4 重置在area文件夹下program对应的gridgen_m，基础网格，运行该m文件，"\
        "运行完成后，create_grid()会在data文件夹生成5个文件（.bot、.mask_nobound、.meta、.obst、.nml），"\
        "个人使用sh附加在data文件夹生成.out文件记录m文件运行过程，"
    cd ${pth_Gridgen}'area'
    cat >${gridgen_m} <<EOF
create_grid(pth_gridgen_baseGrid_nml)
EOF
    ${pth_matlab} -nodisplay -r  \
        "pth_gridgen_baseGrid_nml='${pth_Gridgen}namelist/${gridgen_baseGrid_nml}'; ${programGo}; exit;" \
        >${pth_Gridgen}'data/'${gridgen_baseGrid}'.out' 2>&1
    ####################################################
    echo "----${blank}${step}.2 create_boundary()，重置在area文件夹下program对应的gridgen_m，运行该m文件，"\
        "运行完成后，create_boundary()会在data文件夹生成3个文件（.fullbound、.bound、.mask），"\
        "个人使用sh附加在data文件夹生成.out.create_boundary文件记录m文件运行过程，"
    cd ${pth_Gridgen}'area'
    cat >${gridgen_m} <<EOF
create_boundary(pth_gridgen_objectGrid_nml)
EOF
    ${pth_matlab} -nodisplay -r  \
        "pth_gridgen_objectGrid_nml='${pth_Gridgen}namelist/${gridgen_objectGrid_nml}'; ${programGo}; exit;" \
        >${pth_Gridgen}'data/'${gridgen_objectGrid}'.out.create_boundary' 2>&1
    ########################################################
fi

############################################################################################################
############################################################################################################
bannerSimple "data assimilation" "*"
pth_DA_Code=${pth_OceanForecast}'DA-Code/build/apps/'
declare -i DA_cycle_NoWW3 DA_cycle_NoWW3_ENOI
DA_cycle_NoWW3=0
DA_cycle_NoWW3_ENOI=0

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
echo '├──「FAQ，未完全完成，大纲」VScode书写shell，语法提示，格式化，错误提示，大纲，'
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
echo '├──「FAQ，???」git上传超过50Mb怎么解决？，'
# 放弃git托管大型项目，
# 只用一个.gitignore吧，太多就太烦了，
# https://blog.csdn.net/weixin_45574815/article/details/115231162   github如何删除项目中的文件
# https://blog.csdn.net/qq_36551991/article/details/110405561   .gitignore文件怎么写
# https://www.jianshu.com/p/82bbcfbb0ec9?from=singlemessage     git .ignore忽略文件夹中除了指定的文件外的其他所有文件
#       1、.gitignore写起来很费劲


##
echo '├──「FAQ，???」linux上wps能云同步吗？，'
# 不能

##
echo '├──「FAQ，成功」shell运行Matlab脚本？，' 
# https://www.jianshu.com/p/a8d807949b7d    Linux shell 运行 matlab脚本参数

##
echo '├──「FAQ，成功」shell重定向到文件，' 
# https://blog.csdn.net/phone1126/article/details/118524677， 