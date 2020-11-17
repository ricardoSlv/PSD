package guiao5;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class ChatServer {
    public static void main(String[] args) {
        try (ZContext context = new ZContext();
             ZMQ.Socket socketPub = context.createSocket(SocketType.PUB);
             ZMQ.Socket socketPull = context.createSocket(SocketType.PULL))
        {
            socketPub.bind("tcp://*:" + 5000);
            socketPull.bind("tcp://*:" + 5001);
            while (true) {
                byte[] msg = socketPull.recv();
                socketPub.send(msg);
            }
        }
    }
}
