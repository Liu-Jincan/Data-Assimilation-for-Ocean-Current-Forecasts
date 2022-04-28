module mod_matrix_H
    use mod_params, only: N, NN, programs
    use mod_matrix_read
    use mod_matrix_write
    implicit none

contains
    subroutine H_matrix(blank,iiii,jjjj,M,nc_fileName,tag)
        implicit none
        integer :: iiii, jjjj
        character*255 :: blank, str,nc_fileName,tag
        integer, intent(in) :: M
        real, allocatable :: H(:, :), A(:, :), HA(:, :), HAT(:, :)
        real, allocatable :: AHAT(:, :)

        integer :: i, j
        integer :: Index1D(M)

        !!
        str = trim(blank)//'1. 读取每个nc文件每个时刻对应的Index1.txt，'&
            &//'存储观测数据相对于背景场的位置，'&
            &//'假如有5个观测,则Tindex1D=(10 15 20 22 30 36),其中10表示第一个观测最近的网格点的index为10,'
        if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
        i = index(nc_fileName, '.') ! . 在字符串的位置，
        str = programs//'/'//nc_fileName(1:i - 1)//'_nc_Index1/'//trim(tag)
        ! write (*,*) str
        open (55, file=str, status='old')
        read (55, *) Index1D
        close (55)
        ! write (*,*) Index1D
        ! write (*,*) 1
 
        str = trim(blank)//'2. 根据Index1.txt得到每个nc文件每个时刻的H观测算子，H(M,N)'
        if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
        ! (1) compute matrix H
        allocate (H(M, N))
        H = 0.0
        do i = 1, M
            H(i, Index1D(i)) = 1.0
        end do

        ! write (*, *) '                    ├── 「函数」writematrix(H, M, N, “H”, 1),'
        ! write (*, *) '                               输出H二维矩阵到文本文件, '
        ! write (*, *) '                               H大部分元素是0,稀疏,'
        ! write (*, *) '                               H其他元素为1,为1的个数与观测数一致,'
        ! write (*, *) '                               H的第一个维度是观测数量M,'
        ! write (*, *) '                               H的第二个维度是总共的网格点数N,'
        call writematrix_ENOI(H, M, N, 'H', 1)
        ! write (*, *) "                        「生成文件」"//'ensemble/Hmatrix.txt,'
        ! write (*, *) "                               Writing matrix H(",M,",",N,"),"
        deallocate (H)


        !!
        str = trim(blank)//'3. 读取A(N,NN)，计算HA(M,NN)'
        if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
        ! (2) compute matrix HA
        allocate (A(N, NN), HA(M, NN))
        ! write (*, *) '                    ├── 「函数」readmatrix(A, N, NN, "A", 1),'
        ! write (*, *) '                               读取文本文件的A二维矩阵,'
        ! write (*, *) '                               A的第一个维度是总共的网格点数N,'
        ! write (*, *) '                               A的第二个维度是集合的尺寸NN,'
        call readmatrix_ENOI(A, N, NN, 'A', 1)
        ! write (*, *) "                        「读取文件」"//'ensemble/Amatrix.txt,'
        ! write (*, *) "                               Reading matrix A(",N,",",NN,"),"
        do j = 1, NN
            do i = 1, M
                HA(i, j) = A(Index1D(i), j)
            end do
        end do
        ! print *, 'sdsdsdsds'
        ! write (*, *) '                    ├── 「函数」writematrix(HA, M, NN, “HA”, 2),'
        ! write (*, *) '                               输出H*A二维矩阵到文本文件,'
        ! write (*, *) '                               HA的计算不应使用matmul,需考虑H的稀疏,'
        ! write (*, *) '                               HA的第一个维度是观测数量M,'
        ! write (*, *) '                               HA的第二个维度是集合的尺寸NN,'
        call writematrix_ENOI(HA, M, NN, 'HA', 2)
        ! write (*, *) "                        「生成文件」"//'ensemble/HAmatrix.txt,'
        ! write (*, *) "                               Writing matrix HA(",M,",",NN,"),"

        !!
        str = trim(blank)//'4. 计算HAT(NN,M),AHAT(N,M)'
        if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
        ! (3) compute matrix A(HAT): upper left and lower right
        allocate (HAT(NN, M))
        HAT = transpose(HA)

        allocate (AHAT(N, M))
        AHAT = matmul(A, HAT)

        ! write (*, *) '                    ├── 「函数」writematrix(AHAT, N, M, "AHAT", 4),'
        ! write (*, *) "                               输出A*(HA)'二维矩阵到文本文件,"
        ! write (*, *) '                               AHAT的计算使用matmul,'
        ! write (*, *) '                               AHAT的第一个维度是总共的网格点数N,'
        ! write (*, *) '                               AHAT的第二个维度是观测数量M,'
        call writematrix_ENOI(AHAT, N, M, 'AHAT', 4)
        ! write (*, *) "                        「生成文件」"//'ensemble/AHATmatrix.txt,'
        ! write (*, *) "                               Writing matrix AHAT(",N,",",M,"),"

        deallocate (A, HA, AHAT)

        ! write (*, *) '                    ├── 「done」H_matrix(M), '
        return
    end subroutine H_matrix

end module mod_matrix_H
