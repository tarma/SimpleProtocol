import java.util.*;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class MsgReader implements net.tinyos.message.MessageListener {

  private MoteIF moteIF;
  
  public MsgReader(String source) throws Exception {
    if (source != null) {
      moteIF = new MoteIF(BuildSource.makePhoenix(source, PrintStreamMessenger.err));
    }
    else {
      moteIF = new MoteIF(BuildSource.makePhoenix(PrintStreamMessenger.err));
    }
  }

  public void start() {
  }
  
  public void messageReceived(int to, Message message) {
    if (message instanceof SerialMsg) {
      SerialMsg serialMsg = (SerialMsg) message;
      System.out.println(serialMsg.get_nodeid() + " " + serialMsg.get_counter() + " " + serialMsg.get_interval() + " " + serialMsg.get_buffer() + " " + serialMsg.get_localtime());
    }
  }

  
  private static void usage() {
    System.err.println("usage: MsgReader [-comm <source>] message-class [message-class ...]");
  }

  private void addMsgType(Message msg) {
    moteIF.registerListener(msg, this);
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    Vector v = new Vector();
    if (args.length > 0) {
      for (int i = 0; i < args.length; i++) {
	if (args[i].equals("-comm")) {
	  source = args[++i];
	}
	else {
	  String className = args[i];
	  try {
	    Class c = Class.forName(className);
	    Object packet = c.newInstance();
	    Message msg = (Message)packet;
	    if (msg.amType() < 0) {
		System.err.println(className + " does not have an AM type - ignored");
	    }
	    else {
		v.addElement(msg);
	    }
	  }
	  catch (Exception e) {
	    System.err.println(e);
	  }
	}
      }
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }

    MsgReader mr = new MsgReader(source);
    Enumeration msgs = v.elements();
    while (msgs.hasMoreElements()) {
      Message m = (Message)msgs.nextElement();
      mr.addMsgType(m);
    }
    mr.start();
  }


}
