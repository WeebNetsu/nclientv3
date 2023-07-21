import 'package:flutter/material.dart';
import 'package:nhentai/nhentai.dart' as nh;

class BottomSearchBarWidget extends StatefulWidget {
  final FocusNode _focusNode;
  final Future<void> Function(String text)? _handleSearch;
  final nh.API? _api;

  const BottomSearchBarWidget({
    super.key,
    required FocusNode focusNode,
    Future<void> Function(String text)? handleSearch,
    nh.API? api,
  })  : _focusNode = focusNode,
        _handleSearch = handleSearch,
        _api = api;

  @override
  State<BottomSearchBarWidget> createState() => _BottomSearchBarWidget();
}

class _BottomSearchBarWidget extends State<BottomSearchBarWidget> {
  final TextEditingController _searchText = TextEditingController();

  @override
  void dispose() {
    // _searchText.dispose();
    super.dispose();
  }

  void handleSearch() async {
    if (_searchText.text.isEmpty) return;

    if (widget._handleSearch != null) {
      widget._handleSearch!(_searchText.text);
    } else {
      await Navigator.pushNamed(context, "/search", arguments: {"searchText": _searchText.text, "api": widget._api});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Container(
            // Styling for the container that holds the TextField
            color: Colors.black,

            child: TextField(
              autofocus: false,
              focusNode: widget._focusNode,
              //   use the provided controller (so we don't change pages on search)
              controller: _searchText,
              decoration: InputDecoration(
                labelText: 'Search for a doubjin',
                hintText: '177013',
                prefixIcon: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Handle left icon button tap
                  },
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: handleSearch,
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: () {
                        // Handle right icon button tap
                      },
                    ),
                  ],
                ),
                filled: true,
                fillColor: Colors.black,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none, // Remove border
                ),
              ),
              keyboardType: TextInputType.text,
            ),
          ),
        ),
      ),
    );
  }
}
