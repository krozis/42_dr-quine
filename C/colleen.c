#include <stdio.h>

/*
	Boolean Rhapsody
*/

char	*s = "#include <stdio.h>%c%c/*%c%cBoolean Rhapsody%c*/%c%cchar%c*s = %c%s%c;%c%cvoid%cprint(void)%c{%c%cprintf(s, 10, 10, 10, 9, 10, 10, 10, 9, 34, s, 34, 10, 10, 9, 10, 10, 9, 10, 10, 10, 9, 10, 10, 9, 10, 9, 10, 9, 9, 10, 9, 10, 9, 10, 10, 10);%c}%c%cint%cmain(void)%c{%c%cprint();%c%c/*%c%c%cKiller Quine%c%c*/%c%creturn (0);%c}%c";

void	print(void)
{
	printf(s, 10, 10, 10, 9, 10, 10, 10, 9, 34, s, 34, 10, 10, 9, 10, 10, 9, 10, 10, 10, 9, 10, 10, 9, 10, 9, 10, 9, 9, 10, 9, 10, 9, 10, 10, 10);
}

int	main(void)
{
	print();
	/*
		Killer Quine
	*/
	return (0);
}
