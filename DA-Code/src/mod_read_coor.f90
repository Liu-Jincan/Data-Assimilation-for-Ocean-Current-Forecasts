module mod_read_coor
    use netcdf
    use mod_params, only: NLONS, NLATS, LON_NAME, LAT_NAME, sub_x, sub_y, sub_xy ! NLVLS, LVL_NAME, 
    implicit none

contains
    subroutine readcoor(fname2)
        implicit none
        character(len=18), intent(in) :: fname2

        integer :: ncid
        integer :: lat_varid, lon_varid ! , lvl_varid
        ! real :: lons(NLONS, NLATS), lats(NLONS, NLATS) ! , depth(NLVLS) ! reversed order
        real :: lons(NLONS), lats(NLATS)
        ! real :: lons2(sub_x, sub_y), lats2(sub_x, sub_y)

        ! (1) Open the file.
        call check(nf90_open(fname2, nf90_nowrite, ncid))

        ! (2) Get the varids of longitude, latitude and depth
        call check(nf90_inq_varid(ncid, LON_NAME, lon_varid))
        call check(nf90_inq_varid(ncid, LAT_NAME, lat_varid))
        ! call check(nf90_inq_varid(ncid, LVL_NAME, lvl_varid))

        ! (3) Read longitude and latitude data
        call check(nf90_get_var(ncid, lon_varid, lons))
        call check(nf90_get_var(ncid, lat_varid, lats))
        ! call check(nf90_get_var(ncid, lvl_varid, depth))

        ! (4) Close the file
        call check(nf90_close(ncid))

        ! (5) Write out the coordinates
        ! lons2 = lons(sub_xy(1):sub_xy(3), sub_xy(2):sub_xy(4))
        ! lats2 = lats(sub_xy(1):sub_xy(3), sub_xy(2):sub_xy(4))
        ! open (unit=11, file='ensemble/coordinate.dta', form='unformatted')
        open (unit=11, file='ensemble/coordinate.dta', status='new')
        ! write (11) lons2, lats2 ! , depth
        write (11,*) lons
        write (11,*) lats
        close (11)

        ! write (*, *) "*** SUCCESS Coordinate is written!"

        return
    end subroutine readcoor

    subroutine check(status)
        integer, intent(in) :: status

        if (status /= nf90_noerr) then
            print *, trim(nf90_strerror(status))
            stop "Stopped"
        end if

        return
    end subroutine check

    subroutine checknc(status)
        integer, intent(in) :: status

        if (status /= nf90_noerr) then
            print *, trim(nf90_strerror(status))
            stop "Stopped"
        end if

        return
    end subroutine checknc

end module mod_read_coor
