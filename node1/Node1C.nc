#include <Timer.h>
#include "Node1.h"
#include "../NetworkMsg.h"

module Node1C {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface PacketAcknowledgements;
}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;

  event void Boot.booted() {
    call Leds.led0On();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    counter++;
    if (!busy) {
      NetworkMsg* node1pkt = 
	(NetworkMsg*)(call Packet.getPayload(&pkt, sizeof(NetworkMsg)));
      if (node1pkt == NULL) {
	     return;
      }
      node1pkt->nodeid = TOS_NODE_ID;
      node1pkt->counter = counter;
      call PacketAcknowledgements.requestAck(&pkt);
      if (call AMSend.send(AM_DEST_ADDR, 
          &pkt, sizeof(NetworkMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg && call PacketAcknowledgements.wasAcked(msg)) {
      busy = FALSE;
      call Leds.led1Toggle();
    } else {
    }
  }
}
