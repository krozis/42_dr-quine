NAME	= Colleen Grace Sully

CC		= cc
CFLAGS	= -Wall -Wextra -Werror

SRCS	= colleen.c grace.c sully.c
OBJS	= $(SRCS:.c=.o)

all: $(NAME)

Colleen: colleen.o
	$(CC) $(CFLAGS) -o $@ $^

Grace: grace.o
	$(CC) $(CFLAGS) -o $@ $^

Sully: sully.o
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)
	rm -f Grace_kid.c

re: fclean all

.PHONY: all clean fclean re
