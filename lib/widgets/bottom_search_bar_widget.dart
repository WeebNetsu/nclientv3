import 'package:flutter/material.dart';

class BottomSearchBarWidget extends StatelessWidget {
  const BottomSearchBarWidget({
    super.key,
    required FocusNode focusNode,
  }) : _focusNode = focusNode;

  final FocusNode _focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            // Styling for the container that holds the TextField
            //   padding: EdgeInsets.all(16),
            color: Colors.black,

            child: TextField(
              autofocus: false,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                labelText: 'Search for a doubjin',
                hintText: '177013',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none, // Remove border
                  // borderRadius: BorderRadius.circular(50),
                ),
              ),
              keyboardType: TextInputType.text,
              // TextField properties and event handlers
            ),
          ),
        ),
      ),
    );
  }
}
