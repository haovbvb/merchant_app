import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/sale_data.dart';
import 'package:merchant_app/data/models/shop1_num.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class WorkbenchState {
  final bool loading;
  final SaleData? saleData;
  final Shop1Num? shopNum;

  const WorkbenchState({this.loading = false, this.saleData, this.shopNum});

  WorkbenchState copyWith({
    bool? loading,
    SaleData? saleData,
    Shop1Num? shopNum,
  }) {
    return WorkbenchState(
      loading: loading ?? this.loading,
      saleData: saleData ?? this.saleData,
      shopNum: shopNum ?? this.shopNum,
    );
  }
}

final workbenchProvider = NotifierProvider<WorkbenchNotifier, WorkbenchState>(
  WorkbenchNotifier.new,
);

class WorkbenchNotifier extends Notifier<WorkbenchState> {
  final ApiService _api = ApiService();

  @override
  WorkbenchState build() => const WorkbenchState();

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    final saleResponse = await _api.get<SaleData>(
      ApiPath.workbenchMonthlyIncome,
      parser: (json) => json == null
          ? const SaleData(orderIncome: 0, orderNum: 0, today: '')
          : SaleData.fromJson(Map<String, dynamic>.from(json as Map)),
      showHud: false,
    );
    final shopResponse = await _api.get<Shop1Num>(
      ApiPath.workbenchShopIndex,
      parser: (json) => json == null
          ? const Shop1Num(all: 0, direct: 0, franchise: 0)
          : Shop1Num.fromJson(Map<String, dynamic>.from(json as Map)),
      showHud: false,
    );
    state = state.copyWith(
      loading: false,
      saleData: saleResponse.result,
      shopNum: shopResponse.result,
    );
  }
}
