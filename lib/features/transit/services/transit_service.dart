import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/transit_line.dart';

class TrainStatusReport {
  final String lineId;
  final String lineName;
  final String statusText;
  final String details;
  final bool isLive;
  final DateTime updatedAt;

  const TrainStatusReport({
    required this.lineId,
    required this.lineName,
    required this.statusText,
    required this.details,
    required this.isLive,
    required this.updatedAt,
  });
}

class TransitService {
  static final TransitService instance = TransitService._init();
  TransitService._init();

  /// Fetches real-time train status via ODPT (Open Data Challenge for Public Transportation) API.
  /// 
  /// ODPT is 100% FREE for developers (₹0 cost).
  /// If ODPT_API_KEY is not configured or device is offline, returns truthful cached
  /// schedule metadata with `isLive: false` to comply with the No-Fabrication rule.
  Future<List<TrainStatusReport>> fetchTrainStatuses() async {
    final odptKey = dotenv.env['ODPT_API_KEY']?.trim() ?? '';

    if (odptKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://api.odpt.org/api/v4/odpt:TrainInformation?acl:consumerKey=$odptKey',
        );
        final response = await http.get(url).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
          final reports = <TrainStatusReport>[];

          for (final item in data) {
            final railway = (item['odpt:railway'] as String? ?? '').split(':').last;
            final text = item['odpt:trainInformationText']?['en'] as String? ??
                item['odpt:trainInformationText']?['ja'] as String? ??
                'Normal Operation (平常運転)';
            final status = item['odpt:trainInformationStatus']?['en'] as String? ?? 'Normal';

            reports.add(TrainStatusReport(
              lineId: railway,
              lineName: railway.replaceAll('.', ' '),
              statusText: status,
              details: text,
              isLive: true,
              updatedAt: DateTime.now(),
            ));
          }

          if (reports.isNotEmpty) return reports;
        }
      } catch (e) {
        debugPrint('[TransitService] ODPT live query notice: $e');
      }
    }

    // Truthful offline/cached baseline: JR Yamanote, Tokyo Metro, Toei Subway
    final now = DateTime.now();
    return [
      TrainStatusReport(
        lineId: 'JR-East.Yamanote',
        lineName: 'JR Yamanote Line (山手線)',
        statusText: 'Scheduled Operation (定時運行)',
        details: 'Runs every 2–4 min. Live delay updates require free ODPT API key & network.',
        isLive: false,
        updatedAt: now,
      ),
      TrainStatusReport(
        lineId: 'JR-East.ChuoRapid',
        lineName: 'JR Chuo Rapid Line (中央線快速)',
        statusText: 'Scheduled Operation (定時運行)',
        details: 'Runs every 3–5 min between Tokyo and Shinjuku/Takao.',
        isLive: false,
        updatedAt: now,
      ),
      TrainStatusReport(
        lineId: 'TokyoMetro.Marunouchi',
        lineName: 'Tokyo Metro Marunouchi Line (丸ノ内線)',
        statusText: 'Scheduled Operation (定時運行)',
        details: 'Runs every 3–4 min connecting Ikebukuro, Tokyo, Ginza, Shinjuku.',
        isLive: false,
        updatedAt: now,
      ),
      TrainStatusReport(
        lineId: 'TokyoMetro.Ginza',
        lineName: 'Tokyo Metro Ginza Line (銀座線)',
        statusText: 'Scheduled Operation (定時運行)',
        details: 'Runs every 3 min connecting Shibuya, Ginza, and Asakusa.',
        isLive: false,
        updatedAt: now,
      ),
      TrainStatusReport(
        lineId: 'Toei.Oedo',
        lineName: 'Toei Oedo Line (都営大江戸線)',
        statusText: 'Scheduled Operation (定時運行)',
        details: 'Runs every 6 min connecting Roppongi and Shinjuku.',
        isLive: false,
        updatedAt: now,
      ),
    ];
  }

  List<TransitLine> getTokyoLines() {
    return const [
      TransitLine(
        lineId: 'jy',
        nameEn: 'JR Yamanote Line',
        nameJa: '山手線',
        colorValue: 0xFF9ACD32, // Iconic yellow-green
        operator: 'JR East',
        code: 'JY',
        majorStations: ['Shinjuku', 'Shibuya', 'Shinagawa', 'Tokyo', 'Ueno', 'Ikebukuro'],
        tips: 'Tokyo\'s central circular loop line. Runs clockwise (外回り Soto-mawari) and counter-clockwise (内回り Uchi-mawari).',
      ),
      TransitLine(
        lineId: 'jc',
        nameEn: 'JR Chuo Rapid Line',
        nameJa: '中央線快速',
        colorValue: 0xFFFF5500, // Vibrant orange
        operator: 'JR East',
        code: 'JC',
        majorStations: ['Tokyo', 'Kanda', 'Ochanomizu', 'Yotsuya', 'Shinjuku', 'Nakano'],
        tips: 'Direct cross-city expressway linking Tokyo Station and Shinjuku in only 14 minutes.',
      ),
      TransitLine(
        lineId: 'm',
        nameEn: 'Tokyo Metro Marunouchi Line',
        nameJa: '丸ノ内線',
        colorValue: 0xFFE60012, // Bright red
        operator: 'Tokyo Metro',
        code: 'M',
        majorStations: ['Ikebukuro', 'Ochanomizu', 'Tokyo', 'Ginza', 'Shinjuku', 'Ogikubo'],
        tips: 'Connects major government offices, business districts, and bullet trains at Tokyo Station.',
      ),
      TransitLine(
        lineId: 'g',
        nameEn: 'Tokyo Metro Ginza Line',
        nameJa: '銀座線',
        colorValue: 0xFFFF9500, // Golden yellow
        operator: 'Tokyo Metro',
        code: 'G',
        majorStations: ['Shibuya', 'Omotesando', 'Aoyama', 'Akasaka-mitsuke', 'Ginza', 'Asakusa'],
        tips: 'Asia\'s oldest subway line. Ideal for shopping in Shibuya/Ginza and visiting Senso-ji temple in Asakusa.',
      ),
      TransitLine(
        lineId: 'e',
        nameEn: 'Toei Oedo Line',
        nameJa: '大江戸線',
        colorValue: 0xFFB6007A, // Magenta
        operator: 'Toei Subway',
        code: 'E',
        majorStations: ['Shinjuku', 'Roppongi', 'Daimon (Hamamatsucho)', 'Tsukishima', 'Kiyosumi-shirakawa'],
        tips: 'Deep underground loop around Tokyo. Direct access to Roppongi nightlife and Tokyo Tower (Akabanebashi).',
      ),
    ];
  }

  List<StationExitGuide> getStationExitGuides() {
    return const [
      StationExitGuide(
        stationEn: 'Shinjuku Station',
        stationJa: '新宿駅',
        exitName: 'East Exit (東口)',
        exitNameJa: 'ひがしぐち',
        bestFor: 'Kabukicho, Shinjuku 3-Chome, Isetan, Don Quijote',
        landmarks: 'Famous giant 3D calico cat billboard, Police Koban, Lumine Est.',
      ),
      StationExitGuide(
        stationEn: 'Shinjuku Station',
        stationJa: '新宿駅',
        exitName: 'West Exit (西口)',
        exitNameJa: 'にしぐち',
        bestFor: 'Tokyo Metropolitan Government Office, Skyscraper district, Keio Plaza',
        landmarks: 'Underground walkway directly connects to Tokyo City Hall observation deck.',
      ),
      StationExitGuide(
        stationEn: 'Shinjuku Station',
        stationJa: '新宿駅',
        exitName: 'South Exit / New South (南口・新南改札)',
        exitNameJa: 'みなみぐち',
        bestFor: 'Busta Shinjuku highway bus terminal, Takashimaya Times Square',
        landmarks: 'Direct escalators up to long-distance intercity express buses (Fuji, Kyoto, Airport).',
      ),
      StationExitGuide(
        stationEn: 'Shibuya Station',
        stationJa: '渋谷駅',
        exitName: 'Hachiko Exit (ハチ公改札)',
        exitNameJa: 'はちこうかいさつ',
        bestFor: 'Famous Scramble Crossing, Shibuya 109, Center-Gai, Police Box',
        landmarks: 'Hachiko bronze dog statue meeting spot.',
      ),
      StationExitGuide(
        stationEn: 'Tokyo Station',
        stationJa: '東京駅',
        exitName: 'Marunouchi Central Exit (丸の内中央口)',
        exitNameJa: 'まるのうちちゅうおうぐち',
        bestFor: 'Imperial Palace, red brick historic facade, business district',
        landmarks: 'Grand historic 1914 European red-brick station building.',
      ),
      StationExitGuide(
        stationEn: 'Tokyo Station',
        stationJa: '東京駅',
        exitName: 'Yaesu North / Central Exit (八重洲口)',
        exitNameJa: 'やえすぐち',
        bestFor: 'Tokaido Shinkansen bullet trains, Narita Express bus terminals, Tokyo Ramen Street',
        landmarks: 'Tokyo Station underground shopping labyrinth & bullet train gates.',
      ),
    ];
  }

  List<Map<String, String>> getMannerRules() {
    return const [
      {
        'title': 'Silent / Manner Mode (マナーモード)',
        'rule': 'Always switch smartphones to Manner Mode (vibrate). Refrain from making phone calls inside train cars.',
      },
      {
        'title': 'Priority Seating (優先席)',
        'rule': 'Yield seats marked 優先席 to pregnant women, elderly, injured, or people holding the maternity badge (マタニティマーク). Switch off phones near priority seats when crowded.',
      },
      {
        'title': 'Escalator Etiquette in Tokyo',
        'rule': 'Stand on the LEFT side of escalators in Tokyo/Kanto. The RIGHT side is reserved for commuters walking up/down. (In Osaka, it\'s the opposite).',
      },
      {
        'title': 'Backpacks & Bulky Luggage',
        'rule': 'In crowded trains, carry your backpack on your chest or place it overhead on the luggage racks (網棚 Amadana) to avoid bumping passengers.',
      },
      {
        'title': 'Women-Only Cars (女性専用車)',
        'rule': 'During morning rush hours (typically 7:30–9:30 AM), designated cars (marked with pink floor stickers) are reserved exclusively for female passengers and children.',
      },
    ];
  }

  List<Map<String, String>> getIcCardGuide() {
    return const [
      {
        'title': 'Suica & Pasmo Basics',
        'detail': 'Prepaid contactless IC cards accepted on all trains, subways, city buses, taxis, konbini (7-Eleven, Lawson, FamilyMart), and vending machines across Japan.',
      },
      {
        'title': 'How to Top Up (チャージ Chāji)',
        'detail': 'Insert cash into ticket machines at any train station (select "English" -> "Charge"), or tap your phone/card at any convenience store cash register and say 「チャージお願いします (Chāji onegai-shimasu)」.',
      },
      {
        'title': 'Commuter Pass (定期券 Teikiken)',
        'detail': 'If you commute daily between home and work/school, purchase a 1-month, 3-month, or 6-month Teikiken at commuter pass vending machines to travel unlimited times between those designated stations with massive savings.',
      },
      {
        'title': 'Mobile Suica / Mobile Pasmo',
        'detail': 'Can be added directly to Apple Wallet or Google Wallet on compatible smartphones for instant digital contactless transit payments without physical cards.',
      },
    ];
  }
}
