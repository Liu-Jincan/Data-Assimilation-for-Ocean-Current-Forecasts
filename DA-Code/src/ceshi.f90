program DA_cycle
    use mod_analysis
    implicit none
    integer :: yyyy, mm, dd, hh, ff, ss, time(6)
    integer :: i, j, M
    real, allocatable :: yo(:)
    real:: xx(5, 79*61)
    integer :: Index1D(5)
    character, allocatable:: mat_name

    M = 5

    ! (3) read in observation
    write (*, *) 'Updating the background with observational data...'

    allocate (yo(M))
    open (55, file='/home/wjc/wjc_work/DA_Code/input/obs_data.txt', status='old')
    read (55, *) yo
    close (55)
    write (*, *) yo
    write (*, *) '*** SUCCESS Sorted observation is read in!'

end program DA_cycle
