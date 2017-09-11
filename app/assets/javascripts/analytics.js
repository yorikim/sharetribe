window.ST = window.ST || {};

window.ST.analytics = (function(){
  var init = function(options) {
    $(document).ready(function() {
      $(document).trigger('st-analytics:setup', options.analyticsData);
      if (options.events) {
        for(var i = 0; i < data.length; i++) {
          var _event = data[i];
          logEvent( _event.event, _event.action, null, _event.props);
        }
      }
      if (options.logout) {
        logout();
      }
    });
  };

  var logEvent = function(category, action, opt_label, props) {
    $(document).trigger('st-analytics:event', {category: category, action: action, opt_label: opt_label, props: props});
  };

  var logout = function() {
    $(document).trigger('st-analytics:logout');
  };

  var initAmplitude = function(amplitudeApiKey) {
    var ampClient;
    if (window.amplitude) {
      ampClient = amplitude.getInstance();
      ampClient.init(amplitudeApiKey);
    } else {
      return;
    }
    $(document).on("st-analytics:setup", function(event, info) {
      var userInfo = new amplitude.Identify()
                                  .set('community_id', info.community_id)
                                  .set('marketplace_uuid', info.community_uuid)
                                  .set('admin', info.user_is_admin);

      if (info.plan_status) {
        userInfo.set('plan_status', info.plan_status);
      }

      if (info.user_uuid) {
        ampClient.setUserId(info.user_uuid);
      }

      ampClient.identify(userInfo);
    });

    $(document).on("st-analytics:event", function(event, args){
      ampClient.logEvent(args.category, args.props);
    });

    $(document).on("st-analytics:logout", function(event, args){
      ampClient.setUserId(null);
      ampClient.regenerateDeviceid();
    });
  };

  var initKissmetrics = function(kmq) {
    $(document).on("st-analytics:setup", function(event, info) {
      if(info.user_id) {
        kmq.push(['identify', info.user_id]);
      }
      if(info.community_ident) {
        kmq.push(['set', {'SiteName' : info.community_ident}]);
      } else {
        kmq.push(['set', {'SiteName' : 'dashboard'}]);
      }
    });
  };

  var initGoogleAnalytic = function() {
    $(document).on('st-analytics:event', function(event, args) {
      ST.customerReportEvent(args.category, args.action, args.opt_label);
    });
  };

  var initLegacyGoogleAnalytic = function(gaq) {
    $(document).on('st-analytics:event', function(event, args) {
      var params_array = [args.category, args.action, args.opt_label];
      if (typeof gaq !== 'undefined' && Array.isArray(_gaq)) {
        gaq.push(['_trackEvent'].concat(params_array));
      }
    });
  };

  var initGoogleTagManager= function(gtm_identify) {
    $(document).on('st-analytics:event', function(event, args) {
      if (args.category == 'km_record') {
        var data = $.extend({}, args.props);
        data.event = 'km_record';
        window.ST.gtmPush(data);
      } else {
        window.ST.gtmPush({
          'event' : 'GAEvent',
          'eventCategory' : args.category,
          'eventAction' : args.saction,
          'eventLabel' : args.opt_label,
          'eventValue' : undefined
        });
      }
    });

    $(document).on('st-analytics:setup', function(event, info) {
      gtm_identify(dataLayer, info.community_id, info.feature_flags);
    });
  };

  return {
    "init": init,
    "logEvent": logEvent,
    "logout": logout,
    "initAmplitude": initAmplitude,
    "initKissmetrics": initKissmetrics,
    "initGoogleAnalytic": initGoogleAnalytic,
    "initLegacyGoogleAnalytic": initLegacyGoogleAnalytic,
    "initGoogleTagManager": initGoogleTagManager
  };
})();
