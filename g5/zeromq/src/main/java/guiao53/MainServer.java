package guiao53;

import java.util.ArrayList;
import java.util.Random;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class MainServer {
    public static void main(String[] args) {
        try (ZContext context = new ZContext();
             ZMQ.Socket socketReq = context.createSocket(SocketType.REP);)
        {
            socketReq.bind("tcp://*:" + 9000);
            //Prevent socket repetition on same machine
            Integer uuid = 5000;
            ArrayList<String> pubNodes = new ArrayList<>();
            while (true) {
                String msg = socketReq.recvStr();
                String[] msgFields = msg.split(" ");
                if(msgFields[0].equals("RegisterPublisher")){
                    uuid++;
                    pubNodes.add(msgFields[1]+uuid);
                    socketReq.send(uuid.toString());
                }
                else if(msgFields[0].equals("ConnectClient")){
                    socketReq.send(pubNodes.get(new Random().nextInt(pubNodes.size())));
                }
                else
                    socketReq.send("Go away".getBytes());
            }
        }
    }
}
