import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends SupabaseAuthState<HomePage> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Happy Chat'),
        actions: [
          StreamBuilder<AuthChangeEvent>(
              stream: SupabaseAuth.instance.onAuthChange,
              builder: (context, snapshot) {
                if (snapshot.data == AuthChangeEvent.signedIn) {
                  return TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                    ),
                    onPressed: () async {
                      final res = await Supabase.instance.client
                          .rpc('create_room')
                          .execute();
                      debugPrint(res.error.toString());
                      debugPrint(res.data);
                    },
                    child: const Text('New Room'),
                  );
                } else {
                  return TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ));
                    },
                    child: const Text('Signin'),
                  );
                }
              }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: 2,
              itemBuilder: ((context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.blue[200],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tyler',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text('chat bubble'),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Material(
            color: Colors.red[300],
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type something...',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final message = _messageController.text;
                    Supabase.instance.client.from('messages').insert({
                      'message': message,
                      'room_id': 'ce8c792a-df7b-4247-a75b-b8e022de903b'
                    }).execute();
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    recoverSupabaseSession();
  }

  @override
  void onAuthenticated(Session session) {
    // TODO: implement onAuthenticated
  }

  @override
  void onErrorAuthenticating(String message) {
    // TODO: implement onErrorAuthenticating
  }

  @override
  void onPasswordRecovery(Session session) {
    // TODO: implement onPasswordRecovery
  }

  @override
  void onUnauthenticated() {
    // TODO: implement onUnauthenticated
  }
}
