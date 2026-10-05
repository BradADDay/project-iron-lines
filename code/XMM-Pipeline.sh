#!/bin/bash

# ==================================================================================
# Pipelines
# ==================================================================================

# Unzip
gzip -d *.gz

# Set environment variables and build cif file
export SAS_ODFPATH="$(pwd)"
export SAS_ODF="$(pwd)"
export SAS_CCFPATH="/opt/local/XMM/ccf/"
cifbuild

# Storing the ccf file and running odfingest
export SAS_CCF="$SAS_ODFPATH/ccf.cif"
odfingest

# Storing the odf file as an environment variable
export SAS_ODF="$SAS_ODFPATH/$(ls *SUM.SAS)"

# Make and enter processing directory
mkdir ../PROC
cd ../PROC

# Reprocessing pipelines
emproc
epproc

# ==================================================================================
# Make a symbolic link for easy command use
# ==================================================================================

ln -s *_EMOS1_*ImagingEvts.ds mos1.fits
ln -s *_EMOS2_*ImagingEvts.ds mos2.fits
ln -s *_EPN_*ImagingEvts.ds pn.fits

# ==================================================================================
# Apply standard filters
# ==================================================================================

evselect table=mos1.fits filtertype=expression filteredset=mos1_filt.fits expression='(PATTERN <= 12) && (PI in [200:12000]) && #XMMEA_EM' 

evselect table=mos2.fits filtertype=expression filteredset=mos2_filt.fits expression='(PATTERN <= 12) && (PI in [200:12000]) && #XMMEA_EM' 

evselect table=pn.fits filtertype=expression filteredset=pn_filt.fits expression='(PATTERN <= 4)&&(PI in [200:15000])&&#XMMEA_EP&&(FLAG == 0)'  

# ==================================================================================
# Make light curves
# ==================================================================================

evselect table=mos1_filt.fits withrateset=Y rateset=mos1_ltcrv.fits maketimecolumn=Y timebinsize=100 makeratecolumn=yes 

evselect table=mos2_filt.fits withrateset=Y rateset=mos2_ltcrv.fits maketimecolumn=Y timebinsize=100 makeratecolumn=yes 

evselect table=pn_filt.fits withrateset=Y rateset=pn_ltcrv.fits maketimecolumn=Y timebinsize=100 makeratecolumn=yes 

# ==================================================================================
# Plot the light curve
# ==================================================================================

fplot mos1_ltcrv.fits TIME RATE - /PS EXIT
mv pgplot.ps mos1_ltcrv.ps

fplot mos2_ltcrv.fits TIME RATE - /PS EXIT
mv pgplot.ps mos2_ltcrv.ps

fplot pn_ltcrv.fits TIME RATE - /PS EXIT
mv pgplot.ps pn_ltcrv.ps
