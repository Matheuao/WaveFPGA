#!/bin/bash

# === Configuration ===
VHDL_VERSION=08 # VHDL 2008
TOP_ENTITY=test
VCD_FILE=test.vcd
STOP_TIME=10000ms

# === Functions ===

analyze() {
  echo "Starting analysis with VHDL-${VHDL_VERSION}..."

  # Compile all source files in current directory
  if compgen -G "*.vhd" > /dev/null; then
    echo "Analyzing source files in current directory..."
    ghdl -a --std=${VHDL_VERSION} *.vhd || { echo "Error analyzing source files."; exit 1; }
  else
    echo "No VHDL source files found in current directory."
  fi

  # Compile all testbench files in ./testbench directory if exists
  if [ -d "testbench" ]; then
    if compgen -G "testbench/*.vhd" > /dev/null; then
      echo "Analyzing testbench files in testbench/ directory..."
      ghdl -a --std=${VHDL_VERSION} testbench/*.vhd || { echo "Error analyzing testbench files."; exit 1; }
    else
      echo "No VHDL testbench files found in testbench/ directory."
    fi
  else
    echo "No testbench directory found."
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
