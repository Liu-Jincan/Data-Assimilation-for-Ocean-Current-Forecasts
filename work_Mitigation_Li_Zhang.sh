function bannerSimple() {
    local msg="${2} ${1} ${2}"
    local edge
    edge=${msg//?/$2}
    echo "${edge}"
    echo "$(tput bold)${msg}$(tput sgr0)"
    echo "${edge}"
    echo
}


##########################################################################################################
###########################################################################################################
programGo='work_Mitigation_Li_Zhang'
pth_OceanForecast='/1t/Data-Assimilation-for-Ocean-Current-Forecasts/' ## ～tag，新建文件需要修改～
pth_WW3_regtest=${pth_OceanForecast}'WW3-6.07.1/regtests/'${programGo}
parm_WW3_input='input_experiment1' ## ～tag，新建文件需要修改～，

pth_WW3_regtest_input=${pth_WW3_regtest}"/${parm_WW3_input}/"
mkdir -p ${pth_WW3_regtest_input}

parm_WW3_work='work_experiment1'        ## ～tag，新建文件需要修改～           ## 测试时需要更换名字，
pth_WW3_regtest_work=${pth_WW3_regtest}"/${parm_WW3_work}/"
mkdir -p ${pth_WW3_regtest_work}

parm_WW3_comp='Gnu'        ## ～tag，新建文件需要修改～，实际文件为comp.Gnu，位于model，
parm_WW3_switch='Ifremer1' ## ～tag，新建文件需要修改～，实际文件为switch_Ifremer1，位于input，



##########################################################################################################
###########################################################################################################
bannerSimple "ww3 w3dainmdANDw3wdasmd" "*"
declare -i w3dainmdANDw3wdasmd
w3dainmdANDw3wdasmd=0
if (( w3dainmdANDw3wdasmd == 1 )); then 
    echo "按照manual操作！"
    # w3dainmd.ftn
    # w3wdasmd.ftn
    # make_makefile.sh
fi



##########################################################################################################
###########################################################################################################
bannerSimple "ww3 run_test" "*"
declare -i run_test
run_test=0                          ## ～tag，新建文件需要修改～
if ((run_test == 1)); then
    ######################################################
    cd ${pth_WW3_regtest_input} && cd '..'
    cp -i '../east-USA/run_test' . # -i 参数是为了防止已存在并修改的run_test文件被覆盖，
    chmod +x 'run_test'
fi




##########################################################################################################
###########################################################################################################
bannerSimple "grid preprocessor - ww3_grid_inp" "*"
declare -i ww3_grid_inp
ww3_grid_inp=0

if ((ww3_grid_inp == 1)); then
    ###################################################### 生成对应的ww3_grid
    cd ${pth_WW3_regtest_input} && cd '../../'
    ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
        -r ww3_grid -w ${parm_WW3_work} ../model ${programGo}
    ###################################################### 如果上面运行失败， \
    ########## 确定ww3_grid是由对应的源项编译后，将model/exe/ww3_grid复制到input运行，\
    ########## ./ww3_grid 的结果剪切到work，注意，生成的ww3需要保留在input。
    #cd ${pth_WW3_regtest_input}
    #./ww3_grid
fi




##########################################################################################################
###########################################################################################################
bannerSimple "grid preprocessor - ww3_strt_inp" "*"
declare -i ww3_strt_inp
ww3_strt_inp=0

if ((ww3_strt_inp == 1)); then
    ###################################################### 生成对应的ww3_strt
    cd ${pth_WW3_regtest_input} && cd '../../'
    ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
        -r ww3_strt -w ${parm_WW3_work} ../model ${programGo}
    ###################################################### 如果上面运行失败， \
    ########## 确定ww3_strt是由对应的源项编译后，将model/exe/ww3_strt复制到input运行，\
    ########## ./ww3_strt 的结果剪切到work，注意，生成的ww3需要保留在input。
    #cd ${pth_WW3_regtest_input}
    #./ww3_strt
fi


##########################################################################################################
###########################################################################################################
bannerSimple "grid preprocessor - ww3_prep_inp" "*"
declare -i ww3_prep_inp
ww3_prep_inp=0

if ((ww3_prep_inp == 1)); then
    ###################################################### 生成对应的ww3_prep
    cd ${pth_WW3_regtest_input} && cd '../../'
    ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
        -r ww3_prep -w ${parm_WW3_work} ../model ${programGo}
    ###################################################### 如果上面运行失败， \
    ########## 确定ww3_prep是由对应的源项编译后，将model/exe/ww3_prep复制到input运行，\
    ########## ./ww3_prep 的结果剪切到work，注意，生成的ww3需要保留在input。
    #cd ${pth_WW3_regtest_input}
    #./ww3_prep
fi




##########################################################################################################
###########################################################################################################
bannerSimple "grid preprocessor - ww3_shel_inp" "*"
declare -i ww3_shel_inp
ww3_shel_inp=1

if ((ww3_shel_inp == 1)); then
    ###################################################### 生成对应的ww3_shel
    cd ${pth_WW3_regtest_input} && cd '../../'
    ./${programGo}'/run_test' -i ${parm_WW3_input} -c ${parm_WW3_comp} -s ${parm_WW3_switch} \
        -r ww3_shel -w ${parm_WW3_work} ../model ${programGo}
    ###################################################### 如果上面运行失败， \
    ########## 确定ww3_shel是由对应的源项编译后，将model/exe/ww3_shel复制到input运行，\
    ########## ./ww3_shel 的结果剪切到work，注意，生成的ww3需要保留在input。
    #cd ${pth_WW3_regtest_input}
    #./ww3_shel
fi






#######################################################################
pwd