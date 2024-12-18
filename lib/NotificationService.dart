import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:googleapis/monitoring/v3.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class PushNotifications {
  static Future<String> getAccessToken() async{
    final serviceAccountJSON={
      "type": "service_account",
      "project_id": "hedieaty-eae86",
      "private_key_id": "eede62d735f97f3c4609b6fd80184d2ba5b0c975",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC7eOzC5i0pbKjV\nirHgpJSztYszz6fOcEiXozSnhQgNpWb71HCmJblMBj9NTL04B5FSggZcP+q0GC1f\nhoS8zq2IKFKJhUcQPYGJk9qlXBWGXEM/whaKquMLAJ+2IGEMlB6cbsPgfL2dMqAe\n/yXq6atEaqUfajXlQeTMb2j2jjPzXkaWUggbbVOJ2JaPnNBDlj7NhMHEaNxZdTpn\nEis0ZqK3WtCP/jN60Xl3lxoldcCOBPVAOuRUxnchCJLusI0tA+VluMr76MUIqDMX\nrkA6CX6r9dQYUkYIAq39ukN9dU0r6QKbzallePxG+Ma6zxovztNY94nzQWIR45tT\nIU3qiF+RAgMBAAECggEACWhcUzx7RDKmd07WNcx0hN8lnOQ9CsRCNE/Vltl7abnk\n5NrIi2Hlvk2q9A1Xin4Auif5uzve4oo7Dqngs9vYQ/aoC6wjQIqhmz6O8JDiKKOt\nIUAzYuKH8bemjBxsWlX9gkKhtDx2RHLzq5KIu9Tdihmi7yRkj3xix6qIlSTWMQ5y\nJQ1w2uMfqnQFgCZrfbO8ygi7zy9QZqUmWPYCYahIlbEhSuB7D2ek1Wt3UAgmRDzc\nGWJh2v9pVM2oA9+CUFvexJca2LbzjV7872ISaKzRUzwItirz17KgByRFXxJ9/qio\nn+WhpQJrt/FTkwmNtW1ShWu8L7q8rm4DGXO9n6ZT1QKBgQD5+yv8m1P1+omjjkBW\nQA87f6q+DKA/N+9PsnR3+jUD71/4b78uC5OpZh2NrP+qldTIhJ+n88oQrxIYcP8x\n2gKidKG7JNGfAVIzkyUdtC3/2nYIEx3+gJc9LbHPn3HsvpbKghpd+VJrrrhyhyIG\n/fHhaqcKbf6asZhoutWrM66NHQKBgQC//HZ7QTSCKJoWx4gOgXTgaP83Hm1Rpc9m\nQA9hP2V2igpf8FBOjkPEvMef7lXMJV14tMv3FxMQtLZo736g8aZ4KzBdezb2/M4G\nVr6+oiyHKapNal2NydIYdi5cNzrQVNQEQP1+UdDYEEJj77X3+Kq42rymZ6rv6xu7\nU1wwvnG2BQKBgHV3fbf6FX4k+MCOe9ULzRycZVNhA3wxgJbmuKwYOwlaVrKbcC7m\n6cBUZ9bHUGyMc6y2BYAaov0sB0jM8F4wn8RPIiCasJYTPNlXb72BiYwM0CIDObj6\nHBd3fXKe7h3dgWYvtMwr+Hr5Y1sN/QNkGWFfiJbyEQ4IHiI4iWclpgRRAoGAMUdm\nSiDkj3xIgQxaWg7Upz2MNOO0f76ly8Mpr3aMXq70FsgidOeDcZ5bRyvwDeSRZ4hQ\nym270Q/xumGvCTS93B6J3ZTg+OjPIUVm1Jvf/hmtww1IUjq5mNnM8JKkoBEGEslz\nx9bMWolh4TEIbkv/1k8fGT+G2upoRd8RzNk1atkCgYAcTBjO/lUUHzBOVCqnJJzG\nvmSiTvecOLnwFNzeK8b0okNw9HZECluaU267iv9cdlNzbu4QIwwxrv9O+F5jrw5f\njT6PXlVAeHz9b0AT699kDTtU5x9grxyXdH41eVSDF08C5Z+pGhY3IZhrzCUlQ1X/\nDnhuqIileU50J1x3wnP9HQ==\n-----END PRIVATE KEY-----\n",
      "client_email": "hedieaty@hedieaty-eae86.iam.gserviceaccount.com",
      "client_id": "107810325879496228532",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/hedieaty%40hedieaty-eae86.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes=[
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client=await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJSON),
      scopes,
    );
    auth.AccessCredentials credentials=await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJSON),
        scopes,
        client
    );
    client.close();
    return credentials.accessToken.data;
  }
  static SendNotificationToPledgedFriend(String deviceToken,BuildContext context,String pledgedGiftId,String PledgedGiftName,String EventName,String currentUser) async{
    final String serverAccessTokenKey= await getAccessToken();
    String endpointFCM='https://fcm.googleapis.com/v1/projects/hedieaty-eae86/messages:send';
    final Map<String,dynamic> message={
      'message':{
        'token':deviceToken,
        'notification':
        {
          'title':"Hedieaty",
          'body':"$currentUser Pledged your Gift: $PledgedGiftName for The Event: $EventName ",
        },
        'android': {
          'notification': {
            'icon': 'notification_icon', // Name of the icon in the drawable folder (without extension)
          },
        },
        'data':{
          'pledgedGiftId':pledgedGiftId
        }
      }
    };
    final http.Response response= await http.post(Uri.parse(endpointFCM),
      headers:<String,String>{
        'Content-Type':'application/json',
        'Authorization':'Bearer $serverAccessTokenKey'
      },
      body:jsonEncode(message),);
    if(response.statusCode == 200){
      print("Notification Sent Successfully");
    }else{
      print("Notification not sent");
    }

  }
}