import 'dart:ui';

import 'package:newarea/widgets/ssv-video-player/src/ssv_video_player.dart';
import 'package:newarea/widgets/ssv-video-player/src/cupertino_controls.dart';
import 'package:newarea/widgets/ssv-video-player/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatelessWidget {
  final Widget playerIcon;
  PlayerWithControls({@required this.playerIcon, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SsvVideoPlayerController ssvVideoPlayerController = SsvVideoPlayerController.of(context);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio:
              ssvVideoPlayerController.aspectRatio ?? _calculateAspectRatio(context),
          child: _buildPlayerWithControls(ssvVideoPlayerController, context),
        ),
      ),
    );
  }

  Container _buildPlayerWithControls(
      SsvVideoPlayerController ssvVideoPlayerController, BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          ssvVideoPlayerController.placeholder ?? Container(),
          Center(
            child: AspectRatio(
              aspectRatio: ssvVideoPlayerController.aspectRatio ??
                  _calculateAspectRatio(context),
              child: VideoPlayer(ssvVideoPlayerController.videoPlayerController),
            ),
          ),
          ssvVideoPlayerController.overlay ?? Container(),
          _buildControls(context, ssvVideoPlayerController),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    SsvVideoPlayerController ssvVideoPlayerController,
  ) {
    return ssvVideoPlayerController.showControls
        ? ssvVideoPlayerController.customControls != null
            ? ssvVideoPlayerController.customControls
            : Theme.of(context).platform == TargetPlatform.android
                ? MaterialControls(
                    playerIcon: playerIcon,
                  )
                : CupertinoControls(
                    backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                    iconColor: Color.fromARGB(255, 200, 200, 200),
                  )
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
