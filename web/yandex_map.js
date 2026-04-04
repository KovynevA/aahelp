(function () {
  const DEFAULT_LOCATION = {
    center: [37.618737, 55.751453],
    zoom: 10.5,
  };
  const DEFAULT_BEHAVIORS = ['drag', 'scrollZoom', 'pinchZoom', 'dblClick'];
  const instances = new Map();
  let apiPromise = null;
  let clustererPromise = null;

  function normalizeApiKey(apiKey) {
    if (typeof apiKey !== 'string') {
      return '';
    }

    const trimmed = apiKey.trim();
    if (
      (trimmed.startsWith("'") && trimmed.endsWith("'")) ||
      (trimmed.startsWith('"') && trimmed.endsWith('"'))
    ) {
      return trimmed.slice(1, -1).trim();
    }

    return trimmed;
  }

  function warnIfLikelyInvalidReferer() {
    if (window.location.protocol === 'file:') {
      console.warn(
        'Yandex Maps JS API requires an HTTP Referer-restricted key. ' +
          'Opening the app from file:// can lead to empty tiles or a blank grid.'
      );
    }
  }

  function createMarkerLabel(text) {
    const label = document.createElement('div');
    label.textContent = text;
    label.style.maxWidth = '120px';
    label.style.padding = '4px 8px';
    label.style.borderRadius = '10px';
    label.style.background = 'rgba(255, 255, 255, 0.94)';
    label.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.18)';
    label.style.fontSize = '12px';
    label.style.lineHeight = '1.2';
    label.style.textAlign = 'center';
    label.style.color = '#111827';
    label.style.whiteSpace = 'normal';
    return label;
  }

  function createPin(color) {
    const pin = document.createElement('div');
    pin.style.width = '18px';
    pin.style.height = '18px';
    pin.style.borderRadius = '999px';
    pin.style.background = color;
    pin.style.border = '3px solid white';
    pin.style.boxShadow = '0 3px 12px rgba(0, 0, 0, 0.28)';
    return pin;
  }

  function createMarkerElement(group, onTap) {
    const wrapper = document.createElement('button');
    wrapper.type = 'button';
    wrapper.style.display = 'flex';
    wrapper.style.flexDirection = 'column';
    wrapper.style.alignItems = 'center';
    wrapper.style.gap = '6px';
    wrapper.style.background = 'transparent';
    wrapper.style.border = '0';
    wrapper.style.padding = '0';
    wrapper.style.cursor = 'pointer';

    wrapper.appendChild(createMarkerLabel(group.name));
    wrapper.appendChild(createPin('#dc2626'));
    wrapper.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopPropagation();
      onTap();
    });
    return wrapper;
  }

  function createUserMarkerElement() {
    const wrapper = document.createElement('div');
    wrapper.style.display = 'flex';
    wrapper.style.flexDirection = 'column';
    wrapper.style.alignItems = 'center';
    wrapper.style.gap = '6px';

    const label = createMarkerLabel('Вы здесь');
    const pin = createPin('#2563eb');
    wrapper.appendChild(label);
    wrapper.appendChild(pin);
    return wrapper;
  }

  function createClusterElement(size, onTap) {
    const wrapper = document.createElement('button');
    wrapper.type = 'button';
    wrapper.textContent = String(size);
    wrapper.style.width = '44px';
    wrapper.style.height = '44px';
    wrapper.style.borderRadius = '999px';
    wrapper.style.border = '3px solid white';
    wrapper.style.background = '#2563eb';
    wrapper.style.color = 'white';
    wrapper.style.fontWeight = '700';
    wrapper.style.boxShadow = '0 4px 14px rgba(0, 0, 0, 0.24)';
    wrapper.style.cursor = 'pointer';
    wrapper.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopPropagation();
      onTap();
    });
    return wrapper;
  }

  function dispatchGroupTap(container, groupId) {
    container.dispatchEvent(
      new CustomEvent('aahelp-group-tap', {
        detail: groupId,
      })
    );
  }

  function clearMapObjects(instance) {
    if (instance.clusterer) {
      instance.map.removeChild(instance.clusterer);
      instance.clusterer = null;
    }
    instance.markers.forEach(function (marker) {
      instance.map.removeChild(marker);
    });
    instance.markers = [];

    if (instance.userMarker) {
      instance.map.removeChild(instance.userMarker);
      instance.userMarker = null;
    }
  }

  function ensureApi(apiKey) {
    const normalizedApiKey = normalizeApiKey(apiKey);
    if (!normalizedApiKey) {
      return Promise.reject(new Error('Yandex Maps API key is empty'));
    }

    if (apiPromise) {
      return apiPromise;
    }

    warnIfLikelyInvalidReferer();

    apiPromise = new Promise(function (resolve, reject) {
      if (window.ymaps3) {
        resolve(window.ymaps3);
        return;
      }

      const script = document.createElement('script');
      script.src =
        'https://api-maps.yandex.ru/v3/?apikey=' +
        encodeURIComponent(normalizedApiKey) +
        '&lang=ru_RU';
      script.type = 'text/javascript';
      script.async = true;
      script.onload = function () {
        resolve(window.ymaps3);
      };
      script.onerror = function () {
        reject(new Error('Failed to load Yandex Maps JavaScript API'));
      };
      document.head.appendChild(script);
    }).then(async function (ymaps3) {
      await ymaps3.ready;
      if (ymaps3.import && ymaps3.import.registerCdn) {
        ymaps3.import.registerCdn('https://cdn.jsdelivr.net/npm/{package}', [
          '@yandex/ymaps3-clusterer@0.0',
        ]);
      }
      return ymaps3;
    });

    return apiPromise;
  }

  async function ensureClusterer() {
    if (!clustererPromise) {
      clustererPromise = window.ymaps3.import('@yandex/ymaps3-clusterer');
    }
    return clustererPromise;
  }

  async function renderState(instance, state) {
    clearMapObjects(instance);

    const ymaps3 = instance.ymaps3;
    const YMapMarker = ymaps3.YMapMarker;
    const container = instance.container;
    const markerSource = instance.markerSource;
    const groups = Array.isArray(state.groups) ? state.groups : [];

    if (state.clustered && groups.length > 0) {
      const clustererModule = await ensureClusterer();
      const YMapClusterer = clustererModule.YMapClusterer;
      const clusterByGrid = clustererModule.clusterByGrid;
      const features = groups.map(function (group) {
        return {
          type: 'Feature',
          id: group.id,
          geometry: {
            type: 'Point',
            coordinates: [group.longitude, group.latitude],
          },
          properties: {
            group: group,
          },
        };
      });

      instance.clusterer = new YMapClusterer({
        method: clusterByGrid({gridSize: 64}),
        features: features,
        marker: function (feature) {
          const group = feature.properties.group;
          return new YMapMarker(
            {
              coordinates: feature.geometry.coordinates,
              source: markerSource,
            },
            createMarkerElement(group, function () {
              dispatchGroupTap(container, group.id);
            })
          );
        },
        cluster: function (coordinates, clusterFeatures) {
          return new YMapMarker(
            {
              coordinates: coordinates,
              source: markerSource,
            },
            createClusterElement(clusterFeatures.length, function () {
              const nextZoom = Math.min(21, (instance.zoom || DEFAULT_LOCATION.zoom) + 2);
              instance.zoom = nextZoom;
              instance.map.update({
                location: {
                  center: coordinates,
                  zoom: nextZoom,
                  duration: 300,
                },
              });
            })
          );
        },
      });

      instance.map.addChild(instance.clusterer);
    } else {
      instance.markers = groups.map(function (group) {
        const marker = new YMapMarker(
          {
            coordinates: [group.longitude, group.latitude],
            source: markerSource,
          },
          createMarkerElement(group, function () {
            dispatchGroupTap(container, group.id);
          })
        );
        instance.map.addChild(marker);
        return marker;
      });
    }

    if (state.currentPosition) {
      instance.userMarker = new YMapMarker(
        {
          coordinates: [
            state.currentPosition.longitude,
            state.currentPosition.latitude,
          ],
          source: markerSource,
        },
        createUserMarkerElement()
      );
      instance.map.addChild(instance.userMarker);
    }
  }

  async function create(containerId, apiKey, initialStateJson) {
    const normalizedApiKey = normalizeApiKey(apiKey);
    if (!normalizedApiKey) {
      return false;
    }

    await ensureApi(normalizedApiKey);
    const container = document.getElementById(containerId);
    if (!container) {
      return false;
    }

    const YMap = window.ymaps3.YMap;
    const YMapDefaultSchemeLayer = window.ymaps3.YMapDefaultSchemeLayer;
    const YMapFeatureDataSource = window.ymaps3.YMapFeatureDataSource;
    const YMapLayer = window.ymaps3.YMapLayer;
    const markerSource = containerId + '-markers';

    const map = new YMap(container, {
      location: DEFAULT_LOCATION,
      mode: 'raster',
      behaviors: DEFAULT_BEHAVIORS,
    });
    map.addChild(new YMapDefaultSchemeLayer({theme: 'light'}));
    map.addChild(new YMapFeatureDataSource({id: markerSource}));
    map.addChild(
      new YMapLayer({
        source: markerSource,
        type: 'markers',
        zIndex: 1800,
      })
    );

    const instance = {
      ymaps3: window.ymaps3,
      map: map,
      container: container,
      markerSource: markerSource,
      markers: [],
      clusterer: null,
      userMarker: null,
      zoom: DEFAULT_LOCATION.zoom,
    };

    const initialState = initialStateJson ? JSON.parse(initialStateJson) : {};
    instances.set(containerId, instance);
    await renderState(instance, initialState);
    return true;
  }

  async function update(containerId, nextStateJson) {
    const instance = instances.get(containerId);
    if (!instance) {
      return;
    }

    const nextState = nextStateJson ? JSON.parse(nextStateJson) : {};
    await renderState(instance, nextState);
  }

  async function focus(containerId, longitude, latitude, zoom) {
    const instance = instances.get(containerId);
    if (!instance) {
      return;
    }

    instance.zoom = zoom;
    instance.map.update({
      location: {
        center: [longitude, latitude],
        zoom: zoom,
        duration: 300,
      },
    });
  }

  function destroy(containerId) {
    const instance = instances.get(containerId);
    if (!instance) {
      return;
    }

    clearMapObjects(instance);
    if (typeof instance.map.destroy === 'function') {
      instance.map.destroy();
    }
    instances.delete(containerId);
  }

  window.aahelpYandexMaps = {
    create: create,
    update: update,
    focus: focus,
    destroy: destroy,
  };
})();
