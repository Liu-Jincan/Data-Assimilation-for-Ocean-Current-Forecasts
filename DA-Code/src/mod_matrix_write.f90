module mod_matrix_write
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

        write (*, *) "*** Writing matrix "//mat_name//"..."

        ! open (unit=111, file='/home/wjc/wjc_work/DA_Code/ensemble/'//mat_name//'matrix.txt', status='new')
        open (unit=111, file='ensemble/'//mat_name//'matrix.txt', status='new')
        do i = 1, dim1
            write (111, *) (matrix(i, j), j=1, dim2)
        end do
        close (111)

        write (*, *) "    ...done."

        return
    end subroutine writematrix

end module mod_matrix_write
