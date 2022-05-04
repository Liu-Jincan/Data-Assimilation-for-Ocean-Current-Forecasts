module mod_matrix_write
    use mod_params, only: programs
    implicit none

contains
    subroutine writematrix(matrix, dim1, dim2, mat_name, name_length)
        implicit none
        integer, intent(in)   :: dim1, dim2
        real, intent(in)      :: matrix(dim1, dim2)
        integer, intent(in)   :: name_length
        character(len=name_length), intent(in) :: mat_name
        integer :: i, j

        !mat_name=trim(adjustl(mat_name))
        ! write (*, *) "***"//"「生成文件」"//'ensemble/'//mat_name//'matrix.txt,'
        ! write (*, *) "              Writing matrix "//mat_name//"(",dim1,",",dim2,"),"

        ! open (unit=111, file='/home/wjc/wjc_work/DA_Code/ensemble/'//mat_name//'matrix.txt', status='new')
        
        open (unit=111, file='ensemble/'//mat_name//'matrix.txt', status='new')
        do i = 1, dim1
            write (111, *) (matrix(i, j), j=1, dim2)
        end do
        close (111)

        ! write (*, *) "              done,"

        return
    end subroutine writematrix
    subroutine writematrix_ENOI(matrix, dim1, dim2, mat_name, name_length)
        implicit none
        integer, intent(in)   :: dim1, dim2
        real, intent(in)      :: matrix(dim1, dim2)
        integer, intent(in)   :: name_length
        character(len=name_length), intent(in) :: mat_name
        integer :: i, j

        !mat_name=trim(adjustl(mat_name))
        ! write (*, *) "***"//"「生成文件」"//'ensemble/'//mat_name//'matrix.txt,'
        ! write (*, *) "              Writing matrix "//mat_name//"(",dim1,",",dim2,"),"

        ! open (unit=111, file='/home/wjc/wjc_work/DA_Code/ensemble/'//mat_name//'matrix.txt', status='new')
        
        open (unit=111, file=programs//'/ENOI/'//mat_name//'matrix.txt', status='replace')
        do i = 1, dim1
            write (111, *) (matrix(i, j), j=1, dim2)
        end do
        close (111)

        ! write (*, *) "              done,"

        return
    end subroutine writematrix_ENOI

end module mod_matrix_write
