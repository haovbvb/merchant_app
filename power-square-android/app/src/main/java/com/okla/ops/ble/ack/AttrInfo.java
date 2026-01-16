package com.okla.ops.ble.ack;

import java.util.List;

public class AttrInfo extends BaseAck {

    /**
     * 属性
     */
    private List<Attr> attrList;

    public static class Attr {
        /**
         * 信号量
         */
        private String id;
        /**
         * 值
         */
        private Object value;

        public Attr(String id, Object value) {
            this.id = id;
            this.value = value;
        }

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public Object getValue() {
            return value;
        }

        public void setValue(Object value) {
            this.value = value;
        }
    }

    public List<Attr> getAttrList() {
        return attrList;
    }

    public void setAttrList(List<Attr> attrList) {
        this.attrList = attrList;
    }
}
