INPUT_TEXT_FILE = ../../Macbeth.txt
BSV_ROM_FN_FILE = ../src_BSV/fn_read_ROM.bsvi

../src_BSV/fn_read_ROM.bsvi:
	$(CC)  -o  Gen_ROM_Function  Gen_ROM_Function.c
	./Gen_ROM_Function  $(INPUT_TEXT_FILE)  $(BSV_ROM_FN_FILE)

.PHONY: clean
clean:
	rm -f  *~  Gen_ROM_Function

.PHONY: full_clean
full_clean:
	rm -f  *~  Gen_ROM_Function
	rm -f  $(BSV_ROM_FN_FILE)
