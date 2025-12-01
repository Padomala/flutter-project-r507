// Supabase configuration constants. You can load these via Dart define or hardcode the values here.

// Usage Example:
//
//   import 'supabase_config.dart';
//   import 'package:supabase_flutter/supabase_flutter.dart';
//
//   Future<void> main() async {
//     await Supabase.initialize(
//       url: supabaseUrl,
//       anonKey: supabaseAnonKey,
//     );
//     // Now you can use Supabase.instance.client
//   }

const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://vivjwqfdjeujoomxmqhu.supabase.co',
);

const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZpdmp3cWZkamV1am9vbXhtcWh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyODk0MjIsImV4cCI6MjA3NTg2NTQyMn0.kIG7n8cydeIHFEMI69CsY7X_uFcO6S4_1VuQjWUHyQs',
);
