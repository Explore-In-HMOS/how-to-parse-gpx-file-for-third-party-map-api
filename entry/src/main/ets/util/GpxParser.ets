import { xml, util } from '@kit.ArkTS';
import { GpxPoint, GpxRoute } from '../model/RouteModels';

export class GpxParser {
  static parse(gpxString: string): GpxRoute {
    const route: GpxRoute = {
      name: '',
      description: '',
      points: []
    };

    try {
      const textEncoder = new util.TextEncoder();
      const uint8 = textEncoder.encodeInto(gpxString);
      const parser = new xml.XmlPullParser(uint8.buffer as object as ArrayBuffer, 'utf-8');

      let inTrk = false;
      let inTrkpt = false;
      let inMetadata = false;
      let currentTag = '';
      let lastEndedTag = '';

      let pending: GpxPoint = { lat: 0, lon: 0 };

      const tokenCb = (eventType: xml.EventType, info: xml.ParseInfo): boolean => {
        if (eventType === xml.EventType.START_TAG) {
          const name = info.getName();
          currentTag = name;

          if (name === 'trk') {
            inTrk = true;
          } else if (name === 'metadata') {
            inMetadata = true;
          } else if (name === 'trkpt') {
            inTrkpt = true;
            pending = { lat: 0, lon: 0 };
          }
        } else if (eventType === xml.EventType.END_TAG) {
          const name = info.getName();
          lastEndedTag = name;

          if (name === 'trkpt' && inTrkpt) {
            route.points.push(pending);
            inTrkpt = false;
          } else if (name === 'trk') {
            inTrk = false;
          } else if (name === 'metadata') {
            inMetadata = false;
          }

          currentTag = '';
        } else if (eventType === xml.EventType.TEXT) {
          const text = info.getText().trim();
          if (text.length === 0) {
            return true;
          }

          if (inTrkpt) {
            if (currentTag === 'ele') {
              const v = parseFloat(text);
              if (!isNaN(v)) {
                pending.ele = v;
              }
            } else if (currentTag === 'time') {
              const t = Date.parse(text);
              if (!isNaN(t)) {
                pending.time = t;
              }
            }
          } else if (currentTag === 'name') {
            if (!route.name) {
              route.name = text;
            }
          } else if (currentTag === 'desc') {
            if (!route.description) {
              route.description = text;
            }
          }
        }
        return true;
      };

      const attrWithTagCb: xml.AttributeWithTagCb =
        (tagName: string, key: string, value: string): boolean => {
          if (tagName === 'trkpt' && inTrkpt) {
            if (key === 'lat') {
              const v = parseFloat(value);
              if (!isNaN(v)) {
                pending.lat = v;
              }
            } else if (key === 'lon') {
              const v = parseFloat(value);
              if (!isNaN(v)) {
                pending.lon = v;
              }
            }
          }
          return true;
        };

      const options: xml.ParseOptions = {
        supportDoctype: true,
        ignoreNameSpace: true,
        tokenValueCallbackFunction: tokenCb,
        attributeWithTagCallbackFunction: attrWithTagCb
      };

      parser.parseXml(options);
    } catch (e) {
      console.error('[GpxParser] parse error:', (e as Error).message);
    }

    return route;
  }

  static async parseFromRawfile(
    context: Context,
    fileName: string
  ): Promise<GpxRoute> {
    const rm = context.resourceManager;
    const data: Uint8Array = await rm.getRawFileContent(fileName);
    const decoder = util.TextDecoder.create('utf-8');
    const text = decoder.decodeToString(data);
    return GpxParser.parse(text);
  }
}