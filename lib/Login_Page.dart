import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_green_waste_bin_ticker/Home_Page.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isLogged = false;
  final _auth = FirebaseAuth.instance;
  final _facebooklogin = FacebookLogin();

  String _imgUser;
  @override
  void initState() {
    _auth.currentUser().then((user){
      // user!=null nếu như đã có user đăng nh
      if(user!=null){
        _checkAuthInFirebase(IDUser: user.uid);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                FacebookSignInButton(
                  borderRadius: 10,
                  onPressed: _loginWithFacebook,

                ),
                _imgUser !=null?Image(
                  image: NetworkImage(
                    _imgUser
                  ),
                ):Container()
              ],
            ),
          ),
        )
      ),
    );
  }


  Future _checkAuthInFirebase({String IDUser}) async {
    // hàm này kiểm tra thông tin user trên firebase có chưa nếu chưa có thì tạo


    final snapShot = await Firestore.instance
        .collection('User')
        .document(IDUser)
        .get();

    if (snapShot == null || !snapShot.exists) {
      //nếu chưa có
      Firestore.instance
          .collection('User')
          .document(IDUser).setData({"Point":0});

    }

  }


  Future _loginWithFacebook() async {
    // Gọi hàm LogIn() với giá trị truyền vào là một mảng permission
    // Ở đây mình truyền vào cho nó quền xem email
    final result = await _facebooklogin.logIn(['email']);
    // Kiểm tra nếu login thành công thì thực hiện login Firebase
    // (cách này đơn giản hơn là dùng đường dẫn
    // hơn nữa cũng đồng bộ với hệ sinh thái Firebase, tích hợp được
    // nhiều loại Auth

    if (result.status == FacebookLoginStatus.loggedIn) {
      final credential = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token,
      );
      // Lấy thông tin User qua credential có giá trị token đã đăng nhập
      final user = (await _auth.signInWithCredential(credential)).user;
      setState(() {
        _checkAuthInFirebase(IDUser: user.uid);
        _imgUser = user.photoUrl;
        print(user.uid);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
      });
    }
  }



}