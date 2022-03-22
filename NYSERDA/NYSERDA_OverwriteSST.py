#!/glade/u/home/hawbecke/local/envs/mmc/bin/python

from mmctools.wrf.preprocessing import OverwriteSST
import os

# Option to smooth the SST datasets:
smoothed = False

# Which reanalysis is being used:
reanalysis = 'MERRA2'

# Base directory where everything is stored:
#main_directory = '/glade/work/hawbecke/MMC/NYSERDA/'
main_directory = '/glade/work/hawbecke/MMC/NYSERDA/test/'

# Location of downloaded SST datasets
#main_sst_dir = '{}SST/'.format(main_directory)
main_sst_dir = '/glade/work/hawbecke/MMC/NYSERDA/SST/'

# Location where new met_em datasets will be saved:
met_dir = '{}met_em/{}/'.format(main_directory,reanalysis)
if not os.path.exists(met_dir):
    os.makedirs(met_dir)


# Location of original met_em files:
#orig_met_dir = '{}orig/'.format(met_dir)
orig_met_dir = '/glade/scratch/hawbecke/WRF/MMC/NYSERDA/SENSITIVITY_SUITE/setup_test/MERRA2_DFLT_NOSK_CHRN_MDIS/'

if met_dir not in orig_met_dir:
    # Move the files...
    print('The location of the original met_em files is not where the rest will be located...')
    print('Copying the met_em files to where the code will expect them:')
    expected_met_dir = '{}orig/'.format(met_dir)
    print(expected_met_dir)
    if not os.path.exists(expected_met_dir):
        os.makedirs(expected_met_dir)
    print('Copying...')
    #os.system('cp {}met_em.d0* {}.'.format(orig_met_dir,expected_met_dir))
    orig_met_dir = expected_met_dir


#sst_datasets = ['MUR', 'CMC', 'NAVO', 'OSPO', 'GOES16']
sst_datasets = ['CMC']

for new_data in sst_datasets:
    print('Overwriting for: {}'.format(new_data))
    # Location of where you want to save new met_em files:
    out_dir = '{}{}/'.format(met_dir,new_data)

    # Location of SST data to be included in new met_em files:
    sst_dir = '{}{}/'.format(main_sst_dir,new_data)
    
    OverwriteSST(met_type=reanalysis,
                 overwrite_type=new_data,
                 met_directory=orig_met_dir,
                 sst_directory=sst_dir,
                 out_directory=out_dir,
                 smooth_opt=smoothed,
                 fill_missing=True,
                 skip_finished=True,)
