import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';

// 벽돌 컴포넌트
class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {

  // 벽돌 생성자 (위치값, 색상)
  Brick({required super.position, required Color color})
    : super( // RectangleComponent (사각형 컴포넌트) 부모 생성자 초기화
        size: Vector2(brickWidth, brickHeight),
        anchor: Anchor.center,
        paint:
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
        children: [RectangleHitbox()],
      );

  // CollisionCallbacks 믹스인을 첨가해 벽돌에 충돌이 발생 시 수행하는 로직
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {

    // CollisionCallbacks 부모 믹스인에 정보를 전달하여 부모 초기화
    super.onCollisionStart(intersectionPoints, other);
    // 벽돌이 공에 충돌 시 부모 RectangleComponent 컴포넌트 객체에서도 해당 벽돌을 제거 처리
    removeFromParent();
    // 벽돌이 공에 충돌 시 스코어 추가 + 1
    game.score.value++;

    // 만약 벽돌이 충돌 후 갯수가 1일 경우 로직 수행
    if (game.world.children.query<Brick>().length == 1) {
      // 게임 상태를 이긴 것으로 처리
      game.playState = PlayState.won;

      // 월드에 생성된 공 객체들 전부 제거
      game.world.removeAll(game.world.children.query<Ball>());

      // 월드에 생성된 배트 객체 전부 제거
      game.world.removeAll(game.world.children.query<Bat>());
    }
  }
}
