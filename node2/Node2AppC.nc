#include "Node2.h"

configuration Node2AppC {
}
implementation {
  components MainC;
  components LedsC;
  components Node2C as App;
  components ActiveMessageC;
  components new AMSenderC(AM_NODE2_SEND_CHANNEL);
  components new AMReceiverC(AM_NODE2_RECEIVE_CHANNEL);

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.PacketAcknowledgements -> AMSenderC;
}
