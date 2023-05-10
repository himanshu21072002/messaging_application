class UserModel{
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;

  UserModel({this.email,this.fullname,this.profilepic,this.uid});

  UserModel.fromMap(Map<String,dynamic> map){
    uid=map['uid'];
    fullname=map['fullname'];
    email=map['email'];
    profilepic=map['profilepic'];
  }

  Map<String,dynamic> toMap(){
    return{
      'uid':uid,
      'fullname':fullname,
      'email':email,
      'profilepic':profilepic
    };
  }

}