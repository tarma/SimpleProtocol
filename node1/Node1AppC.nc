#include <Timer.h>
#include "Node1.h"

configuration Node1AppC {
}
implementation {
  components MainC;
  components LedsC;
  components Node1C as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_NODE1);

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.PacketAcknowledgements -> AMSenderC;
}