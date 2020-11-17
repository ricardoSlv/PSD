package guiao5;

import java.nio.charset.StandardCharsets;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class Client {
    public static void main(String[] args) {
        String currentRoom = args[0];
        try (ZContext context = new ZContext();
             ZMQ.Socket socketSub = context.createSocket(SocketType.SUB);
             ZMQ.Socket socketPush = context.createSocket(SocketType.PUSH))
        {
            socketSub.connect("tcp://localhost:" + 5000);
            socketPush.connect("tcp://localhost:" + 5001);

            socketSub.subscribe(args[0].getBytes());
            new pubReaderThread(socketSub).start();
            while (true) {
                String msg = System.console().readLine();
                String token1 = msg.split(" ")[0];
                if(token1.equals("\\room")){
                    try{
                        String token2 = msg.split(" ")[1];
                        socketSub.unsubscribe(currentRoom);
                        socketSub.subscribe(token2);
                        currentRoom = token2;
                        System.out.println("Moved to room "+currentRoom);
                    }catch(Exception e){
                        e.printStackTrace();
                    }
                }
                else
                    socketPush.send(currentRoom +" "+ msg);
            }
        }
    }
}

class pubReaderThread extends Thread{
    private ZMQ.Socket socket;
    public pubReaderThread(ZMQ.Socket socket){
        this.socket=socket;
    }
    @Override
    public void run() {
        while(true){
            byte[] msg = socket.recv();
            System.out.println(new String(msg, StandardCharsets.UTF_8));
        }
    }
}