import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/env/app_env.dart';
import '../services/image/avatar_picker_service.dart';
import 'auth_repository.dart';
import 'profile_repository.dart';

part 'auth_repository_provider.g.dart';

/// The Supabase client, or null when this build has no project configured
/// (see `AppEnv`). Only the public anon key ever reaches it.
@Riverpod(keepAlive: true)
SupabaseClient? supabaseClient(Ref ref) =>
    AppEnv.isSupabaseConfigured ? Supabase.instance.client : null;

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    SupabaseAuthRepository(ref.watch(supabaseClientProvider)?.auth);

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
AvatarPickerService avatarPickerService(Ref ref) => AvatarPickerService();
