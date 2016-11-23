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
            MessageUtil.print("server服务已开启，等待客户端接入...");
            while (isKeep) {
                socket = server.accept();
                if (socket.isConnected()) {
                    host = socket.getInetAddress().getHostAddress() + "," + socket.getPort();
                    MessageUtil.getMap().put(host, new DataOutputStream(socket.getOutputStream()));
                    new Thread(new ServerHandler(socket)).start();
                    MessageUtil.print("客户端：" + host + "已连接...");
                }
                Thread.sleep(1000);
            }
        } catch (Exception e) {
            isKeep = false;
            MessageUtil.print("系统出错：" + e);
        }

    }

}
