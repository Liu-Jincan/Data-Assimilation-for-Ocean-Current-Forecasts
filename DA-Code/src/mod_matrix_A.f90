module mod_matrix_A
   use mod_params, only: data_pth, sub_y, sub_x, N, programs, DN ! , NLVLS, DN, NN,
   ! use mod_namelist
   use mod_read_data, only: readdata_hs_dn_total
   ! use mod_read_coor
   ! use mod_matrix_read
   use mod_matrix_write
   implicit none

contains
   subroutine A_matrix(blank, iiii, jjjj)

      implicit none
      integer :: iiii, jjjj, kkkk
      character*255 :: blank, str, str2, blank2, str3
      !! tmp
      integer :: i, j, k, m, x, s, list, FID
      integer :: NN  ! NN实际是在这里产生的哟～
      integer :: NS
      character*255 :: fname, fname2
      logical :: exist
      real :: tmp(sub_x, sub_y)   ! NS每个文件中的所有时间节点的数据累加
      real :: tmps(sub_x, sub_y)  ! 所有NS文件中累加后，再平均
      real, allocatable :: tmp2(:, :, :)  ! NS每个文件中的包含时间节点信息的数据

      real :: tmpp(sub_x, sub_y)  ! tmpp: the anomalies with respect to the mean, 即减法
      real :: tmpd(sub_x, sub_y)  ! tmpd: the deviation from the mean
      real, allocatable :: A(:, :) ! A(N,NN): ensemble matrix, N=sub_y*sub_x, NN is the ensemble number

      !!
      FID = 137
      kkkk = 1
      !!
      str = trim(blank)//'1. 选取.apps/$(program)/nc/下的哪些nc文件作为生成A的ensemble pool，' &
         &//'该目录下的nc文件记录在nc.txt文件（已经按照顺序排列），一年一个nc文件～'&
         &//'，ensemble pool用到的nc文件记录在nc_ENOI_Amatrix.txt，'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      str2 = programs//'/nc/nc_ENOI_Amatrix.txt'
      open (FID, file=str2)
      NS = GetFileN(FID)
      ! write (*, *) NS  ! 验证正确
      close (FID)

      !!
      str = trim(blank)//'2. 读取ensemble pool每个nc文件，每个nc文件的采样间隔设置为DN小时，'&
         &//'对所有nc文件的Hs三维变量按间隔进行采样，在时间维度求平均值得到二维矩阵tmps，'&
         &//'并得到ensemble的数量NN~，'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      OPEN (unit=FID, file=str2, status='old')
      tmps = 0.0; 
      m = 0
      do list = 1, NS
         read (FID, *) fname
         fname2 = programs//'/nc/'//fname
         ! write (*,*) fname2
         blank2 = '----'//trim(blank)//'2.'
         call readdata_hs_dn_total(blank2,iiii,jjjj,kkkk,DN, tmp, s, tmp2, fname2)
         kkkk = 0;
         tmps = tmps + tmp
         m = m + s
      end do

      tmps = tmps/real(m)
      ! write (*, *) '          「变量」tmps,'
      ! write (*, *) '                    小于0的为nan,'
      ! write (*, *) '                    FAQ：随着sub_x的增加，经度增加？随着sub_y的增加，纬度增加？'
      ! write (*, *) '                         是的，验证方法：matlab显示一个时刻的二维数据，与地图对比，'
      ! write (*, *) '                         ncread("20141227_T.nc","hs",[1 1 1],[69 41 1],[1 1 1])，'
      NN = m; 
      write (*, *) '          「变量」NN=',m,'，记得在parms更新NN，'
      CLOSE (FID)

      !!
      str = trim(blank)//'3. 保存二维矩阵Ameans，即程序中tmps，在.apps/$(program)/ENOI/Ameans.txt'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      call system("mkdir -p "//programs//'/ENOI/')
      str3 = programs//'/ENOI/Ameans.txt'
      open (unit=FID, file=str3, status='replace')
      do i = 1, sub_x
         write (FID, *) (tmps(i, j), j=1, sub_y)
      end do
      close (FID)


      !!
      str = trim(blank)//'4. 计算得到A(N,NN)'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      allocate (A(N, NN))
      OPEN (unit=FID, file=str2, status='old')
      m = 0
      tmpd = 0.0; 
      do list = 1, NS
         read (FID, *) fname
         fname2 = programs//'/nc/'//fname
         call readdata_hs_dn_total(blank2,iiii,jjjj,kkkk,DN,tmp, s, tmp2, fname2)

         do k = 1, s
            tmpp = tmp2(:, :, (k-1)*DN+1) - tmps
            m = m + 1
            x = 0
            ! construct A' (NxNN) from Ai' (Nx1)

            do j = 1, sub_y
               do i = 1, sub_x
                  x = x + 1
                  A(x, m) = tmpp(i, j)
               end do
            end do

            ! do j = 1, sub_y
            !    do i = 1, sub_x
            !       tmpd(i, j) = tmpd(i, j) + tmpp(i, j)**2.0
            !    end do
            ! end do
         end do

      end do

      CLOSE (FID)

      !!
      str = trim(blank)//'5.保存A(N,NN)到.apps/$(program)/ENOI/Amatrix.txt'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      call writematrix_ENOI(A, N, NN, 'A', 1)
      deallocate (A)
      deallocate(tmp2)

      ! (0) initialize summation and std terms
      ! tmps = 0.0; 
      ! tmpd = 0.0; 
      ! (1) Write namelist.txt for the ensemble pool data files (不用这么麻烦，通过nc.txt即可)
      ! write (*, *) '      ├── 「函数」namelists(), Write namelist.txt for the ensemble pool data files,'
      ! call namelists()
      ! write (*, *) '          「生成文件」data/namelist.txt,'
      ! write (*, *) '                    文件内容每行类似20141228_T.nc,'
      ! write (*, *) '                    领悟到了stop的意义,'

      ! (2) Get coordinates for T&S from a sample data file （经纬度信息的获取不用这么麻烦～～，可以直接从nclat,nclon获取）
      ! write (*, *) '      ├── 「读取文件」data/namelist.txt,'
      ! open (unit=15, file=data_pth//'namelist.txt', status='old')
      ! ! open (unit=15, file=data_pth//'namelist.txt', status='old', &
      ! !       access='sequential', form='formatted', action='read')
      ! write (*, *) '                    fname为data/namelist.txt的第一行,'
      ! read (15, '(A13)') fname
      ! close (15)
      ! fname2 = data_pth//fname
      ! write (*, *) '          「函数」readcoor(fname2),'
      ! write (*, *) '                    fname2为类似data/20141228_T.nc的一个文件名称,'
      ! write (*, *) '                    先用wind.2021.nc进行，重命名data/20141227_T.nc,'
      ! write (*, *) '                    在matlab，ncdisp("20141227_T.nc");,'
      ! write (*, *) '                    在终端，ncview 20141227_T.nc,'
      ! call readcoor(fname2)
      ! write (*, *) '          「生成文件」ensemble/coordinate.dta,'
      ! write (*, *) "                    *** SUCCESS Coordinate is written!"

      ! (3) 原来是：Construct Amean from every 6 day sampling of 2-year run
      ! (3) 现在是：Construct Amean of ww3.2021.nc
      ! OPEN (unit=15, file=data_pth//'namelist.txt', status='old', &
      !       access='sequential', form='formatted', action='read')
      ! write (*, *) '      ├── 「读取文件」data/namelist.txt,'
      ! write (*, *) '                    nc文件是每小时一个，hs是三维数据，'
      ! OPEN (unit=15, file=data_pth//'namelist.txt', status='old')
      ! write (*, *) '          「函数」readdata_hs_total(tmp,s,tmp2,fname2),'
      ! write (*, *) '                    FAQ: fortran如何读取nc文件3维变量,'
      ! write (*, *) '                    nf90_get_var(ncid, tmp_varid, tmp)不可,读取的数据是错误的,因为缺少scale'
      ! Fortran处理nc文件基于netcdf库, https://www.csdn.net/tags/MtTaMg4sMjg1MjA2LWJsb2cO0O0O.html
      ! Fortran 读netcdf数据（Linux系统）, https://www.bilibili.com/read/cv15412885/
      ! matlab写的nc数据无法用fortran读取, https://www.ilovematlab.cn/thread-61886-1-1.html
      ! fortran使用netcdf 读写NC文件, https://blog.csdn.net/h4x0r_007/article/details/46900293
      ! 利用fortran创建、读取、写netCDF(.nc)的教程.pdf, https://max.book118.com/html/2021/1028/6152215132004034.shtm
      ! 在linux下用fortran读取netcdf文件(以WRF模式输出的数据为例), https://blog.csdn.net/weixin_35774805/article/details/115735558

      ! (4) Construct A'=A-Amean
      ! write (*, *) '      ├── 「读取文件」data/namelist.txt,'
      ! allocate (A(N, NN))
      ! OPEN (unit=15, file=data_pth//'namelist.txt', status='old', &
      !       access='sequential', form='formatted', action='read')
      ! OPEN (unit=15, file=data_pth//'namelist.txt', status='old')
      ! write (*, *) '          「FAQ」对NN集合大小,DN取样间隔,NS集合池中文件总数的理解,'
      ! write (*, *) '                原来的程序NS文件是每天一个，DN是6天间隔，NN是20？.'
      ! write (*, *) '                现在的程序NS文件是每年一个，DN没有，NN是？.'
      ! write (*, *) '                NN其实就是采样时间点的个数？NS是所有时间点的个数？ok.'

      ! write (*, *) '          「FAQ」fortran动态数组作为形参怎么传递？,'
      ! write (*, *) '                 只能deallocate一次，其他的普通参数传惨一致,'

      ! write (*, *) '          「函数」readdata_hs_total(tmp,s,tmp2,fname2),'
      ! m = 0
      ! do list = 1, NS

      !    read (15, '(A13)') fname
      !    fname2 = data_pth//fname
      !    call readdata_hs_dn_total(blank2,iiii,jjjj,kkkk,DN,tmp, s, tmp2, fname2)

      !    do k = 1, s
      !       tmpp = tmp2(:, :, k) - tmps
      !       m = m + 1
      !       x = 0
      !       ! construct A' (NxNN) from Ai' (Nx1)

      !       do j = 1, sub_y
      !          do i = 1, sub_x
      !             x = x + 1
      !             A(x, m) = tmpp(i, j)
      !          end do
      !       end do

      !       ! do j = 1, sub_y
      !       !    do i = 1, sub_x
      !       !       tmpd(i, j) = tmpd(i, j) + tmpp(i, j)**2.0
      !       !    end do
      !       ! end do
      !    end do

      ! end do

      ! CLOSE (15)

      ! do j = 1, sub_y
      !    do i = 1, sub_x
      !       tmpd(i, j) = (tmpd(i, j)/real(m))**0.5
      !    end do
      ! end do

      ! open (unit=12, file='ensemble/ensemble_sprd_tmp.dta', form='unformatted')
      ! write (12) tmpd
      ! close (12)
      ! open (unit=22, file='ensemble/ensemble_sprd_sal.dta', form='unformatted')
      ! write (22) sald
      ! close (22)

      ! open (unit=11, file='ensemble/AT0matrix.dta', form='unformatted')
      ! do i = 1, N/2
      !    write (11) (A(i, j), j=1, NN)
      ! end do
      ! close (11)

      ! open (unit=11, file='ensemble/AS0matrix.dta', form='unformatted')
      ! do i = N/2 + 1, N
      !    write (11) (A(i, j), j=1, NN)
      ! end do
      ! close (11)
      ! write (*, *) '          「生成文件」ensemble/Amatrix.txt,'
      ! call writematrix(A, N, NN, 'A', 1)
      ! deallocate (A)
      ! write (*, *) '                 Writing matrix A(', N, ',', NN, ')'
      ! write (*, *) '                 ', N, '对应网格排序：先是最低纬度对应经度的增加，...，'
      ! write (*, *) '                 可通过产生A的循环结构进行验证，'

      ! write (*, *) '      ├── 「done」A_matrix()，记得修改mod_params中的 NN 和 step !!!!'
      ! stop
   end subroutine A_matrix

   Integer Function GetFileN(iFileUnit)
      Implicit None
      Integer, Intent(IN)::iFileUnit
      Integer::ios
      Character(Len=1)::cDummy
      GetFileN = 0
      Rewind (iFileUnit)
      Do
         Read (iFileUnit, *, ioStat=ioS) cDummy
         if (ioS /= 0) Exit
         GetFileN = GetFileN + 1
      End Do
   end function

end module mod_matrix_A
