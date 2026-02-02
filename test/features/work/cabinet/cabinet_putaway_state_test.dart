import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_putaway_controller.dart';

void main() {
  group('CabinetPutawayState', () {
    test('copyWith should update loadingCabinet', () {
      const state = CabinetPutawayState();
      final updated = state.copyWith(loadingCabinet: true);
      expect(updated.loadingCabinet, true);
      expect(updated.uploading, false);
      expect(updated.submitting, false);
    });

    test('copyWith should update uploading', () {
      const state = CabinetPutawayState();
      final updated = state.copyWith(uploading: true);
      expect(updated.uploading, true);
    });

    test('copyWith should update submitting', () {
      const state = CabinetPutawayState();
      final updated = state.copyWith(submitting: true);
      expect(updated.submitting, true);
    });

    test('copyWith should update images list', () {
      const state = CabinetPutawayState();
      final updated = state.copyWith(images: ['img1.jpg', 'img2.jpg']);
      expect(updated.images, ['img1.jpg', 'img2.jpg']);
    });

    test('default values should be correct', () {
      const state = CabinetPutawayState();
      expect(state.loadingCabinet, false);
      expect(state.uploading, false);
      expect(state.submitting, false);
      expect(state.cabinet, null);
      expect(state.images, isEmpty);
    });

    test('copyWith should preserve unchanged values', () {
      const state = CabinetPutawayState(
        loadingCabinet: true,
        uploading: true,
        submitting: true,
        images: ['photo.png'],
      );
      final updated = state.copyWith(loadingCabinet: false);
      expect(updated.loadingCabinet, false);
      expect(updated.uploading, true);
      expect(updated.submitting, true);
      expect(updated.images, ['photo.png']);
    });

    test('copyWith with no arguments should return equivalent state', () {
      const state = CabinetPutawayState(
        uploading: true,
        images: ['a.jpg', 'b.jpg'],
      );
      final updated = state.copyWith();
      expect(updated.uploading, true);
      expect(updated.images, ['a.jpg', 'b.jpg']);
    });

    test('images list should be independent after copyWith', () {
      const state = CabinetPutawayState(images: ['x.jpg']);
      final updated = state.copyWith(images: ['y.jpg', 'z.jpg']);
      expect(state.images, ['x.jpg']);
      expect(updated.images, ['y.jpg', 'z.jpg']);
    });

    test('multiple copyWith calls should chain correctly', () {
      const state = CabinetPutawayState();
      final updated = state
          .copyWith(loadingCabinet: true)
          .copyWith(uploading: true)
          .copyWith(submitting: true)
          .copyWith(images: ['final.jpg']);
      expect(updated.loadingCabinet, true);
      expect(updated.uploading, true);
      expect(updated.submitting, true);
      expect(updated.images, ['final.jpg']);
    });
  });
}
