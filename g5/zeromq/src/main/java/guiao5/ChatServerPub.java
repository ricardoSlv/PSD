package guiao5;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class ChatServerPub {
    public static void main(String[] args) {
        try (ZContext context = new ZContext();
        ZMQ.Socket socketPull = context.createSocket(SocketType.PULL);
            ZMQ.Socket socketPub = context.createSocket(SocketType.PUB))
        {   
            int id = Integer.parseInt(args[0]);           
            socketPull.bind("tcp://*:" + (5000+id));
            socketPub.bind("tcp://*:" + (7000+id));
            while (true) {
                byte[] msg = socketPull.recv();
                System.out.println("Got a msg");
                socketPub.send(msg);
            }
        }
    }
}
