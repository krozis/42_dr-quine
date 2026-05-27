#include <stdio.h>

// Another One Writes the Rust

#define S "#include <stdio.h>%c%c// Another One Writes the Rust%c%c#define S %c%s%c%c#define N %cGrace_kid.c%c%c#define MAIN int main(void){FILE*f=fopen(N,%cw%c);fprintf(f,S,10,10,10,10,34,S,34,10,34,34,10,34,34,10,10,10);fclose(f);return(0);}%c%cMAIN%c"
#define N "Grace_kid.c"
#define MAIN int main(void){FILE*f=fopen(N,"w");fprintf(f,S,10,10,10,10,34,S,34,10,34,34,10,34,34,10,10,10);fclose(f);return(0);}

MAIN
