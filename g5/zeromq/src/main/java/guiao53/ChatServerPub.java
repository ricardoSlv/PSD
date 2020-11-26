package guiao53;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class ChatServerPub {
    public static void main(String[] args) {
        try (ZContext context = new ZContext();
            ZMQ.Socket socketPull = context.createSocket(SocketType.PULL);
            ZMQ.Socket socketMainServerReq = context.createSocket(SocketType.REQ);
            ZMQ.Socket socketPub = context.createSocket(SocketType.PUB))
        {   
            socketMainServerReq.connect("tcp://localhost:" + 9000);
            socketMainServerReq.send("RegisterPublisher "+"tcp://localhost:");
            String port = socketMainServerReq.recvStr();
            int id = Integer.parseInt(port);         
            System.out.println("Listening for clients on "+id);  
            socketPull.bind("tcp://*:" + id);
            socketPub.connect("tcp://localhost:" + 7000);
            socketPub.connect("tcp://localhost:" + 7001);
            while (true) {
                byte[] msg = socketPull.recv();
                System.out.println("Got a msg");
                socketPub.send(msg);
            }
        }
    }
}
