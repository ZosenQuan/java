package socket.server;

import java.io.DataOutputStream;
import java.net.ServerSocket;
import java.net.Socket;

import socket.common.MessageUtil;
import socket.handler.ServerHandler;

public class Server {

    public static void main(String[] args) {
        ServerSocket server = null;
        Socket socket = null;
        boolean isKeep = true;
        String host = null;
        try {
            server = new ServerSocket(4700);
            MessageUtil.print("server�����ѿ������ȴ��ͻ��˽���...");
            while (isKeep) {
                socket = server.accept();
                if (socket.isConnected()) {
                    host = socket.getInetAddress().getHostAddress() + "," + socket.getPort();
                    MessageUtil.getMap().put(host, new DataOutputStream(socket.getOutputStream()));
                    new Thread(new ServerHandler(socket)).start();
                    MessageUtil.print("�ͻ��ˣ�" + host + "������...");
                }
                Thread.sleep(1000);
            }
        } catch (Exception e) {
            isKeep = false;
            MessageUtil.print("ϵͳ����" + e);
        }

    }

}
