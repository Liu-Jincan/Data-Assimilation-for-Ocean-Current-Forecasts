subroutine abc
    implicit none
    print *, 'hello world.'
    print *, 'hello world.'
end subroutine abc

program main
    use mod_parms
    implicit none
    real :: tmp
    call abc
    call abcd
    tmp = 0.0
    print *, 'hello world.'
end program
