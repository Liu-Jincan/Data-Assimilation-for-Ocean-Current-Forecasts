# 2022-04-13 对src2中makefile生成的可执行文件DA_cycle入手，输入什么？输出什么？ 

# ./DA_cycle
## error1: DA_time.txt
    $ ./DA_cycle 
    At line 12 of file DA_cycle.f90 (unit = 11, file = 'DA_time.txt')
    Fortran runtime error: End of file
    
    Error termination. Backtrace:
    #0  0x7fcb9717cd21 in ???
    #1  0x7fcb9717d869 in ???
    #2  0x7fcb9717e54f in ???
    #3  0x7fcb973c1c5b in ???
    #4  0x7fcb973bae26 in ???
    #5  0x7fcb973bbdc9 in ???
    #6  0x55d21cb794a7 in da_cycle
            at /home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/Data-Assimilation-Code/src2/DA_cycle.f90:12
    #7  0x55d21cb796ab in main
            at /home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/Data-Assimilation-Code/src2/DA_cycle.f90:3

解决方法？2000 01 01 01 01 01 

## error2: observational data
    $ ./DA_cycle 
    Preparing observational data...
    *** STOP No Argo profile is read in.

DA_cycle --> analysis --> sort_obs

# data文件夹
Freerun output saves here for computing the background matrix (i.e. B and A matrices).

# ensemble文件夹
Here is the list under my Argo data assimilation ensemble folder:

Amatrix.dta :           matrix A(nxN), where n = ii*jj*kk*2 (ii,jj,kk are grid point numbers in x,y,z direction, 2 is because of T and S; N is the ensemble member)
ASmatrix.dta :          (lower part of A matrix (n/2 * N))
ATmatrix.dta :          (upper part of A matrix (n/2 * N))
coordinate.dta :        (lon and lat for data assimilation domain)
ensemble_mean_sal.dta : (ensemble mean of salinity)
ensemble_mean_tmp.dta : (ensemble mean of temperature)
ensemble_sprd_sal.dta : (ensemble spread/std of salinity)
ensemble_sprd_tmp.dta : (ensemble spread/std of temperature)
model_sprd_sal.dta :    same as ensemble spread of salinity
model_sprd_tmp.dta :    same as ensemble spread of temperature

# input文件夹
background file will be copied here by the data assimilation code

# output文件夹
background and analysis files will be saved here

# 整个项目文件流程

DA_time
* 「读取文件*」open (11, file='name_length', form='formatted', action='read')
    * 「注意」此文件不是很重要
* 「读取文件*」open (12, file='name_example', form='formatted', action='read')
    * 「注意」此文件不是很重要
* 「生成文件」open (unit=13, file='DA_time.txt')

DA_cycle
* A_matrix()
    * 「注意」run only 1 time before analysis
    * namelists() 
        * 「生成文件」open (unit=15, file='data/namelist.txt', status='new', access='sequential', form='formatted', action='write')
    * 「读取文件」open (unit=15, file=data_pth//'namelist.txt', status='old', access='sequential', form='formatted', action='read')
    * readcoor(fname2)
        * 「生成文件」open (unit=11, file='ensemble/coordinate.dta', form='unformatted')
    * 「读取文件」open (unit=15, file=data_pth//'namelist.txt', status='old', access='sequential', form='formatted', action='read')
    * readdata(tmp, sal, fname2)
    * 「生成文件」open (unit=12, file='ensemble/ensemble_mean_tmp.dta', form='unformatted')
    * 「生成文件」open (unit=22, file='ensemble/ensemble_mean_sal.dta', form='unformatted')
    * 「读取文件」open (unit=15, file=data_pth//'namelist.txt', status='old', access='sequential', form='formatted', action='read')
    * readdata(tmp, sal, fname2)
    * 「生成文件」open (unit=12, file='ensemble/ensemble_sprd_tmp.dta', form='unformatted')
    * 「生成文件」open (unit=22, file='ensemble/ensemble_sprd_sal.dta', form='unformatted')
    * 「生成文件」open (unit=11, file='ensemble/AT0matrix.dta', form='unformatted')
    * 「生成文件」open (unit=11, file='ensemble/AS0matrix.dta', form='unformatted')
    * writematrix(A, N, NN, 'A', 1)
        * 「生成文件」open (unit=11, file='ensemble/Amatrix.dta', form='unformatted')
    * readmatrix(AT, N/2, NN, 'AT0', 3, 1)
        * 「读取文件」open (unit=11, file='ensemble/AT0matrix.dta', form='unformatted')
    * writematrix(AT, N/2, NN, 'AT', 2)
        * 「生成文件」open (unit=11, file='ensemble/ATmatrix.dta', form='unformatted')
    * readmatrix(AS, N/2, NN, 'AS0', 3, 1)
        * 「读取文件」open (unit=11, file='ensemble/AS0matrix.dta', form='unformatted')
    * writematrix(AS, N/2, NN, 'AS', 2)
        * 「生成文件」open (unit=11, file='ensemble/ASmatrix.dta', form='unformatted')
* 「读取文件」open (unit=11, file='DA_time.txt')
* analysis(time)
    * date(tag, time)
    * sort_obs(M2, time)
        * argo_name(filename, time, p)
        * 「读取文件*」inquire (file='/home/chako/Argo/daily/'//filename, exist=exist)
            * 「注意」此文件是argo浮标
        * bins(loc, lvl, filename)
            * 「读取文件」open (55, file='/home/chako/Argo/daily/'//filename, form='unformatted', access='stream')
            * 「读取文件」open (55, file='ensemble/coordinate.dta', form='unformatted')
            * 「注意」某一位置argo浮标的经纬度取得是平均值～
            * 「注意」T 表示的是温度， S 表示的是盐度， 做的是温度和盐度的数据同化， 故需要对水深尽心 bin 处理，也就是此函数；
            * 「生成文件」open (55, file='/home/chako/Argo/bias_nay/bins'//filename, form='unformatted')
        * 「读取文件」open (55, file='/home/chako/Argo/bias_nay/bins'//filename, form='unformatted')
        * 「生成文件」open (55, file='/home/chako/Argo/bias_nay/Index1D.dta', form='unformatted')
        * 「生成文件」open (55, file='/home/chako/Argo/bias_nay/Index3D.dta', form='unformatted')
        * 「生成文件」open (55, file='/home/chako/Argo/bias_nay/bins.dta', form='unformatted')
    * W_matrix(M2, M, time)
        * H_matrix(M2, M)  
            * 「读取文件」open (55, file='/home/chako/Argo/bias_nay/Index1D.dta', form='unformatted')
            * 「注意」H 观测矩阵？，包含了多层水下温度+多层水下盐度，不是单一要素，
            * writematrix(H, M, N, 'H', 1)
                * 「生成文件」open (unit=11, file='ensemble/Hmatrix.dta', form='unformatted')
            * readmatrix(A, N, NN, 'A', 1)
                * 「读取文件」open (unit=11, file='ensemble/Amatrix.dta', form='unformatted')
            * writematrix(HA, M, NN, 'HA', 2)
                * 「生成文件」open (unit=11, file='ensemble/HAmatrix.dta', form='unformatted')
            * readmatrix(AT, N/2, NN, 'AT', 2)
                * 「读取文件」open (unit=11, file='ensemble/ATmatrix.dta', form='unformatted')
            * writematrix(AHAT1, N/2, M2(1), 'AHAT1', 5)
                * 「生成文件」open (unit=11, file='ensemble/AHAT1matrix.dta', form='unformatted')
            * writematrix(AHAT2, N/2, M2(2), 'AHAT2', 5)
                * 「生成文件」open (unit=11, file='ensemble/AHAT2matrix.dta', form='unformatted')
            * readmatrix(AS, N/2, NN, 'AS', 2)
                * 「读取文件」open (unit=11, file='ensemble/ASmatrix.dta', form='unformatted')
            * writematrix(AHAS1, N/2, M2(1), 'AHAS1', 5)
                * 「生成文件」open (unit=11, file='ensemble/AHAS1matrix.dta', form='unformatted')
            * writematrix(AHAS2, N/2, M2(2), 'AHAS2', 5)
                * 「生成文件」open (unit=11, file='ensemble/AHAS2matrix.dta', form='unformatted')
        * L_matrix(M2, M)
            * 「读取文件」open (unit=11, file='ensemble/coordinate.dta', form='unformatted')
            * 「读取文件」open (55, file='/home/chako/Argo/bias_nay/Index1D.dta', form='unformatted')
            * 「读取文件」open (55, file='/home/chako/Argo/bias_nay/Index3D.dta', form='unformatted')
            * 「生成文件」open (55, file='ensemble/LHTT0matrix.dta', form='unformatted')
            * 「生成文件」open (55, file='ensemble/LHSS0matrix.dta', form='unformatted')
            * writematrix(HLHT, M, M, 'HLHT', 4)
                * 「生成文件」open (unit=11, file='ensemble/HLHTmatrix.dta', form='unformatted')
        * R_matrix(M2, M)
            * 「读取文件*」open (unit=12, file='ensemble/model_sprd_tmp.dta', form='unformatted')
            * 「读取文件*」open (unit=22, file='ensemble/model_sprd_sal.dta', form='unformatted')
            * 「读取文件」open (55, file='/home/chako/Argo/bias_nay/Index3D.dta', form='unformatted')
            * 「读取文件*」open (55, file='glider/Rmatrix.dta', form='unformatted', access='stream')
            * 「读取文件」open (55, file='/home/chako/Argo/bias_nay/Index3D.dta', form='unformatted')
            * writematrix(R, M, M, 'R', 1)
                * 「生成文件」open (unit=11, file='ensemble/Rmatrix.dta', form='unformatted')
        * readmatrix(HA, M, NN, 'HA', 2) 
            * 「读取文件」open (unit=11, file='ensemble/HAmatrix.dta', form='unformatted')
        * readmatrix(HLHT, M, M, 'HLHT', 4)
            * 「读取文件」open (unit=11, file='ensemble/HLHTmatrix.dta', form='unformatted')
        * readmatrix(R, M, M, 'R', 1)
            * 「读取文件」open (unit=11, file='ensemble/Rmatrix.dta', form='unformatted')
        * 「读取文件」open (55, file='/home/chako/Argo/bias_nay/Index3D.dta', form='unformatted')
        * 「生成文件」open (33, file='ensemble/check_error_vari'//tag//'.txt', form='formatted') 
        * readmatrix(AHAT1, N/2, M2(1), 'AHAT1', 5)
        * readmatrix(LHTT, N/2, M2(1), 'LHTT0', 5, 1)
        * readmatrix(AHAT2, N/2, M2(2), 'AHAT2', 5)
        * readmatrix(LHSS, N/2, M2(2), 'LHSS0', 5, 1)
        * writematrix(WT, N/2, M, 'WT', 2)
            * 「生成文件」open (unit=11, file='ensemble/WTmatrix.dta', form='unformatted')
        * ...
        * writematrix(WS, N/2, M, 'WS', 2)
            * 「生成文件」open (unit=11, file='ensemble/WSmatrix.dta', form='unformatted')
    * 「读取文件*」open (55, file='/home/chako/Argo/bias_nay/bins.dta', form='unformatted')
    * 「读取文件*」open (55, file=input_pth//'background.dta', form='unformatted')
    * squeeze(Xb, tmp, sal) 
    * 「读取文件*」open (55, file=output_pth//'/bias/model_bias.dta', form='unformatted') 
    * readmatrix(H, M, N, 'H', 1)
        * 「读取文件」open (unit=11, file='ensemble/Hmatrix.dta', form='unformatted')
    * 「读取文件」open (55, file='/home/chako/Argo/bias_nay/Index3D.dta', form='unformatted')
    * 「生成文件」open (33, file='ensemble/check_innovation'//tag//'.txt', form='formatted')
    * readmatrix(W, N/2, M, 'WT', 2)
        * 「读取文件」open (unit=11, file='ensemble/WTmatrix.dta', form='unformatted')
    * readmatrix(W, N/2, M, 'WS', 2)
        * 「读取文件」open (unit=11, file='ensemble/WSmatrix.dta', form='unformatted')
    * 「生成文件」open (55, file=output_pth//'/bias/model_bias.dta', form='unformatted')
    * expand(tmp, sal, Xb)
    * 「生成文件」open (55, file=output_pth//'analysis'//tag//'.dta', form='unformatted')


# 整个项目的各个模块