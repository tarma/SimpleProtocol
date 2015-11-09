#include <Timer.h>
#include "Node3.h"
#include "../Msg/NetworkMsg.h"
#include "../Msg/SerialMsg.h"

module Node3C {
  uses interface Boot;
  uses interface Leds;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface SplitControl as SerialControl;
  uses interface Packet as RadioPacket;
  uses interface Packet as SerialPacket;
  uses interface PacketAcknowledgements;
  uses interface LocalTime<TMilli> as LocalTime;
}
implementation {

  message_t  queueBufs[QUEUE_LEN];
  message_t * ONE_NOK queue[QUEUE_LEN];
  uint32_t receiveTime[QUEUE_LEN];
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
    call SerialControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }
  
  event void SerialControl.startDone(error_t err) {
    if (err != SUCCESS) {
      call SerialControl.start();
    } else {
      queueFull = FALSE;
    }
  }
  
  event void SerialControl.stopDone(error_t err) {
  }
  
  task void sendTask() {
    message_t *radioMsg, serialMsg;
    SerialMsg *serialPkt;
    NetworkMsg *radioPkt;
    
    atomic {
      if (queueIn == queueOut && !queueFull) {
        queueBusy = FALSE;
        return;
      }
    }
    
    radioMsg = queue[queueOut];
    serialPkt = (SerialMsg*) (call SerialPacket.getPayload(&serialMsg, sizeof(SerialMsg)));
    radioPkt = (NetworkMsg*) (call RadioPacket.getPayload(radioMsg, sizeof(NetworkMsg)));
    if (serialPkt == NULL || radioPkt == NULL) {
      post sendTask();
      return;
    }
    serialPkt->nodeid = radioPkt->nodeid;
    serialPkt->counter = radioPkt->counter;
    serialPkt->interval = radioPkt->interval;
    serialPkt->localtime = receiveTime[queueOut];
    if (call AMSend.send(AM_BROADCAST_ADDR, &serialMsg, sizeof(SerialMsg)) == SUCCESS) {
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
          receiveTime[queueIn] = call LocalTime.get();
          
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
