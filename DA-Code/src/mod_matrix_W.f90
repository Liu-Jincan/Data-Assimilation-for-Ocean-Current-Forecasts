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
    subroutine W_matrix(M, time)
        implicit none
        integer, intent(in) :: M
        integer, intent(in) :: time(6)

        character :: tag*8
        real, allocatable :: WT(:, :), WS(:, :), W_wjc_ljc(:, :)
        real, allocatable :: AHAT(:, :)
        real, allocatable :: LHTT(:, :), LHSS(:, :)

        real :: HA(M, NN), HAT(NN, M)
        real :: HLHT(M, M), R(M, M), W0(M, M), W2(M, M)

        integer :: i, j  !!Tindex3D(M2(1),4), Sindex3D(M2(2),4)

        ! (0) write date from observation time
        call date(tag, time)

        ! (1) compute & write H, HA, LHT, HLHT, R
        write (*, *) '             ├── 「函数」H_matrix(M), use 1D locations to compute H,HA,AHAT...'
        call H_matrix(M)                    ! H(M,N), use 1D locations to compute H,HA,AHATT, AHASS
        !call L_matrix(M2,M)                    ! LHT(N,M), use 3D locations to get LHTT, LHSS
        !call R_matrix(M,M)                    ! magnitude still needs to be determined

        ! (2) the second factor
        write (*, *) '             ├── 「函数」readmatrix(HA, M, NN, "HA", 2),'
        call readmatrix(HA, M, NN, 'HA', 2)        ! HA(M,NN)
        write (*, *) "                 「读取文件」"//'ensemble/HAmatrix.txt,'
        write (*, *) "                        Reading matrix HA(",M,",",NN,"),"

        HAT = transpose(HA)                    ! HAT(NN,M)
        write (*, *) "             ├── 「变量」W0，为增益矩阵W中的H*B*(H)',"
        write (*, *) "                        W=BH'(alpha*HBH'+(NN-1)*R)^(-1),"
        write (*, *) "                        B=AA',这是ENOI与OI区别所在，"
        W0 = matmul(HA, HAT)                    ! HA(M,NN) HAT(NN,M) --> W0(M,M)

        !if (localize) then
        !   call readmatrix(HLHT,M,M,'HLHT',4)  ! HLHT(M,M)
        !   W0 = HLHT*W0
        !endif

        !call readmatrix(R,M,M,'R',1)
        write (*, *) "             ├── 「变量」R，为增益矩阵W中的R,"
        write (*, *) "                        R是观测矩阵协防差矩阵，"
        R = 0
        do i = 1, M
            do j = 1, M
                if (i .eq. j) then
                    R(i, j) = 1
                end if
            end do
        end do

      !!========================================================================
      !!                    Check error variances                             !!
        !open(55,file='/home/chako/Argo/bias_nay/Index3D.dta',form='unformatted')!!
        !read(55) Tindex3D, Sindex3D                                             !!
        !close(55)                                                               !!
                                                                              !!
        !open(33,file='ensemble/check_error_vari'//tag//'.txt',form='formatted') !!
        !do i=1,M                                                                !!
        !   if (i<=M2(1)) then                                                   !!
        !      write(33,'(I3,I3,F24.16,F24.16)') Tindex3D(i,4), Tindex3D(i,3),&  !!
        !                                        R(i,i), W0(i,i)*alpha/(NN-1)    !!
        !   else                                                                 !!
        !      write(33,'(I3,I3,F24.16,F24.16)') Sindex3D(i-M2(1),4),&           !!
        !                   Sindex3D(i-M2(1),3), R(i,i), W0(i,i)*alpha/(NN-1)    !!
        !   endif                                                                !!
        !enddo                                                                   !!
        !close(33)                                                               !!
      !!========================================================================

        write (*, *) "             ├── 「变量」W0，进行更新，加上缩放因子和R，"
        write (*, *) "                        FAQ：alpha，背景误差斜方差矩阵的缩放因子，"
        write (*, *) "                        FAQ：观测误差斜方差矩阵R前需乘以（NN-1），"
        W0 = alpha*W0 + (NN - 1)*R                 ! W0(M,M)

        write (*, *) "             ├── 「变量」W2，求逆矩阵，"
        call inverse(W0, W2, M)                  ! W2(M,M)

        ! (3) the first factor
        ! the upper part of W: WT(N/2,M)
        ! allocate(AHAT1(N/2,M2(1)))
        ! call readmatrix(AHAT1,N/2,M2(1),'AHAT1',5)
        ! if (localize) then
        !    allocate(LHTT(N/2,M2(1)))
        !    call readmatrix(LHTT,N/2,M2(1),'LHTT0',5,1)
        !    AHAT1 = AHAT1*LHTT
        ! endif
        ! allocate(AHAT2(N/2,M2(2)))
        ! call readmatrix(AHAT2,N/2,M2(2),'AHAT2',5)
        ! if (localize) then
        !    allocate(LHSS(N/2,M2(2)))
        !    call readmatrix(LHSS,N/2,M2(2),'LHSS0',5,1)
        !    AHAT2 = AHAT2*LHSS
        ! endif

        ! allocate(WT(N/2,M))
        ! WT(:,1:M2(1)) = AHAT1
        ! WT(:,M2(1)+1:M) = AHAT2
        ! deallocate(AHAT1,AHAT2)
        ! WT = matmul(WT,W2)
        ! WT = alpha*WT
        ! call writematrix(WT,N/2,M,'WT',2)
        ! deallocate(WT)

        ! the lower part of W: WS(N/2,M)
        ! allocate(AHAS1(N/2,M2(1)))
        ! call readmatrix(AHAS1,N/2,M2(1),'AHAS1',5)
        ! if (localize) then
        !    AHAS1 = AHAS1*LHTT
        !    deallocate(LHTT)
        ! endif
        ! allocate(AHAS2(N/2,M2(2)))
        ! call readmatrix(AHAS2,N/2,M2(2),'AHAS2',5)
        ! if (localize) then
        !    AHAS2 = AHAS2*LHSS
        !    deallocate(LHSS)
        ! endif

        ! allocate(WS(N/2,M))
        ! WS(:,1:M2(1)) = AHAS1
        ! WS(:,M2(1)+1:M) = AHAS2
        ! deallocate(AHAS1,AHAS2)
        ! WS = matmul(WS,W2)
        ! WS = alpha*WS
        ! call writematrix(WS,N/2,M,'WS',2)
        ! deallocate(WS)

     !!---wjc
        allocate (W_wjc_ljc(N, M), AHAT(N, M))

        write (*, *) '             ├── 「函数」readmatrix(AHAT, N, M, "AHAT", 4),'
        call readmatrix(AHAT, N, M, 'AHAT', 4)
        write (*, *) "                 「读取文件」"//'ensemble/AHATmatrix.txt,'
        write (*, *) "                        Reading matrix AHAT(",N,",",M,"),"
        W_wjc_ljc = matmul(AHAT, W2)

        write (*, *) '             ├── 「函数」writematrix(W_wjc_ljc, N, M, "W", 1),'
        call writematrix(W_wjc_ljc, N, M, 'W', 1)
        write (*, *) '                 「生成文件」ensemble/Wmatrix.txt,'
        write (*, *) "                        Writing matrix W(",N,",",M,"),"
        deallocate (AHAT, W_wjc_ljc)
     !!--------
        
        write (*, *) '             ├── 「done」W_matrix(M, time)'
        return
    end subroutine W_matrix

end module mod_matrix_W
