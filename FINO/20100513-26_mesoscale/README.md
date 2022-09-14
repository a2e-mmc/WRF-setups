# FINO Mesoscale Simulations

The main case uses ERA5 reanalysis data. Before running the WRF setup script, be sure to download
the necessary ERA5 data (May 14 at 12Z to May 17 at 00Z) for both surface and pressure level data.
The README.md file in the WRF-setups directory explains this in detail. All days (14 to 17) should
be able to be downloaded in one file for pressure levels and one file for surface data.
When the download is available through the website, copy the URL and use 'wget' to download to the 
supercomputer that you are using. 

The script is expecting the files to start with 'era_5_' so I suggest renaming the files to
something like "era_5_May14to17_pres.grib" and "era_5_May14to17_sfc.grib" for the script to find
them and run.

Where ever these files are located, make sure the ICBC_DIR in the setup script is set to this
location. Choose 'skip' when prompted for downloading reanalysis. The setup script will create a new
directory that will need to run WPS, real, and WRF.
