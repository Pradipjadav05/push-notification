import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notification_channels/notification_service.dart';

import 'firebase_options.dart';

// create background handler for firebase messaging notification
Future<void> _backgroundMessageHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {

  //used to bind the services
  WidgetsFlutterBinding.ensureInitialized();

  // initialize firebase to application
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //initialize Firebase Messaging to application
  await FirebaseMessaging.instance.getInitialMessage();

  // used to allow in background Firebase notification
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  // create listener to show notification of FCM (firebase console massage)
  FirebaseMessaging.onMessage
      .listen((RemoteMessage message) async {
    await NotificationServiceChannel().initNotification("FCM push notification");
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _statusText = "Waiting...";
  final String _finished = "Finished creating channel";
  final String _error = "Error while creating channel";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationServiceChannel().requestPermission();

    // for flutter_local_notifications

    // NotificationService().firebaseNotification(context);
    // NotificationService().getToken();
    //
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   NotificationService().showNotification(body: "Background push notification");
    // });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _statusText,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: _createNewChannel,
        onPressed: (){
          try{
            NotificationServiceChannel().initNotification("Local push notification");
            setState(() {
              _statusText = _finished;
            });
          }
          catch(e){
            setState(() {
              _statusText = _error;
            });
          }

        },
        child: const Icon(Icons.add),
      ),
    );
  }



}
