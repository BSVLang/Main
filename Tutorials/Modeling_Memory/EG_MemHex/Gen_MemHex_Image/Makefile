INPUT_TEXT_FILE = ../../Macbeth.txt
MEMHEX_FILE = ../Mem_Contents.hex

../src_BSV/Mem.hex:
	$(CC)  -o  Gen_MemHex_Image  Gen_MemHex_Image.c
	./Gen_MemHex_Image  $(INPUT_TEXT_FILE)  $(MEMHEX_FILE)

.PHONY: clean
clean:
	rm -f  *~  Gen_MemHex_Image

.PHONY: full_clean
full_clean:
	rm -f  *~  Gen_MemHex_Image
	rm -f   $(MEMHEX_FILE)
