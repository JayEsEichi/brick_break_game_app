import 'dart:async';
import 'dart:math' as math; // Add this import

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'; // And this import
import 'package:flutter/services.dart';

import 'components/components.dart';
import 'config.dart';

// 게임 상태에 따른 텍스트 지정 Enum 객체
enum PlayState { welcome, playing, gameOver, won }

// 벽돌 부수기 게임 메인 핵심 객체
class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  // HasCollisionDetection : 충돌 감지 믹스인
  BrickBreaker()
    : super( // 상속받은 FlameGame 객체 초기화 (게임 영역 높이와 너비 고정 초기화)
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      );

  // 벽돌 제거 점수
  final ValueNotifier<int> score = ValueNotifier(0);

  //
  final rand = math.Random();

  // 게임 영역 (월드 ?) 너비 값
  double get width => size.x;

  // 게임 영역 (월드 ?) 높이 값
  double get height => size.y;

  // 게임 상태 변수
  late PlayState _playState;

  // 게임 상태 getter
  PlayState get playState => _playState;

  // 게임 상태 setter
  set playState(PlayState playState) {
    // 게임 상태가 변경될 때마다 Enum 변수 변경
    _playState = playState;

    // 변경된 게임 상태 값에 따라
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won: // 게임에서 이겼을 시 게임 이김 상태 값을 오버레이에 추가
        overlays.add(playState.name);
      case PlayState.playing: // 게임 시작 및 진행 중일 경우 나머지 오버레이 되는 게임 상태 값들 제거
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  }

  // 이 BrickBreaker 게임 객체가 로드될 시 일정 동작 수행
  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    //
    camera.viewfinder.anchor = Anchor.topLeft;

    // 게임 월드에 게임 영역 객체 넣기
    world.add(PlayArea());

    // 게임 상태를 welcome 으로 지정
    playState = PlayState.welcome;
  }

  // 게임 시작 함수
  void startGame() {

    // 만약 게임 상태가 게임 실행 중 혹은 게임 진행 중일 경우에는 그냥 return 처리
    if (playState == PlayState.playing) return;

    // 게임이 실행 중이거나 진행 중인 상태가 아니라면 월드에 존재하는 볼, 배트, 벽돌 객체들을 전부 제거
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());

    // 게임 상태를 플레이 중으로 변경
    playState = PlayState.playing;
    // 점수 초기화
    score.value = 0;

    // 게임이 시작되므로 월드에 공 객체를 추가
    world.add(
      Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: size / 2,
        velocity:
            Vector2(
                (rand.nextDouble() - 0.5) * width,
                height * 0.2,
              ).normalized()
              ..scale(height / 4),
      ),
    );

    // 게임이 시작되므로 월드에 배트 객체를 추가
    world.add(
      Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(width / 2, height * 0.95),
      ),
    );

    // 게임이 시작되므로 월드에 벽돌 객체들을 여러 개 추가
    world.addAll([
      // Drop the await
      for (var i = 0; i < brickColors.length; i++)
        for (var j = 1; j <= 5; j++)
          Brick(
            // 벽돌 하나씩 포지션 위치 값 지정
            position: Vector2(
              (i + 0.5) * brickWidth + (i + 1) * brickGutter,
              (j + 2.0) * brickHeight + j * brickGutter,
            ),
            color: brickColors[i],
          ),
    ]);
  } // Drop the debugMode

  // 스크린 Tap 시 게임 시작 함수 실행
  @override
  void onTap() {
    super.onTap();
    startGame();
  }

  // 게임에서 키보드 키 이벤트가 실행되었을 경우 해당 이벤트에 대한 트리거 로직 수행
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);

    // 키보드 키 이벤트일 경우 진입
    switch (event.logicalKey) {
      // 키보드 키 왼쪽 화살표 버튼 클릭일 경우
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
      case LogicalKeyboardKey.arrowRight: // 키보드 키 오른쪽 화살표 버튼 클릭일 경우
        world.children.query<Bat>().first.moveBy(batStep);
      case LogicalKeyboardKey.space: // 키보드 키 스페이스바 버튼 클릭일 경우
      case LogicalKeyboardKey.enter: // 키보드 키 엔터 버튼 클릭일 경우
        startGame(); // 게임을 시작
    }

    // 키 이벤트 핸들링 (키 이벤트가 수행될 경우 해당 키 이벤트를 핸들링 한다. 즉, 어떤 방향 버튼을 클릭하면 해당 버튼에 대한 동작을 핸들링한다.)
    return KeyEventResult.handled;
  }

  // 현 BrickBreaker 객체의 바탕 색상을 지정
  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
