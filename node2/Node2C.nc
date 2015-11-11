#include "Node2.h"
#include "../Msg/NetworkMsg.h"
#include "../Msg/IntermediateMsg.h"

module Node2C {
  uses interface Boot;
  uses interface Leds;
  uses interface AMSend;
  uses interface Packet;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface PacketAcknowledgements;
}
implementation {

  message_t  queueBufs[QUEUE_LEN];
  message_t * ONE_NOK queue[QUEUE_LEN];
  message_t pkt;
  uint8_t usage[QUEUE_LEN];
  uint8_t times[QUEUE_LEN];
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
    NetworkMsg *initMsg;
    IntermediateMsg *interMsg; 
    
    atomic {
      if (queueIn == queueOut && !queueFull) {
        queueBusy = FALSE;
        return;
      }
    }
    msg = queue[queueOut];
    initMsg = (NetworkMsg*)(call Packet.getPayload(msg, sizeof(NetworkMsg)));
    interMsg = (IntermediateMsg*)(call Packet.getPayload(&pkt, sizeof(IntermediateMsg)));
    if (initMsg == NULL || interMsg == NULL) {
      return;
    }
    interMsg->nodeid = initMsg->nodeid;
    interMsg->counter = initMsg->counter;
    interMsg->interval = initMsg->interval;
    interMsg->buffer = usage[queueOut];
    call PacketAcknowledgements.requestAck(&pkt);
    if (call AMSend.send(AM_DEST_ADDR, &pkt, sizeof(IntermediateMsg)) == SUCCESS) {
      call Leds.led2Toggle();
    } else {
      post sendTask();
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    atomic {
      if ((err == SUCCESS && call PacketAcknowledgements.wasAcked(msg)) || times[queueOut] <= 0) {
        queueOut = (queueOut + 1) % QUEUE_LEN;
        queueFull = FALSE;
      } else {
        times[queueOut]--;
      }
    }
    
    post sendTask();
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    message_t *ret = msg;
  
    if (len == sizeof(NetworkMsg)) {
      atomic {
        if (!queueFull) {
          ret = queue[queueIn];
          queue[queueIn] = msg;
          usage[queueIn] = (queueIn + QUEUE_LEN - queueOut) % QUEUE_LEN + 1;
          times[queueIn] = MAX_TIMES;
          
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
