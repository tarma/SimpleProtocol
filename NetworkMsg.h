#ifndef NETWORKMSG_H
#define NETWORKMSG_H

enum {
  AM_NETWORKMSG = 6
};

typedef nx_struct NetworkMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} NetworkMsg;

#endif
