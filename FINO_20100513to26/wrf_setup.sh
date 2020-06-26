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
CASE_STR="FINO" 
# NUMBER OF HOURS TO RUN
nhours=60 #60
# NUMBER OF SIMULATIONS
nsims=1 #46
# HOURS BETWEEN SIMULATIONS
sim_delta=48
# YEAR START
yyS="2010"
# MONTH START
mmS="05"
# DAY START
ddS="14"
# HOUR START
hhS="12"
# NUMBER OF DOMAINS TO USE
MAX_DOM="3"
# DOMAIN CONFIG (default: "")
DOM_STR=""
# REANALYSIS TO USE (ERA, NARR, GFS, ERA5)
REAN_STR="ERA5" 

# LOCATION TO RUN WPS/WRF
OUT_DIR_BASE="/glade/scratch/$USER/WRF/MMC/FINO1/20100512_to_20100526/FINO_ERA5_MESO/${CASE_STR}"
# LOCATION OF WPS EXECUTABLES
WPS_DIR="$HOME/Models/WRF/WRFvMMC/WPS"
# LOCATION OF WHERE TO DOWNLOAD REANALYSIS DATA
ICBC_DIR="/glade/scratch/$USER/WRF/ICBC"
# LOCATION OF WRF EXECUTABLES
EXE_DIR="$HOME/Models/WRF/WRFvMMC/WRF/run"

# SETUP COMPUTING ENVIRONMENT
module purge
module load intel/19.0.2 
module load mpt/2.19
module load netcdf/4.6.3
export NETCDF=$NETCDF_FORTRAN
export HDF5=$HDF5_ROOT_DIR

# - - - - - - - - - END USER SETTINGS - - - - - - - - - - - #
#===========================================================#

echo -n "link, get, or skip ICBC data?: "
read get_ICBC
if [ $get_ICBC == "get" ]; then
    echo -n "RDA email address: "
    read emailaddr

    echo -n "RDA password: "
    read -s passwd
fi

TEMPLATE_DIR="`pwd`/templates"

sim_counter="0"
while [ $sim_counter -lt $nsims ]
do
    echo "start date: $yyS-$mmS-$ddS $hhS:00:00"
    # LOCATION TO RUN WPS/WRF
    OUT_DIR="${OUT_DIR_BASE}_$yyS$mmS$ddS$hhS"
    echo $OUT_DIR

# Don't overwrite existing directory!
    if [ -d $OUT_DIR ]; then
        echo -n "$OUT_DIR already exists! Do you want to replace it? (y/n): "
        read replace_or_quit
        if [ $replace_or_quit == "n" ]; then
            exit
        elif [ $replace_or_quit == "y" ]; then
            echo "Overwriting previous setup."
        else
            echo "Invalid option. Please enter 'y' or 'n'. Exiting."
            exit
        fi
    else
        mkdir -p $OUT_DIR
    fi

# If directory doesn't exist, create it
    if [ ! -d $ICBC_DIR ]; then
        mkdir -p $ICBC_DIR
    fi


# Calculate the end date...
    END_DATE=$(date -d "$yyS-$mmS-$ddS $hhS + $nhours hours" +%Y-%m-%d_%H:%M:%S)
    END_DATE_STR=$(echo $END_DATE | tr _ " ")
    yyE=$(date -d "$END_DATE_STR" +%Y)
    mmE=$(date -d "$END_DATE_STR" +%m)
    ddE=$(date -d "$END_DATE_STR" +%d)
    hhE=$(date -d "$END_DATE_STR" +%H)
    echo "end date: $END_DATE_STR"



#======================================================================
#======================================================================
#                    Get all of the ICBC data...
#======================================================================
#======================================================================

    if [ $get_ICBC == "get" ]; then
        cd $ICBC_DIR
        pwd
        if [ $REAN_STR == "NARR" ]; then
            cp $TEMPLATE_DIR/get_narr_constants.csh get_narr_constants.csh
            sed -i "s/SETPASSWD/$passwd/g" get_narr_constants.csh
            sed -i "s/MY.EMAIL@asdf.com/$emailaddr/g" get_narr_constants.csh
            ./get_narr_constants.csh && rm get_narr_constants.csh
            echo "Use templates/get_narr.csh to download necessary files"
        fi
        days_of_simulation=$(( nhours / 24 + 2))
        counter="0"
        while [ $counter -lt $days_of_simulation ]
        do
            sim_day=$(date -d "$yyS-$mmS-$ddS + $counter days" +%Y-%m-%d)
            yy=$(echo $sim_day | cut -f1 -d-)
            mm=$(echo $sim_day | cut -f2 -d-)
            dd=$(echo $sim_day | cut -f3 -d-)
            if [ $REAN_STR == "ERA" ]; then
                cp $TEMPLATE_DIR/get_erai_template.csh get_erai.csh
                sed -i "s/SETPASSWD/$passwd/g" get_erai.csh
                sed -i "s/MY.EMAIL@asdf.com/$emailaddr/g" get_erai.csh
                sed -i "s/DD1/$dd/g" get_erai.csh
                sed -i "s/MM1/$mm/g" get_erai.csh
                sed -i "s/YY1/$yy/g" get_erai.csh
                chmod u+x get_erai.csh
                ./get_erai.csh && rm get_erai.csh
                #cp get_erai.csh get_erai.csh_${CASE_STR}_$counter
            elif [ $REAN_STR == "GFS" ]; then
                cp $TEMPLATE_DIR/get_gfs_template.csh get_gfs.csh
                sed -i "s/SETPASSWD/$passwd/g" get_gfs.csh
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
    elif [ $get_ICBC == "link" ]; then
        cd $ICBC_DIR
        pwd
        days_of_simulation=$(( nhours / 24 + 2))
        counter="0"
        while [ $counter -lt $days_of_simulation ]
        do
            sim_day=$(date -d "$yyS-$mmS-$ddS + $counter days" +%Y-%m-%d)
            yy=$(echo $sim_day | cut -f1 -d-)
            mm=$(echo $sim_day | cut -f2 -d-)
            dd=$(echo $sim_day | cut -f3 -d-)
            if [ $REAN_STR == "ERA" ]; then
                cp $TEMPLATE_DIR/link_erai_template.sh link_erai.sh
                sed -i "s/SETPASSWD/$passwd/g" link_erai.sh
                sed -i "s/MY.EMAIL@asdf.com/$emailaddr/g" link_erai.sh
                sed -i "s/DD1/$dd/g" link_erai.sh
                sed -i "s/MM1/$mm/g" link_erai.sh
                sed -i "s/YY1/$yy/g" link_erai.sh
                chmod u+x link_erai.sh
                ./link_erai.sh && rm link_erai.sh
                #cp get_erai.csh get_erai.csh_${CASE_STR}_$counter
            elif [ $REAN_STR == "GFS" ]; then
                echo "You may need to download the data manually... see get_gfs_template.csh for details"
                exit
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
    fi


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
    sed -i "s/START_DATE/${yyS}-${mmS}-${ddS}_${hhS}:00:00/g" namelist.wps
    sed -i "s/END_DATE/$END_DATE/g" namelist.wps
    sed -i "s/FIELD/$REAN_STR/g" namelist.wps

    ln -sf $WPS_DIR/geogrid.exe .
    ln -sf $WPS_DIR/ungrib.exe .
    ln -sf $WPS_DIR/metgrid.exe .
    if [ ! -d geogrid ]; then
        mkdir geogrid
    fi
    if [ ! -d metgrid ]; then
        mkdir metgrid
    fi
    ln -sf $WPS_DIR/geogrid/GEOGRID.TBL geogrid/.
    ln -sf $WPS_DIR/metgrid/METGRID.TBL metgrid/.

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

    if [ ! -f geo_em.d0$MAX_DOM.nc ]; then
        run_geogrid="True"
        #./geogrid.exe
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
            echo "Linking grib files... if this fails, read directions in the WRF-setups/README.md to download ERA5 data and make sure ICBC_DIR is set correctly."
            ./link_grib.csh $ICBC_DIR/era_5_* .
        else
            echo "I don't know which IC/BC files to link..."
        fi
        run_ungrib="True"
        #./ungrib.exe
        if [ $REAN_STR = "NARR" ]; then
            sed -i "s/! constants_name = 'SST:DATE'/ constants_name = 'FIX:1979-11-08_00'/g" namelist.wps
        fi
        run_metgrid="True"
        #./metgrid.exe
    fi
    cp $TEMPLATE_DIR/submit_wps.sh .
    sed -i "s/#SIMNAME/${CASE_STR}_$yyS$mmS$ddS$hhS/g" submit_wps.sh
    if [ $run_geogrid == "True" ]; then
        sed -i "s~# Run geogrid~./geogrid.exe~g" submit_wps.sh
    fi
    if [ $run_ungrib == "True" ]; then
        sed -i "s~# Run ungrib~./ungrib.exe~g" submit_wps.sh
    fi
    if [ $run_metgrid == "True" ]; then
        sed -i "s~# Run metgrid~./metgrid.exe~g" submit_wps.sh
        echo 'rm $REAN_STR:*' >> submit_wps.sh
        echo 'GRIBFILES="GRIBFILE.*"' >> submit_wps.sh
        echo 'for f in $GRIBFILES' >> submit_wps.sh
        echo 'do' >> submit_wps.sh
        echo '    unlink $f' >> submit_wps.sh
        echo 'done' >> submit_wps.sh
    fi
    qsub submit_wps.sh



#======================================================================
#======================================================================
#                               Run WRF               
#======================================================================
#======================================================================

    echo "Using templates/namelist.input.template_$REAN_STR"
    cp $TEMPLATE_DIR/namelist.input.template_$REAN_STR namelist.input
    sed -i "s/NHOURS/$nhours/g" namelist.input
    sed -i "s/YY1/$yyS/g" namelist.input
    sed -i "s/MM1/$mmS/g" namelist.input
    sed -i "s/DD1/$ddS/g" namelist.input
    sed -i "s/HH1/$hhS/g" namelist.input
    sed -i "s/YY2/$yyE/g" namelist.input
    sed -i "s/MM2/$mmE/g" namelist.input
    sed -i "s/DD2/$ddE/g" namelist.input
    sed -i "s/HH2/$hhE/g" namelist.input
    sed -i "s/MAXDOM/$MAX_DOM/g" namelist.input

    ln -sf $EXE_DIR/[aBbCcEGgHikLmopRStUV]* .
    ln -sf $EXE_DIR/real.exe .
    ln -sf $EXE_DIR/wrf.exe .

    dirs_to_create=( auxout rsl wrfout towers wrfrst )
    for dir in "${dirs_to_create[@]}" ; do
        if [ ! -d $dir ]; then mkdir $dir
        fi
    done

    cp $TEMPLATE_DIR/tslist .
    cp $TEMPLATE_DIR/myoutfields.txt .
    cp $TEMPLATE_DIR/submit_real.sh .
    sed -i "s/SIMNAME/$ddS/g" submit_real.sh
    cp $TEMPLATE_DIR/submit_wrf_template.sh submit_wrf.sh
    sed -i "s/SIMNAME/$ddS/g" submit_wrf.sh
    sed -i "s/REAN/$REAN_STR/g" submit_wrf.sh
    sed -i "s/YY1MM1DD1/$yyS$mmS$ddS/g" submit_wrf.sh

    #sbatch submit_real.sh
    #sbatch submit_wrf.sh
    NEW_START_DATE=$(date -d "$yyS-$mmS-$ddS $hhS + $sim_delta hours" +%Y-%m-%d_%H:%M:%S)
    NEW_START_DATE_STR=$(echo $NEW_START_DATE | tr _ " ")
    yyS=$(date -d "$NEW_START_DATE_STR" +%Y)
    mmS=$(date -d "$NEW_START_DATE_STR" +%m)
    ddS=$(date -d "$NEW_START_DATE_STR" +%d)
    hhS=$(date -d "$NEW_START_DATE_STR" +%H)

    sim_counter=$[$sim_counter+1]
    echo "----------"
    
done
