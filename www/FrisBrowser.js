var FrisBrowser = function() {
};

FrisBrowser.open = function(url, options, eventsListeners) {
    if ('undefined' === typeof options) options = {};
    if ('undefined' === typeof eventsListeners) eventsListeners = {};
    // eventlisteners coming in the next version
    exec(function(state) {
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
    }, null, "InAppBrowser", "open", [url, options]);
};

FrisBrowser.close = function() {
    exec(null, null, "InAppBrowser", "close", []);
};

module.exports = FrisBrowser;