targets := $(patsubst %.txt,%.out,$(wildcard input-*.txt))

all: build $(targets)
	cat input-test-a.txt | ./solution

build: solution

solution: solution.nim
	nim compile $<

input-%.out: input-%.txt
	cat $< | ./solution > $@

clean:
	rm $(targets)
