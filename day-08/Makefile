define RUN
  swift solution-$(1).swift < $(2)
endef

include ../common.mk

# sources := $(wildcard input-*.txt)
# parts   := pt1 pt2
#
# check: $(foreach OUT,$(patsubst %.txt,%.out,$(sources)),$(foreach PART,$(parts),check-$(PART)-$(OUT)))
#
# define CHKRULE
# check-$(1)-%.out: %.txt
# 	diff -u <(./solution-$(1).swift < $$< 2>&1) $$*.$(1).out
# endef
#
# generate: $(foreach OUT,$(patsubst %.txt,%.out,$(sources)),$(foreach PART,$(parts),generate-$(PART)-$(OUT)))
#
# define GENRULE
# generate-$(1)-%.out: %.txt
# 	./solution-$(1).swift < $$< > $$*.$(1).out
# endef
#
# $(foreach PART,$(parts),$(eval $(call CHKRULE,$(PART))))
# $(foreach PART,$(parts),$(eval $(call GENRULE,$(PART))))
#
# # Place input file as input-*.txt.
# # Run `make generate` to generate output files.
# # Run `make check` to run program and compare output against pre-generated output files.
