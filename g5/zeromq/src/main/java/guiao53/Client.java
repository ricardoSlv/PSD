package guiao53;

import java.nio.charset.StandardCharsets;
import java.util.Random;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class Client {
    public static void main(String[] args) {
        String currentRoom = args[0];
        try (ZContext context = new ZContext();
                ZMQ.Socket socketMainServerReq = context.createSocket(SocketType.REQ);
                ZMQ.Socket socketSub = context.createSocket(SocketType.SUB);
                ZMQ.Socket socketPush = context.createSocket(SocketType.PUSH)) {
            Integer subPort = new Random().nextInt(2) > 0 ? 8000 : 8001;
            socketSub.connect("tcp://localhost:" + subPort);
            System.out.println("I'm subscribed to " + "tcp://localhost:" + subPort);

            socketSub.subscribe(args[0].getBytes());

            socketMainServerReq.connect("tcp://localhost:" + 9000);
            socketMainServerReq.send("ConnectClient".getBytes());
            String publisherAddress = socketMainServerReq.recvStr();
            System.out.println("I'm publishing to " + publisherAddress);
            socketPush.connect(publisherAddress);

            new pubReaderThread(socketSub).start();

            while (true) {
                String msg = System.console().readLine();
                String token1 = msg.split(" ")[0];
                if (token1.equals("\\room")) {
                    try {
                        String token2 = msg.split(" ")[1];
                        socketSub.unsubscribe(currentRoom);
                        socketSub.subscribe(token2);
                        currentRoom = token2;
                        System.out.println("Moved to room " + currentRoom);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else
                    socketPush.send(currentRoom + " " + msg);
            }
        }
    }
}

class pubReaderThread extends Thread {
    private ZMQ.Socket socket;

    public pubReaderThread(ZMQ.Socket socket) {
        this.socket = socket;
    }

    @Override
    public void run() {
        while (true) {
            byte[] msg = socket.recv();
            System.out.println(new String(msg, StandardCharsets.UTF_8));
        }
    }
}