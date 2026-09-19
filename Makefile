TOP := tt_um_protocol_emulator
GEN := src/$(TOP).v

.PHONY: all gen check-gen check-pins test test-hw test-rtl test-gl fmt fmt-check harden clean

all: gen test

gen:
	cd hw && dune build
	cd hw && dune exec --no-print-directory ./bin/generate.exe > ../$(GEN).tmp
	mv $(GEN).tmp $(GEN)

check-gen: gen
	@test -z "$$(git status --porcelain -- src)" || { git status --short -- src; echo "src/ is stale, run make gen and commit"; exit 1; }

check-pins:
	scripts/check-pins.sh

test: test-hw test-rtl

test-hw:
	cd hw && dune runtest

test-rtl: gen
	cd test && $(MAKE) clean && $(MAKE)
	! grep -q failure test/results.xml

test-gl:
	cp tt_submission/*.v test/gate_level_netlist.v
	cd test && $(MAKE) clean && GATES=yes $(MAKE)
	! grep -q failure test/results.xml

fmt:
	cd hw && dune fmt

fmt-check:
	cd hw && dune build @fmt

harden: gen
	./tt/tt_tool.py --create-user-config --ihp
	./tt/tt_tool.py --harden --ihp
	./tt/tt_tool.py --create-tt-submission --ihp

clean:
	cd hw && dune clean
	cd test && $(MAKE) clean
	rm -rf runs tt_submission
