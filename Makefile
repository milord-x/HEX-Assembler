ASM=nasm
LD=ld
ASMFLAGS=-f elf64
LDFLAGS=
TARGET=hexasm
SRC=hexasm.asm
OBJ=$(SRC:.asm=.o)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $<

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJ) $(TARGET)
