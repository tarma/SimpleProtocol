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
  uint16_t interval_index = 0;
  uint16_t firedCounter = FIRED_TIMES;

  event void Boot.booted() {
    call Leds.led0On();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer.startOneShot(interval_array[interval_index]);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer.fired() {
  atomic {
    counter++;
    if (!busy) {
      NetworkMsg* node1pkt = (NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));
      if (node1pkt == NULL) {
	     return;
      }
      node1pkt->nodeid = TOS_NODE_ID;
      node1pkt->counter = counter;
      node1pkt->interval = interval_array[interval_index];
      call PacketAcknowledgements.requestAck(&pkt);
      if (call AMSend.send(AM_DEST_ADDR, &pkt, sizeof(NetworkMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
    
    firedCounter--;
    if (firedCounter <= 0) {
      interval_index++;
      firedCounter = FIRED_TIMES;
    }
    if (interval_index < INTERVAL_LEN) {
      call Timer.startOneShot(interval_array[interval_index]);
    }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg && call PacketAcknowledgements.wasAcked(msg)) {
      call Leds.led1Toggle();
    } else {
    }
    busy = FALSE;
  }
}
