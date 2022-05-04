module mod_analysis
   use mod_params, only: output_pth, input_pth, N, NN, programs !, NLVLS, sub_y, sub_x, crt_bias, rgamma
   use mod_date
   use mod_matrix_A, only: A_matrix
   ! use mod_read_data
   use mod_matrix_read
   use mod_matrix_W
   ! use mod_obs_sorting
   implicit none

contains
   subroutine ENOI_analysis(blank, iiii, jjjj, nc_fileName, tag,Xb)
      implicit none
      integer :: iiii, jjjj
      character*255 :: blank, tag, nc_fileName, str, str2, blank2
      !! tmp
      integer :: M, i, FID = 137
      ! character ::

      real, allocatable :: yo(:)
      real, allocatable :: H(:, :), HXb(:), W(:, :)
      real :: Xb(N), dX(N), bias(N)
      real :: start, finish
      !!
      str = trim(blank)//'*. 记录开始时间，cpu_time(start)'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      call cpu_time(start) ! start: 0.00205700006

      !!
      str = trim(blank)//'1. 当下时刻的观测数量M，'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      i = index(nc_fileName, '.') ! . 在字符串的位置，
      str2 = programs//'/'//nc_fileName(1:i - 1)//'_nc_yo/'//tag
      ! write (*,*) str2
      open (FID, file=str2)
      M = GetFileN(FID)
      ! write (*, *) M  ! 验证正确
      close (FID)

      !!
      str = trim(blank)//'2. 观测值yo，M*1'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      allocate (yo(M))
      open (FID, file=str2, status='old')
      read (FID, *) yo
      close (FID)
      ! write (*,*) yo ! 验证成功，

      !!
      str = trim(blank)//'3. 生成ENOI中的A，（AA’）为背景误差斜方差B，ENOI中不需要明显表示B，'&
         &//'A的生成只需要进行一次，good～，'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) then
         blank2 = '----'//trim(blank)//'3.'
         call A_matrix(blank2,iiii,jjjj)     ! A matrix: run only 1 time before DA cycles
      end if

      !!
      str = trim(blank)//'4. 计算W=alpha*AHAT*(alpha*HA*HAT+R)^(-1)，alpha的解释'&
          &//'https://liu-jincan.github.io/2022/01/01/yan-jiu-sheng-justtry-target/'&
          &//'yan-yi-xia-gei-ding-qu-yu-ww3-shi-yan-tong-hua-bu-fen/#toc-heading-2'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      blank2 = '----'//trim(blank)//'4.'
      call W_matrix(blank2,iiii,jjjj,M,nc_fileName,tag)


      !!
      str = trim(blank)//'5. 背景场Xb，N*1，之前从nc读取了～'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str

      ! write (*, *) '      ├── 「读取文件」input/bg_data.txt,'
      ! open (55, file='/home/wjc/wjc_work/DA_Code/input/bg_data.txt', status='old')
      ! open (55, file='input/bg_data.txt', status='old')
      ! read (55, *) Xb
      ! close (55)
      ! write (*, *) '                    得到Xb，其维度为N*1,'
      ! write (*, *) '                     *** SUCCESS Sorted background is read in!'

      ! (5) correct model bias
      ! if (crt_bias) then
      !    open(55,file=output_pth//'/bias/model_bias.dta',form='unformatted')
      !    read(55) bias
      !    close(55)
      !    write(*,*) '*** SUCCESS Model bias is read in!'

      !    Xb = Xb-bias
      ! endif


      !!
      str = trim(blank)//'6. 计算增量dX～'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      ! (6) calculate increment
      allocate (H(M, N), HXb(M))
      ! write (*, *) '      ├── 「函数」readmatrix(H, M, N, “H”, 1),'
      call readmatrix_ENOI(H, M, N, 'H', 1)
      ! write (*, *) '          「读取文件」ensemble/Hmatrix.txt,'
      ! write (*, *) "                    Reading matrix H(", M, ",", N, "),"

      HXb = matmul(H, Xb)

      ! write (*, *) '      ├── 「函数」writematrix(HXb, M, 1, "HXb", 3),'
      call writematrix_ENOI(HXb, M, 1, 'HXb', 3)
      ! write (*, *) '          「生成文件」ensemble/HXbmatrix.txt,'
      ! write (*, *) "                    Writing matrix HXb(", M, ",", 1, "),"
      deallocate (H)

      !!========================================================================
      ! IMPORTANT: find topography points in model output (=0.0): model topo points
      ! different from argo topo points
      ! do i = 1, M
      !    if (HXb(i) == 0.0) then
      !       yo(i) = 0.0
      !    end if
      ! end do
      !!========================================================================
      !!                       Check innovations                              !!
      !allocate(Tindex3D(M2(1),4), Sindex3D(M2(2),4))                          !!
      !open(55,file='/home/chako/Argo/bias_nay/Index3D.dta',form='unformatted')!!
      !read(55) Tindex3D, Sindex3D                                             !!
      !close(55)                                                               !!
                                                                              !!
      !open(33,file='ensemble/check_innovation'//tag//'.txt',form='formatted') !!
      !do i=1,M                                                                !!
      !   if (i<=M2(1)) then                                                   !!
      !      write(33,'(I3,I3,I3,I3,F24.16,F24.16)') Tindex3D(i,4),&           !!
      !          Tindex3D(i,1), Tindex3D(i,2), Tindex3D(i,3), yo(i), HXb(i)    !!
      !   else                                                                 !!
      !      write(33,'(I3,I3,I3,I3,F24.16,F24.16)') Sindex3D(i-M2(1),4),&     !!
      !Sindex3D(i-M2(1),1),Sindex3D(i-M2(1),2),Sindex3D(i-M2(1),3),yo(i),HXb(i)!!
      !   endif                                                                !!
      !enddo                                                                   !!
      !close(33)                                                               !!
      !deallocate(Tindex3D, Sindex3D)                                          !!
      !!========================================================================
      ! write (*, *) '      ├── 「变量」dX = W*(yo-HXb),其维度为N*1，'
      yo = yo - HXb
      deallocate (HXb)
      allocate (W(N, M))
      call readmatrix_ENOI(W, N, M, 'W', 1)
      dX = matmul(W, yo)
      deallocate (W)
      deallocate (yo)
      
      !!
      str = trim(blank)//'7. 得到分析值，仍用Xb表示～'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      ! (7) get analysis
      ! if ((maxval(dX(1:N/2)) > 10.0) .or. (minval(dX(1:N/2)) < -10.0)) then
      ! write (*, *) '      ├── 「变量」Xa = Xb+dX，其维度为N*1，'
      if ((maxval(dX(1:N)) > 10.0) .or. (minval(dX(1:N)) < -10.0)) then
         ! write (*, *) '                *** WARNING increment is abnormal!'
         ! write (*, *) '                *** WARNING No observations assimilated!'
         Xb = Xb
      else
         Xb = Xb + dX                  ! acutally Xb=Xa
      end if
      !call expand(tmp,sal,Xb)        ! analysis of tmp & sal
      ! write (*, *) '                *** SUCCESS Analysis is computed!'

      !!
      str = trim(blank)//'8. 保存Xb～'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      ! (8) save analysis as restart
      str2 = programs//'/Xb/'//tag
      open (55, file=str2, status='replace')
      do i = 1, N
         write (55, '(f8.3)') Xb(i)
      end do
      close (55)
      ! write (*, *) '                *** SUCCESS Analysis is saved!'
      
      !!
      str = trim(blank)//'*. 计算时间，cpu_time(finish)～'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      ! write (*, *) '      ├── 「cpu_time」finish'
      call cpu_time(finish)
      ! write (*, *) '                    ', (finish - start), 'seconds,'
      ! write (*, *) '                    ', (finish - start)/60.0, 'minutes,'
      ! print '("Time = ",f10.2," minutes.")', (finish - start)/60.0

      ! write (*, *) '      ├── 「done」analysis(time)'
      return
   end subroutine ENOI_analysis

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

end module mod_analysis
