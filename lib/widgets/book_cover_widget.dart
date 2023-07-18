import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';

class BookCoverWidget extends StatelessWidget {
  const BookCoverWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // double expandedWidth = constraints.maxWidth;
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/read");
              },
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double paddingWidth = constraints.maxWidth;
                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            //   double stackWidth = constraints.maxWidth;
                            return Stack(
                              children: [
                                // change to network when getting cover from online
                                Image.asset(
                                  AssetConstants.coverImagePath,
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                    width: paddingWidth,
                                    child: const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        'Voluptate nulla aliqua ea voluptate id duis eiusmod eiusmod labore veniam sunt velit.',
                                        softWrap: true,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
