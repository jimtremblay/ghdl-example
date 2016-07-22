# vhdl files
FILES = source/*
VHDLEX = .vhd

# testbench
TESTBENCHPATH = testbench/${TESTBENCHFILE}$(VHDLEX)
TESTBENCHFILE = ${TESTBENCH}_tb

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = --ieee=synopsys --warn-no-vital-generic

SIMDIR = simulation
STOP_TIME = 500ns
# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean make run view

compile:
	@$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCHPATH) $(FILES)
	@$(GHDL_CMD) -m  $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCHFILE)

make:
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=<value> to set it."
	@exit 1
endif

	@mkdir -p simulation
	docker run --rm -v $(PWD):/work -w /work jimtremblay/ghdl-ubuntu make compile TESTBENCH=${TESTBENCH}
	@mv $(TESTBENCHFILE) simulation/$(TESTBENCHFILE)

run:
	@$(SIMDIR)/$(TESTBENCHFILE) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(TESTBENCHFILE).vcdgz

view:
	@gunzip --stdout $(SIMDIR)/$(TESTBENCHFILE).vcdgz | $(WAVEFORM_VIEWER) --vcd

clean:
	@rm -rf $(SIMDIR)
