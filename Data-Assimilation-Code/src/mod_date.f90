module mod_date
    implicit none

contains
    subroutine date(flag, times)
        ! 函数说明：
        ! 输入：    times       (/yyyy, mm, dd, hh, ff, ss/)
        ! 输出：    flags       '20210121'


        implicit none
        integer, intent(in) :: times(6)
        character(len=8), intent(out) :: flag

        character :: year*4, month*2, day*2          ! *4 表示4个字节，https://www.manongdao.com/article-818662.html

        write (year, '(I4)') times(1)                ! I 表示输出整数，4表示输出的宽度，https://wenku.baidu.com/view/9f1f2f02cfbff121dd36a32d7375a417866fc1b1.html
        if (times(2) < 10) then
            write (month, '(I1)') times(2)
            month = '0'//month
        else
            write (month, '(I2)') times(2)
        end if
        if (times(3) < 10) then
            write (day, '(I1)') times(3)
            day = '0'//day
        else
            write (day, '(I2)') times(3)
        end if

        flag = year//month//day

        return
    end subroutine date

end module mod_date
