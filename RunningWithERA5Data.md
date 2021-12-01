# Downloading data and running WRF with ERA5
ERA5 is a newer reanalysis product that has gotten a lot of positive feedback about how well it simulates past dates (not for forecasting) from 1979 to within 3 months of real time. Downloading the data, for now, is a bit tricky and can get very large. 
## To download:
- Go to https://cds.climate.copernicus.eu/cdsapp#!/search?type=dataset&text=era5 and create an account (if you don't already have one).
- You will need 2 datasets: <b>ERA5 hourly data on pressure levels from 1979 to present</b> and <b>ERA5 hourly data on single levels from 1979 to present</b>
  - For pressure level data, click the <b>download data</b> tab, select all fields within <i>Pressure level</i> and <i>Variable</i>. For <i>Time</i>, you can select all fields, or you can select incremental hours. Just make sure you change your <i>namelist.wps</i> to reflect the time interval you chose. For <i>Product Type</i> select <b>Reanalysis</b>. Then, select the dates of the data you want to download. Choose <b>GRIB</b> as the <i>Format</i>, agree to the terms of service, and then click <b>Submit Form</b>. Once you have done this, you will be taken to a queue where you can see the status of your download and when it is finished, you can download the data (or copy the URL and use <b>wget</b> on Eagle).
  - For surface data, click the <b>download data</b> tab, select the following fields:
    - Product Type: Reanalysis
    - Variable:
      - Popular: 10m u-component wind, 10m v-component wind, 2m dewpoint temperature, 2m temperature, Mean sea level pressure, sea surface temperature, Surface pressure
      - Temperature and pressure: <b>select all fields</b>
      - Wind: 10m u-component wind, 10m v-component wind
      - Snow: <b>select all fields</b>
      - Soil: <b>select all fields</b>
      - Other: Land-sea mask, Sea-ice cover
    - <b> All other fields should be blank</b>
    - Year / Month / Day: select the days that you want
    - Time: make sure you select the same times as above
    - Format: GRIB
    - Accept terms of service and click <b>Submit Form</b>. Download the data when it is finished or use wget as above.
- Rename the files as you please (I have used era5_PRES.grib and era5_SFC.grib).

## Running with ERA5:
- Use the V-table for ERA-Interim.pl
- Run WPS as if using ERA-Interim data.
- '''NOTE: ERA5 data are hourly'''; therefore the interval should be changed from 21600 (6 hrs) to 3600 (or to whatever interval was downloaded).
