#!/bin/csh
#################################################################
# Csh Script to retrieve 10 online Data files of 'ds083.2',
# # total 153.2M. This script uses 'wget' to download data.
# #
# # Highlight this script by Select All, Copy and Paste it into a file;
# # make the file executable and run it on command line.
# #
# # You need pass in your password as a parameter to execute
# # this script; or you can set an environment variable RDAPSWD
# # if your Operating System supports it.
# #
# # Contact grace@ucar.edu (Grace Peng) for further assistance.
# #################################################################
set pswd = SETPASSWD
if(x$pswd == x && `env | grep RDAPSWD` != '') then
 set pswd = $RDAPSWD
endif
if(x$pswd == x) then
 echo
 echo Usage: $0 YourPassword     
 echo
 exit 1
endif
set v = `wget -V |grep 'GNU Wget ' | cut -d ' ' -f 3`
set a = `echo $v | cut -d '.' -f 1`
set b = `echo $v | cut -d '.' -f 2`
if(100 * $a + $b > 109) then
 set opt = 'wget --no-check-certificate'
else
 set opt = 'wget'
endif
set opt1 = '-O Authentication.log --save-cookies auth.rda_ucar_edu --post-data'
set opt2 = "email=patrick.hawbecker@nrel.gov&passwd=$pswd&action=login"
$opt $opt1="$opt2" https://rda.ucar.edu/cgi-bin/login
set opt1 = "-N --load-cookies auth.rda_ucar_edu"
set opt2 = "$opt $opt1 http://rda.ucar.edu/data/ds083.2/"
set filelist = ( \
  grib2/YY1/YY1.MM1/fnl_YY1MM1DD1_00_00.grib2 \
  grib2/YY1/YY1.MM1/fnl_YY1MM1DD1_06_00.grib2 \
  grib2/YY1/YY1.MM1/fnl_YY1MM1DD1_12_00.grib2 \
  grib2/YY1/YY1.MM1/fnl_YY1MM1DD1_18_00.grib2 \
)
while($#filelist > 0)
 set syscmd = "$opt2$filelist[1]"
 echo "$syscmd ..."
 $syscmd
 shift filelist
end

rm -f auth.rda_ucar_edu Authentication.log
exit 0

