module mod_params
    implicit none

    !********************************* Data Assimilation Step Options *********************************
    character(len=*), parameter :: output_pth = 'output/'      ! analysis file，不能更改名称
    character(len=*), parameter :: input_pth = 'input/'       ! background file，不能更改名称
    character(len=*), parameter :: data_pth = 'data/'        ! ensemble files，不能更改名称
    character(len=*), parameter :: emsemble_pth = 'emsemble/'        !  files, 不能更改名称
    character(len=*), parameter :: fname_var = '_T.nc'        ! suffix of ensemble files

    logical, parameter :: step = .true. ! .false.      ! .T. to construct ensemble
    integer, parameter :: y_start = 2012       ! first year of ensemble data pool
    integer, parameter :: y_end = 2014       ! last year of ensemble data pool
    integer, parameter :: NN = 490      ! size of ensemble (5 days per month from 2-year)
    integer, parameter :: NS = 2 ! 730       ! size of ensemble pool, 
                                             ! mod_namelist.f90中会用到，NS过大会导致生成的data/namelist.txt为二进制文件，出错，
                                             
    ! integer, parameter :: DN = 6       ! step interval to sample the ensemble pool
                                        ! matrix_A 会用到，但也可以不用，

    ! logical, parameter :: localize = .false.      ! .T. for using localization
    ! logical, parameter :: loc_Lh = .true.      ! .T. for using horizontal localization
    ! logical, parameter :: loc_Lv = .true.      ! .T. for using vertical localization
    ! real, parameter    :: Lh = 100.0     ! km, horizontal localization scale
    ! real, parameter    :: Lv = 750.0     ! m, vertical localization scale
    real, parameter    :: alpha = 1   ! scaling parameter of matrix B

    ! logical, parameter :: crt_bias = .false.      ! .T. to correct model bias
    ! real, parameter    :: rgamma = 0.01    ! scaling parameter of model bias

    !************************************* Info about Argo Data ***************************************
    ! integer, parameter :: max_argo = 2       ! max number of argo to assimilate
    ! integer, parameter :: R_method = 2       ! 1 or 2 to select method for R
    ! ! R_method=1
    ! real, parameter    :: sigma_T1 = 1.0     ! instrument error: std of T (C)
    ! real, parameter    :: sigma_S1 = 0.05    ! instrument error: std of S (PSU)
    ! real, parameter    :: kappa_T = 0.5     ! coef of representative error
    ! real, parameter    :: kappa_S = 0.5     ! coef of representative error
    ! ! R_method=2
    ! real, parameter    :: sigma_T2 = 0.5     ! constant error
    ! real, parameter    :: sigma_S2 = 0.1     ! constant error

    !*********************************** Info on NEMO Output Data *************************************
    ! character(len=*), parameter :: REC_NAME = 'time_counter'
    ! character(len=*), parameter :: LVL_NAME = 'deptht'
    character(len=*), parameter :: LAT_NAME = 'latitude' ! read_coor会用到
    character(len=*), parameter :: LON_NAME = 'longitude' ! read_coor会用到
    character(len=*), parameter :: TMP_NAME = 'hs'         ! readdata会用到
    ! character(len=*), parameter :: SAL_NAME = 'vosaline'

    ! integer, parameter :: NDIMS = 4, NRECS = 1              ! 4-D variables, 1 time record
    ! integer, parameter :: NDIMS = 3  NRECS = 245              ! 3-D variables,lon-lat-hs, time record, readdata会用到,
    ! integer, parameter :: NLVLS = 50, NLATS = 616, NLONS = 709 ! (k,j,i)=(50,616,709)
    integer, parameter :: NLATS = 41, NLONS = 69 ! read_coor会用到

    !************************************* DA Subdomain Setting ***************************************
    ! integer, parameter :: sub_xy(4) = (/1, 106, 443, 616/)      ! start and end points in x and y
    ! integer, parameter :: sub_x = 443, sub_y = 511              ! number of points in x-lon and y-lat
    integer, parameter :: sub_xy(4) = (/1, 1, 69, 41/) ! readdata会用到,
    integer, parameter :: sub_x = 69, sub_y = 41 ! x 对应的经度，y 对应的是纬度，readdata会用到,
    integer, parameter :: N = 41*69              ! number of model grid points , NLATS * NLONS

end module mod_params
