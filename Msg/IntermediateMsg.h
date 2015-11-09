#ifndef INTERMEDIATEMSG_H
#define INTERMEDIATEMSG_H

enum {
  AM_INTERMEDIATEMSG = 33
};

typedef nx_struct IntermediateMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint32_t interval;
  nx_uint8_t buffer;
} IntermediateMsg;

#endif
