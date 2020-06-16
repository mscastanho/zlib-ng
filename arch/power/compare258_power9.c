/* Optimized byte comparison for POWER9 processors
 * Copyright (C) 2019 IBM Corporation
 * Author: Matheus Castanho <msc@linux.ibm.com>
 * For conditions of distribution and use, see copyright notice in zlib.h
 */

#include <altivec.h>
#include "zbuild.h"
#include "deflate.h"

static inline int32_t compare256_unaligned_power9_static(const unsigned char *src0, const unsigned char *src1) {
    int32_t total_match = 0;

    do {
        vector unsigned char vsrc0 = *(vector unsigned char *)src0;
        vector unsigned char vsrc1 = *(vector unsigned char *)src1;
        vector unsigned char vc = (vector unsigned char) vec_cmpne(vsrc0,vsrc1);
        int32_t curr_match = vec_cnttz_lsbb(vc);

        if (curr_match != 16)
            return (int32_t)(total_match + curr_match);

        src0 += 16, src1 += 16, total_match += 16;
    } while (total_match < 256);

    return 256;
}

static inline int32_t compare258_unaligned_power9_static(const unsigned char *src0, const unsigned char *src1) {
    if (*(uint16_t *)src0 != *(uint16_t *)src1)
        return (*src0 == *src1);

    return compare256_unaligned_power9_static(src0+2, src1+2) + 2;
}

int32_t compare258_unaligned_power9(const unsigned char *src0, const unsigned char *src1) {
    return compare258_unaligned_power9_static(src0, src1);
}

#define LONGEST_MATCH longest_match_unaligned_power9
#define COMPARE256    compare256_unaligned_power9_static
#define COMPARE258    compare258_unaligned_power9_static

#include "match_tpl.h"
