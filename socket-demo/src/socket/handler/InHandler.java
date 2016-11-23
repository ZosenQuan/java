package socket.handler;

import java.awt.Color;
import java.io.DataInputStream;
import java.io.IOException;
import java.util.regex.Pattern;

import javax.swing.JOptionPane;
import javax.swing.JTextPane;
import javax.swing.text.BadLocationException;
import javax.swing.text.Document;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;

import socket.common.MessageUtil;

public class InHandler implements Runnable {

    private DataInputStream in = null;
    private JTextPane textPane = null;

    public InHandler(DataInputStream in, JTextPane textPane) {
        super();
        this.in = in;
        this.textPane = textPane;
    }

    public void run() {
        String temp = null;
        boolean isKeep = true;
        Pattern regex = Pattern.compile("\n", Pattern.DOTALL);
        SimpleAttributeSet attrSet = new SimpleAttributeSet();
        StyleConstants.setForeground(attrSet, Color.BLUE);
        try {
            while (isKeep) {
                temp = in.readUTF();
                MessageUtil.print("接收到服务器转发的消息:[\n" + temp + "]");
                Document doc = textPane.getDocument();
                for (String res : regex.split(temp)) {
                    if (!res.startsWith(" "))
                        doc.insertString(doc.getLength(), res, attrSet);
                    else
                        doc.insertString(doc.getLength(), "\n" + res + "\n", null);
                }
                //textPane.setText(temp);
                textPane.setCaretPosition(doc.getLength());
                //实现垂直滚动条自动下滑到最低端  
                //logTxtArea.setCaretPosition(logTxtArea.getText().length());
            }
        } catch (IOException | BadLocationException e) {
            isKeep = false;
            MessageUtil.print("服务器失去连接，请重启尝试！");
            JOptionPane.showMessageDialog(null, "服务器失去连接，请重启客户端尝试！", "错误", JOptionPane.ERROR_MESSAGE);
            System.exit(0);
        }

    }
}
