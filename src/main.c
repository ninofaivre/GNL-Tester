/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: nino <nino@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/08/28 11:34:36 by nino              #+#    #+#             */
/*   Updated: 2021/09/01 13:35:34 by nino             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "../../get_next_line.h"

int	main(int argc, char **argv)
{
	int		fd;
	char	*str;

	str = "test";
	if (!argv[1][0] && argc == 3)
		fd = atoi(argv[2]);
	else
		fd = open (argv[1], O_RDONLY);
	while (str != NULL)
	{
		str = get_next_line (fd);
		if (str)
			printf ("%s", str);
		if (str)
			free (str);
	}
	return (0);
}
