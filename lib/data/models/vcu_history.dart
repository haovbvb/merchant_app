enum VcuHistoryType {
  request,
  response,
}

enum VcuHistoryFilter {
  all,
  request,
  response,
}

class VcuHistoryItem {
  final String vin;
  final String command;
  final String? data;
  final String? version;
  final VcuHistoryType type;
  final int timestamp;
  final bool? success;

  const VcuHistoryItem({
    required this.vin,
    required this.command,
    required this.type,
    required this.timestamp,
    this.data,
    this.version,
    this.success,
  });
}