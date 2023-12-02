# targets := $(patsubst %.txt,%.out,$(wildcard input-*.txt))
#
# # build: $(targets)
# #
# # input-%.out: input-%.txt
# # 	cat $< | perl solution.pl > $@
# #
# # clean:
# # 	rm $(targets)
#
# build: build.cm solution.sml str.sml
# 	/usr/local/smlnj/bin/ml-build build.cm Solution.main
#
# run: build $(targets)
# 	cat input-final.out
#
# input-%.out: input-%.txt
# 	cat $< | /usr/local/smlnj/bin/sml @SMLload=build > $@
#
# clean:
# 	rm $(targets)
#
# print-%:
# 	@echo $* = $($*)

define RUN
	/usr/local/smlnj/bin/sml @SMLload=build < $(2)
endef

include ../common.mk
