part of 'receive_kid_cubit.dart';

abstract class ReceiveKidState {}

class ReceiveKidInitial extends ReceiveKidState {}

class ReceiveKidError extends ReceiveKidState {
  ReceiveKidError(this.message);

  final String message;
}

class ReceiveKidReceived extends ReceiveKidState {
  ReceiveKidReceived(this.encryptedFile);

  final File encryptedFile;
}

class ReceiveKidDecrypted extends ReceiveKidState {
  ReceiveKidDecrypted(this.contents);

  final String contents;
}
