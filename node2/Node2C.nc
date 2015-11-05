#include <Timer.h>
#include "Node2.h"
#include "../NetworkMsg.h"

module Node2C {
  uses interface Boot;
  uses interface Leds;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
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
    if (err != SUCCESS) {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      call Leds.led2Toggle();
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(NetworkMsg)) {
      pkt = *msg;
      call Leds.led1Toggle();
      if (call AMSend.send(AM_DEST_ADDR, 
          &pkt, sizeof(NetworkMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
    return msg;
  }
}
