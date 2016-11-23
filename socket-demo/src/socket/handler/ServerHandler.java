package socket.handler;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;

import socket.common.MessageUtil;

public class ServerHandler implements Runnable {

    private Socket socket;

    public ServerHandler(Socket socket) {
        super();
        this.socket = socket;
    }

    @Override
    public void run() {
        DataOutputStream out = null;
        DataInputStream in = null;
        String temp = null;
        String host = socket.getInetAddress().getHostAddress() + "," + socket.getPort();
        try {
            in = new DataInputStream(socket.getInputStream());
        } catch (IOException e) {
            MessageUtil.print("服务器出错：" + e);
        }

        int i = 1;
        boolean isKeep = true;
        while (isKeep) {
            try {
                temp = in.readUTF();
                if (temp != null) {
                    MessageUtil.print("接收到" + host + "发来的消息[\n" + temp + "]...计数" + i++);
                    //获取目标socket-- TODO
                    for (String key : MessageUtil.getMap().keySet()) {
                        if (host.equals(key))
                            continue;
                        out = MessageUtil.getMap().get(key);
                        out.writeUTF(temp);
                        MessageUtil.print("消息转发至" + key);
                    }
                }
            } catch (IOException e) {
                isKeep = false;
                MessageUtil.getMap().remove(host);
                MessageUtil.print(host + "已断开连接，请重启客户端尝试！");
            }
        }
    }

}
