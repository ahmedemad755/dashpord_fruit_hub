// import 'package:supabase_flutter/supabase_flutter.dart';

// Future<void> createProductsTable() async {
//   final supabase = Supabase.instance.client;

//   final response = await supabase.rpc(
//     'exec_sql',
//     params: {
//       'query': '''
//         create table if not exists products (
//           id uuid primary key default gen_random_uuid(),
//           code text unique not null,
//           name text not null,
//           price numeric not null,
//           description text,
//           imageurl text,
//           isOrganic boolean default false,
//           numberOfcalories numeric default 0,
//           averageRating numeric default 0,
//           ratingcount int default 0,
//           expirationDate int not null,
//           unitAmount int not null,
//           reviews jsonb default '[]'::jsonb,
//           created_at timestamp with time zone default now()
//         );
//       ''',
//     },
//   );

//   if (response.error != null) {
//     print('❌ Error creating table: ${response.error!.message}');
//   } else {
//     print('✅ Products table created successfully');
//   }
// }
