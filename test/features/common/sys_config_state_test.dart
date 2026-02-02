import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/common/sys_config_controller.dart';

void main() {
  group('SysConfigState', () {
    test('should have correct default values', () {
      const state = SysConfigState();

      expect(state.uploading, false);
      expect(state.uploadedUrl, isNull);
    });

    test('copyWith should update uploading', () {
      const state = SysConfigState();
      final updated = state.copyWith(uploading: true);

      expect(updated.uploading, true);
      expect(updated.uploadedUrl, isNull);
    });

    test('copyWith should update uploadedUrl', () {
      const state = SysConfigState();
      final updated = state.copyWith(uploadedUrl: 'https://example.com/file.jpg');

      expect(updated.uploadedUrl, 'https://example.com/file.jpg');
      expect(updated.uploading, false);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = SysConfigState(
        uploading: true,
        uploadedUrl: 'https://example.com/old.jpg',
      );
      final updated = state.copyWith(uploading: false);

      expect(updated.uploading, false);
      expect(updated.uploadedUrl, 'https://example.com/old.jpg');
    });

    test('copyWith should return new instance with same values when called without arguments', () {
      const state = SysConfigState(
        uploading: true,
        uploadedUrl: 'https://example.com/test.jpg',
      );
      final updated = state.copyWith();

      expect(updated.uploading, true);
      expect(updated.uploadedUrl, 'https://example.com/test.jpg');
    });
  });
}
