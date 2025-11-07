class Category {
  final String categoryId;
  String name;
  String description;

  Category({
    required this.categoryId,
    required this.name,
    required this.description,
  });

  static List<Category> predefinedCategories() {
    return [
      Category(categoryId: "1", name: "Food", description: "Meals & dining"),
      Category(categoryId: "2", name: "Transport", description: "Travel & commuting"),
      Category(categoryId: "3", name: "Shopping", description: "Personal purchases"),
    ];
  }
}
