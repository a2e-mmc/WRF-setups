import os
import glob
import xarray as xr
import numpy as np

file_names = ['MUR-JPL-L4-GLOB-v4.1','UKMO-L4HRfnd-GLOB-OSTIA','ABOM-L4LRfnd-GLOB-GAMSSA_28km','AVHRR_OI-NCEI-L4-GLOB-v2.0','CMC0.1deg-CMC-L4-GLOB-v3.0',
              'Geo_Polar_Blended-OSPO-L4-GLOB-v1.0','JPL_OUROCEAN-L4UHfnd-GLOB-G1SST','K10_SST-NAVO-L4-GLOB-v01']

#file_names = ['UKMO-L4HRfnd-GLOB-OSTIA']
file_names = ['AVHRR_OI-NCEI-L4-GLOB-v2.0']

date_start = '20200405'
date_end   = '20200408'

wrf_dir = '/glade/work/hawbecke/MMC/NYSERDA/met_em/MERRA2/orig/'
met_files = glob.glob('{}met_em.d01*'.format(wrf_dir))

met = xr.open_dataset(met_files[0])
min_lon_orig = int(np.floor(float(np.min(met.XLONG_M))) - 2)
min_lat_orig = int(np.floor(float(np.min(met.XLAT_M))) - 2)
max_lon_orig = int(np.floor(float(np.max(met.XLONG_M))) + 2)
max_lat_orig = int(np.floor(float(np.max(met.XLAT_M))) + 2)

# Example call:
#./subset_dataset.py -s 20100101 -f 20100201 -b -140 -110 20 30 -x MUR-JPL-L4-GLOB-v4.1
for fn in file_names:
    if 'NAVO' in fn:
        min_lat = max_lat_orig*-1
        max_lat = min_lat_orig*-1
    else:
        min_lat = min_lat_orig
        max_lat = max_lat_orig
    min_lon = min_lon_orig
    max_lon = max_lon_orig
    cmd = 'subset_dataset.py -s {0} -f {1} -b {2} {3} {4} {5} -x {6}'.format(
                        date_start,date_end,min_lon,max_lon,min_lat,max_lat,fn)
    print(cmd)
    os.system(cmd)
