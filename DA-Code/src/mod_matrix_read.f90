module mod_matrix_read
    implicit none

contains
    subroutine readmatrix(matrix, dim1, dim2, mat_name, name_length, opt)
        implicit none
        integer, intent(in)   :: name_length
        integer, intent(in)   :: dim1, dim2
        character(len=name_length), intent(in) :: mat_name
        real, intent(out)     :: matrix(dim1, dim2)
        integer, intent(in), optional :: opt

        integer :: i, j

        ! mat_name=trim(adjustl(mat_name))

        write (*, *) "*** Reading matrix "//mat_name//"..."

        open (unit=110, file='/home/wjc/wjc_work/DA_Code/ensemble/'//mat_name//'matrix.txt', status='old')
        ! if (present(opt)) then
        do i = 1, dim1
            read (110, *, end=110) (matrix(i, j), j=1, dim2)
        end do
        ! else
        !   read(11,*) matrix
        ! endif
110     close (110)

        write (*, *) "    ...done."

        return
    end subroutine readmatrix

end module mod_matrix_read
