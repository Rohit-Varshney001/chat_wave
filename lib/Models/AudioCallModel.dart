/// id : "1"
/// callerName : "Rohit"
/// callerPic : "https://testimage.com"
/// callerUid : "15ds4fsd6451"
/// receiverName : "Rohit2"
/// receiverPic : "https://testImage2.com"
/// receiverUid : "eda8d6as5d"
/// status : "online"
/// isVideoCall : true

class AudioCallModel {
  AudioCallModel({
      String? id, 
      String? callerName, 
      String? callerPic, 
      String? callerUid, 
      String? receiverName, 
      String? receiverPic, 
      String? receiverUid, 
      String? status, 
      bool? isVideoCall,}){
    _id = id;
    _callerName = callerName;
    _callerPic = callerPic;
    _callerUid = callerUid;
    _receiverName = receiverName;
    _receiverPic = receiverPic;
    _receiverUid = receiverUid;
    _status = status;
    _isVideoCall = isVideoCall;
}

  AudioCallModel.fromJson(dynamic json) {
    _id = json['id'];
    _callerName = json['callerName'];
    _callerPic = json['callerPic'];
    _callerUid = json['callerUid'];
    _receiverName = json['receiverName'];
    _receiverPic = json['receiverPic'];
    _receiverUid = json['receiverUid'];
    _status = json['status'];
    _isVideoCall = json['isVideoCall'];
  }
  String? _id;
  String? _callerName;
  String? _callerPic;
  String? _callerUid;
  String? _receiverName;
  String? _receiverPic;
  String? _receiverUid;
  String? _status;
  bool? _isVideoCall;
AudioCallModel copyWith({  String? id,
  String? callerName,
  String? callerPic,
  String? callerUid,
  String? receiverName,
  String? receiverPic,
  String? receiverUid,
  String? status,
  bool? isVideoCall,
}) => AudioCallModel(  id: id ?? _id,
  callerName: callerName ?? _callerName,
  callerPic: callerPic ?? _callerPic,
  callerUid: callerUid ?? _callerUid,
  receiverName: receiverName ?? _receiverName,
  receiverPic: receiverPic ?? _receiverPic,
  receiverUid: receiverUid ?? _receiverUid,
  status: status ?? _status,
  isVideoCall: isVideoCall ?? _isVideoCall,
);
  String? get id => _id;
  String? get callerName => _callerName;
  String? get callerPic => _callerPic;
  String? get callerUid => _callerUid;
  String? get receiverName => _receiverName;
  String? get receiverPic => _receiverPic;
  String? get receiverUid => _receiverUid;
  String? get status => _status;
  bool? get isVideoCall => _isVideoCall;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['callerName'] = _callerName;
    map['callerPic'] = _callerPic;
    map['callerUid'] = _callerUid;
    map['receiverName'] = _receiverName;
    map['receiverPic'] = _receiverPic;
    map['receiverUid'] = _receiverUid;
    map['status'] = _status;
    map['isVideoCall'] = _isVideoCall;
    return map;
  }

}