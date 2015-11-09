#include <Timer.h>
#include "Node1.h"
#include "../Msg/NetworkMsg.h"

module Node1C {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer;
  uses interface AMPacket;
  uses interface Packet;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface PacketAcknowledgements;
}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;
  uint32_t interval = INIT_INTERVAL;
  bool way_down = FALSE;

  event void Boot.booted() {
    call Leds.led0On();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer.startOneShot(interval);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer.fired() {
    counter++;
    if (!busy) {
      NetworkMsg* node1pkt = (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));
      if (node1pkt == NULL) {
	     return;
      }
      node1pkt->nodeid = TOS_NODE_ID;
      node1pkt->counter = counter;
      node1pkt->interval = interval;
      call PacketAcknowledgements.requestAck(&pkt);
      if (call AMSend.send(AM_DEST_ADDR, 
          &pkt, sizeof(NetworkMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
    if (way_down) {
      interval -= 50;
      if (interval <= 100) {
        way_down = FALSE;
      }
    } else {
      interval += 50;
      if (interval >= 500) {
        way_down = TRUE;
      }
    }
    call Timer.startOneShot(interval);
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg && call PacketAcknowledgements.wasAcked(msg)) {
      call Leds.led1Toggle();
    } else {
    }
    busy = FALSE;
  }
}
