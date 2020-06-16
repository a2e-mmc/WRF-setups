The main cases uses ERA5 reanalysis data. Before running the WRF setup script, be sure to download
the necessary ERA5 data (May 14 at 12Z to May 17 at 00Z) for both surface and pressure level data.
The README.md file in the WRF-setups directory explains this in detail. When the download is 
available through the website, copy the URL and use 'wget' to download to the supercomputer that
you are using. Where ever these files are located, make sure the ICBC_DIR in the setup script is 
set to this location. Choose 'skip' when prompted for downloading reanalysis. The setup script 
will create a new directory that will need to run WPS, real, and WRF.
