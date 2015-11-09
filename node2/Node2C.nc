#include "Node2.h"
#include "../Msg/NetworkMsg.h"

module Node2C {
  uses interface Boot;
  uses interface Leds;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface PacketAcknowledgements;
}
implementation {

  message_t  queueBufs[QUEUE_LEN];
  message_t * ONE_NOK queue[QUEUE_LEN];
  uint8_t queueIn, queueOut;
  bool queueBusy, queueFull;

  event void Boot.booted() {
    uint8_t i;
    
    for (i = 0; i < QUEUE_LEN; i++) {
      queue[i] = &queueBufs[i];
    }
    
    queueIn = 0;
    queueOut = 0;
    queueBusy = FALSE;
    queueFull = TRUE;
    
    call Leds.led0On();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call AMControl.start();
    } else {
      queueFull = FALSE;
    }
  }

  event void AMControl.stopDone(error_t err) {
  }
  
  task void sendTask() {
    message_t *msg;
    
    atomic {
      if (queueIn == queueOut && !queueFull) {
        queueBusy = FALSE;
        return;
      }
    }
    
    msg = queue[queueOut];
    call PacketAcknowledgements.requestAck(msg);
    if (call AMSend.send(AM_DEST_ADDR, msg, sizeof(NetworkMsg)) == SUCCESS) {
      call Leds.led2Toggle();
    } else {
      post sendTask();
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (err == SUCCESS) {
      atomic {
        if (msg == queue[queueOut]) {
          queueOut = (queueOut + 1) % QUEUE_LEN;
          queueFull = FALSE;
        }
        
        post sendTask();
      }
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    message_t *ret = msg;
  
    if (len == sizeof(NetworkMsg)) {
      atomic {
        if (!queueFull) {
          ret = queue[queueIn];
          queue[queueIn] = msg;
          
          queueIn = (queueIn + 1) % QUEUE_LEN;
          
          if (queueIn == queueOut) {
            queueFull = TRUE;
          }
          
          if (!queueBusy) {
            post sendTask();
            queueBusy = TRUE;
          }
          
          call Leds.led1Toggle();
        } else {
          // TODO: drop here
        }
      }
    }
    return ret;
  }
}
