import '../models/user.dart';
import '../models/category.dart';

final currentUser = User(
  userId: 'u1',
  name: 'John Doe',
  email: 'john@test.com',
  password: '123456',
  reEnterPassword: '123456',
);

final categories = Category.predefinedCategories();
