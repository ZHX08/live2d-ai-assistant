import 'package:just_audio/just_audio.dart';

class AppAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Future<void> play(String filePath) async {
    _isPlaying = true;
    await _player.setFilePath(filePath);
    await _player.play();
    _isPlaying = false;
  }

  Future<void> pause() => _player.pause();
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Duration? get duration => _player.duration;
  void dispose() => _player.dispose();
}
