import 'package:flutter/material.dart';

class PhotoSlider extends StatefulWidget {
  final List<ImageProvider> images;
  final String quantity;

  const PhotoSlider({super.key, required this.quantity, required this.images});

  @override
  State<PhotoSlider> createState() => _PhotoSliderState();
}

class _PhotoSliderState extends State<PhotoSlider> {
  late final PageController controller;
  int _page = 0;
  void _onPageChanged(int i) => setState(() => _page = i);

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: controller,
              itemCount: widget.images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, i) => Image(
                image: widget.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            if (widget.images.length > 1) ...[
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          if (_page > 0) {
                            controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const SizedBox(
                          width: 72,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.arrow_circle_left,
                              size: 40,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (_page < widget.images.length - 1) {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const SizedBox(
                          width: 72,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.arrow_circle_right,
                              size: 40,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _page == i
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Positioned(
              bottom: 8,
              right: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(190, 0, 0, 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    '${widget.quantity} left',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
