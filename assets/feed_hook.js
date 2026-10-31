(function () {
  if (window.__feedHookInstalled) return;
  window.__feedHookInstalled = true;

  var FEED_KEY = 'xdt_api__v1__feed__timeline__connection';
  var BRIDGE = 'flutter_inappwebview';

  // callHandler comes from the plugin's own document-start script; platform-ready
  // fires only at full page load, so it is just the fallback.
  var queue = [];
  var bridgeReady = !!(window[BRIDGE] && typeof window[BRIDGE].callHandler === 'function');

  function send(message) {
    if (!bridgeReady) {
      queue.push(message);
      return;
    }
    window[BRIDGE].callHandler('feedHook', message);
  }

  function flushQueue() {
    bridgeReady = true;
    while (queue.length) send(queue.shift());
  }

  if (window[BRIDGE] && window[BRIDGE]._platformReady) {
    flushQueue();
  } else {
    window.addEventListener('flutterInAppWebViewPlatformReady', flushQueue, { once: true });
  }

  function isNative(fn) {
    return /\[native code\]/.test(Function.prototype.toString.call(fn));
  }

  send({
    type: 'hookInstalled',
    url: location.href,
    readyState: document.readyState,
    visibilityState: document.visibilityState,
    scriptsInDom: document.getElementsByTagName('script').length,
    fetchWasNative: isNative(window.fetch),
    xhrOpenWasNative: isNative(XMLHttpRequest.prototype.open),
    userAgent: navigator.userAgent,
    uaBrands: navigator.userAgentData
      ? navigator.userAgentData.brands.map(function (b) { return b.brand + ' ' + b.version; })
      : null,
  });

  function isGraphql(url) {
    return typeof url === 'string' && url.indexOf('/graphql') !== -1;
  }

  function friendlyName(body) {
    var match = typeof body === 'string' && body.match(/fb_api_req_friendly_name=([^&]+)/);
    return match ? decodeURIComponent(match[1]) : null;
  }

  function onResponse(via, url, requestBody, text) {
    report(via, url, text);
    if (friendlyName(requestBody) === 'IGDBadgeCountOffMsysQuery') send({ type: 'inboxBadge', body: text });
  }

  function report(via, url, text) {
    var hasFeed = typeof text === 'string' && text.indexOf(FEED_KEY) !== -1;
    send({
      type: 'graphql',
      via: via,
      url: url,
      length: typeof text === 'string' ? text.length : 0,
      body: hasFeed ? text : null,
    });
  }

  var originalFetch = window.fetch;
  window.fetch = function (input, init) {
    var url = (input && input.url) || String(input);
    var promise = originalFetch.apply(this, arguments);
    if (isGraphql(url)) {
      send({ type: 'graphqlStart', via: 'fetch' });
      var requestBody = init && init.body;
      promise.then(function (response) {
        response.clone().text().then(function (text) { onResponse('fetch', url, requestBody, text); }, function () {});
      }, function () {});
    }
    return promise;
  };

  var originalOpen = XMLHttpRequest.prototype.open;
  var originalSend = XMLHttpRequest.prototype.send;

  XMLHttpRequest.prototype.open = function (method, url) {
    this.__feedHookUrl = String(url);
    return originalOpen.apply(this, arguments);
  };

  XMLHttpRequest.prototype.send = function (body) {
    var xhr = this;
    if (isGraphql(xhr.__feedHookUrl)) {
      send({ type: 'graphqlStart', via: 'xhr' });
      xhr.addEventListener('load', function () {
        var text = null;
        if (xhr.responseType === '' || xhr.responseType === 'text') {
          text = xhr.responseText;
        } else if (xhr.responseType === 'json') {
          text = JSON.stringify(xhr.response);
        } else if (xhr.responseType === 'arraybuffer' && xhr.response) {
          text = new TextDecoder().decode(xhr.response);
        }
        onResponse('xhr', xhr.__feedHookUrl, body, text);
      });
    }
    return originalSend.apply(this, arguments);
  };

  var scannedScripts = new WeakSet();

  function scanInlineScripts(phase) {
    var scripts = document.querySelectorAll('script[type="application/json"]');
    var bodies = [];
    for (var i = 0; i < scripts.length; i++) {
      if (scannedScripts.has(scripts[i])) continue;
      scannedScripts.add(scripts[i]);
      var text = scripts[i].textContent;
      if (text && text.indexOf(FEED_KEY) !== -1) bodies.push(text);
    }
    send({ type: 'inline', phase: phase, scriptCount: scripts.length, bodies: bodies });
  }

  document.addEventListener('DOMContentLoaded', function () { scanInlineScripts('DOMContentLoaded'); });
  window.addEventListener('load', function () { scanInlineScripts('load'); });
})();
