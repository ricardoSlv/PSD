package zeromq.guiao4;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class Wg {
    public static void main(String[] args) {
        try (ZContext context = new ZContext(); 
            ZMQ.Socket wfReplySocket = context.createSocket(SocketType.REP);
            ZMQ.Socket clients = context.createSocket(SocketType.ROUTER);
            ZMQ.Socket workers = context.createSocket(SocketType.DEALER)
            ) {
            clients.bind("tcp://*:"+5003);
            workers.bind("inproc://workers");
            for (int i = 0; i < 4; i++)
                new GWorker(context).start();
            ZMQ.proxy(clients, workers, null);
        }
    }
}

class GWorker extends Thread {
    ZContext context;

    GWorker(ZContext context) {
        this.context = context;
    }

    public void run() {
        try (ZMQ.Socket dealerReplySocket = context.createSocket(SocketType.REP)) {
            dealerReplySocket.connect("inproc://workers");
            while (true) {
                byte[] msg = dealerReplySocket.recv();
                String str = new String(msg);
                System.out.println("G worker received " + str);
                Integer result = 0;
                try {
                    result = Integer.valueOf(new String(msg));
                    Thread.sleep(1000); // Simulate running function g
                } catch (Exception e) {
                    System.out.println("Couldnt parse number from request");
                }
                result = result * 2;
                String res = result.toString();
                dealerReplySocket.send(res);
            }
        }
    }
}
