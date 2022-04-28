module mod_matrix_W
   use mod_params, only: N, NN, alpha !, localize
   use mod_date
   use mod_matrix_read
   use mod_matrix_write
   use mod_matrix_inverse
   use mod_matrix_H
   ! use mod_matrix_L
   ! use mod_matrix_R
   implicit none

contains
   subroutine W_matrix(blank, iiii, jjjj, M, nc_fileName, tag)
      implicit none
      integer :: iiii, jjjj
      character*255 :: blank, str, blank2, nc_fileName, tag
      integer, intent(in) :: M
      ! integer, intent(in) :: time(6)

      ! character :: tag*8
      real, allocatable :: WT(:, :), WS(:, :), W_wjc_ljc(:, :)
      real, allocatable :: AHAT(:, :)
      real, allocatable :: LHTT(:, :), LHSS(:, :)

      real :: HA(M, NN), HAT(NN, M)
      real :: HLHT(M, M), R(M, M), W0(M, M), W2(M, M)

      integer :: i, j

      str = trim(blank)//'1. 计算H观测算子,HA,HAT,AHAT，'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      blank2 = '----'//trim(blank)//'1.'
      ! (1) compute & write H, HA, LHT, HLHT, R
      ! write (*, *) '             ├── 「函数」H_matrix(M), use 1D locations to compute H,HA,AHAT...'
      call H_matrix(blank2, iiii, jjjj, M, nc_fileName, tag)                    ! H(M,N), use 1D locations to compute H,HA,AHATT, AHASS
      !call L_matrix(M2,M)                    ! LHT(N,M), use 3D locations to get LHTT, LHSS
      !call R_matrix(M,M)                    ! magnitude still needs to be determined

      str = trim(blank)//'2. 计算W0=HA*HAT，'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      ! (2) the second factor
      ! write (*, *) '             ├── 「函数」readmatrix(HA, M, NN, "HA", 2),'
      call readmatrix_ENOI(HA, M, NN, 'HA', 2)        ! HA(M,NN)
      ! write (*, *) "                 「读取文件」"//'ensemble/HAmatrix.txt,'
      ! write (*, *) "                        Reading matrix HA(",M,",",NN,"),"

      HAT = transpose(HA)                    ! HAT(NN,M)
      ! write (*, *) "             ├── 「变量」W0，为增益矩阵W中的H*B*(H)',"
      ! write (*, *) "                        W=BH'(alpha*HBH'+(NN-1)*R)^(-1),"
      ! write (*, *) "                        B=AA',这是ENOI与OI区别所在，"
      W0 = matmul(HA, HAT)                    ! HA(M,NN) HAT(NN,M) --> W0(M,M)

      str = trim(blank)//'3. 计算R(M,M)，'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      !call readmatrix(R,M,M,'R',1)
      ! write (*, *) "             ├── 「变量」R，为增益矩阵W中的R,"
      ! write (*, *) "                        R是观测矩阵协防差矩阵，"
      R = 0
      do i = 1, M
         do j = 1, M
            if (i .eq. j) then
               R(i, j) = 1
            end if
         end do
      end do

      !!
      str = trim(blank)//'4. 求逆，得到W2，关于ENOI中的alpha和具体公式，看'&
          &//'https://liu-jincan.github.io/2022/01/01/yan-jiu-sheng-justtry-target/'&
          &//'yan-yi-xia-gei-ding-qu-yu-ww3-shi-yan-tong-hua-bu-fen/#toc-heading-2'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      ! write (*, *) "             ├── 「变量」W0，进行更新，加上缩放因子和R，"
      ! write (*, *) "                        FAQ：alpha，背景误差斜方差矩阵的缩放因子，"
      ! write (*, *) "                        FAQ：观测误差斜方差矩阵R前需乘以（NN-1），"
      ! W0 = alpha*W0 + (NN - 1)*R                 ! W0(M,M)

      W0 = alpha*W0 + R                 ! W0(M,M)
      call inverse(W0, W2, M)                  ! W2(M,M)

     !!
    str = trim(blank)//'5. 得到W'
    if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
     !!---wjc
      allocate (W_wjc_ljc(N, M), AHAT(N, M))

    !   write (*, *) '             ├── 「函数」readmatrix(AHAT, N, M, "AHAT", 4),'
      call readmatrix_ENOI(AHAT, N, M, 'AHAT', 4)
    !   write (*, *) "                 「读取文件」"//'ensemble/AHATmatrix.txt,'
    !   write (*, *) "                        Reading matrix AHAT(", N, ",", M, "),"
      W_wjc_ljc = matmul(AHAT, W2)

    !   write (*, *) '             ├── 「函数」writematrix(W_wjc_ljc, N, M, "W", 1),'
      call writematrix_ENOI(W_wjc_ljc, N, M, 'W', 1)
    !   write (*, *) '                 「生成文件」ensemble/Wmatrix.txt,'
    !   write (*, *) "                        Writing matrix W(", N, ",", M, "),"
      deallocate (AHAT, W_wjc_ljc)
     !!--------

    !   write (*, *) '             ├── 「done」W_matrix(M)'
      return
   end subroutine W_matrix

end module mod_matrix_W
