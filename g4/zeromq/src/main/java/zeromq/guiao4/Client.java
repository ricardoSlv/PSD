package zeromq.guiao4;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class Client {
    public static void main(String[] args) {
        try (ZContext context = new ZContext();
             ZMQ.Socket socket = context.createSocket(SocketType.REQ))
        {
            socket.connect("tcp://localhost:" + 5000);
            while (true) {
                String str = System.console().readLine();
                if (str == null) break;
                socket.send(str);
                byte[] msg = socket.recv();
                System.out.println(new String(msg));
            }
        }
    }
}
