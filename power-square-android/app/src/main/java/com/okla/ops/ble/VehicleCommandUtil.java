package com.okla.ops.ble;

import java.util.List;

public class VehicleCommandUtil {

    public static String buildCommand(String id, int value) {
        return "{\"msgType\":500,\"devId\":\"" +
                "TEST" +
                "\",\"txnNo\":" +
                System.currentTimeMillis() +
                ",\"paramList\":[{\"id\":\"" +
                id +
                "\",\"value\":" +
                value +
                "}]}";
    }

    public static String buildCommand(String id, String value) {
        return "{\"msgType\":500,\"devId\":\"" +
                "TEST" +
                "\",\"txnNo\":" +
                System.currentTimeMillis() +
                ",\"paramList\":[{\"id\":\"" +
                id +
                "\",\"value\":" +
                "\"" +
                value +
                "\"" +
                "}]}";
    }

    public static String buildCommand(String id, String value, long txnNo) {
        return "{\"msgType\":500,\"devId\":\"" +
                "TEST" +
                "\",\"txnNo\":" +
                txnNo +
                ",\"paramList\":[{\"id\":\"" +
                id +
                "\",\"value\":" +
                "\"" +
                value +
                "\"" +
                "}]}";
    }

    public static String buildCommand(List<CommandParam> params) {
        StringBuilder stringBuffer = new StringBuilder();
        stringBuffer.append("{\"msgType\":500,\"devId\":\"");
        stringBuffer.append("TEST");
        stringBuffer.append("\",\"txnNo\":");
        stringBuffer.append(System.currentTimeMillis());
        stringBuffer.append(",\"paramList\":[");
        for (int i = 0; i < params.size(); i++) {
            CommandParam p = params.get(i);
            stringBuffer.append("{\"id\":\"");
            stringBuffer.append(p.id);
            stringBuffer.append("\",\"value\":");
            if (p.value instanceof String) {
                stringBuffer.append("\"");
                stringBuffer.append(p.value);
                stringBuffer.append("\"");
            } else {
                stringBuffer.append(p.value);
            }
            stringBuffer.append("}");
            if (i < params.size() - 1) {
                stringBuffer.append(","); // 多个之间添加逗号
            }
        }
        stringBuffer.append("]}");
        return stringBuffer.toString();
    }

    public static String buildCommand(List<CommandParam> params, long txnNo) {
        StringBuilder stringBuffer = new StringBuilder();
        stringBuffer.append("{\"msgType\":500,\"devId\":\"");
        stringBuffer.append("TEST");
        stringBuffer.append("\",\"txnNo\":");
        stringBuffer.append(txnNo);
        stringBuffer.append(",\"paramList\":[");
        for (int i = 0; i < params.size(); i++) {
            CommandParam p = params.get(i);
            stringBuffer.append("{\"id\":\"");
            stringBuffer.append(p.id);
            stringBuffer.append("\",\"value\":");
            if (p.value instanceof String) {
                stringBuffer.append("\"");
                stringBuffer.append(p.value);
                stringBuffer.append("\"");
            } else {
                stringBuffer.append(p.value);
            }
            stringBuffer.append("}");
            if (i < params.size() - 1) {
                stringBuffer.append(","); // 多个之间添加逗号
            }
        }
        stringBuffer.append("]}");
        return stringBuffer.toString();
    }

    public static class CommandParam {
        public String id;
        public Object value;

        public CommandParam(String id, Object value) {
            this.id = id;
            this.value = value;
        }
    }

}
