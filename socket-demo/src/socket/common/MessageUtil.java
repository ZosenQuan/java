package socket.common;

import java.io.DataOutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class MessageUtil {

    private static SimpleDateFormat YYYY_MM_DD_HHMMSS_SSS = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.sss");
    public static SimpleDateFormat YYYY_MM_DD_HHMMSS = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static Map<String, DataOutputStream> map = new HashMap<>();

    public static void print(String message) {
        System.out.println("[" + YYYY_MM_DD_HHMMSS_SSS.format(new Date()) + "]" + message);
    }

    public static synchronized Map<String, DataOutputStream> getMap() {
        return map;
    }

}
