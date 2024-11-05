/*
 * main.h
 *
 *  Created on: Dec 28, 2016
 *      Author: siguser
 */

#ifndef _MAIN_H_
#define _MAIN_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h> // for uint16_t
#include <stdlib.h>
#include <string.h> // for memset
#include <stddef.h> // for NULL
#include <stdbool.h>  // for true false bool
#include <stdio.h>      /* printf */
#include <assert.h>     /* assert */
#include <unistd.h>  // write(), close()
#include <fcntl.h>   // O_WRONLY
#include <errno.h>
#include <stdarg.h> // va_start

#include "user_types.h"

#ifdef __cplusplus
}
#endif

#endif /* _MAIN_H_ */
