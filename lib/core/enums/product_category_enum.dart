part of models;

enum ProductCategory {
  all('all'),
  vehicles('vehicles'),
  property('property'),
  electronics('electronics'),
  home('home'),
  fashion('fashion'),
  jobs('jobs'),
  services('services'),
  entertainment('entertainment'),
  kids('kids'),
  pets('pets'),
  business('business'),
  others('others');

  final String name;
  const ProductCategory(this.name);
}
