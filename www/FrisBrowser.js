var FrisBrowser = function() {
};

FrisBrowser.open = function(url, options, eventsListeners) {
    if ('undefined' === typeof options) options = {};
    if ('undefined' === typeof eventsListeners) eventsListeners = {};
    // eventlisteners coming in the next version
    cordova.exec(function(state) {
        if ('doneLoading' === state && 'undefined' !== typeof eventsListeners.onPageLoadSuccess) {
            eventsListeners.onPageLoadSuccess(url);
        }
        else if ('errorLoading' === state && 'undefined' !== typeof eventsListeners.onPageLoadError) {
            eventsListeners.onPageLoadError(url);
        }
        else if ('opened' === state && 'undefined' !== typeof eventsListeners.onOpen) {
            eventsListeners.onOpen(url);
        }
        else if ('closed' === state && 'undefined' !== typeof eventsListeners.onClose) {
            // remove event listeners?
            eventsListeners.onClose(url);
        }
    }, null, "FrisBrowser", "open", [url, options]);
};

FrisBrowser.close = function() {
    cordova.exec(null, null, "FrisBrowser", "close", []);
};

FrisBrowser.preloadCloseButtonImage = function(url) {
    cordova.exec(null, null, "FrisBrowser", "preloadCloseButtonImage", [url]);
};

module.exports = FrisBrowser;