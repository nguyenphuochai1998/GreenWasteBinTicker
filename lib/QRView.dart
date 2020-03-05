import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_green_waste_bin_ticker/Home_Page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class QRViewPage extends StatefulWidget {
  const QRViewPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewPageState();
}
class _QRViewPageState extends State<QRViewPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  final _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  QRViewController controller;
  @override
  void initState() {
    _auth.currentUser().then((user){
      setState(() {
        _user = user;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: (){
          controller.toggleFlash();
        },
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              children: <Widget>[
                QRView(
                  overlay: QrScannerOverlayShape(
                      borderRadius: 16,
                      borderColor: Colors.white,
                      borderLength: 120,
                      borderWidth: 10,
                      cutOutSize: 250),
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,

                ),
                Container(
                  margin: EdgeInsets.only(top: _size.height*0.05),

                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: _size.width*0.7),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: FlatButton(onPressed: (){


                          }, child: Text("Hủy",style: GoogleFonts.lora(color: Colors.white),)),
                        ),
                        alignment: Alignment.topRight,
                      )
                    ],
                  ),
                )
              ],
            )
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if(scanData !=""){
          controller.pauseCamera();
          controller.dispose();
          print(scanData);
          _getPointInQr(QrString: scanData,Done: (val){
            print(val);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
          },Err: (err){

            print(err);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
          });
        }
      });
    });
  }
  Future _getPointInQr({String QrString,Function(String) Err,Function(String) Done}) async {
    await Firestore.instance.collection("WasteBin01").document(QrString).get().then((dataTicket) async {
      if(!dataTicket.exists){
        //nếu mã này không có trên hệ thống
        Err("Mã tích điểm này không có trên hệ thống!!");
      }else{
        if(dataTicket["UserActive"]!=null){
          Err("Mã tích điểm này đã được sử dụng !!");
        }else{
          // tạo 1 giao dịch là đổi điểm
          final DocumentReference postRef = Firestore.instance.collection("User").document(_user.uid);
          Firestore.instance.runTransaction((Transaction tx) async {
            DocumentSnapshot postSnapshot = await tx.get(postRef);
            if (postSnapshot.exists) {
              await tx.update(postRef, <String, dynamic>{'Point': postSnapshot.data['Point'] + dataTicket["Point"]});
              await Firestore.instance.collection("WasteBin01").document(QrString).updateData({"UserActive":_user.uid,"Activation":"Activated"});
              Done("Tích điểm thành công.");

            }
          });

        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}