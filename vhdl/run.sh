#!/bin/bash

# === Configuration ===
VHDL_VERSION=08 # VHDL 2008
TOP_ENTITY=NDWT_reconstruction_tb
VCD_FILE=test.vcd
STOP_TIME=10000ms

# === Functions ===

analyze() {
  echo "Starting analysis with VHDL-${VHDL_VERSION}..."

  echo "Cleaning work library..."
  rm -f work-obj08.cf

  # 1) Packages
  if compgen -G "packages/*.vhd" > /dev/null; then
    echo "Analyzing packages..."
    for f in packages/*.vhd; do
      ghdl -a --std=${VHDL_VERSION} "$f" || exit 1
    done
  else
    echo "No packages found."
  fi

  # 2) Design files (root .vhd only, excluding packages)
  if compgen -G "*.vhd" > /dev/null; then
    echo "Analyzing design files..."
    for f in *.vhd; do
      ghdl -a --std=${VHDL_VERSION} "$f" || exit 1
    done
  else
    echo "No design VHDL files found."
  fi

  # 3) Testbench
  if compgen -G "testbench/*.vhd" > /dev/null; then
    echo "Analyzing testbench files..."
    for f in testbench/*.vhd; do
      ghdl -a --std=${VHDL_VERSION} "$f" || exit 1
    done
  else
    echo "No testbench files found."
  fi

  echo "Analysis completed successfully."
}

elaborate() {
  echo "Elaborating top entity '${TOP_ENTITY}'..."
  ghdl -e --std=${VHDL_VERSION} ${TOP_ENTITY} && echo "Elaboration completed successfully." || { echo "Error during elaboration."; exit 1; }
}

simulate() {
  echo "Running simulation (stop-time=${STOP_TIME})..."
  ghdl -r --std=${VHDL_VERSION} ${TOP_ENTITY} --vcd=${VCD_FILE} --stop-time=${STOP_TIME} && echo "Simulation completed successfully." || { echo "Error during simulation."; exit 1; }
}

view_waveform() {
  echo "Opening waveform viewer: ${VCD_FILE}"
  gtkwave ${VCD_FILE}
}

# === Main Execution Logic ===

case "$1" in
  analyze)
    analyze
    ;;
  elaborate)
    elaborate
    ;;
  simulate)
    simulate
    ;;
  wave)
    view_waveform
    ;;
  all|"")
    analyze
    elaborate
    simulate
    view_waveform
    ;;
  *)
    echo "Usage: $0 [analyze|elaborate|simulate|wave|all]"
    exit 1
    ;;
esac
