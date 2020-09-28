// Generated by IcedCoffeeScript 108.0.11
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(["jquery", '../base-directive', 'text!./style.css', 'text!./view.html', 'underscore', "moment", 'angularGrid', 'gl-datepicker'], function($, base, css, view, _, moment, agGrid, gl) {
  var NotificationDirective, exports;
  NotificationDirective = (function(_super) {
    __extends(NotificationDirective, _super);

    function NotificationDirective($timeout, $window, $compile, $routeParams, commonService) {
      this.setRule = __bind(this.setRule, this);
      this.loadRules = __bind(this.loadRules, this);
      this.show = __bind(this.show, this);
      NotificationDirective.__super__.constructor.call(this, $timeout, $window, $compile, $routeParams, commonService);
      this.id = "notification";
      this.equipments = {};
    }

    NotificationDirective.prototype.setScope = function() {};

    NotificationDirective.prototype.setCSS = function() {
      return css;
    };

    NotificationDirective.prototype.setTemplate = function() {
      return view;
    };

    NotificationDirective.prototype.show = function(scope, element, attrs) {
      var index, rule, stations, types;
      scope.cates = [
        {
          name: '邮件',
          type: 'email',
          img: 'image/youjian.jpg'
        }, {
          name: '微信',
          type: 'wechat',
          img: 'image/weixin.jpg'
        }, {
          name: '云短信',
          type: 'cloudsms',
          img: 'image/yunduanxin.jpg'
        }, {
          name: '电话',
          type: 'phone',
          img: 'image/phone.jpg'
        }, {
          name: '短信',
          type: 'sms',
          img: 'image/duanxin.jpg'
        }
      ];
      scope.cate = scope.cates[0].type;
      scope.equipments = [];
      rule = {};
      rule.allEventPhases = true;
      rule.allEventTypes = true;
      stations = _.map(scope.project.stations.items, (function(_this) {
        return function(s) {
          return {
            name: s.model.name,
            station: s.model.station,
            checked: false
          };
        };
      })(this));
      scope.stations = stations;
      scope.station_all_select = false;
      scope.station_all_select_chan = (function(_this) {
        return function() {
          if (scope.station_all_select) {
            _.each(scope.stations, function(u) {
              return u.checked = true;
            });
          } else {
            _.each(scope.stations, function(u) {
              return u.checked = false;
            });
          }
          return _this.setEquipments(scope);
        };
      })(this);
      scope.station_select_chan = (function(_this) {
        return function() {
          var cs;
          cs = _.map(scope.stations, function(u) {
            return !u.checked;
          });
          if (_.indexOf(cs, true) < 0) {
            scope.station_all_select = true;
          } else {
            scope.station_all_select = false;
          }
          return _this.setEquipments(scope);
        };
      })(this);
      types = _.map(scope.project.dictionary.equipmenttypes.items, (function(_this) {
        return function(s) {
          return {
            name: s.model.name,
            type: s.model.type,
            checked: false
          };
        };
      })(this));
      scope.types = types;
      scope.type_all_select = false;
      scope.type_all_select_chan = (function(_this) {
        return function() {
          if (scope.type_all_select) {
            return _.each(scope.types, function(u) {
              return u.checked = true;
            });
          } else {
            return _.each(scope.types, function(u) {
              return u.checked = false;
            });
          }
        };
      })(this);
      scope.type_select_chan = (function(_this) {
        return function() {
          var cs;
          cs = _.map(scope.types, function(u) {
            return !u.checked;
          });
          if (_.indexOf(cs, true) < 0) {
            return scope.type_all_select = true;
          } else {
            return scope.type_all_select = false;
          }
        };
      })(this);
      index = 0;
      _.each(scope.project.stations.items, (function(_this) {
        return function(s) {
          return _this.getEquipments(s, function(equips) {
            _this.equipments[s.model.station] = equips;
            index++;
            if (index === scope.project.stations.items.length) {
              return _this.loadRules(scope);
            }
          });
        };
      })(this));
      scope.equipment_all_select = false;
      scope.equipment_all_select_chan = (function(_this) {
        return function() {
          if (scope.equipment_all_select) {
            return _.each(scope.equipments, function(u) {
              return u.checked = true;
            });
          } else {
            return _.each(scope.equipments, function(u) {
              return u.checked = false;
            });
          }
        };
      })(this);
      scope.equipment_select_chan = (function(_this) {
        return function() {
          var cs;
          cs = _.map(scope.equipments, function(u) {
            return !u.checked;
          });
          if (_.indexOf(cs, true) < 0) {
            return scope.equipment_all_select = true;
          } else {
            return scope.equipment_all_select = false;
          }
        };
      })(this);
      this.geteventSeverities(scope, (function(_this) {
        return function(res) {
          scope.eventSeverities = res;
          scope.eventSeveritie_all_select = false;
          scope.eventSeveritie_all_select_chan = function() {
            if (scope.eventSeveritie_all_select) {
              return _.each(scope.eventSeverities, function(u) {
                return u.checked = true;
              });
            } else {
              return _.each(scope.eventSeverities, function(u) {
                return u.checked = false;
              });
            }
          };
          return scope.eventSeveritie_select_chan = function() {
            var cs;
            cs = _.map(scope.eventSeverities, function(u) {
              return !u.checked;
            });
            if (_.indexOf(cs, true) < 0) {
              return scope.eventSeveritie_all_select = true;
            } else {
              return scope.eventSeveritie_all_select = false;
            }
          };
        };
      })(this));
      this.geteventPhases(scope, (function(_this) {
        return function(res) {
          scope.eventphases = res;
          scope.eventphases_all_select = false;
          scope.eventphases_all_select_chan = function() {
            if (scope.eventphases_all_select) {
              return _.each(scope.eventphases, function(u) {
                return u.checked = true;
              });
            } else {
              return _.each(scope.eventphases, function(u) {
                return u.checked = false;
              });
            }
          };
          return scope.eventphases_select_chan = function() {
            var cs;
            cs = _.map(scope.eventphases, function(u) {
              return !u.checked;
            });
            if (_.indexOf(cs, true) < 0) {
              return scope.eventphases_all_select = true;
            } else {
              return scope.eventphases_all_select = false;
            }
          };
        };
      })(this));
      this.getRoles(scope, (function(_this) {
        return function(roles) {
          return _this.getUsers(scope, roles, function(users) {
            scope.users = users;
            _this.loadRules(scope);
            scope.user_all_select = false;
            scope.user_all_select_chan = function() {
              if (scope.user_all_select) {
                return _.each(scope.users, function(u) {
                  return u.checked = true;
                });
              } else {
                return _.each(scope.users, function(u) {
                  return u.checked = false;
                });
              }
            };
            return scope.user_select_chan = function() {
              var cs;
              cs = _.map(scope.users, function(u) {
                return !u.checked;
              });
              if (_.indexOf(cs, true) < 0) {
                return scope.user_all_select = true;
              } else {
                return scope.user_all_select = false;
              }
            };
          });
        };
      })(this));
      scope.save = (function(_this) {
        return function() {
          var contentstr, contenttypestr, filterEquipments, filterStations, filterTypes, filterUsers, filtereventPhases, filtereventSeverities, name, save_api, title, users;
          if (scope.user_all_select) {
            users = ["_all"];
          } else {
            filterUsers = _.filter(scope.users, function(item) {
              return item.checked;
            });
            users = _.map(filterUsers, function(item) {
              return item.user;
            });
          }
          if (scope.station_all_select) {
            rule.allStations = true;
          } else {
            delete rule.allStations;
            filterStations = _.filter(scope.stations, function(item) {
              return item.checked;
            });
            rule.stations = _.map(filterStations, function(item) {
              return item.station;
            });
          }
          if (scope.type_all_select) {
            rule.allEquipmentTypes = true;
          } else {
            delete rule.allEquipmentTypes;
            filterTypes = _.filter(scope.types, function(item) {
              return item.checked;
            });
            rule.equipmentTypes = _.map(filterTypes, function(item) {
              return item.type;
            });
          }
          if (scope.equipment_all_select) {
            rule.allEquipments = true;
          } else {
            delete rule.allEquipments;
            filterEquipments = _.filter(scope.equipments, function(item) {
              return item.checked;
            });
            rule.equipments = _.map(filterEquipments, function(item) {
              return item.station + '/' + item.equipment;
            });
          }
          if (scope.eventSeveritie_all_select) {
            rule.allEventSeverities = true;
          } else {
            delete rule.allEventSeverities;
            filtereventSeverities = _.filter(scope.eventSeverities, function(item) {
              return item.checked;
            });
            rule.eventSeverities = _.map(filtereventSeverities, function(item) {
              return item.severity;
            });
          }
          if (scope.eventphases_all_select) {
            rule.eventphases_all_select = true;
          } else {
            delete rule.allEventPhases;
            filtereventPhases = _.filter(scope.eventphases, function(item) {
              return item.checked;
            });
            rule.eventPhases = _.map(filtereventPhases, function(item) {
              return item.phase;
            });
          }
          switch (scope.cate) {
            case 'email':
              name = "email-1";
              title = "{{equipmentName}}--{{title}}--{{severityName}}--{{phaseName}}";
              contentstr = '<!DOCTYPE html> <html> <head> <meta charset="utf-8"> <title>告警通知</title> <meta name="viewport" content="width=device-width, initial-scale=1"> </head> <body style="background-color: #e9ecef;"> <table border="0" cellpadding="0" cellspacing="0" width="100%"> <tr> <td align="center" bgcolor="#e9ecef"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;"> <tr> <td align="left" bgcolor="#ffffff" style="padding: 36px 24px 0; font-family: \'Microsoft Yahei\', Arial; border-top: 3px solid #d4dadf;"> <h1 style="margin: 0; font-size: 32px; font-weight: 700; letter-spacing: -1px; line-height: 48px;">{{title}}</h1> </td> </tr> </table> </td> </tr> <tr> <td align="center" bgcolor="#e9ecef"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;"> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">告警状态</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{phaseName}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">告警等级</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{severityName}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">站点名称</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{stationName}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">设备名称</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{equipmentName}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">事件名称</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{name}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">开始时间</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{startTimeDisplay}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">结束时间</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{endTimeDisplay}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">确认时间</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{confirmTimeDisplay}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">开始阀值</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{startValue}}</span> </td> </tr> <tr> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 12px; line-height: 20px; color: #9e9e9e; border-bottom: 3px solid #d4dadf"> <label style="margin: 0;">结束阀值</label> </td> <td align="left" bgcolor="#ffffff" style="padding: 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 16px; line-height: 24px; border-bottom: 3px solid #d4dadf"> <span style="margin: 0;">{{endValue}}</span> </td> </tr> </table> </td> </tr> <tr> <td align="center" bgcolor="#e9ecef" style="padding: 24px;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;"> <tr> <td align="center" bgcolor="#e9ecef" style="padding: 12px 24px; font-family: \'Microsoft Yahei\', Arial; font-size: 14px; line-height: 20px; color: #666;"> <p style="margin: 0;">海鸥工业物联网云平台-2019</p> </td> </tr> </table> </td> </tr> </table> </body> </html>';
              contenttypestr = "template";
              break;
            case 'sms':
              name = "sms-1";
              title = "短信告警通知";
              contentstr = '//js \n if($event.phase == "start"){ return $event.stationName + "--" + $event.equipmentName + "--"  + $event.title; }else if($event.phase == "end"){ return $event.stationName + "--" + $event.equipmentName + "--"  + $event.title +  "。恢复正常"; }';
              contenttypestr = "script";
              break;
            case 'wechat':
              name = "wechat-1";
              title = "{{eventName}}";
              contentstr = '{{title}};';
              contenttypestr = "template";
              break;
            case 'phone':
              name = "phone-1";
              title = "告警通知";
              contentstr = '{{equipmentName}}设备,{{title}}告警,告警开始';
              contenttypestr = "template";
              break;
            default:
              name = "cloudsms-1";
              title = "云短信告警通知";
              contentstr = '{{title}};';
              contenttypestr = "template";
              break;
          }
          save_api = {
            id: 'notificationrules',
            item: {
              user: scope.project.model.user,
              project: scope.project.model.project,
              notification: "notification-" + scope.cate,
              content: contentstr,
              contentType: contenttypestr,
              delay: 0,
              enable: true,
              events: [],
              index: 0,
              name: name,
              phase: "start",
              priority: 0,
              repeatPeriod: 0,
              repeatTimes: 0,
              rule: rule,
              ruleType: "complex",
              timeout: 5,
              title: title,
              type: scope.cate,
              users: users,
              visible: true
            }
          };
          return _this.commonService.modelEngine.modelManager.getService(save_api.id).save(save_api.item, function(e, res) {
            if (res && res._id) {
              return _this.display("保存告警模板成功", 10000);
            }
          });
        };
      })(this);
      return scope.cates_chan = (function(_this) {
        return function() {
          return _this.loadRules(scope);
        };
      })(this);
    };

    NotificationDirective.prototype.loadRules = function(scope) {
      var notificationrules_api;
      scope.user_all_select = false;
      scope.station_all_select = false;
      scope.type_all_select = false;
      scope.equipment_all_select = false;
      _.each(scope.users, (function(_this) {
        return function(item) {
          return item.checked = false;
        };
      })(this));
      _.each(scope.stations, (function(_this) {
        return function(item) {
          return item.checked = false;
        };
      })(this));
      _.each(scope.types, (function(_this) {
        return function(item) {
          return item.checked = false;
        };
      })(this));
      _.each(scope.equipments, (function(_this) {
        return function(item) {
          return item.checked = false;
        };
      })(this));
      _.each(scope.eventSeverities, (function(_this) {
        return function(item) {
          return item.checked = false;
        };
      })(this));
      notificationrules_api = {
        id: 'notificationrules',
        query: {
          user: scope.project.model.user,
          project: scope.project.model.project,
          type: scope.cate
        }
      };
      return this.commonService.modelEngine.modelManager.getService(notificationrules_api.id).query(notificationrules_api.query, null, (function(_this) {
        return function(e, res) {
          if ((res != null ? res.length : void 0) === 0 || res === void 0) {

          } else {
            if (res[0].users && res[0].rule) {
              return _this.setRule(scope, res[0]);
            }
          }
        };
      })(this), true);
    };

    NotificationDirective.prototype.setRule = function(scope, res) {
      if (res.users[0]) {
        if (res.users[0] === "_all") {
          scope.user_all_select = true;
          _.each(scope.users, (function(_this) {
            return function(item) {
              return item.checked = true;
            };
          })(this));
        } else {
          scope.user_all_select = false;
          _.each(scope.users, (function(_this) {
            return function(item) {
              return _.each(res.users, function(u) {
                if (item.user === u) {
                  return item.checked = true;
                }
              });
            };
          })(this));
        }
      } else {
        scope.user_all_select = false;
      }
      if (res.rule.allStations) {
        scope.station_all_select = true;
        _.each(scope.stations, (function(_this) {
          return function(item) {
            return item.checked = true;
          };
        })(this));
      } else if (res.rule.stations) {
        scope.station_all_select = false;
        _.each(scope.stations, (function(_this) {
          return function(item) {
            return _.each(res.rule.stations, function(i) {
              if (item.station === i) {
                return item.checked = true;
              }
            });
          };
        })(this));
      }
      if (res.rule.allEquipmentTypes) {
        scope.type_all_select = true;
        _.each(scope.types, (function(_this) {
          return function(item) {
            return item.checked = true;
          };
        })(this));
      } else if (res.rule.equipmentTypes) {
        scope.type_all_select = false;
        _.each(scope.types, (function(_this) {
          return function(item) {
            return _.each(res.rule.equipmentTypes, function(i) {
              if (item.type === i) {
                return item.checked = true;
              }
            });
          };
        })(this));
      }
      this.setEquipments(scope, (function(_this) {
        return function() {
          if (res.rule.allEquipments) {
            scope.equipment_all_select = false;
            return _.each(scope.equipments, function(item) {
              return item.checked = true;
            });
          } else if (res.rule.equipments) {
            scope.equipment_all_select = false;
            return _.each(scope.equipments, function(item) {
              return _.each(res.rule.equipments, function(i) {
                var iistr;
                if (i !== void 0 && (i != null)) {
                  iistr = i.split('/')[1];
                  if (item.equipment === iistr) {
                    return item.checked = true;
                  }
                }
              });
            });
          }
        };
      })(this));
      if (res.rule.allEventSeverities) {
        scope.eventSeveritie_all_select = true;
        _.each(scope.eventSeverities, (function(_this) {
          return function(item) {
            return item.checked = true;
          };
        })(this));
      } else if (res.rule.eventSeverities) {
        scope.eventSeveritie_all_select = false;
        _.each(scope.eventSeverities, (function(_this) {
          return function(item) {
            return _.each(res.rule.eventSeverities, function(i) {
              if (item.severity === i.toString()) {
                return item.checked = true;
              }
            });
          };
        })(this));
      }
      if (res.rule.allEventPhases) {
        scope.eventphases_all_select = true;
        return _.each(scope.eventphases, (function(_this) {
          return function(item) {
            return item.checked = true;
          };
        })(this));
      } else if (res.rule.eventPhases) {
        scope.eventphases_all_select = false;
        return _.each(scope.eventphases, (function(_this) {
          return function(item) {
            return _.each(res.rule.eventPhases, function(i) {
              if (item.phase === i.toString()) {
                return item.checked = true;
              }
            });
          };
        })(this));
      }
    };

    NotificationDirective.prototype.getRoles = function(scope, callback) {
      var roles_api;
      roles_api = {
        id: 'roles',
        query: {
          user: scope.project.model.user,
          project: scope.project.model.project
        },
        field: null
      };
      return this.commonService.modelEngine.modelManager.getService(roles_api.id).query(roles_api.query, roles_api.field, (function(_this) {
        return function(e, rs) {
          var res, union;
          res = _.map(rs, function(r) {
            return r.users;
          });
          union = _.union(_.flatten(res));
          return typeof callback === "function" ? callback(union) : void 0;
        };
      })(this), true);
    };

    NotificationDirective.prototype.getUsers = function(scope, roles, callback) {
      if (_.indexOf(roles, "_all" >= 0)) {
        return this.commonService.modelEngine.modelManager.getService("users").query(null, null, (function(_this) {
          return function(e, rs) {
            var res;
            res = _.map(rs, function(r) {
              return {
                name: r.name,
                user: r.user,
                checked: false
              };
            });
            return typeof callback === "function" ? callback(res) : void 0;
          };
        })(this));
      } else {
        return typeof callback === "function" ? callback(roles) : void 0;
      }
    };

    NotificationDirective.prototype.getEquipments = function(station, callback) {
      return station.loadEquipments(null, null, (function(_this) {
        return function(err, equipments) {
          var equips;
          equips = _.map(equipments, function(e) {
            return {
              name: e.model.name,
              equipment: e.model.equipment,
              checked: false,
              station: e.model.station
            };
          });
          return typeof callback === "function" ? callback(equips) : void 0;
        };
      })(this), true);
    };

    NotificationDirective.prototype.geteventSeverities = function(scope, callback) {
      var eventSeverities_api;
      eventSeverities_api = {
        id: 'eventseverities',
        query: {
          user: scope.project.model.user,
          project: scope.project.model.project
        },
        field: null
      };
      return this.commonService.modelEngine.modelManager.getService(eventSeverities_api.id).query(eventSeverities_api.query, eventSeverities_api.query.field, (function(_this) {
        return function(e, rs) {
          var res;
          res = _.map(rs, function(r) {
            return {
              name: r.name,
              severity: r.severity.toString(),
              checked: false
            };
          });
          return typeof callback === "function" ? callback(res) : void 0;
        };
      })(this), true);
    };

    NotificationDirective.prototype.geteventPhases = function(scope, callback) {
      var eventSeverities_api;
      eventSeverities_api = {
        id: 'eventphases',
        query: {
          user: scope.project.model.user,
          project: scope.project.model.project
        },
        field: null
      };
      return this.commonService.modelEngine.modelManager.getService(eventSeverities_api.id).query(eventSeverities_api.query, eventSeverities_api.query.field, (function(_this) {
        return function(e, rs) {
          var res;
          res = _.map(rs, function(r) {
            return {
              name: r.name,
              phase: r.phase.toString(),
              checked: false
            };
          });
          return typeof callback === "function" ? callback(res) : void 0;
        };
      })(this), true);
    };

    NotificationDirective.prototype.setEquipments = function(scope, callback) {
      var filterStations, mapStations;
      filterStations = _.filter(scope.stations, (function(_this) {
        return function(s) {
          return s.checked;
        };
      })(this));
      mapStations = _.map(filterStations, (function(_this) {
        return function(s) {
          return _this.equipments[s.station] || [];
        };
      })(this));
      scope.equipments = _.union(_.flatten(mapStations));
      return typeof callback === "function" ? callback(scope.equipments) : void 0;
    };

    NotificationDirective.prototype.resize = function(scope) {};

    NotificationDirective.prototype.dispose = function(scope) {};

    return NotificationDirective;

  })(base.BaseDirective);
  return exports = {
    NotificationDirective: NotificationDirective
  };
});
