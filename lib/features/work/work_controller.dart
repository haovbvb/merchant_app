import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/sale_data.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class WorkbenchState {
  final bool loading;
  final SaleData? saleData;

  const WorkbenchState({
    this.loading = false,
    this.saleData,
  });

  WorkbenchState copyWith({
    bool? loading,
    SaleData? saleData,
  }) {
    return WorkbenchState(
      loading: loading ?? this.loading,
      saleData: saleData ?? this.saleData,
    );
  }
}

final workbenchProvider =
    NotifierProvider<WorkbenchNotifier, WorkbenchState>(
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
    state = state.copyWith(
      loading: false,
      saleData: saleResponse.result,
    );
  }
}
