import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';

final currentUserNameProvider = FutureProvider<String>((ref) async {
  return await ref.read(tokenStorageProvider).userName ?? '';
});
