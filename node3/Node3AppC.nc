#include "Node3.h"

configuration Node3AppC {
}
implementation {
  components MainC;
  components LedsC;
  components Node3C as App;
  components ActiveMessageC;
  components SerialActiveMessageC;
  components new SerialAMSenderC(AM_NETWORKMSG);
  components new AMReceiverC(AM_NETWORKMSG);

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.AMControl -> ActiveMessageC;
  App.SerialControl -> SerialActiveMessageC;
  App.AMSend -> SerialAMSenderC;
  App.Receive -> AMReceiverC;
}
