import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_green_waste_bin_ticker/QRView.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';



import 'BottomShapeClipper.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool themeSwitch = false;
  String _nameTopBaner = "";
  final _auth = FirebaseAuth.instance;
  FirebaseUser _user;


  dynamic themeAppBar() {
    return Colors.lightGreen;
  }
  dynamic themeHome(){
    return Color(0xff66ccff);
  }
  dynamic themeTag(){
    return Colors.grey[850];
  }

  int _counter = 0;
  @override
  void initState() {
    _auth.currentUser().then((user){
      setState(() {
        _user = user;
      });
    });
    print("${_user}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xefffffff),

        floatingActionButton: FloatingActionButton(
          onPressed: (){
            _get();
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: BottomShapeClipper(),
                    child: Container(
                      height: _size.height * 0.5,
                      color: themeHome(),
                    ),

                  ),
                  Padding(
                    padding: EdgeInsets.only(top: _size.height*0.2),
                    child: TopBanerName(),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: _size.height*0.25),
                    child: Container(
                      height: _size.height*(1/3),
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: TopBaner(size: Size(_size.width, _size.height*(1/3))),
                      ),
                    ),
                  ),
                  AppBar(),
                ],
              ),
              StreamBuilder<QuerySnapshot>(      // cac phan va cac tag
                stream: Firestore.instance.collection("GiftCatalog").snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData) return Container();
                  return Column(
                    children: <Widget>[
                      for(final item in snapshot.data.documents) Container(
                        height: _size.height/2,
                        child: Column( // ten cua cai loai qua.....
                          children: <Widget>[
                            Container(
                              height: (_size.height/2)/5,
                              child: Row(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      item["Name"] + item["Id"],
                                      style: GoogleFonts.robotoSlab(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500
                                      ),
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
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("Gift").orderBy("Quantity",descending:true).limit(4).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData) return Container();
        return  new Swiper(
          autoplay: true,
          itemBuilder: (BuildContext context, int index) {
            return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Image(
                fit: BoxFit.fill,
                image:  NetworkImage(
                    snapshot.data.documents[index]["img"]
                ),
              ),
            );
          },
          itemCount: snapshot.data.documents.length,
          itemWidth: 300.0,
          layout: SwiperLayout.STACK,
          pagination: SwiperPagination(
            alignment: Alignment.bottomCenter
          ),
          onIndexChanged: (index){
            setState(() {
              _nameTopBaner = snapshot.data.documents[index]["Name"];
            });
          },
        );
      },
    );
  }
  Widget TagNameUser(){
    return Container(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(21),
          child: Row(
            children: <Widget>[
              _user.photoUrl==null?Icon(
                Icons.supervised_user_circle,
                size: 70,
                color: Colors.white,
              ):ClipOval(
                child: Image.network(_user.photoUrl,width: 70,height: 70,fit: BoxFit.cover,),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  //ten nguoi dung
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        _user.displayName,
                        style: GoogleFonts.cuprum(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(2, 10, 0, 10),
                        child: StreamBuilder(
                            stream:  Firestore.instance.collection('User').document(_user.uid).get().asStream(),
                            builder: (BuildContext context, data){
                              if(data.data == null){
                                return Text("");
                              }else{
                                return Text(
                                  "${data.data["Point"].toString()} Điểm",
                                  style: GoogleFonts.cuprum(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600
                                  ),
                                );
                              }
                            }
                        )
                    )
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
  Widget AppBar(){
    return Container(
      child: Row(
        children: <Widget>[
          TagNameUser(),
          Container(
            margin: EdgeInsets.only(left: 30),
            alignment: Alignment.topRight,
              child:FlatButton(
            child: Image.asset("assets/icon/qrCode_icon.png", height: 70, width: 70,),
                onPressed: _scanQr))
        ],
      ),
    );
  }

  _scanQr(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>QRViewPage()));

  }


  Widget TopBanerName(){
    return Container(
      alignment: Alignment.center,
      child: Text(_nameTopBaner,
        style: GoogleFonts.lora(
          fontSize: 20,
          color: Colors.white
        ),

      ),
    );
  }
  String Name = "Thẻ đổi 1 lon nước Monster Energy"; String GCID = "DDG";
  String img = "https://lh3.googleusercontent.com/proxy/57rkAF_4JMSj13QmZ-sQZI-Sy2tDaYzRUctUzvj9XAr0DxaXir0RWJHPocQTLPp4IdjpBI2VgqcyXzq5PFomntGoHpgBRlzz0GhGluBnwt5UF-vg3A6AtZ5GzRJ_iO315VReHP1MRrwve1PUwe227ueJ2LMT5g";

  Timestamp ed=Timestamp.now(),sd=Timestamp.now();
  void _get(){
    print("ok");
    Firestore.instance.collection('Gift').document()
        .setData({ 'Name': Name, 'GCID': GCID,"img":img ,"ED":ed,"SD":sd,"Point":Random().nextInt(600),"Quantity":Random().nextInt(20)});
  }
}