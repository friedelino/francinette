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
	cout << FG_LGRAY << "ft_putstr_fd\t: ";

	int fd = open("tripouille", O_RDWR | O_CREAT);
	ft_putstr_fd((char*)"42", fd);
	lseek(fd, SEEK_SET, 0);
	char s[10] = {0}; read(fd, s, 3);
	check(!strcmp(s, "42"));
	unlink("./tripouille");
	cout << ENDL;
	return (0);
}