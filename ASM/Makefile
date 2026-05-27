NAME	= Colleen Grace Sully

ASM		= nasm
ASMFLAGS= -f elf64

LD		= gcc

SRCS	= colleen.s grace.s sully.s
OBJS	= $(SRCS:.s=.o)

all: $(NAME)

Colleen: colleen.o
	$(LD) -o $@ $^

Grace: grace.o
	$(LD) -o $@ $^

Sully: sully.o
	$(LD) -o $@ $^

%.o: %.s
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
