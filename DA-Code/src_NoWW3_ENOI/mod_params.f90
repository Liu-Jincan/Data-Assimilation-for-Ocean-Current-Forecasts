module mod_params
    implicit none
    !********************************* Path setting  *********************************
    ! 生成的可执行文件位于，/1t/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/apps3/
    character(len=*), parameter :: programs = 'work_eastUSA'              ! 数据同化的区域项目名称
    character(len=*), parameter :: ndbc_pth = '/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/' 
    
    !********************************* ENOI Step Options *********************************
    integer, parameter :: ENOI = 1      ! 使用ENOI同化方法，1为使用, 0为不使用
    integer :: NN = 0       ! size of ensemble，这个需要运行完                                     
    integer, parameter :: DN = 10       ! step interval to sample the ensemble pool, hour       
    real, parameter    :: alpha = 1     ! scaling parameter of matrix B
    integer :: generateAmatriax = 1     ! 1表示生成，0表示不生成，


    !*********************************** Info on input NetCdf file *************************************
    character(len=*), parameter :: nc_pth = programs//'/nc/'              ! 背景场数据所在文件夹
    character(len=*), parameter :: nc_fileNameTxt = nc_pth//'nc.txt'      ! 背景场数据所在文件夹包含的文件名称，按时间顺序从先到后，
    integer, parameter :: nc_fileNameNum = 2                ! nc_fileNameTxt的行数，即需要同化的背景场nc文件个数，
    character(len=*), parameter :: nc_AttTimeName = 'time'                ! nc文件中时间属性的名称，
    character(len=*), parameter :: LAT_NAME = 'latitude'                    ! 
    character(len=*), parameter :: LON_NAME = 'longitude'                   ! 
    character(len=*), parameter :: TMP_NAME = 'hs'                          ! readdata会用到


    !*********************************** Info on output NetCdf file *************************************
    character(len=*), parameter :: nc_daOut = 'nc_NoWW3_ENOI_30days'     ! 输出同化nc文件所在文件夹名称

    !************************************* DA Subdomain Setting ***************************************
    integer, parameter :: sub_xy(4) = (/1, 1, 69, 41/)                      ! readdata会用到,
    integer, parameter :: sub_x = 69, sub_y = 41                            ! x 对应的经度，y 对应的是纬度，readdata会用到,
    integer, parameter :: N = 41*69                                         ! number of model grid points , NLATS * NLONS
    integer, parameter :: NLATS = 41, NLONS = 69                            ! 
end module mod_params

