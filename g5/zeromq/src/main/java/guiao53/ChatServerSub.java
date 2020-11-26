package guiao53;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class ChatServerSub {
    public static void main(String[] args) {
        try (ZContext context = new ZContext();
                ZMQ.Socket socketSub = context.createSocket(SocketType.SUB);
                ZMQ.Socket socketPub = context.createSocket(SocketType.PUB)) {
            int id = Integer.parseInt(args[0]); 
            socketPub.bind("tcp://*:" + (8000 + id));
            socketSub.bind("tcp://*:" + (7000+id));
            socketSub.subscribe("".getBytes());
            while (true) {
                byte[] msg = socketSub.recv();
                System.out.println("Got a msg");
                socketPub.send(msg);
            }
        }
    }
}
