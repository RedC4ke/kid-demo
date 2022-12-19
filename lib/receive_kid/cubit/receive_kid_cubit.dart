import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

part 'receive_kid_state.dart';

class ReceiveKidCubit extends Cubit<ReceiveKidState> {
  ReceiveKidCubit() : super(ReceiveKidInitial()) {
    init();
  }

  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;

  // Set up share receiver
  void init() {
    // For sharing files coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((
      List<SharedMediaFile> value,
    ) {
      if (value.isNotEmpty) _onFileReceived(value.first);
    });

    // For sharing files coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) _onFileReceived(value.first);
    });
  }

  Future<void> _onFileReceived(SharedMediaFile file) async {
    // Remove file prefix from path on iOS
    final receivedFile = File(file.path.replaceFirst('file://', ''));

    _receiveFile(receivedFile);
  }

  void _receiveFile(File file) {
    if (extension(file.path) != '.kid') {
      emit(ReceiveKidError(
        'Udostępniono zły typ pliku. Aplikacja obsługuje tylko pliki o rozszerzeniu .kid',
      ));
      return;
    }

    emit(ReceiveKidReceived(file));
  }

  Future<void> decryptFile(String keyString) async {
    if (state is! ReceiveKidReceived) return;
    final encryptedFile = (state as ReceiveKidReceived).encryptedFile;

    // Read file contents
    final strings = await encryptedFile.readAsLines();
    // Check if the file has been read properly
    if (strings.length != 2) {
      emit(ReceiveKidError('Wystąpił błąd'));
      return;
    }

    // Decode base64 strings to byte lists
    final ivDecoded = base64.decode(strings.first);
    final contentDecoded = base64.decode(strings.last);

    // Create input vector and key from encrypt package
    final iv = IV(ivDecoded);
    final key = Key.fromUtf8(keyString);

    // Create the encrypter with AES cbc mode passing the encryption key
    final encrypter = Encrypter(
      AES(
        key,
        mode: AESMode.cbc,
      ),
    );

    // Decrypt the file with given input vector
    final contentDecrypted = encrypter.decrypt(
      Encrypted(contentDecoded),
      iv: iv,
    );

    // Emit a proper state
    emit(ReceiveKidDecrypted(
      utf8.decode(base64Decode(contentDecrypted)),
    ));
  }

  @override
  Future<void> close() {
    _intentDataStreamSubscription?.cancel();

    return super.close();
  }
}
