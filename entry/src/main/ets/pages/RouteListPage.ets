import { GpxRoute, RouteItem } from '../model/RouteModels';
import { GpxParser } from '../util/GpxParser';
import { RouteCard } from '../component/RouteCard';

@Entry
@Component
export struct RouteListPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State routes: RouteItem[] = [];
  private gpxFiles: string[] = [
    'testroute.gpx',
    'sea-side.gpx'
  ];

  aboutToAppear(): void {
    this.loadRoutes();
  }

  async loadRoutes(): Promise<void> {
    const ctx = this.getUIContext().getHostContext() as Context;
    const items: RouteItem[] = [];

    for (const file of this.gpxFiles) {
      try {
        const route = await GpxParser.parseFromRawfile(ctx, file);
        if (route.points.length > 0) {
          items.push({
            fileName: file,
            name: route.name || file,
            description: route.description,
            distanceKm: this.calcDistance(route),
            elevationGain: this.calcAscent(route),
            pointCount: route.points.length
          });
        }
      } catch (e) {
        console.error('[RouteList] didn\'t load:', file, (e as Error).message);
      }
    }

    this.routes = items;
  }

  private calcDistance(route: GpxRoute): number {
    let total = 0;
    const R = 6371000;
    for (let i = 1; i < route.points.length; i++) {
      const a = route.points[i - 1];
      const b = route.points[i];
      const dLat = (b.lat - a.lat) * Math.PI / 180;
      const dLon = (b.lon - a.lon) * Math.PI / 180;
      const x = Math.sin(dLat / 2)**2 +
        Math.cos(a.lat * Math.PI / 180) * Math.cos(b.lat * Math.PI / 180) *
          Math.sin(dLon / 2)**2;
      total += R * 2 * Math.atan2(Math.sqrt(x), Math.sqrt(1 - x));
    }
    return total / 1000;
  }

  private calcAscent(route: GpxRoute): number {
    let asc = 0;
    for (let i = 1; i < route.points.length; i++) {
      let de: number = 0;
      if (route.points[i].ele !== undefined && route.points[i - 1].ele !== undefined) {
        de = route.points[i].ele! - route.points[i - 1].ele!;
      }
      if (de > 0) {
        asc += de;
      }
    }
    return asc;
  }

  build() {
    NavDestination() {
      Column() {
        Text('Routes')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ top: 16, bottom: 12 })
          .backgroundColor(Color.Blue);

        if (this.routes.length === 0) {
          Text('Route not found')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .width('100%')
            .layoutWeight(1)
            .textAlign(TextAlign.Center);
        } else {
          List({ space: 8 }) {
            ForEach(this.routes, (item: RouteItem) => {
              ListItem() {
                RouteCard({
                  item: item,
                  onCardClick: () => {
                    console.info('[RouteList] open:', item.fileName);
                    this.pageStack.pushPathByName('MapPage', item.fileName);
                  }
                });
              };
            }, (item: RouteItem) => item.fileName);
          }
          .width('100%')
          .layoutWeight(1)
          .padding({
            left: 12,
            right: 12,
            top: 8,
            bottom: 8
          });
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .hideTitleBar(true);
  }
}