import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

// 게임 영역 컴포넌트
class PlayArea extends RectangleComponent with HasGameReference<BrickBreaker> {
  // 게임 영역 컴포넌트 생성자 초기화
  PlayArea()
    : super(
        paint: Paint()..color = const Color(0xfff2e8cf),
        children: [RectangleHitbox()],
      ); // RectangleComponent (사각형 컴포넌트) 초기화

  // 게임 영역 로드 시 크기를 벡터값으로 지정
  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // 게임 영역 크기 지정
    size = Vector2(game.width, game.height);
  }
}
