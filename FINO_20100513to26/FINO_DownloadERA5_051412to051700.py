#!/glade/u/home/hawbecke/local/envs/mmc/bin/python
import pandas as pd
from mmctools.mmctools.wrf.preprocessing import ERA5

icbc_dir = '/glade/scratch/hawbecke/WRF/ICBC/ERA5/'
icbc_dir = './icbc_test/'

period_s = pd.to_datetime('2010-05-12')
period_e = pd.to_datetime('2010-05-27')
start_hr = 12
 
area = {'N':79, 'W':-63, 'S':26, 'E':77}

freq       = '1h'

start_time = period_s + pd.to_timedelta(start_hr,'h')
end_time   = period_e

datetimes = pd.date_range(start=start_time,
                            end=end_time,
                           freq=freq)

icbc = ERA5()
icbc.download(datetimes,path=icbc_dir,bounds=area)
