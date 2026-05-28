#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int	i = 5;

char	*s = "#include <stdio.h>%c#include <stdlib.h>%c#include <unistd.h>%c%cint%ci = %d;%c%cchar%c*s = %c%s%c;%c%cint%cmain(void)%c{%c%cchar%cname[24];%c%cchar%ccmd[128];%c%cFILE%c*f;%c%c%csnprintf(name, sizeof(name), %cSully_%%d.c%c, i - 1);%c%c%c/*%c%c%cThe Stack Must Go On%c%c*/%c%c%cf = fopen(name, %cw%c);%c%cfprintf(f, s, 10, 10, 10, 10, 9, i - 1, 10, 10, 9, 34, s, 34, 10, 10, 9, 10, 10, 9, 9, 10, 9, 9, 10, 9, 9, 10, 10, 9, 34, 34, 10, 10, 9, 10, 9, 9, 10, 9, 10, 10, 9, 34, 34, 10, 9, 10, 9, 10, 9, 34, 34, 10, 9, 10, 9, 10, 9, 10, 9, 9, 34, 34, 10, 9, 9, 10, 9, 10, 9, 10, 10);%c%cfclose(f);%c%csnprintf(cmd, sizeof(cmd), %ccc -Wall -Wextra -Werror -o Sully_%%d %%s%c, i - 1, name);%c%csystem(cmd);%c%cif (i - 1 >= 0)%c%c{%c%c%csnprintf(cmd, sizeof(cmd), %c./Sully_%%d%c, i - 1);%c%c%cexecl(cmd, cmd, NULL);%c%c}%c%creturn (0);%c}%c";

int	main(void)
{
	char	name[24];
	char	cmd[128];
	FILE	*f;

	snprintf(name, sizeof(name), "Sully_%d.c", i - 1);

	/*
		The Stack Must Go On
	*/

	f = fopen(name, "w");
	fprintf(f, s, 10, 10, 10, 10, 9, i - 1, 10, 10, 9, 34, s, 34, 10, 10, 9, 10, 10, 9, 9, 10, 9, 9, 10, 9, 9, 10, 10, 9, 34, 34, 10, 10, 9, 10, 9, 9, 10, 9, 10, 10, 9, 34, 34, 10, 9, 10, 9, 10, 9, 34, 34, 10, 9, 10, 9, 10, 9, 10, 9, 9, 34, 34, 10, 9, 9, 10, 9, 10, 9, 10, 10);
	fclose(f);
	snprintf(cmd, sizeof(cmd), "cc -Wall -Wextra -Werror -o Sully_%d %s", i - 1, name);
	system(cmd);
	if (i - 1 >= 0)
	{
		snprintf(cmd, sizeof(cmd), "./Sully_%d", i - 1);
		execl(cmd, cmd, NULL);
	}
	return (0);
}
