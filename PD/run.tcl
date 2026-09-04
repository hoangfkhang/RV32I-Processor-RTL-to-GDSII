####################################
####################################
###                              ###
###   Student: LY HOANG KHANG	 ###
###   HCMUTE			 ###
###				 ###
####################################
####################################
###############################################################
###################### IMPORT DESIGN ##########################
###############################################################

# MMMC
set init_mmmc_file /home/buet/Desktop/test_no1_newmmmc/mmmc.tcl
# Top module
set init_top_cell top_module
# Netlist
set init_verilog /home/buet/Desktop/test_no1_newmmmc/Synthesis/top_module_slow.v
# LEF
set init_lef_file {/home/buet/cadence/EDI/share/FoundationFlows/EXAMPLES/PROTO/LIBS/GPDK/LIBS/GPDK045/gsclib045.lef}
# Power/Ground
set init_pwr_net VDD
set init_gnd_net VSS
# Import design
init_design

###############################################################
###################### ANALYSIS MODE ##########################
###############################################################
setAnalysisMode \
    -analysisType onChipVariation \
    -cppr both
checkDesign -all
###############################################################
###################### FLOORPLAN ##############################
###############################################################
# Check site name
dbGet top.fPlan.coreSite.name
# Floorplan
floorPlan -site CoreSite -r 1.0 0.7 10 10 10 10
#------------------------------------------------
#| Tham số              | Ý nghĩa                      |
#| ------------- | ---------------------------- |
#| `CoreSite`    | site của standard cell       |
#| `1.0`         | aspect ratio                 |
#| `0.7`         | utilization = 70%            |
#| `10 10 10 10` | margin left right top bottom |
#------------------------------------------------
#########################ARRANGE PORT##########################
# Lock tất cả pin không cho di chuyển
#--------------------------------------------------
# Clock & Reset (Left)
#--------------------------------------------------

source IO_set.tcl

###############################################################
###################### POWER PLAN #############################
###############################################################
#Check site name: thường coresite vì thư viện 45nm
# Check routing layer names
dbGet [dbGet head.layers.type routing -p].name
###############################################################
# GLOBAL NET CONNECT
###############################################################
globalNetConnect VDD -type pgpin -pin VDD -all
globalNetConnect VSS -type pgpin -pin VSS -all
globalNetConnect VDD -type tiehi -all
globalNetConnect VSS -type tielo -all
applyGlobalNets
###############################################################
# ADD POWER RING
###############################################################

addRing -nets {VDD VSS} \
    	-type core_rings \
   	-layer {top Metal5 bottom Metal5 left Metal6 right Metal6} \
    	-width 2 \
    	-spacing 1.5\
    	-offset 0.5

###############################################################
# ADD STRIPES
###############################################################

addStripe \
    -nets {VDD VSS} \
    -layer Metal6 \
    -direction vertical \
    -width 1.25 \
    -spacing 1 \
    -set_to_set_distance 30 \
    -start_from left \
    -start_x 20

###############################################################
# SPECIAL ROUTE POWER
###############################################################

sroute \
    -connect {corePin} \
    -layerChangeRange {Metal1 Metal6} \
    -nets {VDD VSS} \
    -allowJogging true \
    -allowLayerChange true

###############################################################
###################### CHECK POWER ############################
###############################################################

verifyConnectivity -type special -nets {VDD VSS}

verifyGeometry -report ./reports/preplace_drc.rpt

###############################################################
###################### PLACEMENT ##############################
###############################################################

setPlaceMode \
    -timingDriven true \
    -congEffort auto
placeDesign
setDrawView place

###############################################################
# CHECK PLACEMENT
###############################################################

checkPlace

###############################################################
# TIMING REPORT PRE-CTS (truoc khi CTS)
###############################################################

timeDesign \
    -preCTS \
    -outDir /home/buet/Documents/mode_test/PnR/reports/preCTS \
    -prefix preCTS

###############################################################
# OPTIMIZE PRE-CTS (opt placement)
###############################################################
optDesign \
    -preCTS \
    -outDir /home/buet/Documents/mode_test/PnR/reports/optPreCTS \
    -prefix optPreCTS
###############################################################
# TIMING AFTER OPT PRE-CTS
###############################################################
timeDesign \
    -preCTS \
    -outDir /home/buet/Documents/mode_test/PnR/reports/preCTS_opt\
    -prefix preCTS_opt
###############################################################
# UTILIZATION REPORT
###############################################################

redirect ./reports/preCTS/utilization.rpt {
    reportDensity
}

###############################################################
# SUMMARY REPORT
###############################################################

summaryReport \
    -outfile /home/buet/Documents/mode_test/PnR/reports/preCTS_opt/summary.rpt

###############################################################
###################### CTS ####################################
##############################################################
# Tạo cts.spec tự động
clockDesign -genSpecOnly ./cts.spec
cat ./cts.spec
clockDesign -specFile ./cts.spec \
            -outDir ./CTS \
            -fixedInstBeforeCTS

###############################################################
# CHECK DESIGN AFTER CTS
###############################################################

checkDesign -all

###############################################################
# POST CTS TIMING
###############################################################
timeDesign \
    -postCTS \
    -outDir /home/buet/Documents/mode_test/PnR/reports/postCTS \
    -prefix postCTS

###############################################################
# OPTIMIZE POST CTS
###############################################################

optDesign \
    -postCTS \
    -outDir /home/buet/Documents/mode_test/PnR/reports/optPostCTS \
    -prefix optPostCTS

###############################################################
# TIMING AFTER POST CTS OPT
###############################################################

timeDesign \
    -postCTS \
    -outDir /home/buet/Documents/mode_test/PnR/reports/postCTS_opt \
    -prefix postCTS_opt

###############################################################
# DETAILED TIMING REPORT
###############################################################

redirect /home/buet/Documents/mode_test/PnR/reports/postCTS_opt/timing_detail.rpt {
    report_timing \
        -path_type full \
        -max_paths 10
}

###############################################################
###################### ROUTING ###############################
###############################################################

###############################################################
# NANOROUTE SETTINGS
###############################################################

setNanoRouteMode -routeWithTimingDriven true
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -drouteFixAntenna true
setNanoRouteMode -routeInsertAntennaDiode true

###############################################################
# ROUTING
###############################################################

routeDesign

###############################################################
# POST ROUTE CHECK
###############################################################

verifyConnectivity -type all

verifyGeometry \
    -report ./reports/postRoute_drc.rpt

###############################################################
# POST ROUTE OPTIMIZATION
###############################################################

optDesign \
    -postRoute \
    -outDir ./reports/optPostRoute \
    -prefix optPostRoute

###############################################################
# ECO ROUTE
###############################################################

ecoRoute

###############################################################
# VERIFY AFTER ECO
###############################################################

verifyConnectivity -type all

verifyGeometry \
    -report ./reports/postRoute_opt_drc.rpt

verify_drc

###############################################################
# POST ROUTE TIMING
###############################################################

timeDesign \
    -postRoute \
    -outDir ./reports/postRoute \
    -prefix postRoute

###############################################################
# INSERT FILLER CELLS
###############################################################

dbGet [dbGet head.libCells.subClass coreSpacer -p].name

set fillerCells {FILL1 FILL2 FILL4 FILL8 FILL16 FILL32 FILL64}

set BASENAME top_module

setFillerMode \
    -corePrefix ${BASENAME}_FILL \
    -core $fillerCells

addFiller \
    -cell $fillerCells \
    -prefix ${BASENAME}_FILL \
    -markFixed

###############################################################
# FINAL VERIFICATION
###############################################################

verifyConnectivity -type all

verifyGeometry \
    -report ./reports/final_drc.rpt

verify_drc

verifyProcessAntenna

###############################################################
# FINAL TIMING
###############################################################

timeDesign \
    -postRoute \
    -outDir ./reports/postRoute_final \
    -prefix postRoute_final

redirect ./reports/postRoute_final/timing_detail.rpt {
    report_timing \
        -path_type full \
        -max_paths 10
}

###############################################################
# SAVE DATABASE
###############################################################

saveDesign ./output/final_encounter.enc

###############################################################
# STREAM OUT GDS
###############################################################
streamOut ./output/top_module.gds \
    -libName top_module \
    -units 1000 \
    -mode ALL

###############################################################
# FINAL SIGNOFF CHECK
###############################################################

verify_drc \
    -report ./reports/final_stream_drc.rpt

puts "========== FLOW COMPLETED =========="

