import 'package:dak_louk/widgets/category_bar.dart';
import 'package:dak_louk/widgets/product_block.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var image = Image.asset(
      "assets/images/successful-graduation-university-smiling-beautiful-600nw-2246900309.webp",
    );
    return Column(
      children: [
        const SizedBox(height: 16.0),
        CategoryBar(),
        const SizedBox(height: 16.0),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 16.0),
            itemCount: 20,
            itemBuilder: (context, index) {
              return ProductBlock(
                title: 'Product Title ${index + 1}',
                price: ((index + 1) * 10.00).toStringAsFixed(2),
                images: [
                  image.image,
                  image.image,
                  image.image,
                  image.image,
                  image.image,
                ],
                profile: image.image,
                rating: '4.50',
                username: 'User ${(index % 10) + 1}',
                description: '''Drop top, drop top, feel the rain drop
In the rearview, they sayin', "Oh, my God"
What's up, what's up? Tear the roof down
'Til the sunrise, 저기 별을 향해 ride
Drop top, drop top, feel the rain drop
In the rearview, they sayin', "Oh, my God"
What's up, what's up? Tear the roof down
'Til the sunrise, 저기 별을 향해 rideDrop top, drop top, feel the rain drop
In the rearview, they sayin', "Oh, my God"
What's up, what's up? Tear the roof down
'Til the sunrise, 저기 별을 향해 ride
Drop top, drop top, feel the rain drop
In the rearview, they sayin', "Oh, my God"
What's up, what's up? Tear the roof down
'Til the sunrise, 저기 별을 향해 ride''',
                date: '5 hours ago',
                quantity: "10",
              );
            },
          ),
        ),
      ],
    );
  }
}
