/// force : false
/// versionCode : 12002
/// versionName : "1.061"
/// modifyContent : "1. 这是什么\n2. 这是什么"
/// downloadUrl : "https://fishnet.peihuan.net/12002_1.061.apk"
/// createTime : 113333333333331

class UpgradeInfo {
  bool _force;
  int _versionCode;
  String _versionName;
  String _modifyContent;
  String _downloadUrl;
  num _createTime;

  bool get force => _force;
  int get versionCode => _versionCode;
  String get versionName => _versionName;
  String get modifyContent => _modifyContent;
  String get downloadUrl => _downloadUrl;
  num get createTime => _createTime;

  UpgradeInfo({
      bool force,
      int versionCode,
      String versionName,
      String modifyContent,
      String downloadUrl,
      num createTime}){
    _force = force;
    _versionCode = versionCode;
    _versionName = versionName;
    _modifyContent = modifyContent;
    _downloadUrl = downloadUrl;
    _createTime = createTime;
}

  UpgradeInfo.fromJson(Map<String, dynamic> json) {
    _force = json["force"];
    _versionCode = json["versionCode"].round();
    _versionName = json["versionName"];
    _modifyContent = json["modifyContent"];
    _downloadUrl = json["downloadUrl"];
    _createTime = json["createTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["force"] = _force;
    map["versionCode"] = _versionCode;
    map["versionName"] = _versionName;
    map["modifyContent"] = _modifyContent;
    map["downloadUrl"] = _downloadUrl;
    map["createTime"] = _createTime;
    return map;
  }

}