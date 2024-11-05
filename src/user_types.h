#ifndef _MAIN2_H_
#define _USER_TYPES_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned int U32;
typedef unsigned short U16;
typedef unsigned char U8;

typedef signed int S32;
typedef signed short S16;
typedef signed char S8;

typedef signed char int8;
typedef signed short int16;
typedef signed int int32;
typedef signed long int64;

typedef unsigned char uint8;
typedef unsigned short int uint16;
typedef unsigned int uint32;
typedef unsigned long uint64;
typedef signed int sint32;

//#define false 0
//#define true 1
//#define bool _Bool

#ifndef boolean
typedef uint8 boolean;
#endif

#ifdef __cplusplus
}
#endif


#endif /* _MAIN2_H_ */
