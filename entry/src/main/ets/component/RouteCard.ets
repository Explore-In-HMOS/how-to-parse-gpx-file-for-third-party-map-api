import { RouteItem } from '../model/RouteModels';

@Component
export struct RouteCard {
  item: RouteItem = {
    fileName: '',
    name: '',
    description: '',
    distanceKm: 0,
    elevationGain: 0,
    pointCount: 0
  };
  onCardClick?: () => void;

  build() {
    Column({ space: 4 }) {
      Text(this.item.name)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1a1a1a')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.item.description) {
        Text(this.item.description)
          .fontSize(11)
          .fontColor('#888')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      Row({ space: 12 }) {
        this.statBadge(`${this.item.distanceKm.toFixed(1)} km`)
        this.statBadge(`+${Math.round(this.item.elevationGain)}m`)
        this.statBadge(`${this.item.pointCount} points`)
      }
      .margin({ top: 6 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor('#fff')
    .borderRadius(10)
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }

  @Builder
  statBadge(text: string) {
    Text(text)
      .fontSize(10)
      .fontColor('#1D9E75')
      .backgroundColor('#E8F5EF')
      .borderRadius(4)
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
  }
}