import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_demo/receive_kid/cubit/receive_kid_cubit.dart';
import 'package:kid_demo/receive_kid/view/receiver_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KID Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => ReceiveKidCubit(),
        child: const ReceiverPage(),
      ),
    );
  }
}
