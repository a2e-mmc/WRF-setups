#!/bin/bash
set -e
#===========================================================#
#                                                           #
# This script needs the namelist.wps.template to be editted #
# before execution. The user must change the domain size,   # 
# location, and parent_ij locations manually. Once this is  #
# completed, this script will download the specified        #
# reanalysis data for the simulation days, run WPS for the  #
# dates specified, and then set up submission scripts for   #
# WRF to be executed manually.                              #
#                                                           #
# Created by Patrick Hawbecker - April 2019                 #
#===========================================================#

# - - - - - - - - - - USER SETTINGS - - - - - - - - - - - - #
# CASE NAME
CASE_STR="SWIFT"
# NUMBER OF HOURS TO RUN
nhours=60
# YEAR START
yyS="2013"
# MONTH START
mmS="11"
# DAY START
ddS="08"
# HOUR START
hhS="00"
# NUMBER OF DOMAINS TO USE
MAX_DOM="2"
# DOMAIN CONFIG (default: "")
DOM_STR=""
# REANALYSIS TO USE (ERA, NARR, GFS, ERA5)
REAN_STR="GFS" 

# LOCATION OF WPS EXECUTABLES
WPS_DIR="$HOME/WRF/WRFV4.1/WPS"
# LOCATION OF WHERE TO DOWNLOAD REANALYSIS DATA
ICBC_DIR="/scratch/$USER/WRF/ICBC"
# LOCATION OF WRF EXECUTABLES
EXE_DIR="$HOME/WRF/WRFV4.1/WRF_Tendencies/run"
# LOCATION TO RUN WPS/WRF
OUT_DIR="/scratch/$USER/WRF/${CASE_STR}_$yyS$mmS$ddS$hhS"

# - - - - - - - - - END USER SETTINGS - - - - - - - - - - - #
#===========================================================#

# If directory doesn't exist, create it.
if [ ! -d $ICBC_DIR ]; then
    mkdir -p $ICBC_DIR
fi
if [ ! -d $OUT_DIR ]; then
    mkdir -p $OUT_DIR
fi
OUT_DIR="$OUT_DIR/$REAN_STR"
if [ ! -d $OUT_DIR ]; then
    mkdir -p $OUT_DIR
fi

TEMPLATE_DIR="`pwd`/templates"

# Calculate the end date...
END_DATE=$(date -d "$yyS-$mmS-$ddS + $nhours hours" +%Y-%m-%d_%H:%M:%S)
END_DATE_STR=$(echo $END_DATE | tr _ " ")
yyE=$(date -d "$END_DATE_STR" +%Y)
mmE=$(date -d "$END_DATE_STR" +%m)
ddE=$(date -d "$END_DATE_STR" +%d)
hhE=$(date -d "$END_DATE_STR" +%H)

#======================================================================
#======================================================================
#                    Get all of the ICBC data...
#======================================================================
#======================================================================
cd $ICBC_DIR
pwd

echo -n "RDA email address: "
read emailaddr

echo -n "RDA password: "
read -s passwd


if [ $REAN_STR == "NARR" ]; then
    sed "s/SETPASSWD/$passwd/g" $TEMPLATE_DIR/get_narr_constants.csh > get_narr_constants.csh
    sed -i "s/MY.EMAIL@asdf.com/$emailaddr/g" get_narr_constants.csh
    ./get_narr_constants.csh && rm get_narr_constants.csh
    echo "Use templates/get_narr.csh to download necessary files"
fi
days_of_simulation=$(( nhours / 24 + 1))
counter="0"
while [ $counter -lt $days_of_simulation ]
do
    sim_day=$(date -d "$yyS-$mmS-$ddS + $counter days" +%Y-%m-%d)
    yy=$(echo $sim_day | cut -f1 -d-)
    mm=$(echo $sim_day | cut -f2 -d-)
    dd=$(echo $sim_day | cut -f3 -d-)
    if [ $REAN_STR == "ERA" ]; then
        sed "s/SETPASSWD/$passwd/g" $TEMPLATE_DIR/get_erai_template.csh > get_erai.csh
        sed -i "s/MY.EMAIL@asdf.com/$emailaddr/g" get_erai.csh
        sed -i "s/DD1/$dd/g" get_erai.csh
        sed -i "s/MM1/$mm/g" get_erai.csh
        sed -i "s/YY1/$yy/g" get_erai.csh
        chmod u+x get_erai.csh
        ./get_erai.csh && rm get_erai.csh
        #cp get_erai.csh get_erai.csh_${CASE_STR}_$counter
    elif [ $REAN_STR == "GFS" ]; then
        cp $TEMPLATE_DIR/get_gfs_template.csh .
        sed "s/SETPASSWD/$passwd/g" $TEMPLATE_DIR/get_gfs_template.csh > get_gfs.csh
        sed -i "s/MY.EMAIL@asdf.com/$emailaddr/g" get_gfs.csh
        sed -i "s/YY1/$yy/g" get_gfs.csh
        sed -i "s/MM1/$mm/g" get_gfs.csh
        sed -i "s/DD1/$dd/g" get_gfs.csh
        chmod u+x get_gfs.csh
        ./get_gfs.csh && rm get_gfs.csh
        #cp get_gfs.csh get_gfs.csh_${CASE_STR}_$counter
    elif [ $REAN_STR == "NARR" ]; then
        echo "You may need to download the data manually... see get_narr_template.csh for details"
        echo "Do you want to continue? (y/n)"
        read user_continue
        if [ $user_continue == "n" ]; then
            exit
        fi
    elif [ $REAN_STR == "ERA5" ]; then
        if [ -z "$user_continue" ]; then
            echo "You may need to download the data manually... see wind wiki for details"
            echo "Do you want to continue? (y/n)"
            read user_continue
            if [ $user_continue == "n" ]; then
                exit
            fi
        fi

    fi
    counter=$[$counter+1]
    
done
echo "Finished downloading ICBC data."
#======================================================================
#======================================================================
#                               Run WPS               
#======================================================================
#======================================================================

WPS_TEMPLATE="$TEMPLATE_DIR/namelist.wps.template"
if [ -n "$DOM_STR" ]; then
    # append DOM_STR
    WPS_TEMPLATE="${WPS_TEMPLATE}.${DOM_STR}"
fi

cd $OUT_DIR
cp $WPS_TEMPLATE namelist.wps
sed "s/START_DATE/${yyS}-${mmS}-${ddS}_${hhS}:00:00/g" namelist.wps > namelist.wps_S
sed "s/END_DATE/$END_DATE/g" namelist.wps_S > namelist.wps_E && rm namelist.wps_S
sed "s/FIELD/$REAN_STR/g" namelist.wps_E > namelist.wps && rm namelist.wps_E

ln -sf $WPS_DIR/geogrid.exe .
ln -sf $WPS_DIR/ungrib.exe .
ln -sf $WPS_DIR/metgrid.exe .
if [ ! -d geogrid ]; then mkdir geogrid
fi
if [ ! -d metgrid ]; then mkdir metgrid
fi
ln -sf $WPS_DIR/geogrid/GEOGRID.TBL geogrid/.
ln -sf $WPS_DIR/metgrid/METGRID.TBL metgrid/.

module purge
module load intel-mpi/2018.0.3
module load netcdf-c/4.6.2/intel-18.0.3-mpi
module load netcdf-f/4.4.4
module load wrf/3.9.1
module load hdf5/1.10.4/intel1803-impi 
export NETCDF=$NETCDF_FORTRAN
export HDF5=$HDF5_ROOT_DIR 

cp $WPS_DIR/link_grib.csh .
if [ $REAN_STR == "ERA" ]; then
    ln -sf $WPS_DIR/ungrib/Variable_Tables/Vtable.ERA-interim.pl Vtable
elif [ $REAN_STR = "GFS" ]; then
    ln -sf $WPS_DIR/ungrib/Variable_Tables/Vtable.GFS Vtable
elif [ $REAN_STR = "NARR" ]; then
    ln -sf $WPS_DIR/ungrib/Variable_Tables/Vtable.NARR Vtable
elif [ $REAN_STR == "ERA5" ]; then
    ln -sf $WPS_DIR/ungrib/Variable_Tables/Vtable.ERA-interim.pl Vtable
else
    echo "I don't know which Vtable to use..."
fi

if [ ! -f geo_em.d0$MAX_DOM.nc ]; then ./geogrid.exe
fi

if [ ! -f met_em.d0$MAX_DOM.$END_DATE.nc ]; then
    if [ $REAN_STR == "ERA" ]; then
        ./link_grib.csh $ICBC_DIR/ei.oper* .
    elif [ $REAN_STR = "GFS" ]; then
        ./link_grib.csh $ICBC_DIR/fnl* .
    elif [ $REAN_STR = "NARR" ]; then
        ./link_grib.csh $ICBC_DIR/rr-fixed* .
        mv namelist.wps namelist.wps_full
        cp $TEMPLATE_DIR/namelist.narr.constants namelist.wps
        ./ungrib.exe
        mv namelist.wps_full namelist.wps
        ./link_grib.csh $ICBC_DIR/NARR* .
    elif [ $REAN_STR == "ERA5" ]; then
        ./link_grib.csh $ICBC_DIR/era_5_* .
    else
        echo "I don't know which IC/BC files to link..."
    fi
    ./ungrib.exe
    if [ $REAN_STR = "NARR" ]; then
        sed "s/! constants_name = 'SST:DATE'/ constants_name = 'FIX:1979-11-08_00'/g" namelist.wps > namelist.wps_temp
        mv namelist.wps_temp namelist.wps
    fi
    ./metgrid.exe
    rm $REAN_STR:*
    GRIBFILES="GRIBFILE.*"
    for f in $GRIBFILES
    do
        unlink $f
    done
fi

#======================================================================
#======================================================================
#                               Run WRF               
#======================================================================
#======================================================================

cp $TEMPLATE_DIR/namelist.input.template_$REAN_STR namelist.input
echo "Using templates/namelist.input.template_$REAN_STR"
sed "s/YY1/$yyS/g" namelist.input > namelist.input_Y
sed "s/MM1/$mmS/g" namelist.input_Y > namelist.input_M && rm namelist.input_Y
sed "s/DD1/$ddS/g" namelist.input_M > namelist.input_D && rm namelist.input_M
sed "s/HH1/$hhS/g" namelist.input_D > namelist.input_H && rm namelist.input_D

sed "s/YY2/$yyE/g" namelist.input_H > namelist.input_Y && rm namelist.input_H
sed "s/MM2/$mmE/g" namelist.input_Y > namelist.input_M && rm namelist.input_Y
sed "s/DD2/$ddE/g" namelist.input_M > namelist.input_D && rm namelist.input_M
sed "s/HH2/$hhE/g" namelist.input_D > namelist.input && rm namelist.input_D

ln -sf $EXE_DIR/[aBbCcEGgHikLmopRStUV]* .
ln -sf $EXE_DIR/real.exe .
ln -sf $EXE_DIR/wrf.exe .

dirs_to_create=( auxout rsl wrfout towers wrfrst )
for dir in "${dirs_to_create[@]}" ; do
    if [ ! -d $dir ]; then mkdir $dir
    fi
done

cp $TEMPLATE_DIR/submit_real.sh .
sed "s/REAN/$REAN_STR/g" $TEMPLATE_DIR/submit_wrf_template.sh > submit_wrf.sh
sed -i "s/YY1MM1DD1/$yyS$mmS$ddS/g" submit_wrf.sh

#sbatch submit_real.sh
#sbatch submit_wrf.sh
