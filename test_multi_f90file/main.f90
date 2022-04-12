subroutine abc
   implicit none
   print *, 'hello world.'
   print *, 'hello world.'
end subroutine abc

real function mean(x, n)
   implicit none
   integer, intent(in) :: n
   real, intent(in) :: x(n)
   integer :: i, n2
   real :: m

   m = 0.0; n2 = 0
   do i = 1, n
      if (isnan(x(i)) .eqv. .false.) then
         n2 = n2 + 1
         m = m + x(i)
      end if
   end do
   m = m/real(n2)
   mean = m

   return
end function mean

program main
   use mod_parms
   implicit none
   real :: tmp
   call abc
   call abcd
   tmp = 0.0
   print *, 'hello world.'
end program
