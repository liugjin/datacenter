// Generated by IcedCoffeeScript 108.0.13

/*
* File: alarms-monitoring-directive
* User: David
* Date: 2019/07/19
* Desc:
 */
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(['../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", "rx"], function(base, css, view, _, moment, Rx) {
  var AlarmsMonitoringDirective, exports;
  AlarmsMonitoringDirective = (function(_super) {
    __extends(AlarmsMonitoringDirective, _super);

    function AlarmsMonitoringDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.processEvents = __bind(this.processEvents, this);
      this.show = __bind(this.show, this);
      this.id = "alarms-monitoring";
      AlarmsMonitoringDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
    }

    AlarmsMonitoringDirective.prototype.setScope = function() {};

    AlarmsMonitoringDirective.prototype.setCSS = function() {
      return css;
    };

    AlarmsMonitoringDirective.prototype.setTemplate = function() {
      return view;
    };

    AlarmsMonitoringDirective.prototype.show = function(scope, element, attrs) {
      var filter, station, subject, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
      scope.alarms = {};
      scope.types = [];
      scope.datacenters = _.filter(scope.project.stations.items, function(sta) {
        return _.isEmpty(sta.model.parent) && sta.model.station.charAt(0) !== "_";
      });
      scope.parents = [];
      this.findParent(scope, scope.station);
      scope.stations = (_ref = (_ref1 = scope.parents[0]) != null ? _ref1.stations : void 0) != null ? _ref : scope.datacenters;
      scope.parents = scope.parents.reverse();
      scope.severities = (_ref2 = scope.project) != null ? (_ref3 = _ref2.dictionary) != null ? _ref3.eventseverities.items : void 0 : void 0;
      scope.getEventColor = (function(_this) {
        return function(severity) {
          var color, _ref4, _ref5, _ref6, _ref7;
          color = (_ref4 = scope.project) != null ? (_ref5 = _ref4.dictionary) != null ? (_ref6 = _ref5.eventseverities) != null ? (_ref7 = _ref6.getItem(severity)) != null ? _ref7.model.color : void 0 : void 0 : void 0 : void 0;
          return color;
        };
      })(this);
      scope.selectEquipmentType = (function(_this) {
        return function(type) {
          var index;
          if (type === "all") {
            scope.types = [];
          } else {
            index = scope.types.indexOf(type);
            if (index < 0) {
              scope.types.push(type);
            } else {
              scope.types.splice(index, 1);
            }
          }
          return _this.commonService.publishEventBus('event-list-equipmentTypes', scope.types);
        };
      })(this);
      scope.selectStation = function(station) {
        return scope.station = station;
      };
      scope.selectChild = function(station) {
        scope.stations = scope.station.stations;
        scope.parents.push(scope.station);
        return scope.station = station;
      };
      scope.selectParent = function(station) {
        var index, _ref4, _ref5;
        index = scope.parents.indexOf(station);
        scope.parents.splice(index, scope.parents.length - index);
        scope.station = station;
        return scope.stations = (_ref4 = (_ref5 = station.parentStation) != null ? _ref5.stations : void 0) != null ? _ref4 : scope.datacenters;
      };
      if (scope.firstload) {
        _ref4 = scope.project.stations.nitems;
        for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
          station = _ref4[_i];
          scope.alarms[station.model.station] = {
            count: 0,
            severity: 0,
            list: {},
            severities: {},
            types: {}
          };
          _.each(scope.severities, function(severity) {
            return scope.alarms[station.model.station].severities[severity.model.severity] = 0;
          });
        }
        subject = new Rx.Subject;
        filter = {
          user: scope.project.model.user,
          project: scope.project.model.project
        };
        if ((_ref5 = scope.eventSubscription) != null) {
          _ref5.dispose();
        }
        scope.eventSubscription = this.commonService.eventLiveSession.subscribeValues(filter, (function(_this) {
          return function(err, d) {
            var event, key, _ref6;
            if (!((_ref6 = d.message) != null ? _ref6.event : void 0) || !scope.alarms[d.message.station]) {
              return;
            }
            event = d.message;
            key = "" + event.user + "." + event.project + "." + event.station + "." + event.equipment + "." + event.event + "." + event.severity + "." + event.startTime;
            scope.alarms[event.station].list[key] = event;
            if (event.endTime) {
              delete scope.alarms[event.station].list[key];
            }
            return subject.onNext();
          };
        })(this));
        subject.debounce(100).subscribe((function(_this) {
          return function() {
            return _this.processEvents(scope);
          };
        })(this));
      }
      return this.processEvents(scope);
    };

    AlarmsMonitoringDirective.prototype.processEvents = function(scope) {
      var currentStation, key, map, sta, station, stations, types, val, value, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
      _ref = scope.alarms;
      for (key in _ref) {
        value = _ref[key];
        _.each(scope.severities, (function(_this) {
          return function(severity) {
            return value.severities[severity.model.severity] = 0;
          };
        })(this));
        value.types = {};
        value.count = (_.keys(value.list)).length;
        value.starts = _.filter(_.values(value.list), function(item) {
          return item.phase === "start";
        }).length;
        value.ends = _.filter(_.values(value.list), function(item) {
          return item.phase === "end";
        }).length;
        value.confirms = _.filter(_.values(value.list), function(item) {
          return item.phase === "confirm";
        }).length;
        value.severity = (_ref1 = _.max(_.filter(_.values(value.list), function(item) {
          return !item.endTime;
        }), function(it) {
          return it.severity;
        })) != null ? _ref1.severity : void 0;
        map = _.countBy(_.values(value.list), function(item) {
          return item.severity;
        });
        for (key in map) {
          val = map[key];
          value.severities[key] = val;
        }
        types = _.countBy(_.values(value.list), function(item) {
          return item.equipmentType;
        });
        for (key in types) {
          val = types[key];
          value.types[key] = {
            name: (_ref2 = _.find((_ref3 = scope.project.dictionary) != null ? (_ref4 = _ref3.equipmenttypes) != null ? _ref4.items : void 0 : void 0, function(item) {
              return item.model.type === key;
            })) != null ? _ref2.model.name : void 0,
            value: val,
            severity: (_ref5 = _.max(_.filter(_.values(value.list), function(item) {
              return item.equipmentType === key;
            }), function(it) {
              return it.severity;
            })) != null ? _ref5.severity : void 0
          };
        }
      }
      _ref6 = scope.project.stations.nitems;
      for (_i = 0, _len = _ref6.length; _i < _len; _i++) {
        station = _ref6[_i];
        stations = this.commonService.loadStationChildren(station, false);
        currentStation = scope.alarms[station.model.station];
        for (_j = 0, _len1 = stations.length; _j < _len1; _j++) {
          sta = stations[_j];
          if (sta.stations.length === 0) {
            currentStation.count += scope.alarms[sta.model.station].count;
            currentStation.starts += scope.alarms[sta.model.station].starts;
            currentStation.ends += scope.alarms[sta.model.station].ends;
            currentStation.confirms += scope.alarms[sta.model.station].confirms;
            if (currentStation.severity < scope.alarms[sta.model.station].severity) {
              currentStation.severity = scope.alarms[sta.model.station].severity;
            }
            _ref7 = currentStation.severities;
            for (key in _ref7) {
              val = _ref7[key];
              currentStation.severities[key] += (_ref8 = scope.alarms[sta.model.station].severities[key]) != null ? _ref8 : 0;
            }
            _ref9 = scope.alarms[sta.model.station].types;
            for (key in _ref9) {
              val = _ref9[key];
              if (currentStation.types[key]) {
                currentStation.types[key].value += scope.alarms[sta.model.station].types[key].value;
                if (currentStation.types[key].severity < scope.alarms[sta.model.station].types[key].severity) {
                  currentStation.types[key].severity = scope.alarms[sta.model.station].types[key].severity;
                }
              } else {
                currentStation.types[key] = JSON.parse(JSON.stringify(scope.alarms[sta.model.station].types[key]));
              }
            }
          }
        }
        currentStation.statistic = {
          counts: {
            confirmedEvents: currentStation.confirms,
            startEvents: currentStation.starts,
            endEvents: currentStation.ends,
            allEvents: currentStation.count
          },
          severities: currentStation.severities
        };
      }
      return scope.$applyAsync();
    };

    AlarmsMonitoringDirective.prototype.findParent = function(scope, station) {
      var parent;
      parent = _.find(scope.project.stations.items, function(sta) {
        return sta.model.station === station.model.parent;
      });
      if (parent) {
        scope.parents.push(parent);
        return this.findParent(scope, parent);
      }
    };

    AlarmsMonitoringDirective.prototype.resize = function(scope) {};

    AlarmsMonitoringDirective.prototype.dispose = function(scope) {};

    return AlarmsMonitoringDirective;

  })(base.BaseDirective);
  return exports = {
    AlarmsMonitoringDirective: AlarmsMonitoringDirective
  };
});
