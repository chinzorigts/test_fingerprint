import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fingerprint',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Fingerprint'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String authorized = "Not authorized";


  @override
  void initState() {
    super.initState();
    _canCheckBiometrics = false;
    _availableBiometrics = [];
    _checkBiometric();
    _getAvailableBiometric();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 150)),
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 22)),
              const Icon(Icons.fingerprint_outlined, color: Colors.blue, size: 82,),
              const Padding(padding: EdgeInsets.only(top: 10)),
              const Text(
                '지문 인증',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 16, right: 16,top: 8),
                child: ElevatedButton(
                  onPressed: _authenticate,
                  child: const Text(
                    '인증',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 16, left: 16),
                child: Row(
                  children: <Widget>[
                    const Text('Can check biometrics ', style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),),
                    const Padding(padding: EdgeInsets.only(left: 16)),
                    Icon(_canCheckBiometrics != null && _canCheckBiometrics ? Icons.done_outlined : Icons.close_outlined, color: Colors.blue, size: 24,),
                  ],
                )
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 16, left: 16),
                  child: Row(
                    children: <Widget>[
                      const Text('Available fingerprints ', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),),
                      const Padding(padding: EdgeInsets.only(left: 16)),
                      Text(_availableBiometrics.length?.toString(), style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue
                      ),),
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkBiometric() async{
    bool canCheckBiometric;
    try{
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch(e){
      print(e);
    }
    if(!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheckBiometric;
    });
  }

  Future<void> _getAvailableBiometric() async{
    List<BiometricType> availableBioMetric;
    try{
      availableBioMetric = await auth.getAvailableBiometrics();
    } on PlatformException catch(e){
      print(e);
    }

    setState(() {
      _availableBiometrics = availableBioMetric;
    });
  }

  Future<void> _authenticate() async{
    bool authenticated = false;

    try{
      authenticated = await auth.authenticate(
          localizedReason: "지문 인식 센서에 손가락을 올려주세요",
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
          sensitiveTransaction: true,
          androidAuthStrings: const AndroidAuthMessages(
            biometricSuccess: '지문 인증 완료',
            biometricHint: '지문 인증',
            signInTitle: '본인 인증',
            cancelButton: '취소',
          )
      );
    } on PlatformException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code '+ e.code + " \nMessage " + e.message, style: const TextStyle(color: Colors.white, fontSize: 18),)));
    }

    if(!mounted) return;
    setState(() {
      authorized = authenticated ? "Authorized success" : "Failed to authenticate";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authorized, style: const TextStyle(color: Colors.white, fontSize: 18),)));
    });
  }
}
