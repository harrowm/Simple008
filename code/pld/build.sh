# Run this to compile the verilog for the CPLD
# This uses the atf15xx_yosys scripts:
# > cd
# > git clone https://github.com/hoglet67/atf15xx_yosys.git
# 
# This requires wine to be installed to work on a Mac, the site above has
# instructions.
#
# Run this script on rosco.v using the command line:
# > ./build.sh 

echo ""
echo ""
echo "\033[1;42m*************************************\033[0m"
echo "\033[1;42m********* Starting build.sh *********\033[0m"
echo "\033[1;42m*************************************\033[0m"

# Change the directory to point to the yosys scripts
SCRIPTDIR=/Users/malcolm/atf15xx_yosys
BASE=simple008
rm $BASE.fit
rm $BASE.log
rm $BASE.io
rm $BASE.edif
rm $BASE.pin
rm $BASE.tt3

export ROOT=~/atf15xx_yosys

yosys <<EOF
read_liberty -lib ${ROOT}/cells.lib
read_verilog boot_signal.v
read_verilog irq_encoder.v
read_verilog ${BASE}.v
stat
tribuf
stat
synth -flatten -noabc -top ${BASE}
stat
techmap -map ${ROOT}/techmap.v -D skip_DFFE_XX_
stat
simplemap
stat
dfflibmap -liberty ${ROOT}/cells.lib
stat
abc -liberty ${ROOT}/cells.lib
stat
iopadmap -bits -inpad INBUF Q:A -outpad BUF A:Q -toutpad TRI ENA:A:Q -tinoutpad bibuf EN:Q:A:PAD
stat
clean
stat
hierarchy
stat
splitnets -format _
rename -wire -suffix _reg t:*DFF*
rename -wire -suffix _comb
delete t:\$scopeinfo
write_edif ${BASE}.edif
EOF


$SCRIPTDIR/run_fitter.sh -d ATF1508AS -p PLCC84 -s 15 ${BASE} -preassign keep
# print out programmed logic
sed -n '/^PLCC84/,/^PLCC84/{/PLCC84/!p;}' $BASE.fit
echo "Program using the little atf programmer (https://github.com/roscopeco/atfprog-tools), like this .."
echo "atfu program -ed \$(atfu scan -n) ${BASE}.jed"
