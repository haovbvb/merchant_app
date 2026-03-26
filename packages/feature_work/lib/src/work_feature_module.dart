import 'package:go_router/go_router.dart';

import 'work_feature_contract.dart';
import 'work_route_paths.dart';
import 'workbench_tab_page.dart';

class WorkFeatureModule {
  WorkFeatureModule();

  final WorkFeatureContract contract = WorkFeatureContract(
    routes: [
      GoRoute(
        path: WorkRoutePaths.workbench,
        builder: (context, state) => const WorkbenchTabPage(),
      ),
    ],
  );
}
