#!/glade/u/home/hawbecke/local/envs/mmc/bin/python
import pandas as pd
from mmctools.mmctools.wrf.preprocessing import ERA5

# Where you want the ERA5 data to be placed:
icbc_dir = '/glade/scratch/hawbecke/WRF/ICBC/ERA5/'

# Start date for download
start_time = pd.to_datetime('2010-05-12 12:00:00')
# End date for download
end_time   = pd.to_datetime('2010-05-27 00:00:00')
 
# bounds for ERA5 data:
area = {'N':79, 'W':-63, 'S':26, 'E':77}

# We want 1 hour intervals
freq       = '1h'

# Create date range from start_time to end_time
datetimes = pd.date_range(start=start_time,
                            end=end_time,
                           freq=freq)
# Download the data
icbc = ERA5()
icbc.download(datetimes,path=icbc_dir,bounds=area)
