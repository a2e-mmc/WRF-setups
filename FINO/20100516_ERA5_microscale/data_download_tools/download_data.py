#!/g/g12/lassman1/local/quartz/PYTHON3.7/bin/python
import pandas as pd
import sys
sys.path.append('/g/g12/lassman1/mmc/mmc_github_clones/mmctools/wrf/')
from preprocessing import ERA5

args = sys.argv
if len(args) > 3:
    start_time = pd.to_datetime(' '.join(args[1:3]) )
    end_time = pd.to_datetime(' '.join(args[3:5]) )
    freq = args[5]
    area = [int(args[6]), int(args[7]), int(args[8]), int(args[9]) ]

    datetimes = pd.date_range( start = start_time,
                           end = end_time,
                           freq = freq )

else:    
    datetimes = pd.date_range(start = "2010-05-12 0:00",
                          end   = "2010-05-29 12:00",
                          freq='3600s' )
    area = [72, 54, 34, -39]
#datetimes = pd.date_range(start = "2010-05-12 0:00",
#                          end   = "2010-05-15 0:00",
#                          freq='3600s' )
#sys.exit()


icbc = ERA5()
icbc.download(datetimes, area = area )
