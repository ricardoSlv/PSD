package guiao5;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class Publisher {
    public static void main(String[] args) {
        try (ZContext context = new ZContext();
             ZMQ.Socket socket = context.createSocket(SocketType.PUB))
        {
            socket.bind("tcp://*:" + 5000);
            while (true) {
                String str = System.console().readLine();
                if (str == null) break;
                socket.sendMore("room1");
                socket.send(str);
                socket.send(str);
            }
        }
    }
}

