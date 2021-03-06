#include "Node2.h"

configuration Node2AppC {
}
implementation {
  components MainC;
  components LedsC;
  components Node2C as App;
  components ActiveMessageC;
  components new AMSenderC(AM_INTERMEDIATEMSG);
  components new AMReceiverC(AM_NETWORKMSG);

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.PacketAcknowledgements -> AMSenderC;
}
