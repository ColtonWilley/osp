#ifndef __crc32cr_table_h__
#define __crc32cr_table_h__
#include "first.h"

#include <sys/types.h>

#if defined HAVE_STDINT_H
# include <stdint.h>
#elif defined HAVE_INTTYPES_H
# include <inttypes.h>
#endif

uint32_t generate_crc32c(const char *string, size_t length);

#endif
