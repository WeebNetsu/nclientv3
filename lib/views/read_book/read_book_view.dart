import 'package:flutter/material.dart';
import 'package:nclientv3/widgets/book_cover_widget.dart';

class ReadBookView extends StatefulWidget {
  const ReadBookView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const ReadBookView(),
      );

  @override
  State<ReadBookView> createState() => _ReadBookViewState();
}

class _ReadBookViewState extends State<ReadBookView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  BookCoverWidget(),
                  BookCoverWidget(),
                ],
              ),
              Row(
                children: [
                  BookCoverWidget(),
                  BookCoverWidget(),
                ],
              ),
              Row(
                children: [
                  BookCoverWidget(),
                  BookCoverWidget(),
                ],
              ),
              Row(
                children: [
                  BookCoverWidget(),
                  BookCoverWidget(),
                ],
              ),
              Row(
                children: [
                  BookCoverWidget(),
                  BookCoverWidget(),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
