  t_beg='20190101 000000' ; t_end='20190130 230000' ; t_rst='20190107 090000' 
  dt='3600' ;    tn='25'

#     undefined t_rst will give no restart file
  if [ -z "$t_rst" ]
  then
    dte='   0'
    t_rst=$t_end
  else
    dte='   1'
  fi

   fstID=`echo $t_beg | sed 's/ /\./g'`
   rstID=`echo $t_rst | sed 's/ /\./g'`
echo $fstID
echo $rstID
