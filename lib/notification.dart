import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class Notification_ {
   // reciev

  Future<void> sendPushNotification(String fcmToken, String title, String body) async {
    final serviceAccount = ServiceAccountCredentials.fromJson(r'''
    {
      "type": "service_account",
      "project_id": "chat-app-9e8cb",
      "private_key_id": "d3676577b2d59aafc2b075dd4fbb8991406a98d6",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCcJYQwR+20HYq5\nA6A+OxpDY2HDdP1L9ysoFHwpv2yzmzmWS8UQlaKAR2O+g47Q1SLdpc7FLe+KMoOh\nRG3OsOqaEvbsFSwILLAS2DnmF8+7THTNpChrR2SvYi0AtDocWUOxHZTMOIA1iKpf\nTsiwf6jcTbykKJ0G4Ynj4MrWUJU8K7lS0LD5Tx/epsFdgqpewB9L3g/6L3nv752O\nFp5fr750Ui4dbCxhcdVwX4CIrPm6y6n5Pku+x92mbtXEdVF+Yhio6YRTrqUtqqYa\njsHRrgAwYVMFgHxCtsG+jHizADTQ+lDUj5Q6yFt24BVRdG+0GNHno+n+MGrs11Lx\nYb7TSAvhAgMBAAECggEAAKdtktAyUC9Rfe3kdW5E8WRQrANo7jEGVsAjNv+MwoHT\nb2w40pV13UivQ8SETB6ga0I/B/dlyfPlNj81oIiAKw4KR7nc+dnKEQIj1/Fglt2+\nnX/jBXQCmXN1UcvvdF/xVyQTE/nmm5LLd+O6Fncqa2XN9PgQlE9Mhw5Rey1SOrLI\ngqS6nJ/NZa6UuZHR2mwf5DiuI7xAt0sDF7RLXoDObrfSQ9cUK8Bojd6sywYJQQgc\nzx9E5hNAU1iq7I92oyNs49OQwDNdiaPbwPx+MuAB8DJGzwqCcJzzxyeCbR0zGxUV\nRYtERC2eAEFMAMrz9NUoGiL18n1S/zT40egVcO6zswKBgQDKG23EpXPbuy31VDI0\nmNW3u6pJVKj5irRdqTTL3s02WibbnxfPUf7DVVrmgqKV6H1xMV6Vmk24/POXqpoE\n5En4tSu5WIHFh2iaRdWoNGJYs+4Hjfr++n3DSDT8XCBuOGcLSsxEBmjJR3BIcBEE\nx/notoyezvFqZu299zXQuWHXSwKBgQDFyKZMhdS3y9PQF7ph9m6KrfqM51/YBH6A\n+YE6rXx4sQOzzNBjvyvoWFsulsDr6yTekMb6XiiiAZ5t6t1yRwi13d3lT+8Zd0Il\nJ/YDWuNgav8uQohOEjttV8OXvGkhQxDX1qrGsmIzpSInQmuUKCsYeyyqW0qsF+Tk\n1AZNNjXSAwKBgG7q1LgqUUZTGKreFVuWURwvqwnpo36oJ8qLNUV5tkfQ/ChlzIxk\nJJwQ+P0uzonU+RspDA6wi10tvYYMA9ERdKNA0ok60KWWZcrc7qAMd7jUrpqIyior\nUN/efe3NpaK3451n5Gik19c3FKE8l6p3EWks3km9qvJJIMqzpF4zj0W3AoGBAIl2\nTEaRGWforT1K0Ip3iRqvkpzNzqpHbVjckHmkzAbiGI2lgwxgePbSOgVmV41gb86U\nVwb53EnE0ETa4LAlOKOWITvYU3iij4FdhbmNOMzxcIvJSAzi1RTI07MpCvRINXOd\nyjGxF1mHovYgTr65MEKikUeRjZOQQ9Dan8qYK83bAoGAWnzE+1M1EhuvEfyjogUL\n46BMI/nbPQe0DdznnkFkENgHBWUhqyT3jIyVGf1c5BuoyofraHZ1jS0MlMSis+oo\nr0p8r4rCx1FFo5Fzv3q/3OWADtRrgojTwIZNOGoqCgpXgmMT67ZoiU9lsILhPqa+\nKXQdkLK4JKglzcbQGVdrtM8=\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-yopcd@chat-app-9e8cb.iam.gserviceaccount.com",
      "client_id": "115217936692180701918",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-yopcd%40chat-app-9e8cb.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }
    ''');

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(serviceAccount, scopes);

    final String fcmUrl = 'https://fcm.googleapis.com/v1/projects/chat-app-9e8cb/messages:send';

    try {
      final response = await client.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'message': <String, dynamic>{
            'token': fcmToken,
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
      } else {
        print('Failed to send notification: ${response.statusCode} ${response.body}');
      }

      client.close();
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
