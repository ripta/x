define RUN
	./build/exec/solution $(1) $(2)
endef

include ../common.mk

compile:
	mkdir -p ./build/exec
	idris2 -o solution ./solution.idr
