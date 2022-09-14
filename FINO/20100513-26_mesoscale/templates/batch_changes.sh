#!/bin/bash
for value in FINO_2010051212  FINO_2010051412  FINO_2010051612  FINO_2010051812  FINO_2010052012  FINO_2010052212  FINO_2010052412
do
    cd $value/
    pwd
    #unlink wrf.exe 
    #unlink real.exe
    #ln -sf /glade/u/home/hawbecke/Models/WRF/WRFvMMC/WRF/run/wrf.exe .
    #ln -sf /glade/u/home/hawbecke/Models/WRF/WRFvMMC/WRF/run/real.exe .
    for i in GRIBFIL*; do unlink $i; done
    ln -sf /glade/work/hawbecke/MMC/FINO/met_em/ERA5/orig/met_em.d0* .
    cd ..
done
