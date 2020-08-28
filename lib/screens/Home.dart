import 'package:flutter/material.dart';
import 'package:newarea/controllers/Video-Player.dart';
import 'package:video_player/video_player.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Center(
            child: VDOPlayer(
          getContext: context,
          videoPlayerController:
              VideoPlayerController.asset("videos/postmalone.mp4"),
          looping: true,
        )),
      ),
    );
  }
}
// Eminem - I Try [ft. Post Malone] 2019.mp4
