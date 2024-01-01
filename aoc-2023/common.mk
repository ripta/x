SHELL   := /bin/bash
sources := $(wildcard input-*.txt)
parts   := pt1 pt2

check: $(foreach OUT,$(patsubst %.txt,%.out,$(sources)),$(foreach PART,$(parts),check-$(PART)-$(OUT)))

define CHKRULE
check-$(1)-%.out: %.txt
	[[ -f $$*.$(1).skip ]] || diff -u <($(call RUN,$(1),$$<)) $$*.$(1).out
endef

generate: $(foreach OUT,$(patsubst %.txt,%.out,$(sources)),$(foreach PART,$(parts),generate-$(PART)-$(OUT)))

define GENRULE
generate-$(1)-%.out: %.txt
	[[ -f $$*.$(1).skip ]] || $(call RUN,$(1),$$<) > $$*.$(1).out
endef

run: $(foreach OUT,$(patsubst %.txt,%.out,$(sources)),$(foreach PART,$(parts),run-$(PART)-$(OUT)))

define RUNRULE
run-$(1)-%.out: %.txt
	[[ -f $$*.$(1).skip ]] || $(call RUN,$(1),$$<)
endef

list:
	@$(MAKE) -qp \
		| awk -F':' '/^[a-zA-Z0-9][^$$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' \
		| grep -e ^list -e ^check -e ^generate -e ^run \
		| grep -v % \
		| sort

$(foreach PART,$(parts),$(eval $(call CHKRULE,$(PART))))
$(foreach PART,$(parts),$(eval $(call GENRULE,$(PART))))
$(foreach PART,$(parts),$(eval $(call RUNRULE,$(PART))))

# Place input file as input-*.txt.
# Run `make generate` to generate output files.
# Run `make check` to run program and compare output against pre-generated output files.
# Run `make list` to list check/generate/run targets.
