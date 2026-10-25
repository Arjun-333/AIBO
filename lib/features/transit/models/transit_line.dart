class TransitLine {
  final String lineId;
  final String nameEn;
  final String nameJa;
  final int colorValue;
  final String operator; // 'JR East', 'Tokyo Metro', 'Toei Subway'
  final String code; // e.g. 'JY', 'G', 'M', 'E'
  final List<String> majorStations;
  final String tips;

  const TransitLine({
    required this.lineId,
    required this.nameEn,
    required this.nameJa,
    required this.colorValue,
    required this.operator,
    required this.code,
    required this.majorStations,
    required this.tips,
  });
}

class StationExitGuide {
  final String stationEn;
  final String stationJa;
  final String exitName;
  final String exitNameJa;
  final String bestFor;
  final String landmarks;

  const StationExitGuide({
    required this.stationEn,
    required this.stationJa,
    required this.exitName,
    required this.exitNameJa,
    required this.bestFor,
    required this.landmarks,
  });
}
