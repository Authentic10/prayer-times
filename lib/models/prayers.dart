class Prayer {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  Prayer(
      {this.fajr, this.dhuhr, this.asr, this.maghrib, this.isha});

  factory Prayer.fromJSON(Map<String, dynamic> json) {
    return Prayer(
        fajr: json['results']['datetime'][0]['times']['Fajr'],
        dhuhr: json['results']['datetime'][0]['times']['Dhuhr'],
        asr: json['results']['datetime'][0]['times']['Asr'],
        maghrib: json['results']['datetime'][0]['times']['Maghrib'],
        isha: json['results']['datetime'][0]['times']['Isha'],
    );
  }

}
