program main
   use mod_parms
   implicit none
   real :: tmp
   integer :: n2
   character :: year*4


   call abcd

   tmp = 0.0

   print *, 'hello world.'

   n2 = 1992
   write (year, '(I4)') n2
end program
