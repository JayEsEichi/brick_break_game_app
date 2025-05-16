import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart';
import 'play_area.dart';

// 볼 컴포넌트
class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  // 볼 생성자 초기화 (속도값, 위치값, 모서리 스타일값, 수정되는 어려움 난이도 값)
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
         radius: radius,
         anchor: Anchor.center,
         paint:
             Paint()..color = const Color(0xff1e6091)..style = PaintingStyle.fill,
         children: [CircleHitbox()],
       ); // CircleComponent (원형 컴포넌트) 생성자 초기화

  // 속도값
  final Vector2 velocity;
  // 수정되는 어려움 난이도 값
  final double difficultyModifier;

  // 볼 상태 업데이트
  @override
  void update(double dt) {
    super.update(dt);

    // 볼 상태가 업데이트 될 때 마다 속도값을 활용하여 위치값 수정
    position += velocity * dt;
  }

  // 볼에 충돌이 발생 시 수행되는 로직
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // 충돌이 발생된 동적 포지션 컴포넌트의 게임 영역 컴포넌트일 경우
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        add(RemoveEffect(delay: 0.35, onComplete: () {
          game.playState = PlayState.gameOver;
        }));
      }

    } else if (other is Bat) { // 충돌이 발생된 동적 포지션 컴포넌트의 배트 컴포넌트일 경우
      velocity.y = -velocity.y;
      velocity.x =
          velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;

    } else if (other is Brick) { // 충돌이 발생된 동적 포지션 컴포넌트의 벽돌 컴포넌트일 경우
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}
