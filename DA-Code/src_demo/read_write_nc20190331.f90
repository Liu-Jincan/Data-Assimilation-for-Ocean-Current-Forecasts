PROGRAM read_write_nc
 use netcdf

 INTEGER:: nx,ny,nt,N_time,k,num_N,begin_lon,end_lon,begin_lat,end_lat
 
 CHARACTER(LEN=256) filename,outfile,COM_str,fname1,temp_str
 INTEGER, parameter :: NP = SELECTED_REAL_KIND(8) 
 REAL(KIND=NP),allocatable::lon(:),lat(:),windu(:,:,:),windv(:,:,:),time1(:)
 
 INTEGER:: ncid0,status0,varid0

 INTEGER(KIND=4):: ncid,x_dimid,y_dimid,t_dimid
 INTEGER(KIND=4):: varid,x_varid,y_varid,t_varid,u_varid,v_varid
 INTEGER(KIND=4), DIMENSION(3):: dimids



 nx=1440
 ny=628
 nt=4


 fname1='wenjianname.txt'

 COM_str='dir ~/wjc_work/fortran/ccmp/*CCMP*.nc>'//trim(fname1)
 call system(COM_str)
 num_N=0
  open(1287,file=fname1,status='old')
  do while(.true.)
    read(1287,*,end=1287) temp_str
    num_N=num_N+1
  end do
 1287 close(1287)
 
 num_N=num_N*4

print*,num_N

 if(.NOT.ALLOCATED(lon)) then
    allocate(lon(nx))
    allocate(lat(ny))
    allocate(time1(num_N))
    allocate(windu(nx,ny,num_N))
    allocate(windv(nx,ny,num_N))
 end if
 
 k=0
time1=0
windu=0
windv=0

 open(1580,file=fname1)
 do while(.true.)
   read(1580,'(a)',end=1580) filename
   !--------------open CCMP nc file----------!!     
   k=k+1
   N_time=k*nt
   print*,k
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

  status0 = nf90_get_var(ncid0,varid0,time1((N_time-3):N_time))
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if


!---------READ uwnd----------------------------------------------!
  status0=nf90_inq_varid(ncid0,'uwnd',varid0)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  status0 = nf90_get_var(ncid0,varid0,windu(:,:,(N_time-3):N_time))
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if
  !!-------------------------------------------------------------!!

!---------READ vwnd----------------------------------------------!
  status0=nf90_inq_varid(ncid0,'vwnd',varid0)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if

  status0 = nf90_get_var(ncid0,varid0,windv(:,:,(N_time-3):N_time))
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if
  !!-------------------------------------------------------------!!


  !---------CLOSE---------------------------------------------!
  status0=nf90_close(ncid0)
  if(status0 .ne.nf90_noerr) then
    print *, nf90_strerror(status0)
    stop
  end if
  !!-------------------------------------------------------------!!
  !------------End read forecast products---------------------------------！
 print*,'end read forecast products'
end do  !!读CCMP文件结束
1580 close(1580)

 print*,'Begin write nc'

 outfile='ccmpwind.nc'
 status0=nf90_create(outfile,NF90_CLOBBER,ncid)

 !--  1061对应-95度,1281对应-40,394对应lat20,515对应lat50
 begin_lon=1060
 end_lon=1282
 begin_lat=394
 end_lat=515

 
 nx=end_lon-begin_lon+1
 ny=end_lat-begin_lat+1
 
 status0=nf90_def_dim(ncid,"lon",nx,x_dimid)
 status0=nf90_def_dim(ncid,"lat",ny,y_dimid)
 status0=nf90_def_dim(ncid,"time",num_N,t_dimid)

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

 status0=nf90_put_att(ncid,t_varid,"units","hours since 1987-01-01 00:00:00")
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
 
 status0=nf90_put_var(ncid,x_varid,lon(begin_lon:end_lon))
 status0=nf90_put_var(ncid,y_varid,lat(begin_lat:end_lat))
 status0=nf90_put_var(ncid,t_varid,time1)
 status0=nf90_put_var(ncid,u_varid,windu(begin_lon:end_lon,begin_lat:end_lat,:))
 status0=nf90_put_var(ncid,v_varid,windv(begin_lon:end_lon,begin_lat:end_lat,:))

 status0=nf90_close(ncid)

 print*,'end write nc'

 END PROGRAM

 !!----------------------------------------------------------!!
