import 'package:flutter/material.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nhentai/nhentai.dart' as nh;

class PopupMenuItemModel {
  final String title;
  final bool value;

  PopupMenuItemModel({required this.title, required this.value});
}

class BottomSearchBarWidget extends StatefulWidget {
  final FocusNode _focusNode;
  final Future<void> Function(String text)? _handleSearch;
  final Future<void> Function()? _reloadData;
  final nh.API? _api;

  const BottomSearchBarWidget({
    super.key,
    required FocusNode focusNode,
    Future<void> Function(String text)? handleSearch,
    Future<void> Function()? reloadData,
    nh.API? api,
  })  : _focusNode = focusNode,
        _handleSearch = handleSearch,
        _api = api,
        _reloadData = reloadData;

  @override
  State<BottomSearchBarWidget> createState() => _BottomSearchBarWidget();
}

class _BottomSearchBarWidget extends State<BottomSearchBarWidget> {
  final TextEditingController _searchText = TextEditingController();
  final UserPreferencesModel _userPreferences = UserPreferencesModel();
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _userPreferences.loadDataFromFile().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

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
            color: Colors.black,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, "/settings");
                  },
                ),
                Expanded(
                  child: TextField(
                    autofocus: false,
                    focusNode: widget._focusNode,
                    // use the provided controller (so we don't change pages on search)
                    controller: _searchText,
                    decoration: const InputDecoration(
                      labelText: 'Search for a doujin',
                      hintText: '177013',
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // Remove border
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: handleSearch,
                ),
                PopupMenuButton(
                  child: const Icon(Icons.sort),
                  itemBuilder: (_) {
                    if (_loading) return [];

                    return [
                      PopupMenuItemModel(
                        title: "Recent",
                        value: _userPreferences.sort == nh.SearchSort.recent,
                      ),
                      PopupMenuItemModel(
                        title: "Popular",
                        value: _userPreferences.sort == nh.SearchSort.popular,
                      ),
                      PopupMenuItemModel(
                        title: "Popular (Month)",
                        value: _userPreferences.sort == nh.SearchSort.popularMonth,
                      ),
                      PopupMenuItemModel(
                        title: "Popular (Week)",
                        value: _userPreferences.sort == nh.SearchSort.popularWeek,
                      ),
                      PopupMenuItemModel(
                        title: "Popular (Today)",
                        value: _userPreferences.sort == nh.SearchSort.popularToday,
                      ),
                    ].map((item) {
                      return CheckedPopupMenuItem(
                        value: item,
                        checked: item.value,
                        child: Text(item.title),
                      );
                    }).toList();
                  },
                  onSelected: (selectedItem) async {
                    if (selectedItem is PopupMenuItemModel) {
                      if (selectedItem.title == "Recent") {
                        _userPreferences.sort = nh.SearchSort.recent;
                      } else if (selectedItem.title == "Popular") {
                        _userPreferences.sort = nh.SearchSort.popular;
                      } else if (selectedItem.title == "Popular (Month)") {
                        _userPreferences.sort = nh.SearchSort.popularMonth;
                      } else if (selectedItem.title == "Popular (Week)") {
                        _userPreferences.sort = nh.SearchSort.popularWeek;
                      } else if (selectedItem.title == "Popular (Today)") {
                        _userPreferences.sort = nh.SearchSort.popularToday;
                      }

                      await _userPreferences.saveToFileData();

                      if (widget._reloadData != null) await widget._reloadData!();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
