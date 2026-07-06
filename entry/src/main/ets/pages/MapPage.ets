import webview from '@ohos.web.webview';
import { BusinessError } from '@kit.BasicServicesKit';
import { GpxParser } from '../util/GpxParser';
import { GpxPoint } from '../model/RouteModels';

@Component
export struct MapPage {
  controller: webview.WebviewController = new webview.WebviewController();
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State isTracking: boolean = false;
  @State currentIdx: number = 0;
  @State gpxPoints: GpxPoint[] = [];
  @State isWebReady: boolean = false;
  @State isGpxLoaded: boolean = false;
  private timerId: number = -1;
  private gpxFile: string = '';

  async loadGpx(): Promise<void> {
    if (!this.gpxFile) {
      console.error('[MapPage] gpxFile is empty');
      return;
    }
    try {
      const ctx = this.getUIContext().getHostContext() as Context;
      const route = await GpxParser.parseFromRawfile(ctx, this.gpxFile);
      this.gpxPoints = route.points;
      this.isGpxLoaded = true;
      console.info(`[MapPage] ${this.gpxFile}: ${route.points.length} points loaded`);
      this.tryLoadRoute();
    } catch (e) {
      console.error('[MapPage] GPX couldn\'t load:', (e as Error).message);
    }
  }

  tryLoadRoute(): void {
    if (this.isWebReady && this.isGpxLoaded && this.gpxPoints.length > 0) {
      this.loadRoute();
    }
  }

  loadRoute(): void {
    const json = JSON.stringify(this.gpxPoints);
    this.controller.runJavaScript(`loadRoute(${json})`)
      .catch((err: BusinessError) => {
        console.error('[MapPage] loadRoute:', err.message);
      });
  }

  setProgress(idx: number): void {
    this.controller.runJavaScript(`setProgress(${idx})`)
      .catch((err: BusinessError) => {
        console.error('[MapPage] setProgress:', err.message);
      });
  }

  startTracking(): void {
    if (this.gpxPoints.length === 0) {
      return;
    }
    if (this.currentIdx >= this.gpxPoints.length - 1) {
      this.currentIdx = 0;
      this.setProgress(0);
    }
    this.isTracking = true;
    this.timerId = setInterval(() => {
      if (this.currentIdx >= this.gpxPoints.length - 1) {
        this.stopTracking();
        return;
      }
      this.currentIdx++;
      this.setProgress(this.currentIdx);
    }, 1000);
  }

  stopTracking(): void {
    this.isTracking = false;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  resetTracking(): void {
    this.stopTracking();
    this.currentIdx = 0;
    this.setProgress(0);
  }

  build() {
    NavDestination() {
      Stack() {
        Web({ src: $rawfile('map.html'), controller: this.controller })
          .width('100%')
          .height('100%')
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .onPageBegin((event) => {
            console.info('[MAP] onPageBegin:', event?.url);
          })
          .onPageEnd((event) => {
            console.info('[MAP] onPageEnd:', event?.url);
            this.isWebReady = true;
            this.tryLoadRoute();
          })
          .onErrorReceive((event) => {
            console.error('[MAP] onErrorReceive:', event?.error?.getErrorInfo(),
              event?.request?.getRequestUrl());
          })
          .onHttpErrorReceive((event) => {
            console.info('[MAP] onHttpErrorReceive:', event?.response?.getResponseCode(),
              event?.request?.getRequestUrl());
          });

        Row({ space: 10 }) {
          Button(this.isTracking ? 'Stop' : 'Start')
            .width(110)
            .height(44)
            .backgroundColor(this.isTracking ? '#D85A30' : '#1D9E75')
            .fontColor(Color.White)
            .fontSize(15)
            .onClick(() => {
              if (this.isTracking) {
                this.stopTracking();
              } else {
                this.startTracking();
              }
            });

          Button('Reset')
            .width(110)
            .height(36)
            .backgroundColor('#fff')
            .fontColor('#333')
            .fontSize(13)
            .borderWidth(1)
            .borderColor('#ccc')
            .onClick(() => {
              this.resetTracking();
            });
        }
        .margin({ right: 16, top: 110 });
      }
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      const params = ctx.pathInfo?.param as string;
      if (params) {
        this.gpxFile = params;
        this.loadGpx();
      } else {
        console.error('[MapPage] gpxFile parameter not found');
      }
    });
  }
}