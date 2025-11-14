import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennasafi/models/pays.dart';

class CategoriesDatabase {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Pays>> get stream {
    return _client
        .from('pays')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((map) => Pays.fromMap(map)).toList());
  }
}
