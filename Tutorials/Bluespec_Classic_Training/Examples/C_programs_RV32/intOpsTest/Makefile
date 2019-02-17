TOPDIR = ..

include ../Makefile

.PHONY: test_data
test_data:
	cp  genTests_c  genTests.c
	cc -o genTests genTests.c
	./genTests
	rm  -f genTests  genTests.c
	touch intOpsTest.c
	ls
