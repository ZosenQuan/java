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
            MessageUtil.print("����������" + e);
        }

        int i = 1;
        boolean isKeep = true;
        while (isKeep) {
            try {
                temp = in.readUTF();
                if (temp != null) {
                    MessageUtil.print("���յ�" + host + "��������Ϣ[\n" + temp + "]...����" + i++);
                    //��ȡĿ��socket-- TODO
                    for (String key : MessageUtil.getMap().keySet()) {
                        if (host.equals(key))
                            continue;
                        out = MessageUtil.getMap().get(key);
                        out.writeUTF(temp);
                        MessageUtil.print("��Ϣת����" + key);
                    }
                }
            } catch (IOException e) {
                isKeep = false;
                MessageUtil.getMap().remove(host);
                MessageUtil.print(host + "�ѶϿ����ӣ��������ͻ��˳��ԣ�");
            }
        }
    }

}
