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
const isChina = navigator.language.startsWith('zh');
const tileUrl = isChina
  ? 'http://webst0{1-4}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}'
  : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
const attribution = isChina ? '&copy; 高德地图 & OpenStreetMap contributors' : '&copy; OpenStreetMap contributors';
L.tileLayer(tileUrl, { attribution }).addTo(map);

let markers: any[] = [];
const eventList: HTMLElement = document.getElementById('event-list')!;
const eventCount: HTMLElement = document.getElementById('event-count')!;
const updateTime: HTMLElement = document.getElementById('update-time')!;

async function fetchEarthquakes(): Promise<ApiResponse> {
  try {
    const url = `/api/earthquakes?timestamp=${new Date().getTime()}`;
    const response = await fetch(url);
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

  if (data.earthquakes.length === 0 && !data.error) {
    eventList.innerHTML = '<p class="text-muted">过去24小时内无地震数据（min 2.5级）</p>';
    eventCount.textContent = '0';
    updateTime.textContent = new Date().toLocaleString();
    return;
  }

  eventList.innerHTML = '';

  data.earthquakes.forEach((eq: Earthquake) => {
    const timeStr = new Date(eq.time).toLocaleString();
    const row = document.createElement('div');
    row.className = 'event-item';
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

  eventCount.textContent = data.earthquakes.length.toString();
  updateTime.textContent = new Date().toLocaleString();
}

const themeSwitcher = document.getElementById('theme-switcher')!;
const themeIcon = document.getElementById('theme-icon')!;
const themeText = document.getElementById('theme-text')!;
const themeOptions = document.querySelectorAll('[data-theme-value]');

const themeMap: { [key: string]: { icon: string; text: string } } = {
  light: { icon: 'bi-sun-fill', text: '浅色' },
  dark: { icon: 'bi-moon-stars-fill', text: '深色' },
  auto: { icon: 'bi-circle-half', text: '系统' }
};

const getSystemTheme = (): 'light' | 'dark' => {
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
};

const applyTheme = (theme: 'light' | 'dark'): void => {
  document.body.setAttribute('data-theme', theme);
};

const updateThemeUI = (theme: string): void => {
  const { icon, text } = themeMap[theme];
  themeIcon.className = `bi ${icon}`;
  themeText.textContent = text;
};

const handleThemeChange = (theme: string): void => {
  if (theme === 'auto') {
    applyTheme(getSystemTheme());
    localStorage.removeItem('theme');
  } else {
    applyTheme(theme as 'light' | 'dark');
    localStorage.setItem('theme', theme);
  }
  updateThemeUI(theme);
};

const initializeTheme = (): void => {
  const savedTheme = localStorage.getItem('theme');
  if (savedTheme) {
    handleThemeChange(savedTheme);
  } else {
    handleThemeChange('auto');
  }
};

themeOptions.forEach(option => {
  option.addEventListener('click', () => {
    const themeValue = option.getAttribute('data-theme-value');
    if (themeValue) {
      handleThemeChange(themeValue);
    }
  });
});

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
  const currentTheme = localStorage.getItem('theme');
  if (!currentTheme || currentTheme === 'auto') {
    handleThemeChange('auto');
  }
});

function init(): void {
  eventList.innerHTML = '<p class="text-muted">正在加载数据...</p>';
  fetchEarthquakes().then(updateMapAndList);
  initializeTheme();

  setInterval(() => {
    fetchEarthquakes().then(updateMapAndList);
  }, 120000);
}

init();
