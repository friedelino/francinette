extern "C"
{
#define new tripouille
#include "libft.h"
#undef new
}

#include "sigsegv.hpp"
#include "check.hpp"
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(void)
{
	signal(SIGSEGV, sigsegv);
	cout << FG_LGRAY << "ft_putendl_fd\t: ";

	int fd = open("tripouille", O_RDWR | O_CREAT);
	ft_putendl_fd((char*)"42", fd);
	lseek(fd, SEEK_SET, 0);
	char s[10] = {0}; read(fd, s, 4);
	check(!strcmp(s, "42\n"));
	unlink("./tripouille");
	cout << ENDL;
	return (0);
}