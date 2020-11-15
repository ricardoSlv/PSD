package zeromq.guiao4;

import java.util.ArrayList;

import org.zeromq.SocketType;
import org.zeromq.ZMQ;
import org.zeromq.ZContext;

public class Ws {

    private static ArrayList<Integer> currentValue = new ArrayList<>(1);
    public static void main(String[] args) {
        currentValue.add(0);
        try (ZContext context = new ZContext();
            ZMQ.Socket clientSocket = context.createSocket(SocketType.REP);
            ZMQ.Socket responseSocket = context.createSocket(SocketType.REQ);
            ZMQ.Socket wfPushSocket = context.createSocket(SocketType.PUSH))
        {
            
            clientSocket.bind("tcp://*:" + 5000);
            wfPushSocket.bind("tcp://*:" + 5001);
            
            new ResultProcessor(context, currentValue).start();
            while (true) {
                byte[] msg = clientSocket.recv();
                String str = new String(msg);
                System.out.println("Received " + str);
                wfPushSocket.send(str);
                System.out.println(currentValue);
                clientSocket.send(currentValue.get(0).toString());
            }
        }
    }    
}

class ResultProcessor extends Thread {
    ZContext context;
    ArrayList<Integer> currentValue;

    ResultProcessor(ZContext context, ArrayList<Integer> value) {
        this.context = context;
        this.currentValue = value;
    }

    public void run() {
        try (ZMQ.Socket resultSocket = context.createSocket(SocketType.PULL)) {
            resultSocket.bind("tcp://*:" + 5004);
            while (true) {
                byte[] msg = resultSocket.recv();
                Integer result = 0;
                try{
                    result = Integer.valueOf(new String(msg));
                }catch(Exception e){
                    System.out.println("Couldnt parse number from request");
                }
                currentValue.set(0,currentValue.get(0)+result);
            }
        }
    }
}
