class StoredCookieModel {
  final String _name;
  final String _value;

  StoredCookieModel(this._name, this._value);

  String get name => _name;
  String get value => _value;

//   SettingsModel(this.ratingSystem, this.theme, this.sendNotficationsAt);

  /// Create a modal from JSON (Map) data
  StoredCookieModel.fromJSON(dynamic json) : this(json['name'], json['value']);

//   /// Convert model data to JSON format
//   Map<String, dynamic> toJson() => {
//         'ratingSystem': ratingSystem,
//         'theme': theme,
//         'sendNotifcationsAt': sendNotficationsAt?.toString(),
//       };
}
