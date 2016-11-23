package socket.client;

import java.awt.Dimension;
import java.awt.Toolkit;

import javax.swing.JFrame;
import javax.swing.JScrollPane;
import javax.swing.JTextPane;

import socket.handler.ClientHandler;

public class PublicClient {

    public void client(String name) {
        JFrame jFrame = new JFrame(name);
        Dimension dimension = Toolkit.getDefaultToolkit().getScreenSize();//获取屏幕高和宽
        //jFrame.setUndecorated(true);
        //jFrame.getRootPane().setWindowDecorationStyle(JRootPane.FRAME);
        //Image icon=Toolkit.getDefaultToolkit().getImage("F:/ico.png");
        //jFrame.setIconImage(icon);
        jFrame.setBounds(((int) dimension.getWidth() - 600) / 2, ((int) dimension.getHeight() - 400) / 2, 600, 400);
        jFrame.setResizable(false);
        jFrame.setLayout(null);
        jFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);//添加关闭按钮

        JTextPane textOne = new JTextPane();
        textOne.setEditable(false);
        JScrollPane scrollPaneOne = new JScrollPane(textOne);
        //scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_NEVER);//隐藏滚动条
        JTextPane textTwo = new JTextPane();
        JScrollPane scrollPaneTwo = new JScrollPane(textTwo);
        //final JTextField textTwo = new JTextField();
        scrollPaneOne.setBounds(0, 0, 595, 293);
        scrollPaneTwo.setBounds(0, 292, 595, 80);
        //textOne.setOpaque(false);
        //textOne.setEnabled(false);
        //textOne.setLineWrap(true);
        //textOne.setWrapStyleWord(true);
        //textTwo.setBorder(null);

        new ClientHandler().messageSend(name, textOne, textTwo);

        //panelOne.requestFocus();
        //panelOne.updateUI();
        jFrame.add(scrollPaneOne);
        jFrame.add(scrollPaneTwo);
        jFrame.setVisible(true);
    }
}
