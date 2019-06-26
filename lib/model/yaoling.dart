class YaolingInfo {
  String Url;
  List<Yaoling> yaolingList;

  YaolingInfo({this.Url, this.yaolingList});

  factory YaolingInfo.fromJson(Map<String, dynamic> json){
    List<dynamic> temp = json['Data'];
    List<Yaoling> yaolingList = List();
    temp.forEach((item){
      yaolingList.add(Yaoling.fromJson(item));
    });
    return YaolingInfo(Url: json['Url'], yaolingList: yaolingList);
  }
}

class Yaoling {
  int Id;
  String Name;
  List<String> FiveEle;
  String PrefabName;
  String ImgName;
  String BigImgPath;
  String SmallImgPath;
  int Level;

  Yaoling({this.Id, this.Name, this.FiveEle, this.PrefabName, this.ImgName,
      this.BigImgPath, this.SmallImgPath, level});

  factory Yaoling.fromJson(Map<String, dynamic> json){
    var FiveEle = List<String>();
    List<dynamic> temp = json['FiveEle'];
    temp.forEach((item){
      FiveEle.add(item);
    });

    return Yaoling(Id: json['Id'],
    Name: json['Name'],
    FiveEle: FiveEle,
    PrefabName: json['PrefabName'],
    ImgName: json['ImgName'],
    BigImgPath: json['BigImgPath'],
    SmallImgPath: json['SmallImgPath'],
    level: json['level'],
    );
  }


}
