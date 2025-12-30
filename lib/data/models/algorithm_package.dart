class AlgorithmPackage {
  final String version;
  AlgorithmPackage({required this.version});

  Map<String, dynamic> toJson() => {'version': version};
  static AlgorithmPackage fromJson(Map<String, dynamic> json) =>
      AlgorithmPackage(version: json['version']);
}
