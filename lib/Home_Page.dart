import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool themeSwitch = false;

  dynamic themeAppBar() {
    return Color(0xffb3ff66);
  }
  dynamic themeHome(){
    return Colors.grey[850];
  }

  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFf2f2f2),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            _get();
          },
        ),

        appBar: AppBar(
          backgroundColor: themeAppBar(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: _size.height*(1/3),
                child: Text("top baner"),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("GiftCatalog").snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData) return null;
                  return Column(
                    children: <Widget>[
                      for(final item in snapshot.data.documents) Container(
                        height: _size.height/2,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: (_size.height/2)/5,
                              child: Row(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item["Name"] + item["Id"],
                                    style: TextStyle(
                                      color: themeHome(),
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic

                                    ),
                                  )
                                ],
                              ),

                            ), //Tag Name
                            Container(
                              height: ((_size.height/2)/5)*4,
                              child: SlideGift(id: item["Id"],size: Size(_size.width, ((_size.height/2)/5)*4))
                            )
                          ],
                        ),
                      )
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget SlideGift({String id,Size size}){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("Gift").where("GCID",isEqualTo: id).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData) return Container();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for(final item in snapshot.data.documents) Container(
                child: _buildListGift(context, item, size),
              )
            ],
          ),
        );
      },
    );
  }
  _buildListGift(BuildContext context,DocumentSnapshot document,Size size){
    bool onTap = false;
    return Container(
      decoration: new BoxDecoration(
        color: Color(0xffffffff),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      width: size.width*(3/5),
      margin: EdgeInsets.only(left: 10,right: 10,top: 2,bottom: 2),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
            child: Image(
              height: size.height*(1.5/4),
              width: size.width*(3/5),
              fit: BoxFit.fill,
              image:  NetworkImage(
                document["img"]
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(document["Name"]),
              ),
              Padding(
                padding: EdgeInsets.only(top: (size.height-size.height*(1.5/4))*(2/3),left: 20,bottom: 15),
                child: Container(
                  height: 30,
                  alignment: Alignment.topLeft,
                  child: RaisedButton(
                    onPressed: (){

                    },
                    color: Colors.white,
                    child: Text(
                      "Chi tiết",

                      style: TextStyle( fontSize: 18),
                    ),
                    disabledColor: Colors.white70,
                    hoverColor: Colors.redAccent,
                    textColor: onTap ?Colors.white:Colors.lightGreen,
                    splashColor: themeAppBar(),

                    highlightColor: themeAppBar(),
                    onHighlightChanged: (val){
                      if(val){
                        setState(() {
                          print("on tap");
                          onTap = val;
                        });
                      }else{
                        setState(() {
                          onTap = val;
                        });
                      }
                    },
                    shape: RoundedRectangleBorder(side: BorderSide(color: themeAppBar()),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
  Widget TopBaner({Size size}){
    return Container(
      width: size.width,
      height: size.height,
    );
  }
  String Name = "Vé xem phim 2d rạp starlight"; String GCID = "DG";
  String img = "https://starlight.vn/Areas/Admin/Content/Fileuploads/images/sukien/H%E1%BA%A0NG%20M%E1%BB%A4C%20KHAI%20TR%C6%AF%C6%A0NG%20GIA%20LAI-08-1.jpg";
  Timestamp ed=Timestamp.now(),sd=Timestamp.now();
  void _get(){
    print("ok");
    Firestore.instance.collection('Gift').document()
        .setData({ 'Name': Name, 'GCID': GCID,"img":img ,"ED":ed,"SD":sd});
  }
}