package com.base.common.map.location;

import android.util.Log;

import com.base.common.beans.LocationData;
import com.google.android.gms.maps.model.LatLng;

import java.util.List;
import java.util.Map;

public class LocationUtils {

    public static final LocationData[] ps = {
            new LocationData(22.53, 113.93),
            new LocationData(22.50, 113.91),
            new LocationData(22.52, 113.89),
            new LocationData(22.52, 113.92),
    };

    public static boolean isPtInPoly(double Alon, double Alat, Map<String, List<LatLng>> listMap) {
        if (listMap != null) {
            for (Map.Entry<String, List<LatLng>> entry : listMap.entrySet()) {
                List<LatLng> value = entry.getValue();
                LatLng[] array = value.toArray(new LatLng[0]);
                boolean ptInPoly = isPtInPoly(Alon, Alat, array);
                if (ptInPoly) return true;
            }
        }
        return false;
    }

    public static boolean isPtInPoly(double Alon, double Alat, List<List<LatLng>> list) {
        if (list != null) {
            for (List<LatLng> latLngList : list) {
                LatLng[] array = latLngList.toArray(new LatLng[0]);
                boolean ptInPoly = isPtInPoly(Alon, Alat, array);
                if (ptInPoly) return true;
            }
        }
        return false;
    }

    public static boolean isPtInPoly(double ALon, double ALat, LatLng[] ps) {
        int iSum, iCount, iIndex;
        double dLon1 = 0, dLon2 = 0, dLat1 = 0, dLat2 = 0, dLon;
        if (ps.length < 3) {
            return false;
        }
        iSum = 0;
        iCount = ps.length;
        for (iIndex = 0; iIndex < iCount; iIndex++) {
            if (iIndex == iCount - 1) {
                dLon1 = ps[iIndex].longitude;
                dLat1 = ps[iIndex].latitude;
                dLon2 = ps[0].longitude;
                dLat2 = ps[0].latitude;
            } else {
                dLon1 = ps[iIndex].longitude;
                dLat1 = ps[iIndex].latitude;
                dLon2 = ps[iIndex + 1].longitude;
                dLat2 = ps[iIndex + 1].latitude;
            }
            // 以下语句判断A点是否在边的两端点的水平平行线之间，在则可能有交点，开始判断交点是否在左射线上
            if (((ALat >= dLat1) && (ALat < dLat2)) || ((ALat >= dLat2) && (ALat < dLat1))) {
                if (Math.abs(dLat1 - dLat2) > 0) {
                    //得到 A点向左射线与边的交点的x坐标：
                    dLon = dLon1 - ((dLon1 - dLon2) * (dLat1 - ALat)) / (dLat1 - dLat2);
                    // 如果交点在A点左侧（说明是做射线与 边的交点），则射线与边的全部交点数加一：
                    if (dLon < ALon) {
                        iSum++;
                    }
                }
            }
        }
        if ((iSum % 2) != 0) {
            return true;
        }
        return false;
    }

}
