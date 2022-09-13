import pandas as pd
import sys
sys.path.append('/g/g12/lassman1/mmc/mmc_github_clones/')
from mmctools.wrf.preprocessing import ERA5
import subprocess

period_s = pd.to_datetime('2010-05-12')
period_e = pd.to_datetime('2010-05-28')
start_time = 12

area = [79, -63, 26, 77]

date_range = pd.date_range( start = period_s, end = period_e, freq = '1d' )
for dd, day in enumerate( date_range):
    if dd==0:
        download_s = day + pd.Timedelta( start_time, 'h' )
    else:
        download_s = day
    download_e = day + pd.Timedelta( 23, 'h' )

    datetimes = pd.date_range( start = download_s,
                               end   = download_e,
                               freq = '1h' )
    area_str = str(area).replace('[', '').replace(']','').replace(',','')
    cmd = './download_data.py {} {} {} {}'.format( download_s, download_e, '1h', area_str )
    print(cmd)
    subprocess.Popen([cmd], shell = True )
