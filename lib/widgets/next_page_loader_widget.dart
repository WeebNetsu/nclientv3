import 'package:flutter/material.dart';
import 'package:nclientv3/models/user_preferences.dart';

class NextPageLoaderWidget extends StatelessWidget {
  final UserPreferencesModel userPreferences;
  final bool loadingNextPage;
  final void Function() fetchData;

  const NextPageLoaderWidget({
    super.key,
    required this.userPreferences,
    required this.loadingNextPage,
    required this.fetchData,
  });

  @override
  Widget build(BuildContext context) {
    if (userPreferences.slowInternetMode) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: loadingNextPage ? null : () => fetchData(),
                child: Row(
                  children: [
                    if (loadingNextPage) const CircularProgressIndicator(),
                    const SizedBox(width: 20),
                    const Text("Load More"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        //   if (!loadingNextPage) const Text("Scroll up to load more..."),
        //   const SizedBox(height: 100),
        if (loadingNextPage)
          const Center(
            child: CircularProgressIndicator(),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}
