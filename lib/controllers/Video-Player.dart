import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:newarea/widgets/ssv-video-player/ssv_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';

class VDOPlayer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final BuildContext getContext;

  VDOPlayer(
      {@required this.videoPlayerController,
      @required this.getContext,
      this.looping,
      Key key})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<VDOPlayer> {
  IconData playerIcon = Feather.play;
  SsvVideoPlayerController _chewieController;

  @override
  void initState() {
    super.initState();
    VideoPlayerController player = widget.videoPlayerController;
    _chewieController = SsvVideoPlayerController(
        startAt: Duration(seconds: 90),
        videoPlayerController: player,
        aspectRatio: 16 / 9,
        looping: widget.looping,
        autoInitialize: true,
        autoPlay: false,
        allowedScreenSleep: true,
        materialProgressColors: SsvVideoPlayerProgressColors(
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey[800],
            handleColor: Colors.red),
        cupertinoProgressColors: SsvVideoPlayerProgressColors(
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey[800],
            handleColor: Colors.red),
        errorBuilder: (context, err) {
          return Center(
            child: Text("$err"),
          );
        });
  }

  Widget _playerIcon(
      {IconData iconData, double size, Color color = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(48.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Icon(
          iconData,
          size: size,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Center(
            child: SsvVideoPlayer(
          controller: _chewieController,
          playerIcon: _playerIcon(iconData: Icons.play_arrow, size: 50),
        )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
  }
}
