package socket.handler;

import java.awt.Color;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.Date;

import javax.swing.JTextPane;
import javax.swing.text.BadLocationException;
import javax.swing.text.Document;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;

import socket.common.MessageUtil;

public class ClientHandler {

    public void messageSend(String name, JTextPane textOne, JTextPane textTwo) {
        Socket socket = null;
        try {
            socket = new Socket("127.0.0.1", 4700);
            if (socket.isConnected()) {
                MessageUtil.print("服务器：" + socket.getInetAddress().getHostAddress() + "已连接...");
            }
            DataOutputStream out = new DataOutputStream(socket.getOutputStream());
            DataInputStream in = new DataInputStream(socket.getInputStream());

            new Thread(new InHandler(in, textOne)).start();

            textTwo.addKeyListener(new TextListener(name, out, textOne, textTwo));

        } catch (Exception e) {
            MessageUtil.print("无法连接服务器");
        }
    }

    private class TextListener implements KeyListener {

        private String name;
        private DataOutputStream out;
        private JTextPane textOne;
        private JTextPane textTwo;

        public TextListener(String name, DataOutputStream out, JTextPane textOne, JTextPane textTwo) {
            super();
            this.name = name;
            this.out = out;
            this.textOne = textOne;
            this.textTwo = textTwo;
        }

        @Override
        public void keyTyped(KeyEvent e) {

        }

        @Override
        public void keyPressed(KeyEvent e) {
            Document doc = textOne.getDocument();

            SimpleAttributeSet attrSet = new SimpleAttributeSet();
            StyleConstants.setForeground(attrSet, new Color(0, 180, 0));

            String date = null;
            if (e.getKeyCode() == KeyEvent.VK_ENTER) {
                try {
                    date = MessageUtil.YYYY_MM_DD_HHMMSS.format(new Date());
                    doc.insertString(doc.getLength(), name + "  " + date + "\n", attrSet);
                    doc.insertString(doc.getLength(), "   " + textTwo.getText() + "\n", null);
                    out.writeUTF(name + "  " + date + "\n   " + textTwo.getText() + "\n");
                    MessageUtil.print("消息发送至服务器，消息内容：[\n" + name + "  " + date + "\n   " + textTwo.getText() + "\n]");
                } catch (IOException | BadLocationException e1) {
                    System.out.println("系统出错" + e1);
                }
                e.consume();
                textTwo.setText("");
            }
        }

        @Override
        public void keyReleased(KeyEvent e) {

        }

    }
}
