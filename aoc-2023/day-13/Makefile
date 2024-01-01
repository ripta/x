define RUN
	./solution < $(2)
endef

build: solution

solution: solution.zig
	zig build-exe $<

include ../common.mk
