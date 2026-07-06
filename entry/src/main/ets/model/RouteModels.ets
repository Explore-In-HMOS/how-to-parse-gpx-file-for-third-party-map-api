export interface RouteItem {
  fileName: string;
  name: string;
  description: string;
  distanceKm: number;
  elevationGain: number;
  pointCount: number;
}

export interface GpxPoint {
  lat: number;
  lon: number;
  ele?: number;
  time?: number;
}

export interface GpxRoute {
  name: string;
  description: string;
  points: GpxPoint[];
}