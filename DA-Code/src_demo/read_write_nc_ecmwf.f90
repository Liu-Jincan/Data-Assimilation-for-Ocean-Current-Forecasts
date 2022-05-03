PROGRAM read_write_nc
 use netcdf
!!!ecwmf的风场的纬度是从高纬度到低纬度,ww3需要将它反过来,当然winduv也需要反过来
 INTEGER:: nx,ny,nt,k,Head,Tail
 
 CHARACTER(LEN=256) filename,outfile,COM_str,fname1,temp_str
 INTEGER, parameter :: NP = SELECTED_REAL_KIND(8) 
 REAL(KIND=NP),allocatable::lon(:),lat(:),windu(:,:,:),windv(:,:,:),time1(:),temp_array(:)
 
 INTEGER:: ncid0,status0,varid0

 INTEGER(KIND=4):: ncid,x_dimid,y_dimid,t_dimid
 INTEGER(KIND=4):: varid,x_varid,y_varid,t_varid,u_varid,v_varid
 INTEGER(KIND=4), DIMENSION(3):: dimids
 REAL scale_factor,add_offset,temp


 nx=101
 ny=73
 nt=124



 if(.NOT.ALLOCATED(lon)) then
    allocate(lon(nx))
    allocate(temp_array(nx))
    allocate(lat(ny))
    allocate(time1(nt))
    allocate(windu(nx,ny,nt))
    allocate(windv(nx,ny,nt))
 end if
 
 k=0
time1=0
windu=0
windv=0

 filename='wind_ecmwf.nc'

 !------------Begin read wind products---------------------------------！
 status0=nf90_open(filename,0,ncid0)
 if(status0 .ne.nf90_noerr) then
   print *, nf90_strerror(status0)
   stop 'can not open nc file!'
 end if

  !---------READ LON----------------------------------------------!
  status0=nf90_inq_varid(ncid0,'longitude',varid0)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  status0 = nf90_get_var(ncid0,varid0,lon)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  !!-------------------------------------------------------------!!

  !---------READ LAT----------------------------------------------!
  status0=nf90_inq_varid(ncid0,'latitude',varid0)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  status0 = nf90_get_var(ncid0,varid0,lat)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  !!-------------------------------------------------------------!!


  !---------READ TIME----------------------------------------------!
  status0=nf90_inq_varid(ncid0,'time',varid0)

  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  status0 = nf90_get_var(ncid0,varid0,time1)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if


!---------READ uwnd----------------------------------------------!
  status0=nf90_inq_varid(ncid0,'u10',varid0)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  status0 = nf90_get_var(ncid0,varid0,windu)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if
  status0 = nf90_get_att(ncid0, varid0, 'scale_factor', scale_factor)
  status0 = nf90_get_att(ncid0, varid0, 'add_offset', add_offset)

  windu=windu*scale_factor+add_offset

  !!-------------------------------------------------------------!!

!---------READ vwnd----------------------------------------------!
  status0=nf90_inq_varid(ncid0,'v10',varid0)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  status0 = nf90_get_var(ncid0,varid0,windv)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if
  status0 = nf90_get_att(ncid0, varid0, 'scale_factor', scale_factor)
  status0 = nf90_get_att(ncid0, varid0, 'add_offset', add_offset)

  windv=windv*scale_factor+add_offset

  !!-------------------------------------------------------------!!


  !---------CLOSE---------------------------------------------!
  status0=nf90_close(ncid0)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if
  !!-------------------------------------------------------------!!
 
 !!翻转纬度-----------------------------
  Head = 1                             ! start with the beginning
  Tail = ny                             ! start with the end
   DO                                   ! for each pair...
      IF (Head >= Tail)  EXIT           !    if Head crosses Tail, exit
      temp    = lat(Head)                 !    otherwise, swap them
      lat(Head) = lat(Tail)
      lat(Tail) = Temp
      Head    = Head + 1                !    move forward
      Tail    = Tail - 1                !    move backward
   END DO  
 !!-------------------------------------- 

 !!翻转uandv-------------------------------
 do i=1,nt
   Head=1
   Tail=ny
   do
     if (Head >= Tail) EXIT
     temp_array=windu(:,Head,i)
     windu(:,Head,i)=windu(:,Tail,i)
     windu(:,Tail,i)=temp_array
     Head=head+1
     Tail=Tail-1
   end do
 end do

  do i=1,nt
   Head=1
   Tail=ny
   do
     if (Head >= Tail) EXIT
     temp_array=windv(:,Head,i)
     windv(:,Head,i)=windv(:,Tail,i)
     windv(:,Tail,i)=temp_array
     Head=head+1
     Tail=Tail-1
   end do
 end do



 print*,'Begin write nc'

 outfile='mywind1.nc'
 status0=nf90_create(outfile,NF90_CLOBBER,ncid)


 
 status0=nf90_def_dim(ncid,"lon",nx,x_dimid)
 status0=nf90_def_dim(ncid,"lat",ny,y_dimid)
 status0=nf90_def_dim(ncid,"time",nt,t_dimid)

 status0=nf90_def_var(ncid,"lon",NF90_DOUBLE,x_dimid,x_varid)
 status0=nf90_def_var(ncid,"lat",NF90_DOUBLE,y_dimid,y_varid)
 status0=nf90_def_var(ncid,"time",NF90_DOUBLE,t_dimid,t_varid)
 dimids=(/x_dimid,y_dimid,t_dimid/)
 status0=nf90_def_var(ncid,"windu",NF90_DOUBLE,dimids,u_varid)
 status0=nf90_def_var(ncid,"windv",NF90_DOUBLE,dimids,v_varid)
 

! status0=nf90_put_att(ncid,x_varid,'standard_name','longitude')
! status0=nf90_put_att(ncid,x_varid,'units','degrees_east')
! status0=nf90_put_att(ncid,x_varid,'long_name','Longitude in degrees east')
! status0=nf90_put_att(ncid,x_varid,'_Fillvalue','-9999.0')
! status0=nf90_put_att(ncid,x_varid,'axis','X')

! status0=nf90_put_att(ncid,y_varid,'standard_name','latitude')
! status0=nf90_put_att(ncid,y_varid,'units','degrees_north')
! status0=nf90_put_att(ncid,y_varid,'long_name','Latitude in degrees north')
! status0=nf90_put_att(ncid,y_varid,'_Fillvalue','-9999.0')
! status0=nf90_put_att(ncid,y_varid,'axis','Y');

 status0=nf90_put_att(ncid,t_varid,"units","hours since 1900-01-01 00:00:00")
 status0=nf90_put_att(ncid,t_varid,"calendar","proleptic_gregorian")
! status0=nf90_put_att(ncid,t_varid,'delta_t','0000-00-00 06:00:00')

! status0=nf90_put_att(ncid,u_varid,'standard_name','eastward_wind')
! status0=nf90_put_att(ncid,u_varid,'long_name','u-wind vector component at 10 meters')
 status0=nf90_put_att(ncid,u_varid,'units','m s-1')
 status0=nf90_put_att(ncid,u_varid,'_Fillvalue','-9999.0')
! status0=nf90_put_att(ncid,u_varid,'coordinates','time latitude longitude')

! status0=nf90_put_att(ncid,v_varid,'standard_name','northward_wind')
! status0=nf90_put_att(ncid,v_varid,'long_name','v-wind vector component at 10 meters')
 status0=nf90_put_att(ncid,v_varid,'units','m s-1')
 status0=nf90_put_att(ncid,v_varid,'_Fillvalue','-9999.0')
! status0=nf90_put_att(ncid,v_varid,'coordinates','time latitude longitude')
 
 status0=nf90_enddef(ncid)
 
 status0=nf90_put_var(ncid,x_varid,lon)
 status0=nf90_put_var(ncid,y_varid,lat)
 status0=nf90_put_var(ncid,t_varid,time1)
 status0=nf90_put_var(ncid,u_varid,windu)
 status0=nf90_put_var(ncid,v_varid,windv)

 status0=nf90_close(ncid)

 print*,'end write nc'

  if(ALLOCATED(lon)) then
    deallocate(lon)
    deallocate(temp_array)
    deallocate(lat)
    deallocate(time1)
    deallocate(windu)
    deallocate(windv)
 end if

 END PROGRAM

 !!----------------------------------------------------------!!
