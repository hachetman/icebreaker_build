
PROJ = 7segment

all: $(PROJ).rpt $(PROJ).bin

$(PROJ).json: hdl/top_level.sv
	yosys -ql $(PROJ).yslog -p 'synth_ice40 -top top_level -json $@' $<

$(PROJ).asc: $(PROJ).json constr/7segment.pcf
	nextpnr-ice40 -ql $(PROJ).nplog --up5k --package sg48 --freq 12 --asc $@ --pcf constr/7segment.pcf --json $<

$(PROJ).bin: $(PROJ).asc
	icepack $< $@

$(PROJ).rpt: $(PROJ).asc
	icetime -d up5k -c 12 -mtr $@ $<

$(PROJ)_syn.v: $(PROJ).json
	yosys -p 'read_json $^; write_verilog $@'

prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	rm -f $(PROJ).yslog $(PROJ).nplog $(PROJ).json $(PROJ).asc $(PROJ).rpt $(PROJ).bin
	rm -f $(PROJ)_tb $(PROJ)_tb.vcd $(PROJ)_syn.v $(PROJ)_syntb $(PROJ)_syntb.vcd

.SECONDARY:
.PHONY: all prog clean
