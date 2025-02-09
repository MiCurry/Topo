#
# COMPILER/MACHINE SETTINGS
#
#machine=harmon
#machine=my_mac
machine=cheyenne
#FC = ifort
FC = gfortran
#FC=ifort
#FC = nagfor
#FC = pgf95
DEBUG=FALSE
#
# Note: NO white spaces after variable assignment
#
# STANDARD CONGIGURATIONS
#
# fv0.9x1.25-gmted2010_modis-cam_fv_smooth-intermediate_ncube3000-no_anisoSGH.nc
#
model=fv
res=0.9x1.25
raw_data=gtopo30
smoothing=cam_fv_smooth
ncube=3000
aniso=no_anisoSGH
#
# fv1.9x2.5-gmted2010_modis-cam_fv_smooth-intermediate_ncube3000-no_anisoSGH.nc
#
#model=fv
#res=1.9x2.5
#raw_data=gmted2010_modis
#smoothing=cam_fv_smooth
#ncube=3000
#aniso=no_anisoSGH
#
# fv0.9x1.25-gmted2010_modis-cam_fv_smooth-intermediate_ncube3000-no_anisoSGH.nc
#
#model=fv
#res=0.9x1.25
#raw_data=gmted2010_modis
#smoothing=cam_fv_smooth
#ncube=3000
#aniso=no_anisoSGH

#
# se_ne30np4-gmted2010_modis-cam_se_smooth-intermediate_ncube3000-no_anisoSGH.nc
#
#model=se
#res=ne30np4
#raw_data=gmted2010_modis
#smoothing=cam_se_smooth
#ncube=3000
#aniso=no_anisoSGH

#
# SE variable resolution: 1 degree globally with 0.25 degree nest over US
#
#model=se
#res=cordex_ne120np4_ne30np4
#raw_data=gtopo30
#smoothing=cam_se_smooth
#ncube=3000
#aniso=no_anisoSGH


#
# Julio developmental setup
#
# se_ne30np4-gtopo30_modis-cam_se_smooth-intermediate_ncube3000-no_anisoSGH.nc
#
#model=se
#res=ne30np4
#raw_data=gmted2010_modis
#smoothing=julio_smooth
#ncube=3000
#aniso=julio_anisoSGH

#
###########################################################################################################################################
# DONE CASE DEFINITION # DONE CASE DEFINITION # DONE CASE DEFINITION # DONE CASE DEFINITION # DONE CASE DEFINITION # DONE CASE DEFINITION #
###########################################################################################################################################
#
ifeq ($(machine),my_mac)
  python_command:=~pel/anaconda/bin/python
else
  python_command:=python
endif
cr:=create_netCDF_from_rawdata
sm:=cam_fv_topo-smoothing

all: cube_to_target plot
rawdata: raw_netCDF_$(raw_data) 
bin_to_cube: bin_to_cube/$(raw_data)-ncube$(ncube).nc raw_netCDF_$(raw_data)
cube_to_target: bin_to_cube/$(raw_data)-ncube$(ncube).nc cube_to_target/output/$(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).nc
plot: cube_to_target/ncl/topo-vars-$(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).pdf

cube_to_target/ncl/topo-vars-$(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).pdf:
	(cd cube_to_target/ncl; chmod +x plot-topo-vars.sh; ./plot-topo-vars.sh $(model) $(res) $(raw_data) $(smoothing) $(ncube) $(aniso) pdf;\
	gv topo-vars-$(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).pdf)

#
#********************************
# 
# cube_to_target make commands
#
#********************************
#
cube_to_target: cube_to_target/output/$(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).nc
cube_to_target/output/fv_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).nc: bin_to_cube/$(raw_data)-ncube$(ncube).nc cam_fv_topo-smoothing/$(raw_data)-$(model)_$(res)-$(smoothing).nc
	echo cube_to_target/$(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).nc
	echo ./run.sh $(model)_$(res) $(raw_data) $(smoothing) $(ncube) $(aniso)
	(cd cube_to_target; make; chmod +x run.sh; rm cube_to_target.nl; ./run.sh $(model)_$(res) $(raw_data) $(smoothing) $(ncube) $(aniso))


cube_to_target/output/se_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).nc: bin_to_cube/$(raw_data)-ncube$(ncube).nc
	echo cube_to_target/$(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).nc
	echo ./run.sh $(model)_$(res) $(raw_data) $(smoothing) $(ncube) $(aniso)
	(cd cube_to_target; make; chmod +x run.sh; rm cube_to_target.nl; ./run.sh $(model)_$(res) $(raw_data) $(smoothing) $(ncube) $(aniso))


cesm_compliance:
	(cd cesm_meta_data_compliance; $(python_command) meta.py ../cube_to_target/output/$(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).nc $(model)_$(res)-$(raw_data)-$(smoothing)-intermediate_ncube$(ncube)-$(aniso).metadata)	

#
#********************************
#
# smooth PHIS the CAM-FV way
#
#********************************
#
cam_fv_smooth:  cam_fv_topo-smoothing/$(raw_data)-$(model)_$(res)-$(smoothing).nc
cam_fv_topo-smoothing/$(raw_data)-$(model)_$(res)-$(smoothing).nc: $(sm)/input/10min-$(raw_data)-phis-raw.nc
	(cd $(sm)/definesurf; make; ./definesurf -t ../input/10min-$(raw_data)-phis-raw.nc  -g ../input/outgrid/$(model)_$(res).nc -l ../input/landm_coslat.nc -remap ../$(raw_data)-$(model)_$(res)-$(smoothing).nc)
cam_fv_topo-smoothing/input/10min-gmted2010_modis-phis-raw.nc: create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc
	(cd $(sm)/input; ncl < make-10min-raw-phis.ncl 'gmted2010_modis=True')
cam_fv_topo-smoothing/input/10min-gtopo30-phis-raw.nc: create_netCDF_from_rawdata/gtopo30-rawdata.nc
	(cd $(sm)/input; ncl < make-10min-raw-phis.ncl 'gmted2010_modis=False')
#
#********************************
#
# raw data Make commands
#
#********************************
#
raw_netCDF_gmted2010_modis: create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc

#
# the "test -f" commands is to make sure Make does not try to execute when the final rawdata file already exists
#
create_netCDF_from_rawdata/gmted2010_elevation_and_landfrac_modis_sft.nc: $(cr)/modis/landwater.nc $(cr)/gmted2010/mea.nc
	test -f create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc || (cd create_netCDF_from_rawdata/gmted2010/fix-inland-water-elevation; make; ./fix_inland_water_elevation)
	test -f create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc || $(python_command) $(cr)/create_gmted2010_modis.py $(cr)/modis/landwater.nc $(cr)/gmted2010/mea.nc $(cr)/gmted2010_elevation_and_landfrac_modis.nc
	test -f create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc || $(python_command) $(cr)/shift.py $(cr)/gmted2010_elevation_and_landfrac_modis.nc $(cr)/gmted2010_elevation_and_landfrac_modis_sft.nc
	test -f create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc || rm create_netCDF_from_rawdata/gmted2010_elevation_and_landfrac_modis.nc

create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc: create_netCDF_from_rawdata/gmted2010_elevation_and_landfrac_modis_sft.nc
	test -f create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc || (cd create_netCDF_from_rawdata/gmted2010/fix-inland-water-elevation; make; ./fix_inland_water_elevation)
#
# generate ~1km land fraction data from MODIS source data
#
create_netCDF_from_rawdata/modis/landwater.nc:   
	test -f create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc || (cd $(cr)/modis; chmod +x unpack.sh; ./unpack.sh)
#	if [ -a create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc ];
#	then
#	  echo "file exists"
#	fi
#	(cd $(cr)/modis; chmod +x unpack.sh; ./unpack.sh)
#
# generate ~1km GMTED2010 data from source
##
create_netCDF_from_rawdata/gmted2010/mea.nc:
	test -f create_netCDF_from_rawdata/gmted2010_modis-rawdata.nc || (cd $(cr)/gmted2010; chmod +x unpack.sh; ./unpack.sh)
#
# GTOPO30
#
raw_netCDF_gtopo30: create_netCDF_from_rawdata/gtopo30-rawdata.nc
create_netCDF_from_rawdata/gtopo30-rawdata.nc:
	(cd $(cr)/gtopo30; chmod +x unpack.sh; ./unpack.sh; cd src; make; ./create_netCDF_gtopo30_raw_data)
#
# calculate data for CAM-FV smoothing
#

#********************************
#
# bin ~1km lat-lon data (GMTED2010, MODIS) to ~3km cubed-sphere grid
#
#********************************
#
bin_to_cube/$(raw_data)-ncube$(ncube).nc: create_netCDF_from_rawdata/$(raw_data)-rawdata.nc
	(cd bin_to_cube; make; chmod +x run.sh; rm bin_to_cube.nl; ./run.sh $(raw_data) $(ncube))
test:
	echo bin_to_cube/$(raw_data)-ncube$(ncube).nc
#
#=====================================================================================================================
#
# user settings (compiler)
#
export FC

 # default settings
# LIB_NETCDF := /opt/local/lib
# INC_NETCDF := /opt/local/include

#
#------------------------------------------------------------------------
# ifort
#------------------------------------------------------------------------
#
#ifeq ($(FC),ifort)
#  FFLAGS = -c -g -r8 -O1 -I$(INC_NETCDF)
#  LDFLAGS = -L$(LIB_NETCDF) -lnetcdf
#endif


#------------------------------------------------------------------------
# GFORTRAN
#------------------------------------------------------------------------
#
ifeq ($(FC),gfortran)
#  ifeq ($(machine),my_mac)
#    INC_NETCDF := /opt/local/include
#    LIB_NETCDF := /opt/local/lib
#  endif
#  ifeq ($(machine),harmon)
#    INC_NETCDF :=/usr/local/netcdf-gcc-g++-gfortran/include
#    LIB_NETCDF :=/usr/local/netcdf-gcc-g++-gfortran/lib
# # endif
##
#
  LDFLAGS = -L$(LIB_NETCDF) -lnetcdf -lnetcdff 
  FFLAGS   := -c  -fdollar-ok  -I$(INC_NETCDF)
#
  ifeq ($(DEBUG),TRUE)
#   FFLAGS += --chk aesu  -Cpp --trace
    FFLAGS += -Wall -fbacktrace -fbounds-check -fno-range-check
  else
    FFLAGS += -O
  endif
#
endif

#------------------------------------------------------------------------
# NAG
#------------------------------------------------------------------------
#ifeq ($(FC),nagfor)
#
##  INC_NETCDF :=/usr/local/netcdf-gcc-nag/include
##  LIB_NETCDF :=/usr/local/netcdf-pgi/lib
#
#  INC_NETCDF :=/usr/local/netcdf-gcc-nag/include
#  LIB_NETCDF :=/usr/local/netcdf-gcc-nag/lib
#
#  LDFLAGS = -L$(LIB_NETCDF) -lnetcdf -lnetcdff
#  FFLAGS   := -c  -I$(INC_NETCDF)
#
#
#  ifeq ($(DEBUG),TRUE)
#    FFLAGS += -g -C
#  else
#    FFLAGS += -O
#  endif
#
#endif

#------------------------------------------------------------------------
# PGF95
#------------------------------------------------------------------------
#
# setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/local/netcdf-4.1.3-gcc-4.4.4-13-lf9581/lib
#

#ifeq ($(FC),pgf95)
#  INC_NETCDF :=/opt/local/include
#  LIB_NETCDF :=/opt/local/lib
#
#  LDFLAGS = -L$(LIB_NETCDF) -lnetcdf -lnetcdff
#  FFLAGS   := -c -Mlarge_arrays -I$(INC_NETCDF)
#
#
#  ifeq ($(DEBUG),TRUE)
#    FFLAGS += -g -Mbounds -traceback -Mchkfpstk
#  else
#    FFLAGS += -O
#  endif
#
#endif
#------------------------------------------------------------------------
# ifort
#------------------------------------------------------------------------
#

#ifeq ($(FC),ifort)
#  INC_NETCDF :=${NETCDF}/include
#  LIB_NETCDF :=${NETCDF}/lib
#
##  LDFLAGS = -L$(LIB_NETCDF) -lnetcdf -lnetcdff
#  FFLAGS   := -c -I$(INC_NETCDF)
#
#
#  ifeq ($(DEBUG),TRUE)
#    FFLAGS += -g -Mbounds -traceback -Mchkfpstk
#  else
#    FFLAGS += -O
#  endif
#
#endif


#export INC_NETCDF
#export LIB_NETCDF
export LDFLAGS
export FFLAGS

