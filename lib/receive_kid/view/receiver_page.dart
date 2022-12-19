import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/receive_kid_cubit.dart';

class ReceiverPage extends StatelessWidget {
  const ReceiverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: BlocBuilder<ReceiveKidCubit, ReceiveKidState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                //* Show an error message
                case ReceiveKidError:
                  final errorMessage = (state as ReceiveKidError).message;
                  return Center(
                    child: Text(errorMessage),
                  );

                //* Show a textfield for the user to enter the encryption key
                case ReceiveKidReceived:
                  final controller = TextEditingController();
                  return Column(
                    children: [
                      const Text('Podaj szesnastoznakowy klucz do pliku .kid:'),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.maxFinite,
                        child: TextField(
                          controller: controller,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<ReceiveKidCubit>()
                                .decryptFile(controller.text);
                          },
                          child: const Text('ODSZYFRUJ'),
                        ),
                      )
                    ],
                  );

                //* Show the content of decrypted file
                case ReceiveKidDecrypted:
                  final contents = (state as ReceiveKidDecrypted).contents;
                  final json = Map<String, dynamic>.from(
                    jsonDecode(contents) as Map,
                  );
                  final kidPubliczny = json['kidPubliczny'];
                  final kidPrywatny = json['kidPrywatny'];
                  return Text(
                    'KID publiczny: $kidPubliczny\nKID prywatny: $kidPrywatny',
                  );

                //* Default state
                default:
                  return const Center(
                    child: Text('Nie udostępniono pliku .kid'),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
