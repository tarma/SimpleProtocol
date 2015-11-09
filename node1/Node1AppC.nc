#include <Timer.h>
#include "Node1.h"

configuration Node1AppC {
}
implementation {
  components MainC;
  components LedsC;
  components Node1C as App;
  components new TimerMilliC() as Timer;
  components ActiveMessageC;
  components new AMSenderC(AM_NETWORKMSG);

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer -> Timer;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.PacketAcknowledgements -> AMSenderC;
}
