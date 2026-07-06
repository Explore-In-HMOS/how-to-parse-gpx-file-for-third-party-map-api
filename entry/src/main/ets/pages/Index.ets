import { MapPage } from './MapPage';
import { RouteListPage } from './RouteListPage';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  _pagesMap(name: string) {
    if (name === 'MapPage') {
      MapPage();
    } else if (name === 'RouteListPage') {
      RouteListPage();
    }
  }

  aboutToAppear(): void {
    this.pageStack.pushPathByName('RouteListPage', null);
  }

  build() {
    Navigation(this.pageStack) {

    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .navDestination(this._pagesMap)
    .hideBackButton(true)
    .ignoreLayoutSafeArea();

  }
}