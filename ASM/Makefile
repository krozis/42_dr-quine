NAME			= Colleen Grace Sully

GRACE_CHILDS	= Grace_kid.s

SULLY_CHILDS	= Sully_*
SULLY_OBJS		= Sully_*.o

ASM				= nasm
ASMFLAGS		= -f elf64

LD				= gcc

SRCS			= colleen.s grace.s sully.s
OBJS			= $(SRCS:.s=.o)

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
	rm -f $(SULLY_OBJS)

fclean: clean
	rm -f $(NAME)
	rm -f $(GRACE_CHILDS)
	rm -f $(SULLY_CHILDS)

re: fclean all

.PHONY: all clean fclean re
