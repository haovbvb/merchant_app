import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/features/login/models/auth_result.dart';
import 'package:merchant_app/features/login/providers/auth_controller.dart';
import 'package:merchant_app/network/network.dart';
import 'package:video_player/video_player.dart';

/// 启动引导页：判断登录态后跳转 Home 或 Login。
class BootstrapPage extends ConsumerStatefulWidget {
  const BootstrapPage({super.key});

  @override
  ConsumerState<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends ConsumerState<BootstrapPage>
    with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  late final AuthNotifier _authNotifier;
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _videoCompleted = false;
  bool _authResolved = false;
  bool _targetAuthenticated = false;
  bool _navigated = false;
  bool _resumeAutoPlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authNotifier = ref.read(authNotifierProvider.notifier);
    _initSplashVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _videoController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _videoCompleted) {
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _resumeAutoPlay = controller.value.isPlaying;
      controller.pause();
      return;
    }
    if (state == AppLifecycleState.resumed && _resumeAutoPlay) {
      _resumeAutoPlay = false;
      controller.play();
    }
  }

  Future<void> _initSplashVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/okla-admin-splash.mp4',
    );
    _videoController = controller;
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller
        ..setLooping(false)
        ..addListener(_onVideoTick);
      setState(() => _videoReady = true);
      controller.play();
    } catch (_) {
      _markVideoCompleted();
    }
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _videoCompleted) {
      return;
    }
    final duration = controller.value.duration;
    final position = controller.value.position;
    if (duration <= Duration.zero) {
      return;
    }
    if (position >= duration - const Duration(milliseconds: 120)) {
      _markVideoCompleted();
    }
  }

  void _markVideoCompleted() {
    if (_videoCompleted) {
      return;
    }
    _videoCompleted = true;
    _tryNavigate();
  }

  Future<void> _bootstrap() async {
    try {
      final token = await _authNotifier.loadTokenFromStorage();
      if (!mounted) {
        return;
      }

      if (token != null && token.isNotEmpty) {
        _authNotifier.setToken(token);
        _targetAuthenticated = await _refreshToken();
      } else {
        await _authNotifier.clearSession();
        _targetAuthenticated = false;
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      await _authNotifier.clearSession();
      _targetAuthenticated = false;
    } finally {
      _authResolved = true;
      _tryNavigate();
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final response = await _apiService.post<AuthResult>(
        ApiPath.refreshToken,
        parser: _parseAuthResult,
        showHud: false,
        notifyOnError: false,
        toastOnBusinessError: false,
      );

      if (response.isSuccess && response.result != null) {
        await _authNotifier.updateSession(response.result!);
        return true;
      } else {
        await _authNotifier.clearSession();
        return false;
      }
    } catch (_) {
      await _authNotifier.clearSession();
      return false;
    }
  }

  void _tryNavigate() {
    if (!mounted || _navigated || !_videoCompleted || !_authResolved) {
      return;
    }
    _navigated = true;
    if (_targetAuthenticated) {
      AppRouter.goHome();
    } else {
      AppRouter.goLogin();
    }
  }

  AuthResult _parseAuthResult(dynamic data) {
    if (data is Map<String, dynamic>) {
      return AuthResult.fromJson(data);
    }
    if (data is Map) {
      return AuthResult.fromJson(Map<String, dynamic>.from(data));
    }
    throw NetworkExceptions('响应格式错误!!!');
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    final canRenderVideo =
        _videoReady && controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: !canRenderVideo
            ? const SizedBox.expand()
            : SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
      ),
    );
  }
}
