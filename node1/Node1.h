#ifndef NODE1_H
#define NODE1_H

enum {
  AM_NODE1 = 6,
  TIMER_PERIOD_MILLI = 250,
  AM_DEST_ADDR = 2
};

typedef nx_struct Node1Msg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} Node1Msg;

#endif
