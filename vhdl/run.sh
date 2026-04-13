#!/bin/bash

# === Configuration ===
VHDL_VERSION=08
TOP_ENTITY=NDWT_reconstruction_tb
VCD_FILE=test.vcd
STOP_TIME=10000ms
WORKDIR=ghdl  # Nome da pasta para os arquivos de compilação

# Criar a pasta de trabalho se não existir
mkdir -p $WORKDIR

# === Functions ===

analyze() {
  echo "Starting analysis with VHDL-${VHDL_VERSION}..."

  echo "Cleaning work library in ${WORKDIR}..."
  # Limpa o arquivo de biblioteca dentro da pasta ghdl
  rm -f $WORKDIR/work-obj${VHDL_VERSION}.cf

  # 1) Packages
  if compgen -G "packages/*.vhd" > /dev/null; then
    echo "Analyzing packages..."
    for f in packages/*.vhd; do
      # Adicionado --workdir=$WORKDIR
      ghdl -a --std=${VHDL_VERSION} --workdir=$WORKDIR "$f" || exit 1
    done
  else
    echo "No packages found."
  fi

  # 2) Design files
  if compgen -G "*.vhd" > /dev/null; then
    echo "Analyzing design files..."
    for f in *.vhd; do
      ghdl -a --std=${VHDL_VERSION} --workdir=$WORKDIR "$f" || exit 1
    done
  else
    echo "No design VHDL files found."
  fi

  # 3) Testbench
  if compgen -G "testbench/*.vhd" > /dev/null; then
    echo "Analyzing testbench files..."
    for f in testbench/*.vhd; do
      ghdl -a --std=${VHDL_VERSION} --workdir=$WORKDIR "$f" || exit 1
    done
  else
    echo "No testbench files found."
  fi

  echo "Analysis completed successfully."
}

elaborate() {
  echo "Elaborating top entity '${TOP_ENTITY}'..."
  # -o força o executável para dentro da pasta ghdl/
  ghdl -e --std=${VHDL_VERSION} --workdir=$WORKDIR -o $WORKDIR/${TOP_ENTITY} ${TOP_ENTITY} && \
  echo "Elaboration completed successfully." || { echo "Error during elaboration."; exit 1; }
}

simulate() {
  echo "Running simulation (stop-time=${STOP_TIME})..."
  
  # IMPORTANTE: Para rodar, chamamos o binário gerado diretamente 
  # ou usamos o ghdl -r apontando o workdir e o binário.
  # A forma mais robusta com GCC é rodar o binário que o 'elaborate' criou:
  
  ./$WORKDIR/${TOP_ENTITY} --vcd=$WORKDIR/${VCD_FILE} --stop-time=${STOP_TIME} && \
  echo "Simulation completed successfully." || { echo "Error during simulation."; exit 1; }
}

view_waveform() {
  echo "Opening waveform viewer: $WORKDIR/${VCD_FILE}"
  gtkwave $WORKDIR/${VCD_FILE}
}

# === Main Execution Logic ===
# (O restante permanece igual, as funções acima já cuidam dos caminhos)
case "$1" in
  analyze) analyze ;;
  elaborate) elaborate ;;
  simulate) simulate ;;
  wave) view_waveform ;;
  all|"")
    analyze
    elaborate
    simulate
    #view_waveform
    ;;
  *)
    echo "Usage: $0 [analyze|elaborate|simulate|wave|all]"
    exit 1
    ;;
esac