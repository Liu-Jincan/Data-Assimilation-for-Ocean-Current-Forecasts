module mod_date
   implicit none

contains
   subroutine date_day(flag, times)
      implicit none
      integer, intent(in) :: times(6)
      character(len=8), intent(out) :: flag

      character :: year*4, month*2, day*2

      write (year, '(I4)') times(1)
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
   end subroutine date_day

   subroutine date_minute(flag, times)
      implicit none
      integer, intent(in) :: times(6)
      character(len=12), intent(out) :: flag

      character :: year*4, month*2, day*2, hour*2, minute*2

      write (year, '(I4)') times(1)
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
      if (times(4) < 10) then
         write (hour, '(I1)') times(4)
         hour = '0'//hour
      else
         write (hour, '(I2)') times(4)
      end if
      if (times(5) < 10) then
         write (minute, '(I1)') times(5)
         minute = '0'//minute
      else
         write (minute, '(I2)') times(5)
      end if
      flag = year//month//day//hour//minute

      return
   end subroutine date_minute
end module mod_date
