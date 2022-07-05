# Adding synthetic turbulence
We added the turbulence field along the inflow boundaries of the innermost microscale domain in the WRF framework. The turbulence field can be generated using any method, such as Mann [Mann 1998], TurbSim [Jonkman 2009] etc. However, the cases described here use the turbulence field generated from Mann method. Following, we described the turbulence file and the input variables in the WRF namelist file that is associated with the turbulence file.

## 1. Turbulence file
- As mentioned above, the turbulence field can be generated using the code for the Mann method available in Gilling’s report [Gilling 2009]. 
- The turbulence inflow data in a file was written in ASCII format in 10-second interval for 10-min period. The file-name looks like ‘inflowSynthDataSSSS-EEEE.txt, where SSSS and EEEE represent the start and end time in minutes (e.g., 0000-0010, 0010-0020, etc.). Each 10-min file has data size of [nxyCnfg,nzCnfg,ncomp, ntCnfg], representing horizontal grid points as nxyCnfg, vertical grid points as nzCnfg, wind components as ncomp, and the number of inflow planes ntConfg. Data in each file is written as:\
`write* nxyCnfg, nzCnfg`\
`for loop i=1 to 61`     #61 ten seconds steps\
`write* ntCnfg[i]`  #time in minutes\
`write* data[1:nxyCnfg,1:nzCnfg,1,i]` #u-velocity\
`write* data[1:nxyCnfg,1:nzCnfg,2,i]` #v-velocity\
`write* data[1:nxyCnfg,1:nzCnfg,3,i]` #w-velocity\
`end`
- We use a uniform vertical resolution of 10 m in the inflow turbulence file. If we want to use a different value, we need to change it in the WRF module_add_synthturb module. 
- The turbulence field is supposed to be applied within the boundary-layer depth. We can also scale the wind velocity components with the turbulent intensity obtained from the observation data.

## 2. namlist.input file
To apply the synthetic turbulence in the innermost domain in WRF, the following input variables need to be added under the section ‘&physics’ in the namelist.input file. Examples of namelist.input file for FINO and WFIP2 cases are in FINO and WFIP2 directories.\

*use_synthturb       =.false.,.false.,.false.,.false.,.false.,.true.,* \
*nxyCnfg             = 620,* \
*nzCnfg              = 64,* \
*ntCnfg              = 61,* \
*start_synthturb     = 2100,*\
*nfiles_synthturb    = 12,*\
*sides_synthturb     = 'WN'*\

The input variables above are.\
*use_synthturb*: ‘true’ for using the turbulence, otherwise ‘false.’\
*start_synthturb*: time (in minutes) to add turbulence field, relative to the beginning of the simulation \
*nfiles_synthturb*: number of 10-minute files, e.g., inflowSynthData0000-0010.txt, etc. \
*sides_synthturb*: boundary names to add the turbulence, e.g., SW is for South and West\

### **References**
- Mann, J (1998). Wind field simulation. Prob. Engng. Mech. 13(4):269-282
- Gilling, L. (2009). TuGen: Synthetic Turbulence Generator, Manual and User’s Guide. Department of Civil Engineering, Aalborg University. DCE Technical reports No. 76
- Jonkman, Bonnie J. TurbSim User’s Guide: Version 1.50. No. NREL/TP-500-46198. National Renewable Energy Lab. (NREL), Golden, CO, 2009.

   
