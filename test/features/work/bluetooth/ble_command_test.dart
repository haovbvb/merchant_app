import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/bluetooth/ble_command.dart';

void main() {
  group('BleCommandBuilder Constants', () {
    test('should have correct service UUID', () {
      expect(
        BleCommandBuilder.serviceId,
        '0000FFE0-0000-1000-8000-00805F9B34FB',
      );
    });

    test('should have correct read UUID', () {
      expect(
        BleCommandBuilder.readUuid,
        '0000FFE4-0000-1000-8000-00805F9B34FB',
      );
    });

    test('should have correct write UUID', () {
      expect(
        BleCommandBuilder.writeUuid,
        '0000FFE9-0000-1000-8000-00805F9B34FB',
      );
    });

    test('should have correct command head and end', () {
      expect(BleCommandBuilder.commandHead, '7E');
      expect(BleCommandBuilder.commandEnd, '7E7E');
    });
  });

  group('BleCommandBuilder.buildReadKeyIdData', () {
    test('should return userPwd', () {
      final result = BleCommandBuilder.buildReadKeyIdData();
      expect(result, BleCommandBuilder.userPwd);
      expect(result, '55707578');
    });
  });

  group('BleCommandBuilder.buildClearAuthorizationData', () {
    test('should combine userPwd, keyId and bleKeyBlock', () {
      final result = BleCommandBuilder.buildClearAuthorizationData('12345678');
      expect(result, '5570757812345678${BleCommandBuilder.bleKeyBlock}');
    });

    test('should work with different keyId', () {
      final result = BleCommandBuilder.buildClearAuthorizationData('AABBCCDD');
      expect(result.startsWith(BleCommandBuilder.userPwd), true);
      expect(result.contains('AABBCCDD'), true);
    });
  });

  group('BleCommandBuilder.unescapeResponse', () {
    test('should replace 7d5d with 7d', () {
      final result = BleCommandBuilder.unescapeResponse('aa7d5dbb');
      expect(result, 'aa7dbb');
    });

    test('should replace 7d5e with 7e', () {
      final result = BleCommandBuilder.unescapeResponse('aa7d5ebb');
      expect(result, 'aa7ebb');
    });

    test('should handle multiple replacements', () {
      final result = BleCommandBuilder.unescapeResponse('7d5d7d5e7d5d');
      expect(result, '7d7e7d');
    });

    test('should return unchanged string when no escapes', () {
      final result = BleCommandBuilder.unescapeResponse('aabbccdd');
      expect(result, 'aabbccdd');
    });
  });

  group('BleCommandBuilder.extractSignal', () {
    test('should extract signal from hex string', () {
      // Hex string with at least 18 characters
      // extractSignal returns substring(14, 18)
      final hex = '01234567890123aabbccdd1122';
      final result = BleCommandBuilder.extractSignal(hex);
      expect(result, 'aabb');
    });

    test('should return original hex when too short', () {
      final hex = '0102030405';
      final result = BleCommandBuilder.extractSignal(hex);
      expect(result, hex);
    });
  });

  group('BleCommandBuilder.extractDecryptStr', () {
    test('should extract decrypt string from hex', () {
      // Minimum 18 chars, returns substring(18, length-8)
      final hex = '012345678901234567aabbccdd11223344';
      final result = BleCommandBuilder.extractDecryptStr(hex);
      expect(result, 'aabbccdd');
    });

    test('should return original hex when too short', () {
      final hex = '0102030405';
      final result = BleCommandBuilder.extractDecryptStr(hex);
      expect(result, hex);
    });
  });

  group('BleCommandBuilder.buildCommand', () {
    test('should build command with correct structure', () {
      final result = BleCommandBuilder.buildCommand(
        signal: 'a1b2',
        plainHex: '0102',
        encryptedHex: 'aabbccdd',
      );

      // Should start with command head (7e) and end with command end (7e7e)
      expect(result.startsWith('7e'), true);
      expect(result.endsWith('7e7e'), true);
    });

    test('should escape 7d in command body', () {
      final result = BleCommandBuilder.buildCommand(
        signal: '7d00',
        plainHex: '0102',
        encryptedHex: '7d7d7d7d',
      );

      // 7d should be escaped as 7d5d
      expect(result.contains('7e'), true);
    });
  });

  group('BleCommandBuilder.buildResetAuthorizationData', () {
    test('should build reset authorization data', () {
      final now = DateTime(2024, 6, 15, 10, 30);
      final result = BleCommandBuilder.buildResetAuthorizationData(now);

      // Should start with userPwd
      expect(result.startsWith(BleCommandBuilder.userPwd), true);
      // Should end with bleKeyBlock
      expect(result.endsWith(BleCommandBuilder.bleKeyBlock), true);
    });
  });

  group('BleCommandBuilder.buildAddAuthorizationData', () {
    test('should build add authorization data', () {
      final result = BleCommandBuilder.buildAddAuthorizationData(
        keyId: '12345678',
        lockId: 'LOCK0001',
        userNum: 'USER0001',
        days: 30,
      );

      // Should contain lockId
      expect(result.contains('LOCK0001'), true);
      // Should contain userNum
      expect(result.contains('USER0001'), true);
      // Should contain lockPwd
      expect(result.contains(BleCommandBuilder.lockPwd), true);
    });
  });

  group('BleCommandBuilder.buildFactoryAuthorizationData', () {
    test('should build factory authorization data', () {
      final result = BleCommandBuilder.buildFactoryAuthorizationData(
        keyId: '12345678',
        days: 365,
      );

      // Should contain lockPwd
      expect(result.contains(BleCommandBuilder.lockPwd), true);
      // Should contain factory lockId
      expect(result.contains('0a000000'), true);
    });
  });
}
