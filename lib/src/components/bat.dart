import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

// 배트 컴포넌트
class Bat extends PositionComponent
    with DragCallbacks, HasGameReference<BrickBreaker> {

  // 배트 생성자 (배트 코너 쪽 radius 스타일 값, 위치 값, 크기 값)
  Bat({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center, children: [RectangleHitbox()]); // PositionComponent (포지션 동적 컴포넌트) 부모 생성장 초기화

  // 배트 코너 쪽 radius 스타일 값 필드 변수
  final Radius cornerRadius;

  // 색상 및 스타일 페인팅 필드 변수
  final _paint =
      Paint()
        ..color = const Color(0xff1e6091)
        ..style = PaintingStyle.fill;

  // 배트 캔버스 렌더링 (배트 화면에 그리기)
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 캔버스에 색상 및 스타일 페이팅 적용, 그리기
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size.toSize(), cornerRadius),
      _paint,
    );
  }

  // 배트 드래그 동적 이동 시 위치 수정 처리
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    // 배트 객체가 드래그 이동 수행시 그에 따라 포지션 위치 값을 변동
    position.x = (position.x + event.localDelta.x).clamp(0, game.width);
  }

  // 배트 이동 시 이펙트 수행
  void moveBy(double dx) {
    add(
      MoveToEffect(
        Vector2((position.x + dx).clamp(0, game.width), position.y),
        EffectController(duration: 0.1),
      ),
    );
  }
}
