import 'package:reservoir/reservoir.dart';

class User {
  final String id;
  final String name;
  final String status;
  User(this.id, this.name, this.status);

  @override
  String toString() => 'User($id, $name, $status)';
}

class UserReservoir extends Reservoir<String, User> {
  late IndexMultiple byStatus;

  UserReservoir(Source<String, User> source, GetKey<String, User> getKey)
      : super(source, getKey) {
    byStatus = addIndexMultiple('status', (user) => user.status);
  }
}

void main() async {
  var source = MapSource<String, User>();
  var res = UserReservoir(source, (User user) => user.id);
  await res.save(User('1', 'John', 'active'));
  await res.save(User('2', 'Shawna', 'active'));
  await res.save(User('3', 'Meili', 'inactive'));
  print(res.byStatus.getAll('active'));
  // => (User(1, John, active), User(2, Shawna, active))
}
