#ifndef SGTL5000_TEST_H
#define SGTL5000_TEST_H

#include <system.h>
#include <alt_types.h>

typedef struct SGTL5000_MMAP {
    alt_u32 start;
} sgtl5000_mmap_t;

static volatile sgtl5000_mmap_t* sgtl5000_mmap = (sgtl5000_mmap_t*) SOUND_0_BASE;

#endif /*SGTL5000_TEST_H*/