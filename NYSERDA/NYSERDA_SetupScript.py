#!/glade/u/home/hawbecke/local/envs/mmc/bin/python

import pandas as pd
from mmctools.wrf import preprocessing as wps
import numpy as np
from string import ascii_lowercase
import xarray as xr
import copy


# User Settings:
#===============

# Have you run this to create the first case yet?
# ... if you haven't set this to true. Once you have
# ... run WPS for the first case, you can run the 
# ... program again to:
#      - Overwrite the SST data
#      - Create a tslist file
#      - Create all the other cases
first_time_running = False

# Directory where WRF runs will be created:
#main_directory    = '/glade/scratch/hawbecke/WRF/MMC/NYSERDA/SENSITIVITY_SUITE/LES/'
main_directory    = '/glade/scratch/hawbecke/WRF/MMC/NYSERDA/SENSITIVITY_SUITE/production/'
# WRF executables location:
wrf_exe_location = '/glade/work/hawbecke/Models/WRF/WRFvMMC/WRF/run/'
# WPS executables location:
wps_exe_location = '/glade/work/hawbecke/Models/WRF/WRFv3.9.1/WPS/'
# WRF geog data path:
wrf_geog_path = '/glade/work/hawbecke/geog/'

# Case information dictionary location (to be created):
case_dict_f = '/glade/u/home/hawbecke/Code/Python/assessment/studies/NYSERDA/NYSERDA_case_dict.py'

max_dom = 5 # 2 - mesoscale only; 5 - Meso-to-LES

# Which IC/BCs are you using:
icbc_type = 'MERRA2'  # ERAI, ERA5, FNL
# Location of the IC/BC data:
icbc_directory = '/glade/work/hawbecke/public_get_merra2/merra2/wrf-interm/2020/202004/'
# Location of met_em files (if overwriting with SST; met_dir from NYSERDA_OverwriteSST.py)):
met_dir = '/glade/work/hawbecke/MMC/NYSERDA/met_em/{}'.format(icbc_type) 

# Generate eta levels:
# -------------------
p_top = 10000.0
# -- The following were found after doing a small run without specified eta levels:
sfc_temperature = 280.7896728515625
sfc_pressure = 99952.921875

working_eta_dict = {'131_levels':{'nz':131,'dz_bot':9.0,'dz_top':300.0,'steep':6.5,'infpt':0.69,'ptop':10000.0,'ztop':-999.}}

use_eta = '131_levels'

eta = wps.CreateEtaLevels(nz=working_eta_dict[use_eta]['nz'],
                          dz_bottom=working_eta_dict[use_eta]['dz_bot'],
                          dz_top=working_eta_dict[use_eta]['dz_top'],
                          transition_steepness=working_eta_dict[use_eta]['steep'],
                          transition_inflection_location=working_eta_dict[use_eta]['infpt'],
                          sfc_pressure=sfc_pressure,
                          sfc_temperature=sfc_temperature,
                          top_pressure=working_eta_dict[use_eta]['ptop'],
                          top_z=working_eta_dict[use_eta]['ztop'],
                          verbose=False)

eta_level_str = ''
count = 1
for et in eta.eta_levels:
    if count < 4:
        eta_level_str += '{0:8.7f}, '.format(et)
        count += 1
    else:
        eta_level_str += '{0:8.7f},\n  '.format(et)
        count = 1
eta_level_str = eta_level_str[:-2]
n_eta_levels = len(eta.eta_levels)



# Case specifics - 48 hour runs for 2 days, 1 day intervals
case_start  = '2020-04-04 06:00:00'
case_end    = '2020-04-06 06:00:00'
case_delta  = '2d'  # Time between runs
case_length = '48h' # How long each run is


# Submission script info
submission_dict = {
            'account_key' : 'nwsa0002',
         'walltime_hours' : {'wrf':12,'wps':2,'real':3},
             'user_email' : 'hawbecke@ucar.edu',
                  'nodes' : {'wrf':36,'wps':1,'real':32},
          'optional_args' : {'wrf':None,'wps':None,'real':None},
                   }

# Different start times for each domain:
meso_start = '2020-04-04 06:00:00'
micro_start_1 = '2020-04-05 18:00:00'
micro_start_2 = '2020-04-06 00:00:00'
micro_start_3 = '2020-04-06 00:00:00'

# Namelist specifics:
setup_dict = {
             'start_date' : [meso_start,meso_start,micro_start_1,micro_start_2,micro_start_3],
               'end_date' : '2020-04-06 06:00:00',
              'icbc_type' : icbc_type,
                'max_dom' : max_dom,
                    'dxy' : 6250,
              'time_step' : 15,
           'max_ts_level' : 66,
            'ts_buf_size' : 100,
 'tslist_unstagger_winds' : True,
'tslist_turbulent_output' : 1,
            'max_ts_locs' : 4,
             'eta_levels' : eta_level_str,
      'parent_grid_ratio' : [1,5,5,5,5],
 'parent_time_step_ratio' : [1,3,5,5,5],
         'i_parent_start' : [1,  200,  115,  225,  280],
         'j_parent_start' : [1,  200,  125,	 210,  310],
                     'nx' : [480,  481,  631,  601,  601],
                     'ny' : [480,  481,  631,  601,  601],
                'ref_lat' : 39.8,
                'ref_lon' : -73.0,
               'truelat1' : 25.0,
               'truelat2' : 55.0,
              'stand_lon' : -70.0,
          'geog_data_res' : '30s+topobath_30s',
        'input_from_file' : [True,True,True,True,True],
         'geog_data_path' : wrf_geog_path,
       'history_interval' : [120,60,30,10,10],
       'restart_interval' : 2160, 
'override_restart_timers' : True,
     'force_use_old_data' : True,
       'auxinput4_inname' : 'wrflowinp_d<domain>',
     'auxinput4_interval' : 360,
      'io_form_auxinput4' : 2,
      'iofields_filename' : ['myoutfields.txt','myoutfields.txt','myoutfieldsLES.txt','myoutfieldsLES.txt','myoutfieldsLES.txt'],
'ignore_iofields_warning' : True,
            'debug_level' : 0,
        'p_top_requested' : 10000,
               'feedback' : 0,
          'smooth_option' : 0,
             'mp_physics' : 5,
      'sf_sfclay_physics' : [1,1,1,1,1],
     'sf_surface_physics' : [2,2,2,2,2],
         'bl_pbl_physics' : [5,5,0,0,0],
             'cu_physics' : [1,0,0,0,0],
                 'isfflx' : 1,
                 'icloud' : 1,
             'sst_update' : 1,
               'sst_skin' : 0,
       'sf_ocean_physics' : 0,
             'hybrid_opt' : 0,
            'use_theta_m' : 0,
              'w_damping' : 1,
               'diff_opt' : [1,2,2,2,2],
                 'km_opt' : [4,4,2,2,2],
           'diff_6th_opt' : [2],
              'grid_fdda' : [2,0,0,0,0],
           'gfdda_inname' : 'wrffdda_d<domain>',
       'gfdda_interval_m' : [360,   0,   0,0,0],
          'io_form_gfdda' : 2,
   'if_no_pbl_nudging_uv' : [1,    0,   0,0,0],
    'if_no_pbl_nudging_t' : [1,    0,   0,0,0],
   'if_no_pbl_nudging_ph' : [1,    0,   0,0,0],
             'if_zfac_uv' : [1,    0,   0,0,0],
              'k_zfac_uv' : [51,   0,   0,0,0],
              'if_zfac_t' : [1,    0,   0,0,0],
               'k_zfac_t' : [51,   0,   0,0,0], 
             'if_zfac_ph' : [1,    0,   0,0,0], 
              'k_zfac_ph' : [51,   0,   0,0,0], 
                    'guv' : [0.0003, 0.000075, 0.000075, 0.000075, 0.000075], 
                     'gt' : [0.0003, 0.000075, 0.000075, 0.000075, 0.000075], 
                    'gph' : [0.0003, 0.000075, 0.000075, 0.000075, 0.000075], 
             'if_ramping' : 1, 
             'dtramp_min' : 60.0, 
               'xwavenum' : 7, 
               'ywavenum' : 7,
        'shalwater_z0' : 0,
                'gwd_opt' : 1,
      'diff_6th_slopeopt' : [1,0,0,0,0],
#      'auxhist15_begin_h' : [0,0,0,0,0],
#        'auxhist15_end_h' : [0,0,0,60,60],
#     'auxhist15_interval' : [0,0,0,5,0],
#      'auxhist15_outname' : 'auxout/mmc_d<domain>_<date>',
#   'frames_per_auxhist15' : [0,0,0,1,1],
    
#     'force_use_old_data' : True,
#       'auxinput5_inname' : "cellpert_d<domain>",
#     'auxinput5_interval' : [100000,100000,100000,  10, 10], 
#      'io_form_auxinput5' : 2,
#              'cell_pert' : [False,False,False,True,True],
#              'cell_tvcp' : [False,False,False,True,True],
#              'pert_tsec' : [100., 100., 100., 100., 20.],
#           'cell_kbottom' : [3, 3, 3, 3, 3],  
#                  'm_opt' : [0,0,0,1,1],
                    'c_k' : [0.1],
          'cpm_meso_pblh' : [0,0,1,1,1],
                'cpm_opt' : [0,0,0,1,1],
                  'm_opt' : [0,0,0,1,1],
              'cpm_lim_z' : 50.0,
                 'cpm_eb' : [0,0,0,1,1],
                 'cpm_wb' : [0,0,0,1,1],
                 'cpm_nb' : [0,0,0,1,1],
                 'cpm_sb' : [0,0,0,1,1],
}


# IO Adjustments:
io_fields_meso = {'remove': 
                 {0 : ['EDMF_A','EDMF_QC','EDMF_QT','EDMF_ENT','EDMF_W','EDMF_THL','QVAPOR','SH20',
                   'F_ICE_PHY','F_RAIN_PHY','F_RIMEF_PHY','QCLOUD','QRAIN','QSNOW','QHAIL','QGRAUP','QVAPOR',
                  'SMCREL','SHDMAX','SHDMIN','SNOALB','SEAICE','XICEM','SFROFF',
                  'UDROFF','IVGTYP','ACSNOM','SNOW','SNOWNC','SNOWH','CANWAT','COSZEN','LAI','TSLB',
                  'GLW','TMN','SNOWC','SR','QICE','QNICE','QNSNOW','QNRAIN','QNGRAUPEL',
                  'ACLWDNB','ACLWDNBC','ACLWDNT','ACLWDNTC','ACLWUPB','ACLWUPBC','ACLWUPT','ACLWUPTC',
                  'ACSWDNB','ACSWDNBC','ACSWDNT','ACSWDNTC','ACSWUPB','ACSWUPBC','ACSWUPT','ACSWUPTC',
                  'AFWA_RAIN','ALBBCK','ALBEDO','E','EMISS','NEST_POS','LAKEMASK',
                  'MAPFAC_M','MAPFAC_U','MAPFAC_V','MAPFAC_MX','MAPFAC_MY','MAPFAC_UX','MAPFAC_UY','MAPFAC_VX','MF_VX_INV','MAPFAC_VY',
                  'I_ACLWDNB','I_ACLWDNBC','I_ACLWDNT','I_ACLWDNTC','I_ACLWUPB','I_ACLWUPBC','I_ACLWUPT','I_ACLWUPTC','SINALPHA',
                  'I_ACSWDNB','I_ACSWDNBC','I_ACSWDNT','I_ACSWDNTC','I_ACSWUPB','I_ACSWUPBC','I_ACSWUPT','I_ACSWUPTC',
                  'GRAUPELNC','HAILNC','NOAHRES','NUPDRAFT','OLR','XICEM','ZS','DZS',
                  'VAR_SSO','RDX','RDY','SMOIS','VAR','ALBBCK','XLAND','EL_PBL',
                  'P_HYD','CWM','RQCBLTEN','RQIBLTEN','RQNIBLTEN','RQVBLTEN','RUBLTEN','RVBLTEN','RTHBLTEN',
                  'ACHFX','ACLHF','GRDFLX','ACGRDFLX','SMOIS',
                  'SWUPB','SWUPBC','SWDNB','SWDNBC','LWUPB','LWUPBC','LWDNB','LWDNBC',
                  'RU_TEND','RU_TEND_ADV','RU_TEND_PGF','RU_TEND_COR','RU_TEND_CURV','RU_TEND_HDIFF','RU_TEND_PHYS','T_TEND_ADV',
                  'RV_TEND','RV_TEND_ADV','RV_TEND_PGF','RV_TEND_COR','RV_TEND_CURV','RV_TEND_HDIFF','RV_TEND_PHYS',
                  'U_G','V_G','U_G_TEND','V_G_TEND','MUU','MUV','MUT']
                 },
             'add' : {0: ['ZNT','SST','SSTSK','UST','QFX','HFX','LH','PBLH','TKE_PBL','QKE']}
            }


io_fields_LES = copy.deepcopy(io_fields_meso)
io_fields_LES['add'][0] = ['ZNT','SST','SSTSK','UST','QFX','HFX','LH','PBLH','TKE']
#io_fields_LES['add'][15] = ['U','V','W','T','P','PB','PH','PHB','HFX','THM']


# Information for each case:
case_dict = {
    'DFLT':{'sst':'orig','diurnal_var':'NOSK','roughness':'CHRN','land_surface':'MDIS','color':'darkred'},
    'CMCS':{'sst':'CMC','diurnal_var':'NOSK','roughness':'CHRN','land_surface':'MDIS','color':'c'},
    'OSPO':{'sst':'OSPO','diurnal_var':'NOSK','roughness':'CHRN','land_surface':'MDIS','color':'lime'},
    'MURS':{'sst':'MUR','diurnal_var':'NOSK','roughness':'CHRN','land_surface':'MDIS','color':'r'},
    'NAVO':{'sst':'NAVO','diurnal_var':'NOSK','roughness':'CHRN','land_surface':'MDIS','color':'m'},
    'OSTI':{'sst':'OSTIA','diurnal_var':'NOSK','roughness':'CHRN','land_surface':'MDIS','color':'orange'},
    'GO16':{'sst':'GOES16','diurnal_var':'NOSK','roughness':'CHRN','land_surface':'MDIS','color':'b'},
    #'SKNT':{'sst':'orig','diurnal_var':'SKNT','roughness':'CHRN','land_surface':'MDIS','color':'g'},
    #'OMLM':{'sst':'orig','diurnal_var':'OMLM','roughness':'CHRN','land_surface':'MDIS','color':'darkblue'},
    'SHAL':{'sst':'orig','diurnal_var':'NOSK','roughness':'SHAL','land_surface':'MDIS','color':'goldenrod'},
    #'USGS':{'sst':'orig','diurnal_var':'NOSK','roughness':'CHRN','land_surface':'USGS','color':'darkmagenta'},

}
cases = list(case_dict.keys())

for cc,case in enumerate(cases):
    if case_dict[case]['sst'] == 'orig':
        case_str = 'DFLT'
    else:
        case_str = case
    case_str = '{}_{}_{}_{}_{}'.format(icbc_type,
                                       case_str,
                                       case_dict[case]['diurnal_var'],
                                       case_dict[case]['roughness'],
                                       case_dict[case]['land_surface'])
    case_dict[case]['case_str'] = case_str

f = open(case_dict_f,'w')
f.write('case_dict = {\n')
for cc,case in enumerate(cases):
    f.write("    '{}':".format(case_dict[case]['case_str']) + '{\n')
    for key in list(case_dict[case].keys()):
        f.write("{0:>34}:'{1}',\n".format("'{}'".format(key),case_dict[case][key]))
    f.write("{0:>34}:'{1}',\n".format("'case_name'",case))
    f.write('                                  },\n\n')
f.write('            }\n')
f.close()


# Create tslist file:
twr_lat = [ 39.969278,  39.546772,  39.2717,  41.325567]
twr_lon = [-72.716692, -73.428892, -73.8892, -70.568883]
twr_names = ['E05','E06','Atlantic Shores','DOE_MV']
twr_abbreviation = ['E05','E06','ATS','DMV']

if not first_time_running:
    if max_dom == 5:
        les_dom = xr.open_dataset('{}/{}/wrfinput_d05'.format(main_directory,case_dict['DFLT']['case_str'])).squeeze()
        stn_of_interest = 'E06'

        stn_lat = twr_lat[np.where(np.asarray(twr_names)==stn_of_interest)[0][0]]
        stn_lon = twr_lon[np.where(np.asarray(twr_names)==stn_of_interest)[0][0]]

        les_lat = les_dom.XLAT
        les_lon = les_dom.XLONG

        dist = ((les_lat-stn_lat)**2 + (les_lon-stn_lon)**2)**0.5
        stnj,stni = np.where(dist==np.nanmin(dist))

        nx = 9
        ny = 9
        x_int = 14
        y_int = 14

        x_s = stni - ((nx-1)*0.5)*x_int
        x_e = stni + ((nx-1)*0.5)*x_int

        y_s = stnj - ((ny-1)*0.5)*y_int
        y_e = stnj + ((ny-1)*0.5)*y_int

        x_inds = np.arange(x_s,x_e+1,x_int)
        y_inds = np.arange(y_s,y_e+1,y_int)

        count = 0

        stn_lats = []
        stn_lons = []
        stn_names = []

        for i in x_inds:
            i = int(i)
            for j in y_inds:
                j = int(j)
                stn_lats += [float(les_lat[j,i].data)]
                stn_lons += [float(les_lon[j,i].data)]
                stn_names += ['T{0:03d}'.format(count+1)]
                count += 1

        # Combine meso and LES towers:
        twr_lat += stn_lats
        twr_lon += stn_lons
        twr_names += stn_names
        twr_abbreviation += stn_names



case_dates = pd.date_range(case_start,case_end,freq=case_delta)
#met_em_dir = '/glade/work/hawbecke/MMC/NYSERDA/met_em/MERRA2/orig/'
full_case_names = []

case_dict_of_interest = case_dict

if met_dir[-1] != '/':met_dir+='/'


if first_time_running:
    cases_to_create = [cases[0]]
else:
    cases_to_create = cases

for cc,case in enumerate(cases_to_create):
    sst = case_dict_of_interest[case]['sst']
    
    if not first_time_running:
        if sst == 'orig':
            met_em_dir = '{}{}/'.format(met_dir,sst)
        else:
            met_em_dir = '{}{}/v3.9.1/smooth-filled/'.format(met_dir,sst)

    case_str = case_dict_of_interest[case]['case_str']

    run_directory = '{}{}/'.format(main_directory,case_str)
    print(case_str)
    full_case_names.append(case_str)

    if case_dict_of_interest[case]['diurnal_var'] == 'SKNT':
        setup_dict['sst_skin'] = 1
    else:
        setup_dict['sst_skin'] = 0
        
    if case_dict_of_interest[case]['diurnal_var'] == 'OMLM':
        setup_dict['sf_ocean_physics'] = 1
    else:
        setup_dict['sf_ocean_physics'] = 0
        
    if case_dict_of_interest[case]['roughness'] == 'SHAL':
        setup_dict['shalwater_z0'] = 1
    else:
        setup_dict['shalwater_z0'] = 0
    
    if case_dict_of_interest[case]['land_surface'] == 'USGS':
        setup_dict['geog_data_res'] = 'usgs_lakes+30s+topobath_30s'
        met_em_dir = '{}USGS/'.format(met_dir,sst)
    else:
        setup_dict['geog_data_res'] = '30s+topobath_30s'
    print(run_directory)
    
    
    wrf_setup = wps.SetupWRF(run_directory=run_directory,
                             icbc_directory=icbc_directory,
                             executables_dict={'wrf':wrf_exe_location,'wps':wps_exe_location},
                            )
    wrf_setup.CreateRunDirectory(auxdir='auxout')
    wrf_setup.SetupNamelist(setup_dict)
    wrf_setup.write_namelist('wps')
    wrf_setup.write_namelist('input')
    wrf_setup.write_submission_scripts(submission_dict=submission_dict,hpc='cheyenne',restart_args=True)
    wrf_setup.write_io_fieldnames(io_fields={'myoutfields.txt':io_fields_meso,
                                             'myoutfieldsLES.txt': io_fields_LES})

    if not first_time_running:
        wrf_setup.link_metem_files(met_em_dir)
        wrf_setup.create_tslist_file(lat=twr_lat,lon=twr_lon,twr_names=twr_names,twr_abbr=twr_abbreviation)

    if max_dom > 2:
        # NAMELIST MAGIC
        # Run A: Start - initialize d03:
        new_setup_dict = copy.deepcopy(setup_dict)
        new_setup_dict['run_days'] = 0
        new_setup_dict['run_hours'] = 36
        wrf_setup.SetupNamelist(new_setup_dict)
        wrf_setup.write_namelist('input','namelist.input_A')

        # Run B: restart just before d04 & d05 start
        # New run time: 6 hours, 59 minutes, 30 seconds
        new_setup_dict['run_hours'] = 0
        runtime = int(5*3600 + 59*60 + 30)
        new_setup_dict['run_seconds'] = runtime
        del new_setup_dict['restart_interval']
        new_setup_dict['restart_interval_s'] = runtime
        start_dates = new_setup_dict['start_date']
        start_dates[0:3] = [start_dates[2]]*3
        new_setup_dict['restart'] = True
        wrf_setup.SetupNamelist(new_setup_dict)
        wrf_setup.write_namelist('input','namelist.input_B')

        # Run C: initialize d04 and d05 in a weird way
        new_setup_dict['run_seconds'] = 45
        new_setup_dict['restart_interval_s'] = 15
        start_dates[:3] = ['2020-04-05 23:59:30']*3
        wrf_setup.SetupNamelist(new_setup_dict)
        wrf_setup.write_namelist('input','namelist.input_C')

        # Run D: LES - 20 mintes (-15 seconds)
        runtime = int(20*60 - 15)
        new_setup_dict['run_seconds'] = runtime
        new_setup_dict['restart_interval_s'] = runtime
        start_dates[:] = ['2020-04-06 00:00:15']*5
        # Add in LES towers:
        new_setup_dict['max_ts_locs'] = 85
        wrf_setup.SetupNamelist(new_setup_dict)
        wrf_setup.write_namelist('input','namelist.input_D')

        # Loop over for LES runs at 20 minute intervals:
        end_date = '2020-04-06 04:00:00'
        del new_setup_dict['restart_interval_s']
        new_setup_dict['run_seconds'] = 0

        for dd,date in enumerate(pd.date_range(pd.to_datetime('2020-04-06 00:20:00'),end_date,freq='20min')):
            runtime = 20
            new_setup_dict['run_minutes'] = runtime
            new_setup_dict['restart_interval'] = runtime
            start_dates[:] = [str(date)]*5
            wrf_setup.SetupNamelist(new_setup_dict)
            wrf_setup.write_namelist('input','namelist.input_{}'.format((ascii_lowercase[dd+4]).upper()))

if first_time_running:
    print('Success! To generate the full suite of cases, please do the following:')
    print(' - Run WPS to get the met_em files')
    print(' - Download the auxiliary SST datasets')
    print(' - Run NYSERDA_OverwriteSST.py to overwrite the SST files')
    print(' - Run this script again - with first_time_running = False - to generate the rest of the cases')
    print()
    print('If not running the full suite, but you are running LES, run this script again after a successful completion of WPS to generate the tslist file')

