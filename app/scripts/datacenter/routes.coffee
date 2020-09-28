###
* File: routes
* User: Dow
* Date: 2014/10/24
###

# compatible for node.js and requirejs
`if (typeof define !== "function") { var define = require("amdefine")(module) }`

define ["clc.foundation.angular/router"], (base) ->
  class Router extends base.Router
    constructor: ($routeProvider) ->
      super $routeProvider

    start: () ->
      namespace = window.setting.namespace ? "datacenter"

      @routeTemplateUrl "/home", "/#{namespace}/home/templates/index", "HomeController"
      @routeTemplateUrl "/config", "/#{namespace}/home/templates/config", "HomeController"

      namespace += "/portal"

      @routeTemplateUrl "/login", "/#{namespace}/templates/login", "LoginController"
      @routeTemplateUrl "/users/:user", "/#{namespace}/templates/user", "UserController"
      @routeTemplateUrl "/401", "/#{namespace}/templates/401", "MainController"

      @routeTemplateUrl "/", "/#{namespace}/templates/projects", "DatacenterController"
      @routeTemplateUrl "/dispatch/:user/:project", "/#{namespace}/templates/projects", "DispatchController"

      # project model
      @routeTemplateUrl "/projects", "/#{namespace}/templates/projects", "ProjectsController"
      @routeTemplateUrl "/project/:user/:project", "/#{namespace}/templates/project", "ProjectController"

#      @routeTemplateUrl "/datacenter/:user/:project", "/#{namespace}/templates/datacenter", "DatacenterController"
      @routeTemplateUrl "/setting/:user/:project", "/#{namespace}/templates/setting", "SettingController"
      @routeTemplateUrl "/dashboard/:user/:project", "/#{namespace}/templates/dashboard", "DashboardController"
      @routeTemplateUrl "/capacity/:user/:project", "/#{namespace}/templates/capacity", "CapacityController"
      @routeTemplateUrl "/inventory/:user/:project", "/#{namespace}/templates/inventory", "InventoryController"
      @routeTemplateUrl "/capacity-2d/:user/:project", "/#{namespace}/templates/capacity_2d", "Capacity2dController"
      @routeTemplateUrl "/station-setting/:user/:project", "/#{namespace}/templates/station_setting", "StationSettingController"
      @routeTemplateUrl "/event-manager/:user/:project", "/#{namespace}/templates/alarm", "AlarmController"
      @routeTemplateUrl "/rack-plan/:user/:project", "/#{namespace}/templates/rack_plan", "RackPlanController"
      @routeTemplateUrl "/energy/:user/:project", "/#{namespace}/templates/energy", "EnergyController"
      @routeTemplateUrl "/video/:user/:project", "/#{namespace}/templates/video", "VideoController"
      @routeTemplateUrl "/monitoring/:user/:project", "/#{namespace}/templates/monitoring", "MonitoringController"
      @routeTemplateUrl "/door-manager/:user/:project", "/#{namespace}/templates/door_manager", "DoorManagerController"

      @routeTemplateUrl "/user-manager/:user/:project", "/#{namespace}/templates/user_manager", "UserManagerController"
      @routeTemplateUrl "/user-management/:user/:project", "/#{namespace}/templates/user_management", "UserManagementController"
      @routeTemplateUrl "/card-manage/:user/:project", "/#{namespace}/templates/card_manage", "CardManageController"
      @routeTemplateUrl "/distribute/:user/:project", "/#{namespace}/templates/distribute", "DistributeController"
      @routeTemplateUrl "/graphicac/:user/:project", "/#{namespace}/templates/graphicac", "GraphicacController"
      @routeTemplateUrl "/link/:user/:project", "/#{namespace}/templates/link", "LinkController"
      @routeTemplateUrl "/notification/:user/:project", "/#{namespace}/templates/notification", "NotificationController"
      @routeTemplateUrl "/asset-report/:user/:project", "/#{namespace}/templates/asset_report", "AssetReportController"
      @routeTemplateUrl "/user-info/:user/:project", "/#{namespace}/templates/user_info", "UserInfoController"
      @routeTemplateUrl "/alarm-report/:user/:project", "/#{namespace}/templates/alarm_report", "AlarmReportController"
      @routeTemplateUrl "/temperature-cloud/:user/:project", "/#{namespace}/templates/temperature_cloud", "TemperatureCloudController"
      @routeTemplateUrl "/inspect/:user/:project", "/#{namespace}/templates/inspect", "InspectController"
      @routeTemplateUrl "/job/:user/:project", "/#{namespace}/templates/job", "JobController"
      @routeTemplateUrl "/knowledge/:user/:project", "/#{namespace}/templates/knowledge", "KnowledgeController"
      @routeTemplateUrl "/schedule/:user/:project", "/#{namespace}/templates/schedule", "ScheduleController"
      @routeTemplateUrl "/log/:user/:project", "/#{namespace}/templates/log", "LogController"
      @routeTemplateUrl "/signal-report/:user/:project", "/#{namespace}/templates/signal_report", "SignalReportController"
      @routeTemplateUrl "/card-manager/:user/:project", "/#{namespace}/templates/card_manager", "CardManagerController"
      @routeTemplateUrl "/door-plan/:user/:project", "/#{namespace}/templates/door_plan", "DoorPlanController"
      @routeTemplateUrl "/video_histroy_list/:user/:project", "/#{namespace}/templates/video_histroy_list", "Video_histroy_listController"
      @routeTemplateUrl "/station-3d/:user/:project", "/#{namespace}/templates/station_3d", "Station3dController"
      @routeTemplateUrl "/alarm-setting/:user/:project", "/#{namespace}/templates/alarm_setting", "AlarmSettingController"
      @routeTemplateUrl "/mobile/:user/:project", "/#{namespace}/templates/mobile", "MobileController"
      @routeTemplateUrl "/jobs/:user/:project", "/#{namespace}/templates/jobs", "JobsController"
      @routeTemplateUrl "/door-report/:user/:project", "/#{namespace}/templates/door_report", "DoorReportController"
      @routeTemplateUrl "/video_reliable_list/:user/:project", "/#{namespace}/templates/video_reliable_list", "Video_reliable_listController"
      @routeTemplateUrl "/energy_flow/:user/:project", "/#{namespace}/templates/energy_flow", "Energy_flowController"
      @routeTemplateUrl "/work-overviewinfo/:user/:project", "/#{namespace}/templates/work_overviewinfo", "WorkOverviewinfoController"
      @routeTemplateUrl "/work-calendar/:user/:project", "/#{namespace}/templates/work_calendar", "WorkCalendarController"
      @routeTemplateUrl "/main-tasks/:user/:project", "/#{namespace}/templates/main_tasks", "MainTasksController"
      @routeTemplateUrl "/report-tasksum/:user/:project", "/#{namespace}/templates/report_tasksum", "ReportTasksumController"
      @routeTemplateUrl "/work-manager/:user/:project", "/#{namespace}/templates/work_manager", "WorkManagerController"
      @routeTemplateUrl "/electric-calendar/:user/:project", "/#{namespace}/templates/electric_calendar", "ElectricCalendarController"
      @routeTemplateUrl "/work-employee/:user/:project", "/#{namespace}/templates/work_employee", "WorkEmployeeController"
      @routeTemplateUrl "/report-frequencyevents/:user/:project", "/#{namespace}/templates/report_frequencyevents", "ReportFrequencyeventsController"
      @routeTemplateUrl "/record-hiscurve/:user/:project", "/#{namespace}/templates/record_hiscurve", "RecordHiscurveController"
      @routeTemplateUrl "/reporting-signal/:user/:project", "/#{namespace}/templates/reporting_signal", "ReportingSignalController"
      @routeTemplateUrl "/electricity-consumption/:user/:project", "/#{namespace}/templates/electricity_consumption", "ElectricityConsumptionController"
      @routeTemplateUrl "/report-activeevents/:user/:project", "/#{namespace}/templates/report_activeevents", "ReportActiveeventsController"
      @routeTemplateUrl "/finish-alarm/:user/:project", "/#{namespace}/templates/finish_alarm", "FinishAlarmController"
      @routeTemplateUrl "/battery-alarm/:user/:project", "/#{namespace}/templates/battery_alarm", "BatteryAlarmController"
      @routeTemplateUrl "/ups-alarm/:user/:project", "/#{namespace}/templates/ups_alarm", "UpsAlarmController"
      @routeTemplateUrl "/repord-report-alarm/:user/:project", "/#{namespace}/templates/repord_report_alarm", "RepordReportAlarmController"
      @routeTemplateUrl "/reporting/:user/:project", "/#{namespace}/templates/reporting", "ReportingController"
      @routeTemplateUrl "/ac-alarm/:user/:project", "/#{namespace}/templates/ac_alarm", "AcAlarmController"
      @routeTemplateUrl "/history-send-notification/:user/:project", "/#{namespace}/templates/history_send_notification", "HistorySendNotificationController"
      @routeTemplateUrl "/report-operations/:user/:project", "/#{namespace}/templates/report_operations", "ReportOperationsController"
      @routeTemplateUrl "/report-systemlog/:user/:project", "/#{namespace}/templates/report_systemlog", "ReportSystemlogController"
      @routeTemplateUrl "/temperature-cloud-2d/:user/:project", "/#{namespace}/templates/temperature_cloud_2d", "TemperatureCloud2dController"
      @routeTemplateUrl "/user-exclu/:user/:project", "/#{namespace}/templates/user_exclu", "UserExcluController"
      @routeTemplateUrl "/component-rolesrights/:user/:project", "/#{namespace}/templates/component_rolesrights", "ComponentRolesrightsController"
      @routeTemplateUrl "/temperature-cloud-3d/:user/:project", "/#{namespace}/templates/temperature_cloud_3d", "TemperatureCloud3dController"
      @routeTemplateUrl "/rack-stage-3d/:user/:project", "/#{namespace}/templates/rack_stage_3d", "RackStage3dController"
      @routeTemplateUrl "/temperature-cloud-history/:user/:project", "/#{namespace}/templates/temperature_cloud_history", "TemperatureCloudHistoryController"
      @routeTemplateUrl "/distribute-faultdrill/:user/:project", "/#{namespace}/templates/distribute_faultdrill", "DistributefaultdrillController"
      @routeTemplateUrl "/distribute-safe/:user/:project", "/#{namespace}/templates/distribute_safe", "DistributesafeController"
      @routeTemplateUrl "/ip-setting/:user/:project", "/#{namespace}/templates/ip_setting", "IpSettingController"
      @routeTemplateUrl "/equipments/:user/:project", "/#{namespace}/templates/equipments", "EquipmentsController"
      @routeTemplateUrl "/base-map-configuration/:user/:project", "/#{namespace}/templates/base_map_configuration", "BaseMapConfigurationController"
      @routeTemplateUrl "/batch-configuration/:user/:project", "/#{namespace}/templates/batch_configuration", "BatchConfigurationController"
      @routeTemplateUrl "/graphic-page/:user/:project", "/#{namespace}/templates/graphic_page", "GraphicPageController"
      @routeTemplateUrl "/historical-alarm/:user/:project", "/#{namespace}/templates/historical_alarm", "HistoricalAlarmController"
      @routeTemplateUrl "/signal-configuration/:user/:project", "/#{namespace}/templates/signal_configuration", "SignalConfigurationController"
      @routeTemplateUrl "/manage-data/:user/:project", "/#{namespace}/templates/manage_data", "ManageDataController"
      @routeTemplateUrl "/time-manage/:user/:project", "/#{namespace}/templates/time_manage", "TimeManageController"
      @routeTemplateUrl "/help-information/:user/:project", "/#{namespace}/templates/help_information", "HelpInformationController"
      # {{route-register}}

      super
      @routeTemplateUrl "/:key/:user/:project", "/#{namespace}/templates/custom_dashboard", "DashboardController"

  exports =
    Router: Router