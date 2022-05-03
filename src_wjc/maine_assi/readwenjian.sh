

 mapfile myarr <ceshi.txt

 echo ${myarr[0]}
num=${#myarr[@]} 
echo $num
echo ${#myarr[1]}
haha=${myarr[1]}

echo ${haha:0:5}
