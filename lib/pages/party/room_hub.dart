import 'package:flutter/material.dart';
import 'package:game_v1/widget/atoms/atom_background_page.dart';
import 'package:game_v1/widget/atoms/atom_title.dart';

class RoomHub extends StatefulWidget {
  const RoomHub({super.key});

  @override
  State<RoomHub> createState() => _RoomHubMinimalState();
}

class _RoomHubMinimalState extends State<RoomHub> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundPage(pathBackground: "../../assets/images/carrefour.png"),
        ],
      ),
    );
  }
}
