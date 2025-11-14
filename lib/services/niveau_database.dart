import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/models/niveau.dart';

class CategoriesDatabase {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Niveau>> get stream {
    return _client
        .from('niveau')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((map) => Niveau.fromMap(map)).toList());
  }
}
