import 'dart:async';

import 'package:newarea/widgets/ssv-video-player/src/ssv_video_player.dart';
import 'package:newarea/widgets/ssv-video-player/src/ssv_video_player_progress_colors.dart';
import 'package:newarea/widgets/ssv-video-player/src/material_progress_bar.dart';
import 'package:newarea/widgets/ssv-video-player/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MaterialControls extends StatefulWidget {
  final Widget playerIcon;
  final Color controlButtonColor;
  final double barHeight, timeTextSize;
  const MaterialControls(
      {@required this.playerIcon,
      this.barHeight = 40,
      this.timeTextSize = 12,
      this.controlButtonColor = Colors.white,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<MaterialControls> {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;
  final marginSize = 5.0;

  VideoPlayerController controller;
  SsvVideoPlayerController ssvVideoPlayerController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return ssvVideoPlayerController.errorBuilder != null
          ? ssvVideoPlayerController.errorBuilder(
              context,
              ssvVideoPlayerController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideStuff,
          child: Column(
            children: <Widget>[
              _latestValue != null &&
                          !_latestValue.isPlaying &&
                          _latestValue.duration == null ||
                      _latestValue.isBuffering
                  ? const Expanded(
                      child: const Center(
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : _buildHitArea(widget.playerIcon),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = ssvVideoPlayerController;
    ssvVideoPlayerController = SsvVideoPlayerController.of(context);
    controller = ssvVideoPlayerController.videoPlayerController;

    if (_oldController != ssvVideoPlayerController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  AnimatedOpacity _buildBottomBar(
    BuildContext context,
  ) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        height: widget.barHeight,
        color: Colors.transparent,
        child: Row(
          children: <Widget>[
            _buildPlayPause(controller),
            ssvVideoPlayerController.isLive
                ? Expanded(child: const Text('LIVE'))
                : _buildPosition(iconColor, 0),
            ssvVideoPlayerController.isLive ? const SizedBox() : _buildProgressBar(),
            _buildPosition(iconColor, 1),
            ssvVideoPlayerController.allowMuting
                ? _buildMuteButton(controller)
                : Container(),
            ssvVideoPlayerController.allowFullScreen
                ? _buildExpandButton()
                : Container(),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          height: widget.barHeight,
          margin: EdgeInsets.only(right: 12.0),
          padding: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              ssvVideoPlayerController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: widget.controlButtonColor,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitArea(Widget playerIcon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 25),
        child: GestureDetector(
          onTap: () {
            if (_latestValue != null && _latestValue.isPlaying) {
              if (_displayTapped) {
                setState(() {
                  _hideStuff = true;
                });
              } else
                _cancelAndRestartTimer();
            } else {
              _playPause();

              setState(() {
                _hideStuff = true;
              });
            }
          },
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: AnimatedOpacity(
                opacity: _latestValue != null &&
                        !_latestValue.isPlaying &&
                        !_dragging
                    ? 1.0
                    : 0.0,
                duration: Duration(milliseconds: 300),
                child: GestureDetector(
                  child: !_latestValue.isPlaying
                      ? widget.playerIcon
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(48.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.pause,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            child: Container(
              height: widget.barHeight,
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Icon(
                (_latestValue != null && _latestValue.volume > 0)
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: widget.controlButtonColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: widget.barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 8.0, right: 4.0),
        padding: EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: widget.controlButtonColor,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor, int startEnd) {
    final position = _latestValue != null && _latestValue.position != null
        ? _latestValue.position
        : Duration.zero;
    final duration = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration
        : Duration.zero;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, startEnd == 0 ? 10 : 0, 0),
      child: Text(
        startEnd == 0
            ? '${formatDuration(position)} '
            : ' ${formatDuration(duration)}',
        style: TextStyle(
            fontSize: widget.timeTextSize, color: widget.controlButtonColor),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
      _displayTapped = true;
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        ssvVideoPlayerController.autoPlay) {
      _startHideTimer();
    }

    if (ssvVideoPlayerController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      ssvVideoPlayerController.toggleFullScreen();
      _showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: MaterialVideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });

            _startHideTimer();
          },
          colors: ssvVideoPlayerController.materialProgressColors ??
              SsvVideoPlayerProgressColors(
                  playedColor: Theme.of(context).accentColor,
                  handleColor: Theme.of(context).accentColor,
                  bufferedColor: Theme.of(context).backgroundColor,
                  backgroundColor: Theme.of(context).disabledColor),
        ),
      ),
    );
  }
}
