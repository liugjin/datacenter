###
* File: main
* User: Dow
* Date: 2014/10/8
###

# compatible for node.js and requirejs
`if (typeof define !== 'function') { var define = require('amdefine')(module) }`

define [
  './module'

  './services/common-service'
  './services/datacenter-service'
  # {{service-file}}

  './controllers/datacenter-controller'
  './controllers/setting-controller'
  './controllers/dashboard-controller'

  './controllers/inventory-controller'

  './controllers/station-setting-controller'
  './controllers/alarm-controller'

  './controllers/energy-controller'
  './controllers/video-controller'
  './controllers/monitoring-controller'
  './controllers/door-manager-controller'
  './controllers/user-manager-controller'
  './controllers/user-management-controller'
  './controllers/card-manage-controller'

  './controllers/link-controller'
  './controllers/notification-controller'
  './controllers/asset-report-controller'
  './controllers/user-info-controller'
  './controllers/alarm-report-controller'
  './controllers/temperature-cloud-controller'

  './controllers/log-controller'
  './controllers/signal-report-controller'
  './controllers/card-manager-controller'
  './controllers/door-plan-controller'
  './controllers/video_histroy_list-controller'
  './controllers/live-main-controller'
  './controllers/login-controller'
  './controllers/dispatch-controller'
  './controllers/station-3d-controller'
  './controllers/alarm-setting-controller'
  './controllers/mobile-controller'

  './controllers/video_reliable_list-controller'

  './controllers/record-hiscurve-controller'
  './controllers/reporting-signal-controller'
  './controllers/electricity-consumption-controller'
  './controllers/report-activeevents-controller'
  './controllers/finish-alarm-controller'
  './controllers/battery-alarm-controller'
  './controllers/ups-alarm-controller'

  './controllers/reporting-controller'
  './controllers/ac-alarm-controller'
  './controllers/history-send-notification-controller'
  './controllers/report-operations-controller'
  './controllers/report-systemlog-controller'
  './controllers/user-exclu-controller'
  './controllers/component-rolesrights-controller'

  './controllers/ip-setting-controller'
  './controllers/equipments-controller'
  './controllers/base-map-configuration-controller'
  './controllers/batch-configuration-controller'
  './controllers/graphic-page-controller'
  './controllers/historical-alarm-controller'
  './controllers/signal-configuration-controller'
  './controllers/manage-data-controller'
  './controllers/time-manage-controller'
  './controllers/help-information-controller'
  # {{controller-file}}

#  'graphic-directives'
  './directives/menu/component'
  './directives/menu-control/component'
  './directives/signal-gauge/component'
  './directives/custom-header/component'
  './directives/capacity-radar/component'
  
  
  
  './directives/station-breadcrumbs/component'
  
  
  
  './directives/room-3d-component/component'
  './directives/rack-3d-component/component'
  './directives/inventory-manage/component'
  './directives/header/component'
  './directives/system-setting/component'
  
  './directives/event-manager/component'
  './directives/event-statistic/component'
  './directives/event-statistic-chart/component'
  './directives/event-list/component'
  './directives/search-input/component'
  
  
  
  
  './directives/equipment-breadcrumbs/component'
  './directives/percent-gauge/component'
  './directives/discovery-station/component'
  
  './directives/micromodule-dashboard/component'
  './directives/safe-operation-days/component'
  './directives/alarm-number-box/component'
  './directives/pue-value/component'
  './directives/capacity-management/component'
  './directives/capacity-asset/component'
  './directives/equipment-quantity/component'
  './directives/yingmai-video/component'
  './directives/yingmai-environment/component'
  './directives/energy-management/component'
  './directives/signal-gauge-picker/component'
  './directives/energy-year-pie/component'
  './directives/real-time-pue/component'
  './directives/total-energy-bar/component'
  './directives/pue/component'
  
  './directives/equipment-info/component'
  './directives/door-manager/component'
  './directives/credit-record-last/component'
  './directives/credit-records/component'
  './directives/equip-door/component'
  './directives/user-manager/component'
  './directives/rotate-showing-model/component'
  './directives/video-list/component'
  './directives/single-video/component'
  './directives/func-devicemonitor/component'
  
  './directives/graphicparamter-box/component'
  './directives/user-management/component'
  './directives/card-manage/component'
  './directives/notification/component'
  './directives/alarm-link/component'
  './directives/station-visualization/component'
  './directives/visualization-tree/component'
  './directives/reporting-asset/component'
  './directives/user-personinfo/component'
  './directives/graphic-box/component'
  './directives/report-operations/component'
  './directives/report-historysignal/component'
  './directives/device-tree/component'
  './directives/grid-table/component'
  './directives/bar-or-line/component'
  './directives/drop-down/component'
  './directives/card-manager/component'
  './directives/door-plan/component'
  './directives/query-report/component'
  './directives/equipment-property/component'
  './directives/video-history/component'
  './directives/glvideo-datepicker/component'
  './directives/report-query-time/component'
  './directives/report-alarm-records/component'
  './directives/custom-dashboard/component'
  './directives/dashboard-header1/component'
  './directives/station-graphic/component'
  './directives/discovery-station-management/component'
  './directives/equipment-signals/component'
  './directives/alarm-severity-boxes/component'
  './directives/child-stations-environment/component'
  './directives/ups-manager/component'
  './directives/percent-pie/component'
  './directives/distribution-manager/component'
  './directives/signal-pie/component'
  './directives/station-environment/component'
  './directives/signal-real-value/component'
  './directives/acousto-optic-control/component'
  './directives/device-filter/component'
  './directives/station-tree/component'
  
  './directives/signal-extreme/component'
  './directives/monitoring/component'
  './directives/equipment-timefilter/component'
  
  './directives/alarm-setting/component'
  './directives/station-3d/component'
  
  
  
  
  
  './directives/app-qrcode/component'
  
  './directives/component-pie/component'
  
  './directives/alarms-monitoring/component'
  './directives/station-tree-with-count/component'
  './directives/station-video/component'
  './directives/equipment-statistic/component'
  
  
  './directives/video-reliable-dahua/component'
  './directives/video-reliable-hik/component'
  './directives/video-history-dahua/component'
  './directives/import-assets/component'
  './directives/server-performanceinfo/component'

  './directives/event-analysis-chart/component'
  

  './directives/equipment-air/component'

  


  
  
  
  './directives/one-file-uploader/component'
  
  
  
  
  
  
  './directives/three-quarter-pie/component'
  
  './directives/device-tree-leon/component'
  './directives/station-environmentyu/component'
  './directives/notificationyu/component'
  './directives/plugin-uploader/component'
  './directives/electricity-consumption/component'
  './directives/report-activeevents/component'
  './directives/battery-alarm/component'
  './directives/device-accla-alarm/component'
  './directives/finish-alarm/component'
  './directives/alarm-query/component'
  './directives/report-users/component'
  
  './directives/reporting-signal/component'
  './directives/record-hiscurve/component'
  './directives/lineorbar-tree/component'
  './directives/lineorbar-echart/component'
  
  './directives/paging-equipment/component'
  './directives/event-startlist/component'
  './directives/history-send-notification/component'
  './directives/report-systemlog/component'
  './directives/report-notifications/component'
  './directives/station-videos/component'
  './directives/single-video-core/component'
  './directives/video-listbetter/component'
  
  './directives/component-rolesrights/component'
  
  
  './directives/heatfield-cloud/component'
  
  
  
  
  
  './directives/video-autoplay/component'
  './directives/asset-manage/component'
  './directives/asset-detail/component'
  './directives/reporting-table/component'
  './directives/room-3d-component2/component'
  
  
  
  
  './directives/equip-lineorbarless/component'
  './directives/event-listless/component'
  
  './directives/ip-setting/component'
  './directives/equipments/component'
  './directives/discovery-management/component'

  
  './directives/station-environment-chongqing/component'
  './directives/notice-tip2/component'
  
  './directives/custom-label-location/component'
  './directives/base-map-configuration/component'
  './directives/batch-configuration/component'
  
  './directives/equipment-list/component'
  './directives/system-info/component'
  
  
  './directives/graphic-page/component'
  './directives/list-breadcrumbs/component'
  './directives/logic-action/component'
  './directives/notification-setting/component'
  './directives/login-hmu2500/component'
  './directives/alarms-monitoring-hmu2500/component'
  './directives/event-statistic-hmu2500/component'
  './directives/event-startlist-hmu2500/component'
  './directives/pue-hmu2500/component'
  './directives/real-time-pue-hmu2500/component'
  './directives/report-historysignal-single/component'
  './directives/device-tree-single/component'
  './directives/report-query-time-single/component'
  './directives/bar-or-line-single/component'
  './directives/alarm-query-hmu2500/component'
  './directives/signal-configuration/component'
  './directives/user-manage/component'
  './directives/manage-data/component'
  './directives/time-manage/component'
  './directives/component-devicemonitor-hmu2500/component'
  './directives/component-line-hmu2500/component'
  './directives/equip-lineorbar-hmu2500/component'
  './directives/monitoring-leon-hmu2500/component'
  './directives/help-information/component'
  './directives/equipment-air-cloud/component'
  './directives/log-system/component'
  './directives/signal-configuration-hmu2500/component'
  # {{directive-file}}

  'json!./directives/plugins.json'
  # {{filter-file}}
], (
  module

  commonService
  datacenterService
  # {{service-namespace}}

  datacenterController
  settingController
  dashboardController

  inventoryController

  stationSettingController
  alarmController

  energyController
  videoController
  monitoringController
  doorManagerController
  userManagerController
  userManagementController
  cardManageController

  linkController
  notificationController
  assetReportController
  userInfoController
  alarmReportController
  temperatureCloudController

  logController
  signalReportController
  cardManagerController
  doorPlanController
  video_histroy_listController
  liveMainController
  loginController
  dispatchController
  station3dController
  alarmSettingController
  mobileController

  video_reliable_listController

  recordHiscurveController
  reportingSignalController
  electricityConsumptionController
  reportActiveeventsController
  finishAlarmController
  batteryAlarmController
  upsAlarmController

  reportingController
  acAlarmController
  historySendNotificationController
  reportOperationsController
  reportSystemlogController
  userExcluController
  componentRolesrightsController

  ipSettingController
  equipmentsController

  baseMapConfigurationController
  batchConfigurationController
  graphicPageController
  historicalAlarmController
  signalConfigurationController
  manageDataController
  timeManageController
  helpInformationController
  # {{controller-namespace}}

#  graphicDirectives
  menuDirective
  menuControlDirective
  signalGaugeDirective
  customHeaderDirective
  capacityRadarDirective
  
  
  
  stationBreadcrumbsDirective
  
  
  
  room3dComponentDirective
  rack3dComponentDirective
  inventoryManageDirective
  headerDirective
  systemSettingDirective
  
  eventManagerDirective
  eventStatisticDirective
  eventStatisticChartDirective
  eventListDirective
  searchInputDirective
  
  
  
  
  equipmentBreadcrumbsDirective
  percentGaugeDirective
  discoveryStationDirective
  
  micromoduleDashboardDirective
  safeOperationDaysDirective
  alarmNumberBoxDirective
  pueValueDirective
  capacityManagementDirective
  capacityAssetDirective
  equipmentQuantityDirective
  yingmaiVideoDirective
  yingmaiEnvironmentDirective
  energyManagementDirective
  signalGaugePickerDirective
  energyYearPieDirective
  realTimePueDirective
  totalEnergyBarDirective
  pueDirective
  
  equipmentInfoDirective
  doorManagerDirective
  creditRecordLastDirective
  creditRecordsDirective
  equipDoorDirective
  userManagerDirective
  rotateShowingModelDirective
  videoListDirective
  singleVideoDirective
  funcDevicemonitorDirective
  
  graphicparamterBoxDirective
  userManagementDirective
  cardManageDirective
  notificationDirective
  alarmLinkDirective
  stationVisualizationDirective
  visualizationTreeDirective
  reportingAssetDirective
  userPersoninfoDirective
  graphicBoxDirective
  reportOperationsDirective
  reportHistorysignalDirective
  deviceTreeDirective
  gridTableDirective
  barOrLineDirective
  dropDownDirective
  cardManagerDirective
  doorPlanDirective
  queryReportDirective
  equipmentPropertyDirective
  videoHistoryDirective
  glvideoDatepickerDirective
  reportQueryTimeDirective
  reportAlarmRecordsDirective
  customDashboardDirective
  dashboardHeader1Directive
  stationGraphicDirective
  discoveryStationManagementDirective
  equipmentSignalsDirective
  alarmSeverityBoxesDirective
  childStationsEnvironmentDirective
  upsManagerDirective
  percentPieDirective
  distributionManagerDirective
  signalPieDirective
  stationEnvironmentDirective
  signalRealValueDirective
  acoustoOpticControlDirective
  deviceFilterDirective
  stationTreeDirective
  
  signalExtremeDirective
  monitoringDirective
  equipmentTimefilterDirective
  
  alarmSettingDirective
  station3dDirective
  
  
  
  
  
  appQrcodeDirective
  
  componentPieDirective
  
  alarmsMonitoringDirective
  stationTreeWithCountDirective
  stationVideoDirective
  equipmentStatisticDirective
  
  
  videoReliableDahuaDirective
  videoReliableHikDirective
  videoHistoryDahuaDirective
  importAssetsDirective
  serverPerformanceinfoDirective

  eventAnalysisChartDirective
  

  equipmentAirDirective

  
  
  
  
  
  
  oneFileUploaderDirective
  
  
  
  
  
  
  threeQuarterPieDirective
  
  deviceTreeLeonDirective
  stationEnvironmentyuDirective
  notificationyuDirective
  pluginUploaderDirective
  electricityConsumptionDirective
  reportActiveeventsDirective
  batteryAlarmDirective
  deviceAcclaAlarmDirective
  finishAlarmDirective
  alarmQueryDirective
  reportUsersDirective
  
  reportingSignalDirective
  recordHiscurveDirective
  lineorbarTreeDirective
  lineorbarEchartDirective
  
  pagingEquipmentDirective
  eventStartlistDirective
  historySendNotificationDirective
  reportSystemlogDirective
  reportNotificationsDirective
  stationVideosDirective
  singleVideoCoreDirective
  videoListbetterDirective
  
  componentRolesrightsDirective
  
  
  heatfieldCloudDirective
  
  
  
  
  
  videoAutoplayDirective
  assetManageDirective
  assetDetailDirective
  reportingTableDirective
  room3dComponent2Directive
  
  
  
  
  equipLineorbarlessDirective
  eventListlessDirective
  
  ipSettingDirective
  equipmentsDirective
  discoveryManagementDirective

  
  stationEnvironmentChongqingDirective
  noticeTip2Directive
  
  customLabelLocationDirective
  baseMapConfigurationDirective
  batchConfigurationDirective
  
  equipmentListDirective
  systemInfoDirective
  
  
  graphicPageDirective
  listBreadcrumbsDirective

  logicActionDirective
  notificationSettingDirective
  loginHmu2500Directive
  alarmsMonitoringHmu2500Directive
  eventStatisticHmu2500Directive
  eventStartlistHmu2500Directive
  pueHmu2500Directive
  realTimePueHmu2500Directive
  reportHistorysignalSingleDirective
  deviceTreeSingleDirective
  reportQueryTimeSingleDirective
  barOrLineSingleDirective
  alarmQueryHmu2500Directive
  signalConfigurationDirective
  userManageDirective
  manageDataDirective
  timeManageDirective
  componentDevicemonitorHmu2500Directive
  componentLineHmu2500Directive
  equipLineorbarHmu2500Directive
  monitoringLeonHmu2500Directive
  helpInformationDirective
  equipmentAirCloudDirective
  logSystemDirective
  signalConfigurationHmu2500Directive
  # {{directive-namespace}}

  # {{filter-namespace}}
  plugins
) ->
  # services
  module.service 'commonService', ['$rootScope', '$http', 'modelEngine','liveService', 'reportingService', 'uploadService', commonService.CommonService]

  module.service 'datacenterService', ['$rootScope', 'httpService', ($rootScope, httpService) ->
    new datacenterService.DatacenterService $rootScope, httpService
  ]
  # {{service-register}}

  # controllers
  # add $timeout and modelEngine
  createModelController20 = (name, Controller, type, key, title) ->
    module.controller name, ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$timeout', 'modelManager', 'modelEngine', 'uploadService',
      ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService) ->
        options =
          type: type
          key: key
          title: title
          uploadUrl: setting.urls.uploadUrl
          fileUrl: setting.urls.fileUrl
          url: setting.urls[type]

        new Controller $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, options
    ]

  # add datacenter service
  createModelController21 = (name, Controller, type, key, title) ->
    module.controller name, ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$timeout', 'modelManager', 'modelEngine', 'uploadService', 'datacenterService'
      ($scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, datacenterService) ->
        options =
          type: type
          key: key
          title: title
          uploadUrl: setting.urls.uploadUrl
          fileUrl: setting.urls.fileUrl
          url: setting.urls[type]

        new Controller $scope, $rootScope, $routeParams, $location, $window, $timeout, modelManager, modelEngine, uploadService, datacenterService, options
    ]

  createModelController21 'DatacenterController', datacenterController.DatacenterController, 'project', ['user', 'project'], '数据中心'
  createModelController20 'SettingController', settingController.SettingController, 'project', ['user', 'project'], '系统设置'
  createModelController20 'DashboardController', dashboardController.DashboardController, 'project', ['user', 'project'], 'Dashboard'

  createModelController20 'InventoryController', inventoryController.InventoryController, 'project', ['user', 'project'], '资产管理'

  createModelController20 'StationSettingController', stationSettingController.StationSettingController, 'project', ['user', 'project'], '站点管理'
  createModelController20 'AlarmController', alarmController.AlarmController, 'project', ['user', 'project'], '告警管理'

  createModelController20 'EnergyController', energyController.EnergyController, 'project', ['user', 'project'], '能耗分析'
  createModelController20 'VideoController', videoController.VideoController, 'project', ['user', 'project'], '视频监控'
  createModelController20 'MonitoringController', monitoringController.MonitoringController, 'project', ['user', 'project'], '实时监控'
  createModelController20 'DoorManagerController', doorManagerController.DoorManagerController, 'project', ['user', 'project'], '门禁管理'
  createModelController20 'UserManagerController', userManagerController.UserManagerController, 'project', ['user', 'project'], '门禁用户'
  createModelController20 'UserManagementController', userManagementController.UserManagementController, 'project', ['user', 'project'], 'UserManagement'
  createModelController20 'CardManageController', cardManageController.CardManageController, 'project', ['user', 'project'], '门卡管理'

  createModelController20 'LinkController', linkController.LinkController, 'project', ['user', 'project'], '联动管理'
  createModelController20 'NotificationController', notificationController.NotificationController, 'project', ['user', 'project'], '告警通知'
  createModelController20 'AssetReportController', assetReportController.AssetReportController, 'project', ['user', 'project'], '资产报表'
  createModelController20 'UserInfoController', userInfoController.UserInfoController, 'project', ['user', 'project'], '用户管理'
  createModelController20 'AlarmReportController', alarmReportController.AlarmReportController, 'project', ['user', 'project'], '告警记录'
  createModelController20 'TemperatureCloudController', temperatureCloudController.TemperatureCloudController, 'project', ['user', 'project'], '温度云场'

  createModelController20 'LogController', logController.LogController, 'project', ['user', 'project'], '日志管理'
  createModelController20 'SignalReportController', signalReportController.SignalReportController, 'project', ['user', 'project'], '历史数据'
  createModelController20 'CardManagerController', cardManagerController.CardManagerController, 'project', ['user', 'project'], '门卡管理'
  createModelController20 'DoorPlanController', doorPlanController.DoorPlanController, 'project', ['user', 'project'], '门授权'
  createModelController20 'Video_histroy_listController', video_histroy_listController.Video_histroy_listController, 'project', ['user', 'project'], '历史视频'

  module.controller 'LiveMainController', ['$scope', '$rootScope', '$routeParams', '$location', '$window', '$translate', 'storage', 'authService', 'liveService', 'modelManager', 'modelEngine', '$filter', liveMainController.LiveMainController]
  module.controller 'LoginController', ['$scope', '$rootScope', '$routeParams', '$location', '$window', 'authService', 'storage', loginController.LoginController]
  createModelController20 'DispatchController', dispatchController.DispatchController, 'project', ['user', 'project'], 'Dispatch'
  createModelController20 'Station3dController', station3dController.Station3dController, 'project', ['user', 'project'], '3D呈现'
  createModelController20 'AlarmSettingController', alarmSettingController.AlarmSettingController, 'project', ['user', 'project'], '告警设置'
  createModelController20 'MobileController', mobileController.MobileController, 'project', ['user', 'project'], '移动APP'

  createModelController20 'Video_reliable_listController', video_reliable_listController.Video_reliable_listController, 'project', ['user', 'project'], 'Video_reliable_list'

  createModelController20 'RecordHiscurveController', recordHiscurveController.RecordHiscurveController, 'project', ['user', 'project'], 'RecordHiscurve'
  createModelController20 'ReportingSignalController', reportingSignalController.ReportingSignalController, 'project', ['user', 'project'], 'ReportingSignal'
  createModelController20 'ElectricityConsumptionController', electricityConsumptionController.ElectricityConsumptionController, 'project', ['user', 'project'], 'ElectricityConsumption'
  createModelController20 'ReportActiveeventsController', reportActiveeventsController.ReportActiveeventsController, 'project', ['user', 'project'], 'ReportActiveevents'
  createModelController20 'FinishAlarmController', finishAlarmController.FinishAlarmController, 'project', ['user', 'project'], 'FinishAlarm'
  createModelController20 'BatteryAlarmController', batteryAlarmController.BatteryAlarmController, 'project', ['user', 'project'], 'BatteryAlarm'
  createModelController20 'UpsAlarmController', upsAlarmController.UpsAlarmController, 'project', ['user', 'project'], 'UpsAlarm'

  createModelController20 'ReportingController', reportingController.ReportingController, 'project', ['user', 'project'], 'Reporting'
  createModelController20 'AcAlarmController', acAlarmController.AcAlarmController, 'project', ['user', 'project'], 'AcAlarm'
  createModelController20 'HistorySendNotificationController', historySendNotificationController.HistorySendNotificationController, 'project', ['user', 'project'], 'HistorySendNotification'
  createModelController20 'ReportOperationsController', reportOperationsController.ReportOperationsController, 'project', ['user', 'project'], 'ReportOperations'
  createModelController20 'ReportSystemlogController', reportSystemlogController.ReportSystemlogController, 'project', ['user', 'project'], 'ReportSystemlog'
  createModelController20 'UserExcluController', userExcluController.UserExcluController, 'project', ['user', 'project'], 'UserExclu'
  createModelController20 'ComponentRolesrightsController', componentRolesrightsController.ComponentRolesrightsController, 'project', ['user', 'project'], 'ComponentRolesrights'

  createModelController20 'IpSettingController', ipSettingController.IpSettingController, 'project', ['user', 'project'], 'IpSetting'
  createModelController20 'EquipmentsController', equipmentsController.EquipmentsController, 'project', ['user', 'project'], 'Equipments'
  createModelController20 'BaseMapConfigurationController', baseMapConfigurationController.BaseMapConfigurationController, 'project', ['user', 'project'], 'BaseMapConfiguration'
  createModelController20 'BatchConfigurationController', batchConfigurationController.BatchConfigurationController, 'project', ['user', 'project'], 'BatchConfiguration'
  createModelController20 'GraphicPageController', graphicPageController.GraphicPageController, 'project', ['user', 'project'], 'GraphicPage'
  createModelController20 'HistoricalAlarmController', historicalAlarmController.HistoricalAlarmController, 'project', ['user', 'project'], 'HistoricalAlarm'
  createModelController20 'SignalConfigurationController', signalConfigurationController.SignalConfigurationController, 'project', ['user', 'project'], 'SignalConfiguration'
  createModelController20 'ManageDataController', manageDataController.ManageDataController, 'project', ['user', 'project'], 'ManageData'
  createModelController20 'TimeManageController', timeManageController.TimeManageController, 'project', ['user', 'project'], 'TimeManage'
  createModelController20 'HelpInformationController', helpInformationController.HelpInformationController, 'project', ['user', 'project'], 'HelpInformation'
  # {{controller-register}}

  # directives
#  module.directive 'graphicViewer', ['$window', '$timeout', 'modelManager', 'storage', graphicDirectives.GraphicViewerDirective]
#  module.directive 'graphicPlayer', ['$window', '$timeout', '$compile', 'modelManager', 'liveService', 'storage', graphicDirectives.GraphicPlayerDirective]
#  module.directive 'elementPopover', ['$timeout', '$compile', graphicDirectives.ElementPopoverDirective]
  # {{directive-register}}

  createDirective = (name, Directive) ->
    module.directive name, ['$timeout', '$window', '$compile', '$routeParams', 'commonService', ($timeout, $window, $compile, $routeParams, commonService)->
      new Directive $timeout, $window, $compile, $routeParams, commonService
    ]
  createDirective 'menu', menuDirective.MenuDirective
  createDirective 'menuControl', menuControlDirective.MenuControlDirective
  createDirective 'signalGauge', signalGaugeDirective.SignalGaugeDirective
  createDirective 'customHeader', customHeaderDirective.CustomHeaderDirective
  createDirective 'capacityRadar', capacityRadarDirective.CapacityRadarDirective
  
  
  
  createDirective 'stationBreadcrumbs', stationBreadcrumbsDirective.StationBreadcrumbsDirective
  
  
  
  createDirective 'room3dComponent', room3dComponentDirective.Room3dComponentDirective
  createDirective 'rack3dComponent', rack3dComponentDirective.Rack3dComponentDirective
  createDirective 'inventoryManage', inventoryManageDirective.InventoryManageDirective
  createDirective 'header', headerDirective.HeaderDirective
  createDirective 'systemSetting', systemSettingDirective.SystemSettingDirective
  
  createDirective 'eventManager', eventManagerDirective.EventManagerDirective
  createDirective 'eventStatistic', eventStatisticDirective.EventStatisticDirective
  createDirective 'eventStatisticChart', eventStatisticChartDirective.EventStatisticChartDirective
  createDirective 'eventList', eventListDirective.EventListDirective
  createDirective 'searchInput', searchInputDirective.SearchInputDirective
  
  
  
  
  createDirective 'equipmentBreadcrumbs', equipmentBreadcrumbsDirective.EquipmentBreadcrumbsDirective
  createDirective 'percentGauge', percentGaugeDirective.PercentGaugeDirective
  createDirective 'discoveryStation', discoveryStationDirective.DiscoveryStationDirective
  
  createDirective 'micromoduleDashboard', micromoduleDashboardDirective.MicromoduleDashboardDirective
  createDirective 'safeOperationDays', safeOperationDaysDirective.SafeOperationDaysDirective
  createDirective 'alarmNumberBox', alarmNumberBoxDirective.AlarmNumberBoxDirective
  createDirective 'pueValue', pueValueDirective.PueValueDirective
  createDirective 'capacityManagement', capacityManagementDirective.CapacityManagementDirective
  createDirective 'capacityAsset', capacityAssetDirective.CapacityAssetDirective
  createDirective 'equipmentQuantity', equipmentQuantityDirective.EquipmentQuantityDirective
  createDirective 'yingmaiVideo', yingmaiVideoDirective.YingmaiVideoDirective
  createDirective 'yingmaiEnvironment', yingmaiEnvironmentDirective.YingmaiEnvironmentDirective
  createDirective 'energyManagement', energyManagementDirective.EnergyManagementDirective
  createDirective 'signalGaugePicker', signalGaugePickerDirective.SignalGaugePickerDirective
  createDirective 'energyYearPie', energyYearPieDirective.EnergyYearPieDirective
  createDirective 'realTimePue', realTimePueDirective.RealTimePueDirective
  createDirective 'totalEnergyBar', totalEnergyBarDirective.TotalEnergyBarDirective
  createDirective 'pue', pueDirective.PueDirective
  
  createDirective 'equipmentInfo', equipmentInfoDirective.EquipmentInfoDirective
  createDirective 'doorManager', doorManagerDirective.DoorManagerDirective
  createDirective 'creditRecordLast', creditRecordLastDirective.CreditRecordLastDirective
  createDirective 'creditRecords', creditRecordsDirective.CreditRecordsDirective
  createDirective 'equipDoor', equipDoorDirective.EquipDoorDirective
  createDirective 'userManager', userManagerDirective.UserManagerDirective
  createDirective 'rotateShowingModel', rotateShowingModelDirective.RotateShowingModelDirective
  createDirective 'videoList', videoListDirective.VideoListDirective
  createDirective 'singleVideo', singleVideoDirective.SingleVideoDirective
  createDirective 'funcDevicemonitor', funcDevicemonitorDirective.FuncDevicemonitorDirective
  
  createDirective 'graphicparamterBox', graphicparamterBoxDirective.GraphicparamterBoxDirective
  createDirective 'userManagement', userManagementDirective.UserManagementDirective
  createDirective 'cardManage', cardManageDirective.CardManageDirective
  createDirective 'notification', notificationDirective.NotificationDirective
  createDirective 'alarmLink', alarmLinkDirective.AlarmLinkDirective
  createDirective 'stationVisualization', stationVisualizationDirective.StationVisualizationDirective
  createDirective 'visualizationTree', visualizationTreeDirective.VisualizationTreeDirective
  createDirective 'reportingAsset', reportingAssetDirective.ReportingAssetDirective
  createDirective 'userPersoninfo', userPersoninfoDirective.UserPersoninfoDirective
  createDirective 'graphicBox', graphicBoxDirective.GraphicBoxDirective
  createDirective 'reportOperations', reportOperationsDirective.ReportOperationsDirective
  createDirective 'reportHistorysignal', reportHistorysignalDirective.ReportHistorysignalDirective
  createDirective 'deviceTree', deviceTreeDirective.DeviceTreeDirective
  createDirective 'gridTable', gridTableDirective.GridTableDirective
  createDirective 'barOrLine', barOrLineDirective.BarOrLineDirective
  createDirective 'dropDown', dropDownDirective.DropDownDirective
  createDirective 'cardManager', cardManagerDirective.CardManagerDirective
  createDirective 'doorPlan', doorPlanDirective.DoorPlanDirective
  createDirective 'queryReport', queryReportDirective.QueryReportDirective
  createDirective 'equipmentProperty', equipmentPropertyDirective.EquipmentPropertyDirective
  createDirective 'videoHistory', videoHistoryDirective.VideoHistoryDirective
  createDirective 'glvideoDatepicker', glvideoDatepickerDirective.GlvideoDatepickerDirective
  createDirective 'reportQueryTime', reportQueryTimeDirective.ReportQueryTimeDirective
  createDirective 'reportAlarmRecords', reportAlarmRecordsDirective.ReportAlarmRecordsDirective
  createDirective 'customDashboard', customDashboardDirective.CustomDashboardDirective
  createDirective 'dashboardHeader1', dashboardHeader1Directive.DashboardHeader1Directive
  createDirective 'stationGraphic', stationGraphicDirective.StationGraphicDirective
  createDirective 'discoveryStationManagement', discoveryStationManagementDirective.DiscoveryStationManagementDirective
  createDirective 'equipmentSignals', equipmentSignalsDirective.EquipmentSignalsDirective
  createDirective 'alarmSeverityBoxes', alarmSeverityBoxesDirective.AlarmSeverityBoxesDirective
  createDirective 'childStationsEnvironment', childStationsEnvironmentDirective.ChildStationsEnvironmentDirective
  createDirective 'upsManager', upsManagerDirective.UpsManagerDirective
  createDirective 'percentPie', percentPieDirective.PercentPieDirective
  createDirective 'distributionManager', distributionManagerDirective.DistributionManagerDirective
  createDirective 'signalPie', signalPieDirective.SignalPieDirective
  createDirective 'stationEnvironment', stationEnvironmentDirective.StationEnvironmentDirective
  createDirective 'signalRealValue', signalRealValueDirective.SignalRealValueDirective
  createDirective 'acoustoOpticControl', acoustoOpticControlDirective.AcoustoOpticControlDirective
  createDirective 'deviceFilter', deviceFilterDirective.DeviceFilterDirective
  createDirective 'stationTree', stationTreeDirective.StationTreeDirective
  
  createDirective 'signalExtreme', signalExtremeDirective.SignalExtremeDirective
  createDirective 'monitoring', monitoringDirective.MonitoringDirective
  createDirective 'equipmentTimefilter', equipmentTimefilterDirective.EquipmentTimefilterDirective
  
  createDirective 'alarmSetting', alarmSettingDirective.AlarmSettingDirective
  createDirective 'station3d', station3dDirective.Station3dDirective
  
  
  
  
  
  createDirective 'appQrcode', appQrcodeDirective.AppQrcodeDirective
  
  createDirective 'componentPie', componentPieDirective.ComponentPieDirective
  
  createDirective 'alarmsMonitoring', alarmsMonitoringDirective.AlarmsMonitoringDirective
  createDirective 'stationTreeWithCount', stationTreeWithCountDirective.StationTreeWithCountDirective
  createDirective 'stationVideo', stationVideoDirective.StationVideoDirective
  createDirective 'equipmentStatistic', equipmentStatisticDirective.EquipmentStatisticDirective
  
  
  createDirective 'videoReliableDahua', videoReliableDahuaDirective.VideoReliableDahuaDirective
  createDirective 'videoReliableHik', videoReliableHikDirective.VideoReliableHikDirective
  createDirective 'videoHistoryDahua', videoHistoryDahuaDirective.VideoHistoryDahuaDirective
  createDirective 'importAssets', importAssetsDirective.ImportAssetsDirective
  createDirective 'serverPerformanceinfo', serverPerformanceinfoDirective.ServerPerformanceinfoDirective

  createDirective 'eventAnalysisChart', eventAnalysisChartDirective.EventAnalysisChartDirective
  

  createDirective 'equipmentAir', equipmentAirDirective.EquipmentAirDirective

  
  
  
  
  
  
  createDirective 'oneFileUploader', oneFileUploaderDirective.OneFileUploaderDirective
  
  
  
  
  
  
  createDirective 'threeQuarterPie', threeQuarterPieDirective.ThreeQuarterPieDirective
  
  createDirective 'deviceTreeLeon', deviceTreeLeonDirective.DeviceTreeLeonDirective
  createDirective 'stationEnvironmentyu', stationEnvironmentyuDirective.StationEnvironmentyuDirective
  createDirective 'notificationyu', notificationyuDirective.NotificationyuDirective
  createDirective 'pluginUploader', pluginUploaderDirective.PluginUploaderDirective
  createDirective 'electricityConsumption', electricityConsumptionDirective.ElectricityConsumptionDirective
  createDirective 'reportActiveevents', reportActiveeventsDirective.ReportActiveeventsDirective
  createDirective 'batteryAlarm', batteryAlarmDirective.BatteryAlarmDirective
  createDirective 'deviceAcclaAlarm', deviceAcclaAlarmDirective.DeviceAcclaAlarmDirective
  createDirective 'finishAlarm', finishAlarmDirective.FinishAlarmDirective
  createDirective 'alarmQuery', alarmQueryDirective.AlarmQueryDirective
  createDirective 'reportUsers', reportUsersDirective.ReportUsersDirective
  
  createDirective 'reportingSignal', reportingSignalDirective.ReportingSignalDirective
  createDirective 'recordHiscurve', recordHiscurveDirective.RecordHiscurveDirective
  createDirective 'lineorbarTree', lineorbarTreeDirective.LineorbarTreeDirective
  createDirective 'lineorbarEchart', lineorbarEchartDirective.LineorbarEchartDirective
  
  createDirective 'pagingEquipment', pagingEquipmentDirective.PagingEquipmentDirective
  createDirective 'eventStartlist', eventStartlistDirective.EventStartlistDirective
  createDirective 'historySendNotification', historySendNotificationDirective.HistorySendNotificationDirective
  createDirective 'reportSystemlog', reportSystemlogDirective.ReportSystemlogDirective
  createDirective 'reportNotifications', reportNotificationsDirective.ReportNotificationsDirective
  createDirective 'stationVideos', stationVideosDirective.StationVideosDirective
  createDirective 'singleVideoCore', singleVideoCoreDirective.SingleVideoCoreDirective
  createDirective 'videoListbetter', videoListbetterDirective.VideoListbetterDirective
  
  createDirective 'componentRolesrights', componentRolesrightsDirective.ComponentRolesrightsDirective
  
  
  createDirective 'heatfieldCloud', heatfieldCloudDirective.HeatfieldCloudDirective
  
  
  
  
  
  createDirective 'videoAutoplay', videoAutoplayDirective.VideoAutoplayDirective
  createDirective 'assetManage', assetManageDirective.AssetManageDirective
  createDirective 'assetDetail', assetDetailDirective.AssetDetailDirective
  createDirective 'reportingTable', reportingTableDirective.ReportingTableDirective
  createDirective 'room3dComponent2', room3dComponent2Directive.Room3dComponent2Directive
  
  
  
  
  createDirective 'equipLineorbarless', equipLineorbarlessDirective.EquipLineorbarlessDirective
  createDirective 'eventListless', eventListlessDirective.EventListlessDirective
  
  createDirective 'ipSetting', ipSettingDirective.IpSettingDirective
  createDirective 'equipments', equipmentsDirective.EquipmentsDirective
  createDirective 'discoveryManagement', discoveryManagementDirective.DiscoveryManagementDirective

  
  createDirective 'stationEnvironmentChongqing', stationEnvironmentChongqingDirective.StationEnvironmentChongqingDirective
  createDirective 'noticeTip2', noticeTip2Directive.NoticeTip2Directive
  
  createDirective 'customLabelLocation', customLabelLocationDirective.CustomLabelLocationDirective
  createDirective 'baseMapConfiguration', baseMapConfigurationDirective.BaseMapConfigurationDirective
  createDirective 'batchConfiguration', batchConfigurationDirective.BatchConfigurationDirective
  
  createDirective 'equipmentList', equipmentListDirective.EquipmentListDirective
  createDirective 'systemInfo', systemInfoDirective.SystemInfoDirective
  createDirective 'loginHmu2500', loginHmu2500Directive.LoginHmu2500Directive
  createDirective 'alarmsMonitoringHmu2500', alarmsMonitoringHmu2500Directive.AlarmsMonitoringHmu2500Directive
  createDirective 'eventStatisticHmu2500', eventStatisticHmu2500Directive.EventStatisticHmu2500Directive
  createDirective 'eventStartlistHmu2500', eventStartlistHmu2500Directive.EventStartlistHmu2500Directive
  createDirective 'pueHmu2500', pueHmu2500Directive.PueHmu2500Directive
  createDirective 'realTimePueHmu2500', realTimePueHmu2500Directive.RealTimePueHmu2500Directive
  createDirective 'reportHistorysignalSingle', reportHistorysignalSingleDirective.ReportHistorysignalSingleDirective
  createDirective 'deviceTreeSingle', deviceTreeSingleDirective.DeviceTreeSingleDirective
  createDirective 'reportQueryTimeSingle', reportQueryTimeSingleDirective.ReportQueryTimeSingleDirective
  createDirective 'barOrLineSingle', barOrLineSingleDirective.BarOrLineSingleDirective
  createDirective 'alarmQueryHmu2500', alarmQueryHmu2500Directive.AlarmQueryHmu2500Directive
  createDirective 'signalConfiguration', signalConfigurationDirective.SignalConfigurationDirective
  createDirective 'userManage', userManageDirective.UserManageDirective
  createDirective 'manageData', manageDataDirective.ManageDataDirective
  createDirective 'timeManage', timeManageDirective.TimeManageDirective
  createDirective 'componentDevicemonitorHmu2500', componentDevicemonitorHmu2500Directive.ComponentDevicemonitorHmu2500Directive
  createDirective 'componentLineHmu2500', componentLineHmu2500Directive.ComponentLineHmu2500Directive
  createDirective 'equipLineorbarHmu2500', equipLineorbarHmu2500Directive.EquipLineorbarHmu2500Directive
  createDirective 'monitoringLeonHmu2500', monitoringLeonHmu2500Directive.MonitoringLeonHmu2500Directive
  createDirective 'helpInformation', helpInformationDirective.HelpInformationDirective
  createDirective 'equipmentAirCloud', equipmentAirCloudDirective.EquipmentAirCloudDirective
  createDirective 'logSystem', logSystemDirective.LogSystemDirective
  createDirective 'signalConfigurationHmu2500', signalConfigurationHmu2500Directive.SignalConfigurationHmu2500Directive
  # {{component-register}}

  
  
  createDirective 'graphicPage', graphicPageDirective.GraphicPageDirective
  createDirective 'listBreadcrumbs', listBreadcrumbsDirective.ListBreadcrumbsDirective
  createDirective 'logicAction', logicActionDirective.LogicActionDirective
  createDirective 'notificationSetting', notificationSettingDirective.NotificationSettingDirective
# {{component-register}}

  #filters
  # {{filter-register}}

