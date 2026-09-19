TOP := tt_um_protocol_emulator
GEN := src/$(TOP).v

.PHONY: all gen check-gen test test-hw test-rtl fmt fmt-check harden clean

all: gen test

gen:
	cd hw && dune build
	cd hw && dune exec --no-print-directory ./bin/generate.exe > ../$(GEN).tmp
	mv $(GEN).tmp $(GEN)

check-gen: gen
	@test -z "$$(git status --porcelain -- src)" || { git status --short -- src; echo "src/ is stale, run make gen and commit"; exit 1; }

test: test-hw test-rtl

test-hw:
	cd hw && dune runtest

test-rtl: gen
	cd test && $(MAKE) clean && $(MAKE)
	! grep -q failure test/results.xml

fmt:
	cd hw && dune fmt

fmt-check:
	cd hw && dune build @fmt

harden: gen
	./tt/tt_tool.py --create-user-config --ihp
	./tt/tt_tool.py --harden --ihp

clean:
	cd hw && dune clean
	cd test && $(MAKE) clean
	rm -rf runs tt_submission
