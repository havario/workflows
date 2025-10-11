declare const L: any;

interface Earthquake {
  time: number;
  title: string;
  mag: number;
  lat: number;
  lon: number;
  depth: number;
}

interface ApiResponse {
  earthquakes: Earthquake[];
  error?: string;
}

const map = L.map('map').setView([0, 0], 2);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);

let markers: any[] = [];
let eventList: HTMLElement = document.getElementById('event-list')!;
let updateTime: HTMLElement = document.getElementById('update-time')!;

async function fetchEarthquakes(): Promise<ApiResponse> {
  try {
    const response = await fetch('/api/earthquakes');
    if (!response.ok) throw new Error('API Error');
    return await response.json();
  } catch (error) {
    console.error('Fetch failed:', error);
    return { earthquakes: [], error: (error as Error).message };
  }
}

function updateMapAndList(data: ApiResponse): void {
  markers.forEach(marker => map.removeLayer(marker));
  markers = [];
  eventList.innerHTML = data.error ? `<p class="text-danger">加载失败: ${data.error}</p>` : '';

  if (data.earthquakes.length === 0) {
    eventList.innerHTML = '<p class="text-muted">暂无今日地震数据（min 2.5级）</p>';
    updateTime.textContent = new Date().toLocaleString('zh-CN');
    return;
  }

  data.earthquakes.forEach((eq: Earthquake) => {
    const timeStr = new Date(eq.time).toLocaleString('zh-CN');
    const row = document.createElement('div');
    row.className = 'event-item mb-2 p-2 border-bottom';
    row.innerHTML = `
            <strong>${eq.title}</strong><br>
            <small>时间: ${timeStr} | 震级: ${eq.mag} | 深度: ${eq.depth.toFixed(1)}km</small>
        `;
    eventList.appendChild(row);

    const radius = Math.max(5, eq.mag * 3);
    const color = eq.mag > 6 ? 'red' : eq.mag > 4 ? 'orange' : 'yellow';
    const marker = L.circleMarker([eq.lat, eq.lon], {
      radius: radius,
      fillColor: color,
      color: '#000',
      weight: 1,
      opacity: 1,
      fillOpacity: 0.8
    }).addTo(map);
    marker.bindPopup(`<b>${eq.title}</b><br>震级: ${eq.mag}<br>时间: ${timeStr}<br>深度: ${eq.depth.toFixed(1)}km`);
    markers.push(marker);
  });

  if (data.earthquakes.length > 0) {
    const group = new L.featureGroup(markers);
    map.fitBounds(group.getBounds().pad(0.1));
  }

  updateTime.textContent = `前${data.earthquakes.length}条 | 更新于: ${new Date().toLocaleString('zh-CN')}`;
}

function init(): void {
  updateMapAndList({ earthquakes: [] });
  fetchEarthquakes().then(updateMapAndList);
  setInterval(() => fetchEarthquakes().then(updateMapAndList), 600000);  // 10min
}

init();
