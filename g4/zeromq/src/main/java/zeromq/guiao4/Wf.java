package zeromq.guiao4;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class Wf {

    public static void main(String[] args) {
        try (ZContext context = new ZContext(); 
            ZMQ.Socket wsPullSocket = context.createSocket(SocketType.PULL);
            ZMQ.Socket internalPushSocket = context.createSocket(SocketType.PUSH)) {
            wsPullSocket.connect("tcp://localhost:" + 5001);
            internalPushSocket.bind("inproc://push");

            new ResultHandler(context).start();
            while (true) {
                byte[] msg = wsPullSocket.recv();
                String str = new String(msg);
                System.out.println("Received " + str);
                Integer result = 0;
                try {
                    result = Integer.parseInt(str);
                    Thread.sleep(3000); // Simulate running function f
                } catch (Exception e) {
                    System.out.println("Couldnt parse number from request");
                    e.printStackTrace();
                } 
                Integer calculatedResult = result + 3; 
                System.out.println("Result is: " + calculatedResult);
                internalPushSocket.send(calculatedResult.toString());
            }
        }
    }
}

class ResultHandler extends Thread {
    ZContext context;

    ResultHandler(ZContext context) {
        this.context = context;
    }

    public void run() {
        try (ZMQ.Socket wgRouteSocket = context.createSocket(SocketType.REQ);
            ZMQ.Socket  wsResultSocket = context.createSocket(SocketType.PUSH);
            ZMQ.Socket internalPushSocket = context.createSocket(SocketType.PULL)) {

            wgRouteSocket.connect("tcp://localhost:" + 5003);
            wsResultSocket.connect("tcp://localhost:" + 5004);
            internalPushSocket.connect("inproc://push");

            while (true) {
                byte[] msg = internalPushSocket.recv();
                Integer value = Integer.valueOf(new String(msg));
                wgRouteSocket.send(value.toString());
                byte[] resultMsg = wgRouteSocket.recv();
                String resultValue = new String(resultMsg);
                wsResultSocket.send(resultValue);
            }
        }
    }
}
