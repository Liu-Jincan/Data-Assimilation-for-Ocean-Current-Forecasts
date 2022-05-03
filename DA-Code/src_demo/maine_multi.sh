# 0. Preparations -----------------------------------------------------------

  set -e

# User must specify compiler string (as per in ww3_dir/bin options) here:
#  compstr="Intel"

# 0.a Define model input

   wind='ccmpwind'           # 0.25 degree ccmp wind data to be used by all grids
   buoys='points'       ###由于是多网格,除了正常的网格外,所有的输入(比如风场)也要定义虚拟的网格.如果进行点输出,也需要定义虚拟网格
  

# 0.b Define model grids

   mods='grd1 grd2'

   NR=`echo $mods | wc -w | awk '{print $1}'`

# 0.c Set initial conditions

# itype=1 ; Hini='10.0'    # Set initial swell
# itype=3                  # Initialize by wind
  itype=5                  # Start from calm conditions

# 0.d Set output
  FIELDS='WND HS T02 DIR'

# 0.e Set run times
#     undefined t_rst will give no restart file

  t_beg='20080301 000000' ; t_end='20080401 000000' ; t_rst= 
     dt='3600' ;    tn='744'

  if [ -z "$t_rst" ]
  then
    dte='   0'
    t_rst=$t_end
  else
    dte='   1'
  fi

   fstID=`echo $t_beg | sed 's/ /\./g'`
   rstID=`echo $t_rst | sed 's/ /\./g'`

# 0.f Parallel environment 

    MPI='yes'              # run ww3_multi in MPI mode
    proc=4

# 0.g Set-up variables

  case_dir=`pwd`
  ww3_dir=`echo $case_dir | sed 's/\/cases\/*//g'`
 
  path_c="$case_dir"
  path_d="$path_c/input"   # path for data directory
  path_w="$path_c/work" 
  path_e="/home/wjc/WW3_516/exe"

# 0.h Clean-up
 
  rm -rf $path_w
  mkdir -p $path_w
  cd $path_w

  echo ' ' ; echo ' '
  echo '                  ======> TEST RUN WAVEWATCH III <====== '
  echo '                    ==================================   '
  echo ' '

# 1. Grid pre-processor -----------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '|  Grid preprocessor |'
  echo '+--------------------+'
  echo ' '

  rm -f mod_def.*

  cp $path_d/ww3_grid.inp.* .
  cp $path_d/maine_big.* .
  cp $path_d/maine_small.* .

  for mod in $mods $wind $buoys
  do
    if [ "$mod" != 'no' ]
    then
      mv ww3_grid.inp.$mod ww3_grid.inp

      echo "   Screen ouput routed to ww3_grid.$mod.out"
      $path_e/ww3_grid >ww3_grid.$mod.out

      rm -f ww3_grid.inp
      mv mod_def.ww3 mod_def.$mod
    fi
  done

  rm -f *.bot *.obs *.mask ww3_grid.inp.*

# 2. Initial conditions -----------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '| Initial conditions |'
  echo '+--------------------+'
  echo ' '

# Compile appropriate code 

cat > ww3_strt.inp << EOF
$ WAVEWATCH III Initial conditions input file
$ -------------------------------------------
  $itype
   0.07 0.01  245. 5  -40.  20.  50.  10.  $Hini
EOF

  for grid in $mods
  do
    if [ -f $path_d/restart.$grid.$fstID ]
    then
      echo "   initial conditions from $path_d/restart.$grid.$fstID"
      ln -sf $path_d/restart.$grid.$fstID restart.$grid
    else
      rm -f mod_def.ww3
      ln -s mod_def.$grid mod_def.ww3
      echo "   Running ww3_strt for initial conditions"
      echo "   Screen ouput routed to $path_o/ww3_strt.$grid.out"
      $path_e/ww3_strt > ww3_strt.$grid.out
      mv restart.ww3 restart.$grid
    fi
  done

  rm -f ww3_strt.inp mod_def.ww3

# 3. Input fields -----------------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '| Input data         |'
  echo '+--------------------+'
  echo ' '

# Compile appropriate code 
 
 cp $path_d/ccmpwind.nc .
 rm -f mod_def.ww3
 ln -s mod_def.$wind mod_def.ww3

 cat > ww3_prnc.inp << EOF
$ WAVEWATCH III Field preprocessor input file
$ -------------------------------------------
   'WND' 'LL' T T
$
$ Name of spatial dimensions------------------------------------------ $
$ NB: time dimension is expected to be called 'time'
$
 lon lat
$
$ Variables to use --------------------------------------------------- $
$
  windu windv
$
$ Additional time input ---------------------------------------------- $
$ If time flag is .FALSE., give time of field in yyyymmdd hhmmss format.
$
$   19680606 053000
$
$ Define data files -------------------------------------------------- $
$ The input line identifies the filename using for the forcing field.
$
  'ccmpwind.nc'
$
$ -------------------------------------------------------------------- $
$ End of input file                                                    $
$ -------------------------------------------------------------------- $
EOF

  echo "   Screen ouput routed to  ww3_prnc.out"
  $path_e/ww3_prnc >  ww3_prnc.wind.out
  mv wind.ww3 wind.$wind
  rm -f ww3_prep.inp.$wind ww3_prep.inp mod_def.ww3

 
# 4. Main program -----------------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '|    Main program    |'
  echo '+--------------------+'
  echo ' '


cat > ww3_multi.inp << EOF
$ WAVEWATCH III multi-grid input file
$ ------------------------------------
  2 1 F 1 F F 
$
EOF
  if [ "$wind" != 'no' ] ; then
     echo " '$wind'  F F T F F F F"   >> ww3_multi.inp ; fi
   flags="'no' 'no' '$wind' 'no' 'no' 'no' 'no'"
  
 #echo " '$buoys'" >> ww3_multi.inp ##这句本来是该有的,但是加上会出错,索性把上面的第三个数改成F,后面直接加上点坐标

  for grid in $mods
  do
    case $grid in
     'grd1') echo " 'grd1' $flags  1 1  0.00 1.00  F" >> ww3_multi.inp ;;
     'grd2') echo " 'grd2' $flags  2 1  0.00 1.00  F" >> ww3_multi.inp ;;
       *   ) echo " *** HELP *** " ; exit 99 ;;
    esac
  done

cat >> ww3_multi.inp << EOF
$
   $t_beg  $t_end
$
   T  T
$
   $t_beg  $dt  $t_end
   N
   $FIELDS
   $t_beg  3600  $t_end
   $
   290.642 43.715 'p44032' 
   290.872 43.204 'p44005'
   292.117 43.484 'p44037'   
   291.000 44.060 'p44033'
   290.753 40.502 'p44008'
   289.856 43.531 'p44007'
   289.349 42.346 'p44013'
   290.370 42.126 'p44018'
   292.686 44.273 'p44027'
   295.980 42.500 'p44150'
   293.400 41.105 'p44011'
   294.073 42.312 'p44024'
$ 
  0.0   0.0  'STOPSTRING'

   $t_beg      0  $t_end
   $t_rst      1  $t_rst
   $t_beg      0  $t_end
   $t_beg      0  $t_end
$
  'the_end'  0
$
  'STP'
$
$ End of input file
EOF

  echo "   Running multi-grid model ..."
# echo "   Screen output routed to $path_o/ww3_multi.out"

  if [ "$MPI" = 'yes' ]
  then
    mpirun -np $proc $path_e/ww3_multi # > ww3_multi.out
  else
#   hpmcount $path_e/ww3_multi # > $path_o/ww3_multi.out
    $path_e/ww3_multi # > $path_o/ww3_multi.out
  fi

 echo 'end of ww3_multi'

  for grid in $mods
  do
    if [ -f restart001.$grid ]
    then
      echo "   Output file restart001.$grid routed to"
      echo "      $path_d/restart.$grid.$rstID"
      mv restart001.$grid $path_d/restart.$grid.$rstID
    fi
  done

  #rm -f ww3_multi.inp
  #rm -f restart.*
  #rm -f wind.*  

  set +e

  echo ' '

  set -e

# exit 99


# 5. Point output -----------------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '|    Point output    |'
  echo '+--------------------+'

cat > ww3_outp.inp << EOF
$ WAVEWATCH III Grid output post-processing
$ -----------------------------------------
  20080301 000000  3600. 744
$
$
  1
$
  -1
$  
  2
  2 33
EOF

 for mod in $mods
  do
    echo "   point data for $mod ..."
    echo "      Screen ouput routed to ww3_outp.$mod.out"
    ln -s mod_def.$mod mod_def.ww3
    ln -s out_pnt.$mod out_pnt.ww3

    $path_e/ww3_outp > ww3_outp.$mod.out

    mv tab33.ww3 tab.$mod.ww3
    rm -f mod_def.ww3 out_pnt.ww3

  done

  #rm -f ww3_outp.inp



# 6. End, cleaning up -------------------------------------------------------
  echo ' ' ; echo ' '
  echo '                  ======>  END OF WAVEWATCH III  <====== '
  echo '                    ==================================   '
  echo ' '

# End of maine_multi-------------------------------------------------------
