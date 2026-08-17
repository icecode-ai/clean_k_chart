import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

class InfoWindowEntity {
  KLineEntity kLineEntity;
  bool isLeft;

  InfoWindowEntity(this.kLineEntity, {this.isLeft = false});
}
