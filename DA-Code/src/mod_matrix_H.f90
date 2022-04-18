module mod_matrix_H
    use mod_params, only: N, NN
    use mod_matrix_read
    use mod_matrix_write
    implicit none

contains
    subroutine H_matrix(M)
        implicit none
        integer, intent(in) :: M
        real, allocatable :: H(:, :), A(:, :), HA(:, :), HAT(:, :)
        real, allocatable :: AHAT(:, :)

        integer :: i, j
        integer :: Index1D(M)

        write (*, *) '                    ├── 「读取文件」input/Index1D.txt'
        write (*, *) '                                  Tindex1D,存储温度观测数据相对于背景场的位置，'
        write (*, *) '                                  假如有5个观测,则Tindex1D=(10 15 20 22 30 36),'
        write (*, *) '                                  其中10表示第一个观测最近的网格点的index为10'
        
        ! open (55, file='/home/wjc/wjc_work/DA_Code/input/Index1D.txt', status='old')
        open (55, file='input/Index1D.txt', status='old')
        read (55, *) Index1D
        close (55)
        print *, Index1D

        ! (1) compute matrix H
        allocate (H(M, N))
        H = 0.0
        do i = 1, M
            H(i, Index1D(i)) = 1.0
        end do

        call writematrix(H, M, N, 'H', 1)
        deallocate (H)

        ! (2) compute matrix HA
        allocate (A(N, NN), HA(M, NN))
        call readmatrix(A, N, NN, 'A', 1)
        do j = 1, NN
            do i = 1, M
                HA(i, j) = A(Index1D(i), j)
            end do
        end do
        print *, 'sdsdsdsds'
        call writematrix(HA, M, NN, 'HA', 2)

        ! (3) compute matrix A(HAT): upper left and lower right
        allocate (HAT(NN, M))
        HAT = transpose(HA)

        allocate (AHAT(N, M))
        AHAT = matmul(A, HAT)

        call writematrix(AHAT, N, M, 'AHAT', 4)

        deallocate (A, HA, AHAT)

        return
    end subroutine H_matrix

end module mod_matrix_H
