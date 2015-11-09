#include "Node3.h"

configuration Node3AppC {
}
implementation {
  components MainC;
  components LedsC;
  components Node3C as App;
  components ActiveMessageC;
  components SerialActiveMessageC;
  components LocalTimeMilliC as LocalTime;
  components new SerialAMSenderC(AM_SERIALMSG);
  components new AMReceiverC(AM_INTERMEDIATEMSG);

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.LocalTime -> LocalTime;
  App.AMControl -> ActiveMessageC;
  App.SerialPacket -> SerialAMSenderC;
  App.RadioPacket -> AMReceiverC;
  App.SerialControl -> SerialActiveMessageC;
  App.AMSend -> SerialAMSenderC;
  App.Receive -> AMReceiverC;
}
