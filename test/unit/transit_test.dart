import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/transit/services/transit_service.dart';

void main() {
  group('TransitService & Tokyo Commuter Navigator Tests', () {
    final service = TransitService.instance;

    test('Loads major Tokyo train and subway lines with correct operator metadata', () {
      final lines = service.getTokyoLines();
      expect(lines.length >= 5, true);

      // Verify JR Yamanote Line
      final yamanote = lines.firstWhere((l) => l.lineId == 'jy');
      expect(yamanote.nameEn, 'JR Yamanote Line');
      expect(yamanote.code, 'JY');
      expect(yamanote.operator, 'JR East');
      expect(yamanote.majorStations.contains('Shinjuku'), true);
      expect(yamanote.majorStations.contains('Shibuya'), true);

      // Verify Tokyo Metro Marunouchi
      final marunouchi = lines.firstWhere((l) => l.lineId == 'm');
      expect(marunouchi.nameEn.contains('Marunouchi'), true);
      expect(marunouchi.operator, 'Tokyo Metro');
    });

    test('Station exit guide contains critical hub exits', () {
      final exits = service.getStationExitGuides();
      expect(exits.isNotEmpty, true);

      // Shinjuku East and West exits
      expect(exits.any((e) => e.stationEn.contains('Shinjuku') && e.exitName.contains('East')), true);
      expect(exits.any((e) => e.stationEn.contains('Shinjuku') && e.exitName.contains('West')), true);

      // Shibuya Hachiko exit
      expect(exits.any((e) => e.stationEn.contains('Shibuya') && e.exitName.contains('Hachiko')), true);

      // Tokyo Station Marunouchi and Yaesu
      expect(exits.any((e) => e.stationEn.contains('Tokyo') && e.exitName.contains('Marunouchi')), true);
    });

    test('Manner rules cover silent mode, priority seats, and escalators', () {
      final manners = service.getMannerRules();
      expect(manners.length >= 4, true);
      expect(manners.any((m) => m['title']!.contains('Manner Mode')), true);
      expect(manners.any((m) => m['title']!.contains('Priority Seating')), true);
      expect(manners.any((m) => m['title']!.contains('Escalator')), true);
    });

    test('IC Card guide contains Suica, Pasmo, and Teikiken details', () {
      final icGuide = service.getIcCardGuide();
      expect(icGuide.any((g) => g['title']!.contains('Suica')), true);
      expect(icGuide.any((g) => g['title']!.contains('Teikiken')), true);
    });
  });
}
