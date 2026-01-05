part of models;

enum ProductCategory {
  all('all'),
  vehicles('vehicles'),
  property('property'),
  electronics('electronics'),
  home('home'),
  fashion('fashion'),
  kids('kids'),
  pets('pets'),
  others('others');

  final String name;
  const ProductCategory(this.name);
}
