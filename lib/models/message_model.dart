class MessageModel{
  String? messageId;
  String?  sender;
  String? text;
  bool? seen;
  DateTime? createdOn;

  MessageModel({this.text,this.sender,this.createdOn,this.seen,this.messageId});

  MessageModel.fromMap(Map<String,dynamic> map){
    sender=map['sender'];
    text=map['text'];
    seen=map['seen'];
    createdOn=map['createdOn'].toDate();
    messageId=map['messageId'];
  }

  Map<String,dynamic> toMap(){
    return{
      'sender':sender,
      'text':text,
      'seen':seen,
      'createdOn':createdOn,
      'messageId':messageId,
    };   
  }
}