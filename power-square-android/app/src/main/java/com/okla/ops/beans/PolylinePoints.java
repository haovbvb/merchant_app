package com.okla.ops.beans;

import androidx.databinding.BaseObservable;
import androidx.databinding.Bindable;

import com.okla.ops.BR;

import java.util.List;
public class PolylinePoints extends BaseObservable{

    /**
     * geocoded_waypoints : [{"geocoder_status":"OK","place_id":"ChIJEaJdyBHuAzQR8kk6vf8oHVw","types":["premise"]},{"geocoder_status":"OK","place_id":"ChIJ33eDwbDvAzQRNF2U_685KvY","types":["establishment","food","point_of_interest","restaurant"]}]
     * routes : [{"bounds":{"northeast":{"lat":22.5338293,"lng":113.9372068},"southwest":{"lat":22.4936993,"lng":113.921834}},"copyrights":"Map data ©2021","legs":[{"distance":{"text":"6.0 km","value":6003},"duration":{"text":"18 mins","value":1079},"end_address":"China, Guangdong Sheng, Shenzhen Shi, Nanshan Qu, 育材路蛇口培训基地内（近蛇口电信）","end_location":{"lat":22.4947695,"lng":113.9226652},"start_address":"Li Shan Can Ting, Nanshan Qu, Shenzhen Shi, Guangdong Sheng, China","start_location":{"lat":22.5338293,"lng":113.9372068},"steps":[{"distance":{"text":"0.2 km","value":153},"duration":{"text":"1 min","value":29},"end_location":{"lat":22.5334828,"lng":113.9357712},"html_instructions":"Head <b>west<\/b> toward <b>学生西路<\/b>","polyline":{"points":"mcphCqjlvT@T@T@HBHBJBFJVBH@JL|@R~A"},"start_location":{"lat":22.5338293,"lng":113.9372068},"travel_mode":"DRIVING"},{"distance":{"text":"38 m","value":38},"duration":{"text":"1 min","value":12},"end_location":{"lat":22.5338105,"lng":113.9356825},"html_instructions":"Turn <b>right<\/b>","maneuver":"turn-right","polyline":{"points":"gaphCqalvTaAP"},"start_location":{"lat":22.5334828,"lng":113.9357712},"travel_mode":"DRIVING"},{"distance":{"text":"78 m","value":78},"duration":{"text":"1 min","value":19},"end_location":{"lat":22.5336504,"lng":113.9349425},"html_instructions":"Turn <b>left<\/b>","maneuver":"turn-left","polyline":{"points":"icphC_alvT^rC"},"start_location":{"lat":22.5338105,"lng":113.9356825},"travel_mode":"DRIVING"},{"distance":{"text":"37 m","value":37},"duration":{"text":"1 min","value":12},"end_location":{"lat":22.5336835,"lng":113.9346297},"html_instructions":"Turn <b>right<\/b>","maneuver":"turn-right","polyline":{"points":"ibphCk|kvTK@?DDt@"},"start_location":{"lat":22.5336504,"lng":113.9349425},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":111},"duration":{"text":"1 min","value":26},"end_location":{"lat":22.5329476,"lng":113.9340522},"html_instructions":"Turn <b>left<\/b>","maneuver":"turn-left","polyline":{"points":"obphCmzkvTHAR@`@N@@VNFPDHPF?B@HBJ@BBDDDDB"},"start_location":{"lat":22.5336835,"lng":113.9346297},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":107},"duration":{"text":"1 min","value":20},"end_location":{"lat":22.5329102,"lng":113.9330116},"html_instructions":"Turn <b>right<\/b> toward <b>深大西路<\/b>","maneuver":"turn-right","polyline":{"points":"}}ohCyvkvT?Z?\\Aj@@Z@n@D\\"},"start_location":{"lat":22.5329476,"lng":113.9340522},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":258},"duration":{"text":"1 min","value":51},"end_location":{"lat":22.5307785,"lng":113.9321075},"html_instructions":"Turn <b>left<\/b> onto <b>深大西路<\/b>","maneuver":"turn-left","polyline":{"points":"u}ohCipkvTpB~@l@X`@Lp@XLFPFd@RRFLBH@J@R@ZAFA"},"start_location":{"lat":22.5329102,"lng":113.9330116},"travel_mode":"DRIVING"},{"distance":{"text":"32 m","value":32},"duration":{"text":"1 min","value":11},"end_location":{"lat":22.5307435,"lng":113.9318039},"html_instructions":"Turn <b>right<\/b> toward <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"kpohCujkvT?\\@F?DDP"},"start_location":{"lat":22.5307785,"lng":113.9321075},"travel_mode":"DRIVING"},{"distance":{"text":"50 m","value":50},"duration":{"text":"1 min","value":10},"end_location":{"lat":22.53093,"lng":113.9313595},"html_instructions":"Turn <b>right<\/b> toward <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"cpohCwhkvTUt@O`@"},"start_location":{"lat":22.5307435,"lng":113.9318039},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":136},"duration":{"text":"1 min","value":23},"end_location":{"lat":22.5320444,"lng":113.9318931},"html_instructions":"Turn <b>right<\/b> onto <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"iqohC_fkvTsCmAME]K]I"},"start_location":{"lat":22.53093,"lng":113.9313595},"travel_mode":"DRIVING"},{"distance":{"text":"70 m","value":70},"duration":{"text":"1 min","value":10},"end_location":{"lat":22.5322095,"lng":113.9315848},"html_instructions":"Continue straight","maneuver":"straight","polyline":{"points":"gxohCiikvTG?_@GEAGBABAF?H?D?HBFDBLP"},"start_location":{"lat":22.5320444,"lng":113.9318931},"travel_mode":"DRIVING"},{"distance":{"text":"3.7 km","value":3742},"duration":{"text":"10 mins","value":611},"end_location":{"lat":22.5002094,"lng":113.921834},"html_instructions":"Slight <b>left<\/b> onto <b>南海大道<\/b>","maneuver":"turn-slight-left","polyline":{"points":"iyohCkgkvTl@Np@RlA`@zAn@BBr@ZhAf@@@f@Th@TZ?nB~@LFrCpALDb@PPHJB`@LbBX@?XDVBX@Z@jABV?n@?bA?R?V?|@?|@Ar@CXAp@EHArBSn@Eh@CjACR?T?N?H?B?T@R@V@d@DZBD@N@VBZFVDj@Jf@JFBj@NtCz@hA\\JDF@x@TvAb@j@Nt@TdAZLB|@Vf@NHBn@PZJfA\\p@PDB`@J`@H|@P|APV@nAHvCN~CVB?jAPlATvAXh@NRFpA^bAXhA\\j@Nv@Vz@XF@PFLDb@N\\Jh@PJB~@XnBn@zAb@r@TdBd@dBh@bAXh@N`Bf@LDLDbB`@~@V?@bAXpA^JBVHhA\\RFzAb@THfCr@VHB@D@b@Lb@Jt@Tj@NPF"},"start_location":{"lat":22.5322095,"lng":113.9315848},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":308},"duration":{"text":"2 mins","value":95},"end_location":{"lat":22.4993142,"lng":113.9246694},"html_instructions":"Turn <b>left<\/b> onto <b>工业八路<\/b>","maneuver":"turn-left","polyline":{"points":"iqihCmjivTDUPy@Ns@f@uBFYZoAJi@T_APs@Hc@@Q"},"start_location":{"lat":22.5002094,"lng":113.921834},"travel_mode":"DRIVING"},{"distance":{"text":"0.6 km","value":626},"duration":{"text":"2 mins","value":99},"end_location":{"lat":22.4936993,"lng":113.924759},"html_instructions":"Turn <b>right<\/b> onto <b>公园路<\/b>","maneuver":"turn-right","polyline":{"points":"ukihCe|ivTpBC~@CdDI^Ah@Af@?l@BD?jBJN@pBFB?f@@r@AN?hBIrBGf@C"},"start_location":{"lat":22.4993142,"lng":113.9246694},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":257},"duration":{"text":"1 min","value":51},"end_location":{"lat":22.4947695,"lng":113.9226652},"html_instructions":"Turn <b>right<\/b> onto <b>工业七路<\/b>","maneuver":"turn-right","polyline":{"points":"shhhCw|ivTAx@Cd@ATALGZERIVMVOV_@f@s@|@g@f@YV"},"start_location":{"lat":22.4936993,"lng":113.924759},"travel_mode":"DRIVING"}],"traffic_speed_entry":[],"via_waypoint":[]}],"overview_polyline":{"points":"mcphCqjlvTBj@DRVt@NhAR~AaAP^rCK@Dz@\\?b@PVNFPDHPF@LDNHJDB?ZAhABjAD\\pB~@nAf@vB|@`@JTBn@?FA?\\@LDPUt@O`@sCmAk@QkASIFAP?NHJLPl@N~Bt@|EvBh@Vh@TZ?|BfA`DvAbBl@vCb@xCF~C?zBAlAE~Ea@~CGr@@lBLhANrB`@vGnBlKxC~GpB~AZtBRfFXbDVxCf@`Ch@rF~AhGlBdF~AzIhC|EvApD`AhKzCrI`CPFDU`@mBvAiGf@sBJu@vJSpAAr@BpFTzA?xBIzCKE~ACb@Mn@Wn@o@~@{AdBYV"},"summary":"南海大道","warnings":[],"waypoint_order":[]}]
     * status : OK
     */

    private String status;
    private List<GeocodedWaypointsBean> geocoded_waypoints;
    private List<RoutesBean> routes;

    @Bindable
    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        notifyPropertyChanged(BR.status);
    }

    @Bindable
    public List<GeocodedWaypointsBean> getGeocoded_waypoints() {
        return geocoded_waypoints;
    }

    public void setGeocoded_waypoints(List<GeocodedWaypointsBean> geocoded_waypoints) {
        this.geocoded_waypoints = geocoded_waypoints;
        notifyPropertyChanged(BR.geocoded_waypoints);
    }

    @Bindable
    public List<RoutesBean> getRoutes() {
        return routes;
    }

    public void setRoutes(List<RoutesBean> routes) {
        this.routes = routes;
        notifyPropertyChanged(BR.routes);
    }

    public static class GeocodedWaypointsBean extends BaseObservable {
        /**
         * geocoder_status : OK
         * place_id : ChIJEaJdyBHuAzQR8kk6vf8oHVw
         * types : ["premise"]
         */

        private String geocoder_status;
        private String place_id;
        private List<String> types;

        @Bindable
        public String getGeocoder_status() {
            return geocoder_status;
        }

        public void setGeocoder_status(String geocoder_status) {
            this.geocoder_status = geocoder_status;
            notifyPropertyChanged(BR.geocoder_status);
        }

        @Bindable
        public String getPlace_id() {
            return place_id;
        }

        public void setPlace_id(String place_id) {
            this.place_id = place_id;
            notifyPropertyChanged(BR.place_id);
        }

        @Bindable
        public List<String> getTypes() {
            return types;
        }

        public void setTypes(List<String> types) {
            this.types = types;
            notifyPropertyChanged(BR.types);
        }
    }

    public static class RoutesBean extends BaseObservable {
        /**
         * bounds : {"northeast":{"lat":22.5338293,"lng":113.9372068},"southwest":{"lat":22.4936993,"lng":113.921834}}
         * copyrights : Map data ©2021
         * legs : [{"distance":{"text":"6.0 km","value":6003},"duration":{"text":"18 mins","value":1079},"end_address":"China, Guangdong Sheng, Shenzhen Shi, Nanshan Qu, 育材路蛇口培训基地内（近蛇口电信）","end_location":{"lat":22.4947695,"lng":113.9226652},"start_address":"Li Shan Can Ting, Nanshan Qu, Shenzhen Shi, Guangdong Sheng, China","start_location":{"lat":22.5338293,"lng":113.9372068},"steps":[{"distance":{"text":"0.2 km","value":153},"duration":{"text":"1 min","value":29},"end_location":{"lat":22.5334828,"lng":113.9357712},"html_instructions":"Head <b>west<\/b> toward <b>学生西路<\/b>","polyline":{"points":"mcphCqjlvT@T@T@HBHBJBFJVBH@JL|@R~A"},"start_location":{"lat":22.5338293,"lng":113.9372068},"travel_mode":"DRIVING"},{"distance":{"text":"38 m","value":38},"duration":{"text":"1 min","value":12},"end_location":{"lat":22.5338105,"lng":113.9356825},"html_instructions":"Turn <b>right<\/b>","maneuver":"turn-right","polyline":{"points":"gaphCqalvTaAP"},"start_location":{"lat":22.5334828,"lng":113.9357712},"travel_mode":"DRIVING"},{"distance":{"text":"78 m","value":78},"duration":{"text":"1 min","value":19},"end_location":{"lat":22.5336504,"lng":113.9349425},"html_instructions":"Turn <b>left<\/b>","maneuver":"turn-left","polyline":{"points":"icphC_alvT^rC"},"start_location":{"lat":22.5338105,"lng":113.9356825},"travel_mode":"DRIVING"},{"distance":{"text":"37 m","value":37},"duration":{"text":"1 min","value":12},"end_location":{"lat":22.5336835,"lng":113.9346297},"html_instructions":"Turn <b>right<\/b>","maneuver":"turn-right","polyline":{"points":"ibphCk|kvTK@?DDt@"},"start_location":{"lat":22.5336504,"lng":113.9349425},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":111},"duration":{"text":"1 min","value":26},"end_location":{"lat":22.5329476,"lng":113.9340522},"html_instructions":"Turn <b>left<\/b>","maneuver":"turn-left","polyline":{"points":"obphCmzkvTHAR@`@N@@VNFPDHPF?B@HBJ@BBDDDDB"},"start_location":{"lat":22.5336835,"lng":113.9346297},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":107},"duration":{"text":"1 min","value":20},"end_location":{"lat":22.5329102,"lng":113.9330116},"html_instructions":"Turn <b>right<\/b> toward <b>深大西路<\/b>","maneuver":"turn-right","polyline":{"points":"}}ohCyvkvT?Z?\\Aj@@Z@n@D\\"},"start_location":{"lat":22.5329476,"lng":113.9340522},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":258},"duration":{"text":"1 min","value":51},"end_location":{"lat":22.5307785,"lng":113.9321075},"html_instructions":"Turn <b>left<\/b> onto <b>深大西路<\/b>","maneuver":"turn-left","polyline":{"points":"u}ohCipkvTpB~@l@X`@Lp@XLFPFd@RRFLBH@J@R@ZAFA"},"start_location":{"lat":22.5329102,"lng":113.9330116},"travel_mode":"DRIVING"},{"distance":{"text":"32 m","value":32},"duration":{"text":"1 min","value":11},"end_location":{"lat":22.5307435,"lng":113.9318039},"html_instructions":"Turn <b>right<\/b> toward <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"kpohCujkvT?\\@F?DDP"},"start_location":{"lat":22.5307785,"lng":113.9321075},"travel_mode":"DRIVING"},{"distance":{"text":"50 m","value":50},"duration":{"text":"1 min","value":10},"end_location":{"lat":22.53093,"lng":113.9313595},"html_instructions":"Turn <b>right<\/b> toward <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"cpohCwhkvTUt@O`@"},"start_location":{"lat":22.5307435,"lng":113.9318039},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":136},"duration":{"text":"1 min","value":23},"end_location":{"lat":22.5320444,"lng":113.9318931},"html_instructions":"Turn <b>right<\/b> onto <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"iqohC_fkvTsCmAME]K]I"},"start_location":{"lat":22.53093,"lng":113.9313595},"travel_mode":"DRIVING"},{"distance":{"text":"70 m","value":70},"duration":{"text":"1 min","value":10},"end_location":{"lat":22.5322095,"lng":113.9315848},"html_instructions":"Continue straight","maneuver":"straight","polyline":{"points":"gxohCiikvTG?_@GEAGBABAF?H?D?HBFDBLP"},"start_location":{"lat":22.5320444,"lng":113.9318931},"travel_mode":"DRIVING"},{"distance":{"text":"3.7 km","value":3742},"duration":{"text":"10 mins","value":611},"end_location":{"lat":22.5002094,"lng":113.921834},"html_instructions":"Slight <b>left<\/b> onto <b>南海大道<\/b>","maneuver":"turn-slight-left","polyline":{"points":"iyohCkgkvTl@Np@RlA`@zAn@BBr@ZhAf@@@f@Th@TZ?nB~@LFrCpALDb@PPHJB`@LbBX@?XDVBX@Z@jABV?n@?bA?R?V?|@?|@Ar@CXAp@EHArBSn@Eh@CjACR?T?N?H?B?T@R@V@d@DZBD@N@VBZFVDj@Jf@JFBj@NtCz@hA\\JDF@x@TvAb@j@Nt@TdAZLB|@Vf@NHBn@PZJfA\\p@PDB`@J`@H|@P|APV@nAHvCN~CVB?jAPlATvAXh@NRFpA^bAXhA\\j@Nv@Vz@XF@PFLDb@N\\Jh@PJB~@XnBn@zAb@r@TdBd@dBh@bAXh@N`Bf@LDLDbB`@~@V?@bAXpA^JBVHhA\\RFzAb@THfCr@VHB@D@b@Lb@Jt@Tj@NPF"},"start_location":{"lat":22.5322095,"lng":113.9315848},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":308},"duration":{"text":"2 mins","value":95},"end_location":{"lat":22.4993142,"lng":113.9246694},"html_instructions":"Turn <b>left<\/b> onto <b>工业八路<\/b>","maneuver":"turn-left","polyline":{"points":"iqihCmjivTDUPy@Ns@f@uBFYZoAJi@T_APs@Hc@@Q"},"start_location":{"lat":22.5002094,"lng":113.921834},"travel_mode":"DRIVING"},{"distance":{"text":"0.6 km","value":626},"duration":{"text":"2 mins","value":99},"end_location":{"lat":22.4936993,"lng":113.924759},"html_instructions":"Turn <b>right<\/b> onto <b>公园路<\/b>","maneuver":"turn-right","polyline":{"points":"ukihCe|ivTpBC~@CdDI^Ah@Af@?l@BD?jBJN@pBFB?f@@r@AN?hBIrBGf@C"},"start_location":{"lat":22.4993142,"lng":113.9246694},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":257},"duration":{"text":"1 min","value":51},"end_location":{"lat":22.4947695,"lng":113.9226652},"html_instructions":"Turn <b>right<\/b> onto <b>工业七路<\/b>","maneuver":"turn-right","polyline":{"points":"shhhCw|ivTAx@Cd@ATALGZERIVMVOV_@f@s@|@g@f@YV"},"start_location":{"lat":22.4936993,"lng":113.924759},"travel_mode":"DRIVING"}],"traffic_speed_entry":[],"via_waypoint":[]}]
         * overview_polyline : {"points":"mcphCqjlvTBj@DRVt@NhAR~AaAP^rCK@Dz@\\?b@PVNFPDHPF@LDNHJDB?ZAhABjAD\\pB~@nAf@vB|@`@JTBn@?FA?\\@LDPUt@O`@sCmAk@QkASIFAP?NHJLPl@N~Bt@|EvBh@Vh@TZ?|BfA`DvAbBl@vCb@xCF~C?zBAlAE~Ea@~CGr@@lBLhANrB`@vGnBlKxC~GpB~AZtBRfFXbDVxCf@`Ch@rF~AhGlBdF~AzIhC|EvApD`AhKzCrI`CPFDU`@mBvAiGf@sBJu@vJSpAAr@BpFTzA?xBIzCKE~ACb@Mn@Wn@o@~@{AdBYV"}
         * summary : 南海大道
         * warnings : []
         * waypoint_order : []
         */

        private BoundsBean bounds;
        private String copyrights;
        private OverviewPolylineBean overview_polyline;
        private String summary;
        private List<LegsBean> legs;
        private List<?> warnings;
        private List<?> waypoint_order;

        @Bindable
        public BoundsBean getBounds() {
            return bounds;
        }

        public void setBounds(BoundsBean bounds) {
            this.bounds = bounds;
            notifyPropertyChanged(BR.bounds);
        }

        @Bindable
        public String getCopyrights() {
            return copyrights;
        }

        public void setCopyrights(String copyrights) {
            this.copyrights = copyrights;
            notifyPropertyChanged(BR.copyrights);
        }

        @Bindable
        public OverviewPolylineBean getOverview_polyline() {
            return overview_polyline;
        }

        public void setOverview_polyline(OverviewPolylineBean overview_polyline) {
            this.overview_polyline = overview_polyline;
            notifyPropertyChanged(BR.overview_polyline);
        }

        @Bindable
        public String getSummary() {
            return summary;
        }

        public void setSummary(String summary) {
            this.summary = summary;
            notifyPropertyChanged(BR.summary);
        }

        @Bindable
        public List<LegsBean> getLegs() {
            return legs;
        }

        public void setLegs(List<LegsBean> legs) {
            this.legs = legs;
            notifyPropertyChanged(BR.legs);
        }

        @Bindable
        public List<?> getWarnings() {
            return warnings;
        }

        public void setWarnings(List<?> warnings) {
            this.warnings = warnings;
            notifyPropertyChanged(BR.warnings);
        }

        @Bindable
        public List<?> getWaypoint_order() {
            return waypoint_order;
        }

        public void setWaypoint_order(List<?> waypoint_order) {
            this.waypoint_order = waypoint_order;
            notifyPropertyChanged(BR.waypoint_order);
        }

        public static class BoundsBean extends BaseObservable {
            /**
             * northeast : {"lat":22.5338293,"lng":113.9372068}
             * southwest : {"lat":22.4936993,"lng":113.921834}
             */

            private NortheastBean northeast;
            private SouthwestBean southwest;

            @Bindable
            public NortheastBean getNortheast() {
                return northeast;
            }

            public void setNortheast(NortheastBean northeast) {
                this.northeast = northeast;
                notifyPropertyChanged(BR.northeast);
            }

            @Bindable
            public SouthwestBean getSouthwest() {
                return southwest;
            }

            public void setSouthwest(SouthwestBean southwest) {
                this.southwest = southwest;
                notifyPropertyChanged(BR.southwest);
            }

            public static class NortheastBean extends BaseObservable {
                /**
                 * lat : 22.5338293
                 * lng : 113.9372068
                 */

                private double lat;
                private double lng;

                @Bindable
                public double getLat() {
                    return lat;
                }

                public void setLat(double lat) {
                    this.lat = lat;
                    notifyPropertyChanged(BR.lat);
                }

                @Bindable
                public double getLng() {
                    return lng;
                }

                public void setLng(double lng) {
                    this.lng = lng;
                    notifyPropertyChanged(BR.lng);
                }
            }

            public static class SouthwestBean extends BaseObservable {
                /**
                 * lat : 22.4936993
                 * lng : 113.921834
                 */

                private double lat;
                private double lng;

                @Bindable
                public double getLat() {
                    return lat;
                }

                public void setLat(double lat) {
                    this.lat = lat;
                    notifyPropertyChanged(BR.lat);
                }

                @Bindable
                public double getLng() {
                    return lng;
                }

                public void setLng(double lng) {
                    this.lng = lng;
                    notifyPropertyChanged(BR.lng);
                }
            }
        }

        public static class OverviewPolylineBean extends BaseObservable {
            /**
             * points : mcphCqjlvTBj@DRVt@NhAR~AaAP^rCK@Dz@\?b@PVNFPDHPF@LDNHJDB?ZAhABjAD\pB~@nAf@vB|@`@JTBn@?FA?\@LDPUt@O`@sCmAk@QkASIFAP?NHJLPl@N~Bt@|EvBh@Vh@TZ?|BfA`DvAbBl@vCb@xCF~C?zBAlAE~Ea@~CGr@@lBLhANrB`@vGnBlKxC~GpB~AZtBRfFXbDVxCf@`Ch@rF~AhGlBdF~AzIhC|EvApD`AhKzCrI`CPFDU`@mBvAiGf@sBJu@vJSpAAr@BpFTzA?xBIzCKE~ACb@Mn@Wn@o@~@{AdBYV
             */

            private String points;

            @Bindable
            public String getPoints() {
                return points;
            }

            public void setPoints(String points) {
                this.points = points;
                notifyPropertyChanged(BR.points);
            }
        }

        public static class LegsBean extends BaseObservable {
            /**
             * distance : {"text":"6.0 km","value":6003}
             * duration : {"text":"18 mins","value":1079}
             * end_address : China, Guangdong Sheng, Shenzhen Shi, Nanshan Qu, 育材路蛇口培训基地内（近蛇口电信）
             * end_location : {"lat":22.4947695,"lng":113.9226652}
             * start_address : Li Shan Can Ting, Nanshan Qu, Shenzhen Shi, Guangdong Sheng, China
             * start_location : {"lat":22.5338293,"lng":113.9372068}
             * steps : [{"distance":{"text":"0.2 km","value":153},"duration":{"text":"1 min","value":29},"end_location":{"lat":22.5334828,"lng":113.9357712},"html_instructions":"Head <b>west<\/b> toward <b>学生西路<\/b>","polyline":{"points":"mcphCqjlvT@T@T@HBHBJBFJVBH@JL|@R~A"},"start_location":{"lat":22.5338293,"lng":113.9372068},"travel_mode":"DRIVING"},{"distance":{"text":"38 m","value":38},"duration":{"text":"1 min","value":12},"end_location":{"lat":22.5338105,"lng":113.9356825},"html_instructions":"Turn <b>right<\/b>","maneuver":"turn-right","polyline":{"points":"gaphCqalvTaAP"},"start_location":{"lat":22.5334828,"lng":113.9357712},"travel_mode":"DRIVING"},{"distance":{"text":"78 m","value":78},"duration":{"text":"1 min","value":19},"end_location":{"lat":22.5336504,"lng":113.9349425},"html_instructions":"Turn <b>left<\/b>","maneuver":"turn-left","polyline":{"points":"icphC_alvT^rC"},"start_location":{"lat":22.5338105,"lng":113.9356825},"travel_mode":"DRIVING"},{"distance":{"text":"37 m","value":37},"duration":{"text":"1 min","value":12},"end_location":{"lat":22.5336835,"lng":113.9346297},"html_instructions":"Turn <b>right<\/b>","maneuver":"turn-right","polyline":{"points":"ibphCk|kvTK@?DDt@"},"start_location":{"lat":22.5336504,"lng":113.9349425},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":111},"duration":{"text":"1 min","value":26},"end_location":{"lat":22.5329476,"lng":113.9340522},"html_instructions":"Turn <b>left<\/b>","maneuver":"turn-left","polyline":{"points":"obphCmzkvTHAR@`@N@@VNFPDHPF?B@HBJ@BBDDDDB"},"start_location":{"lat":22.5336835,"lng":113.9346297},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":107},"duration":{"text":"1 min","value":20},"end_location":{"lat":22.5329102,"lng":113.9330116},"html_instructions":"Turn <b>right<\/b> toward <b>深大西路<\/b>","maneuver":"turn-right","polyline":{"points":"}}ohCyvkvT?Z?\\Aj@@Z@n@D\\"},"start_location":{"lat":22.5329476,"lng":113.9340522},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":258},"duration":{"text":"1 min","value":51},"end_location":{"lat":22.5307785,"lng":113.9321075},"html_instructions":"Turn <b>left<\/b> onto <b>深大西路<\/b>","maneuver":"turn-left","polyline":{"points":"u}ohCipkvTpB~@l@X`@Lp@XLFPFd@RRFLBH@J@R@ZAFA"},"start_location":{"lat":22.5329102,"lng":113.9330116},"travel_mode":"DRIVING"},{"distance":{"text":"32 m","value":32},"duration":{"text":"1 min","value":11},"end_location":{"lat":22.5307435,"lng":113.9318039},"html_instructions":"Turn <b>right<\/b> toward <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"kpohCujkvT?\\@F?DDP"},"start_location":{"lat":22.5307785,"lng":113.9321075},"travel_mode":"DRIVING"},{"distance":{"text":"50 m","value":50},"duration":{"text":"1 min","value":10},"end_location":{"lat":22.53093,"lng":113.9313595},"html_instructions":"Turn <b>right<\/b> toward <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"cpohCwhkvTUt@O`@"},"start_location":{"lat":22.5307435,"lng":113.9318039},"travel_mode":"DRIVING"},{"distance":{"text":"0.1 km","value":136},"duration":{"text":"1 min","value":23},"end_location":{"lat":22.5320444,"lng":113.9318931},"html_instructions":"Turn <b>right<\/b> onto <b>南海大道<\/b>","maneuver":"turn-right","polyline":{"points":"iqohC_fkvTsCmAME]K]I"},"start_location":{"lat":22.53093,"lng":113.9313595},"travel_mode":"DRIVING"},{"distance":{"text":"70 m","value":70},"duration":{"text":"1 min","value":10},"end_location":{"lat":22.5322095,"lng":113.9315848},"html_instructions":"Continue straight","maneuver":"straight","polyline":{"points":"gxohCiikvTG?_@GEAGBABAF?H?D?HBFDBLP"},"start_location":{"lat":22.5320444,"lng":113.9318931},"travel_mode":"DRIVING"},{"distance":{"text":"3.7 km","value":3742},"duration":{"text":"10 mins","value":611},"end_location":{"lat":22.5002094,"lng":113.921834},"html_instructions":"Slight <b>left<\/b> onto <b>南海大道<\/b>","maneuver":"turn-slight-left","polyline":{"points":"iyohCkgkvTl@Np@RlA`@zAn@BBr@ZhAf@@@f@Th@TZ?nB~@LFrCpALDb@PPHJB`@LbBX@?XDVBX@Z@jABV?n@?bA?R?V?|@?|@Ar@CXAp@EHArBSn@Eh@CjACR?T?N?H?B?T@R@V@d@DZBD@N@VBZFVDj@Jf@JFBj@NtCz@hA\\JDF@x@TvAb@j@Nt@TdAZLB|@Vf@NHBn@PZJfA\\p@PDB`@J`@H|@P|APV@nAHvCN~CVB?jAPlATvAXh@NRFpA^bAXhA\\j@Nv@Vz@XF@PFLDb@N\\Jh@PJB~@XnBn@zAb@r@TdBd@dBh@bAXh@N`Bf@LDLDbB`@~@V?@bAXpA^JBVHhA\\RFzAb@THfCr@VHB@D@b@Lb@Jt@Tj@NPF"},"start_location":{"lat":22.5322095,"lng":113.9315848},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":308},"duration":{"text":"2 mins","value":95},"end_location":{"lat":22.4993142,"lng":113.9246694},"html_instructions":"Turn <b>left<\/b> onto <b>工业八路<\/b>","maneuver":"turn-left","polyline":{"points":"iqihCmjivTDUPy@Ns@f@uBFYZoAJi@T_APs@Hc@@Q"},"start_location":{"lat":22.5002094,"lng":113.921834},"travel_mode":"DRIVING"},{"distance":{"text":"0.6 km","value":626},"duration":{"text":"2 mins","value":99},"end_location":{"lat":22.4936993,"lng":113.924759},"html_instructions":"Turn <b>right<\/b> onto <b>公园路<\/b>","maneuver":"turn-right","polyline":{"points":"ukihCe|ivTpBC~@CdDI^Ah@Af@?l@BD?jBJN@pBFB?f@@r@AN?hBIrBGf@C"},"start_location":{"lat":22.4993142,"lng":113.9246694},"travel_mode":"DRIVING"},{"distance":{"text":"0.3 km","value":257},"duration":{"text":"1 min","value":51},"end_location":{"lat":22.4947695,"lng":113.9226652},"html_instructions":"Turn <b>right<\/b> onto <b>工业七路<\/b>","maneuver":"turn-right","polyline":{"points":"shhhCw|ivTAx@Cd@ATALGZERIVMVOV_@f@s@|@g@f@YV"},"start_location":{"lat":22.4936993,"lng":113.924759},"travel_mode":"DRIVING"}]
             * traffic_speed_entry : []
             * via_waypoint : []
             */

            private DistanceBean distance;
            private DurationBean duration;
            private String end_address;
            private EndLocationBean end_location;
            private String start_address;
            private StartLocationBean start_location;
            private List<StepsBean> steps;
            private List<?> traffic_speed_entry;
            private List<?> via_waypoint;

            @Bindable
            public DistanceBean getDistance() {
                return distance;
            }

            public void setDistance(DistanceBean distance) {
                this.distance = distance;
                notifyPropertyChanged(BR.distance);
            }

            @Bindable
            public DurationBean getDuration() {
                return duration;
            }

            public void setDuration(DurationBean duration) {
                this.duration = duration;
                notifyPropertyChanged(BR.duration);
            }

            @Bindable
            public String getEnd_address() {
                return end_address;
            }

            public void setEnd_address(String end_address) {
                this.end_address = end_address;
                notifyPropertyChanged(BR.end_address);
            }

            @Bindable
            public EndLocationBean getEnd_location() {
                return end_location;
            }

            public void setEnd_location(EndLocationBean end_location) {
                this.end_location = end_location;
                notifyPropertyChanged(BR.end_location);
            }

            @Bindable
            public String getStart_address() {
                return start_address;
            }

            public void setStart_address(String start_address) {
                this.start_address = start_address;
                notifyPropertyChanged(BR.start_address);
            }

            @Bindable
            public StartLocationBean getStart_location() {
                return start_location;
            }

            public void setStart_location(StartLocationBean start_location) {
                this.start_location = start_location;
                notifyPropertyChanged(BR.start_location);
            }

            @Bindable
            public List<StepsBean> getSteps() {
                return steps;
            }

            public void setSteps(List<StepsBean> steps) {
                this.steps = steps;
                notifyPropertyChanged(BR.steps);
            }

            @Bindable
            public List<?> getTraffic_speed_entry() {
                return traffic_speed_entry;
            }

            public void setTraffic_speed_entry(List<?> traffic_speed_entry) {
                this.traffic_speed_entry = traffic_speed_entry;
                notifyPropertyChanged(BR.traffic_speed_entry);
            }

            @Bindable
            public List<?> getVia_waypoint() {
                return via_waypoint;
            }

            public void setVia_waypoint(List<?> via_waypoint) {
                this.via_waypoint = via_waypoint;
                notifyPropertyChanged(BR.via_waypoint);
            }

            public static class DistanceBean extends BaseObservable {
                /**
                 * text : 6.0 km
                 * value : 6003
                 */

                private String text;
                private int value;

                @Bindable
                public String getText() {
                    return text;
                }

                public void setText(String text) {
                    this.text = text;
                    notifyPropertyChanged(BR.text);
                }

                @Bindable
                public int getValue() {
                    return value;
                }

                public void setValue(int value) {
                    this.value = value;
                    notifyPropertyChanged(BR.value);
                }
            }

            public static class DurationBean extends BaseObservable {
                /**
                 * text : 18 mins
                 * value : 1079
                 */

                private String text;
                private int value;

                @Bindable
                public String getText() {
                    return text;
                }

                public void setText(String text) {
                    this.text = text;
                    notifyPropertyChanged(BR.text);
                }

                @Bindable
                public int getValue() {
                    return value;
                }

                public void setValue(int value) {
                    this.value = value;
                    notifyPropertyChanged(BR.value);
                }
            }

            public static class EndLocationBean extends BaseObservable {
                /**
                 * lat : 22.4947695
                 * lng : 113.9226652
                 */

                private double lat;
                private double lng;

                @Bindable
                public double getLat() {
                    return lat;
                }

                public void setLat(double lat) {
                    this.lat = lat;
                    notifyPropertyChanged(BR.lat);
                }

                @Bindable
                public double getLng() {
                    return lng;
                }

                public void setLng(double lng) {
                    this.lng = lng;
                    notifyPropertyChanged(BR.lng);
                }
            }

            public static class StartLocationBean extends BaseObservable {
                /**
                 * lat : 22.5338293
                 * lng : 113.9372068
                 */

                private double lat;
                private double lng;

                @Bindable
                public double getLat() {
                    return lat;
                }

                public void setLat(double lat) {
                    this.lat = lat;
                    notifyPropertyChanged(BR.lat);
                }

                @Bindable
                public double getLng() {
                    return lng;
                }

                public void setLng(double lng) {
                    this.lng = lng;
                    notifyPropertyChanged(BR.lng);
                }
            }

            public static class StepsBean extends BaseObservable {
                /**
                 * distance : {"text":"0.2 km","value":153}
                 * duration : {"text":"1 min","value":29}
                 * end_location : {"lat":22.5334828,"lng":113.9357712}
                 * html_instructions : Head <b>west</b> toward <b>学生西路</b>
                 * polyline : {"points":"mcphCqjlvT@T@T@HBHBJBFJVBH@JL|@R~A"}
                 * start_location : {"lat":22.5338293,"lng":113.9372068}
                 * travel_mode : DRIVING
                 * maneuver : turn-right
                 */

                private DistanceBeanX distance;
                private DurationBeanX duration;
                private EndLocationBeanX end_location;
                private String html_instructions;
                private PolylineBean polyline;
                private StartLocationBeanX start_location;
                private String travel_mode;
                private String maneuver;

                @Bindable
                public DistanceBeanX getDistance() {
                    return distance;
                }

                public void setDistance(DistanceBeanX distance) {
                    this.distance = distance;
                    notifyPropertyChanged(BR.distance);
                }

                @Bindable
                public DurationBeanX getDuration() {
                    return duration;
                }

                public void setDuration(DurationBeanX duration) {
                    this.duration = duration;
                    notifyPropertyChanged(BR.duration);
                }

                @Bindable
                public EndLocationBeanX getEnd_location() {
                    return end_location;
                }

                public void setEnd_location(EndLocationBeanX end_location) {
                    this.end_location = end_location;
                    notifyPropertyChanged(BR.end_location);
                }

                @Bindable
                public String getHtml_instructions() {
                    return html_instructions;
                }

                public void setHtml_instructions(String html_instructions) {
                    this.html_instructions = html_instructions;
                    notifyPropertyChanged(BR.html_instructions);
                }

                @Bindable
                public PolylineBean getPolyline() {
                    return polyline;
                }

                public void setPolyline(PolylineBean polyline) {
                    this.polyline = polyline;
                    notifyPropertyChanged(BR.polyline);
                }

                @Bindable
                public StartLocationBeanX getStart_location() {
                    return start_location;
                }

                public void setStart_location(StartLocationBeanX start_location) {
                    this.start_location = start_location;
                    notifyPropertyChanged(BR.start_location);
                }

                @Bindable
                public String getTravel_mode() {
                    return travel_mode;
                }

                public void setTravel_mode(String travel_mode) {
                    this.travel_mode = travel_mode;
                    notifyPropertyChanged(BR.travel_mode);
                }

                @Bindable
                public String getManeuver() {
                    return maneuver;
                }

                public void setManeuver(String maneuver) {
                    this.maneuver = maneuver;
                    notifyPropertyChanged(BR.maneuver);
                }

                public static class DistanceBeanX extends BaseObservable {
                    /**
                     * text : 0.2 km
                     * value : 153
                     */

                    private String text;
                    private int value;

                    @Bindable
                    public String getText() {
                        return text;
                    }

                    public void setText(String text) {
                        this.text = text;
                        notifyPropertyChanged(BR.text);
                    }

                    @Bindable
                    public int getValue() {
                        return value;
                    }

                    public void setValue(int value) {
                        this.value = value;
                        notifyPropertyChanged(BR.value);
                    }
                }

                public static class DurationBeanX extends BaseObservable {
                    /**
                     * text : 1 min
                     * value : 29
                     */

                    private String text;
                    private int value;

                    @Bindable
                    public String getText() {
                        return text;
                    }

                    public void setText(String text) {
                        this.text = text;
                        notifyPropertyChanged(BR.text);
                    }

                    @Bindable
                    public int getValue() {
                        return value;
                    }

                    public void setValue(int value) {
                        this.value = value;
                        notifyPropertyChanged(BR.value);
                    }
                }

                public static class EndLocationBeanX extends BaseObservable {
                    /**
                     * lat : 22.5334828
                     * lng : 113.9357712
                     */

                    private double lat;
                    private double lng;

                    @Bindable
                    public double getLat() {
                        return lat;
                    }

                    public void setLat(double lat) {
                        this.lat = lat;
                        notifyPropertyChanged(BR.lat);
                    }

                    @Bindable
                    public double getLng() {
                        return lng;
                    }

                    public void setLng(double lng) {
                        this.lng = lng;
                        notifyPropertyChanged(BR.lng);
                    }
                }

                public static class PolylineBean extends BaseObservable {
                    /**
                     * points : mcphCqjlvT@T@T@HBHBJBFJVBH@JL|@R~A
                     */

                    private String points;

                    @Bindable
                    public String getPoints() {
                        return points;
                    }

                    public void setPoints(String points) {
                        this.points = points;
                        notifyPropertyChanged(BR.points);
                    }
                }

                public static class StartLocationBeanX extends BaseObservable {
                    /**
                     * lat : 22.5338293
                     * lng : 113.9372068
                     */

                    private double lat;
                    private double lng;

                    @Bindable
                    public double getLat() {
                        return lat;
                    }

                    public void setLat(double lat) {
                        this.lat = lat;
                        notifyPropertyChanged(BR.lat);
                    }

                    @Bindable
                    public double getLng() {
                        return lng;
                    }

                    public void setLng(double lng) {
                        this.lng = lng;
                        notifyPropertyChanged(BR.lng);
                    }
                }
            }
        }
    }
}
