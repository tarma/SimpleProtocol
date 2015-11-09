GEN=SerialMsg.java

MsgReader.class: SerialMsg.java
	javac *.java
	
SerialMsg.java:
	mig java -target=null -java-classname=SerialMsg ../Msg/SerialMsg.h SerialMsg -o $@
	
clean:
	rm -f *.class $(GEN)

