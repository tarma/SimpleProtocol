#ifndef SERIALMSG_H
#define SERIALMSG_H

enum {
  AM_SERIALMSG = 11
};

typedef nx_struct SerialMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint32_t interval;
  nx_uint32_t localtime;
} SerialMsg;

#endif
