import 'package:dart_either/dart_either.dart';
import 'package:pin_tunnel_application_production/features/feature/data/data_sources/supabase_service.dart';
import 'package:pin_tunnel_application_production/features/feature/data/models/chart_data/daily_chart_data_dao.dart';
import 'package:pin_tunnel_application_production/features/feature/data/models/chart_data/monthly_chart_data_dao.dart';
import 'package:pin_tunnel_application_production/features/feature/data/models/chart_data/weekly_chart_data_dao.dart';
import 'package:pin_tunnel_application_production/features/feature/data/models/latest_data_dao.dart';
import 'package:pin_tunnel_application_production/features/feature/data/models/sensor_range_dao.dart';
import 'package:pin_tunnel_application_production/features/feature/domain/entities/action_class.dart';
import 'package:pin_tunnel_application_production/features/feature/domain/entities/chart_data.dart';
import 'package:pin_tunnel_application_production/features/feature/domain/entities/latest_data.dart';
import 'package:pin_tunnel_application_production/features/feature/domain/repository/i_pin_tunnel_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/sensor_class.dart';
import '../models/sensor_dao.dart';

class PinTunnelRepository implements IPinTunnelRepository {
  @override
  subscribeToChannel(int sensorId, Function(dynamic) onReceived) async {
    try {
      /*final response = await supabaseManager.supabaseClient
          .from('pintunnel_data')
          .select('''time, data''')
          .eq('sensor_mac', sensorId)
          .order('time', ascending: false)
          .limit(10);

      print(sensorId);
      print("RESPONSE: $response");
      if (response != null) {
        onReceived({'sensor_data': response});
      }*/

      supabaseManager.supabaseClient.channel('*').on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
            event: '*',
            schema: '*',
            table: 'pintunnel_data',
            filter: 'sensor_mac=eq.$sensorId'),
        (payload, [ref]) {
          //print('Change received: ${payload.toString()}');
          print(payload);
          onReceived({
            'sensor_data': payload['new']['data'],
            'sensor_mac': payload['new']['sensor_mac']
          });
        },
      ).subscribe();
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<Either<Failure, List<LatestData>>> getLatestData(
      List<int> listOfMacs) async {
    print(listOfMacs);
    try {
      final List<LatestData> listOfLatestData = [];
      for (int i = 0; i < listOfMacs.length; i++) {
        final response = await supabaseManager.supabaseClient
            .from('daily_data')
            .select('''created_at, avg, sensor_id''')
            .eq('sensor_id', listOfMacs[i])
            .order('created_at', ascending: false)
            .limit(1);

        final latestData = LatestDataDao.fromJSON(response[0]);
        listOfLatestData.add(latestData);
      }
      if (listOfLatestData.isNotEmpty) {
        return Right(listOfLatestData);
      } else {
        return Left(
            NotFoundFailure(message: "Daily data not found", statusCode: 404));
      }
    } catch (e) {
      return Left(NotFoundFailure(
          message: "Exception ${e.toString()}", statusCode: 404));
    }
  }

  @override
  Future<Either<Failure, List<ChartData>>> getDailyData(int sensorMac) async {
    try {
      final response = await supabaseManager.supabaseClient
          .from('daily_data')
          .select('''created_at, avg''')
          .eq('sensor_id', sensorMac)
          .order('created_at', ascending: false);

      print("RESPONSE FROM DAILY DATA: $response");
      List<ChartData> chartDataList = [];
      for (int index = 0; index < response.length; index++) {
        final chartData =
            DailyChartDataDao.fromJSON(response[index] as Map<String, dynamic>);
        chartDataList.add(chartData);
      }
      if (chartDataList.isNotEmpty) {
        return Right(chartDataList);
      }

      return const Left(
          NotFoundFailure(message: "Daily data not found", statusCode: 404));
    } catch (e) {
      print(e);
      return const Left(
          NotFoundFailure(message: "Unknown exception", statusCode: 404));
    }
  }

  @override
  Future<Either<Failure, List<ChartData>>> getWeeklyData(int sensorMac) async {
    print("SENSOR ID IN SUBSCRIBETOWEEKLYDATA: $sensorMac");

    final response = await supabaseManager.supabaseClient
        .from('weekly_data')
        .select('''created_at, avg''')
        .eq('sensor_id', sensorMac)
        .order('created_at', ascending: false);

    print("WEEKLY DATA RESPONSE: $response");

    List<ChartData> chartDataList = [];
    for (int index = 0; index < response.length; index++) {
      final chartData =
          WeeklyChartDataDao.fromJSON(response[index] as Map<String, dynamic>);
      chartDataList.add(chartData);
    }
    print("WEEKLY CHART DATA LIST - $chartDataList");
    if (chartDataList.isNotEmpty) {
      return Right(chartDataList);
    }
    return Left(
        NotFoundFailure(message: "Weekly data not found", statusCode: 404));
  }

  @override
  Future<Either<Failure, List<ChartData>>> getMonthlyData(int sensorMac) async {
    final response = await supabaseManager.supabaseClient
        .from('monthly_data')
        .select('''created_at, avg''')
        .eq('sensor_id', sensorMac)
        .order('created_at', ascending: false);

    List<ChartData> chartDataList = [];
    for (int index = 0; index < response.length; index++) {
      final chartData =
          MonthlyChartDataDao.fromJSON(response[index] as Map<String, dynamic>);
      chartDataList.add(chartData);
    }
    if (chartDataList.isNotEmpty) {
      return Right(chartDataList);
    }
    return Left(
        NotFoundFailure(message: "Monthly data not found", statusCode: 404));
  }

  @override
  Future<Either<Failure, SensorRangeDAO>> getRangeForSensor(
      int sensorId) async {
    try {
      final data = await supabaseManager.supabaseClient.from('range').select('''
    min_value,
    max_value
  ''').eq('sensor_id', sensorId);
      return Right(SensorRangeDAO.fromJSON(data[0]));
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }

  getPortConfigForSensor(int sensorId) {}

  getPintunnelForProfileEmail(String email) {}

  @override
  Future<Either<Failure, List<SensorClass>>> getSensorsForUser(
      String email) async {
    try {
      final clientId =
          (await supabaseManager.supabaseClient.from('profiles').select('''
    id
  ''').eq('email', email));
      print("CLIENT ID IN pintunnel_repository: $clientId");

      if (clientId.isEmpty || clientId == null) {
        return Left(NotFoundFailure(
            message: "ClientId not found for given email", statusCode: 404));
      }

      print(clientId[0]['id']);

      final pintunnelData = await supabaseManager.supabaseClient
          .from('pintunnel')
          .select('mac_address')
          .eq('user_id', clientId[0]['id']);

      print("PINTUNNEL DATA IN pintunnel_repository: $pintunnelData");
      if (pintunnelData.isEmpty) {
        return Left(NotFoundFailure(
            message: "Pintunnel not found for given email", statusCode: 404));
      }

      final sensorData = (await supabaseManager.supabaseClient
          .from('sensor')
          .select('''cfg_code, sensor_mac, nickname''').eq(
              'mac_address', pintunnelData[0]['mac_address']));
      print("SENSOR DATA $sensorData");
      if (sensorData.isEmpty || sensorData == null) {
        return Left(
            NotFoundFailure(message: "Sensor data is null", statusCode: 404));
      }

      List<dynamic> cfgCodes =
          sensorData.map((data) => data['cfg_code'] as int).toList();

      final data = await supabaseManager.supabaseClient
          .from('sensor_config')
          .select('''description, isActuator, unit, version, min_value, max_value, image, name''').in_(
              'cfg_code', cfgCodes);

      List<SensorClass> sensorClassList = [];
      for (int index = 0; index < data.length; index++) {
        final sensor = SensorDAO.fromJSON(data[index] as Map<String, dynamic>);
        sensor.sensorMac = sensorData[index]['sensor_mac'].toString();
        sensor.nickname = sensorData[index]['nickname'].toString();
        sensorClassList.add(sensor);
      }
      if (sensorClassList.isNotEmpty) {
        return Right(sensorClassList);
      }
      return Left(
          NotFoundFailure(message: "Sensors not found", statusCode: 404));
    } on APIException catch (e) {
      print("EXCEPTION pin_tunnel_repository $e");
      return Left(APIFailure.fromException(e));
    }
  }

  void updateUserStatus(String status, String email) async {
    if (status.toUpperCase() == "ONLINE") {
      final response = await supabaseManager.supabaseClient
          .from('profiles')
          .update({'status': "ONLINE"}).match({'email': email});
    }
    if (status.toUpperCase() == "OFFLINE") {
      final response = await supabaseManager.supabaseClient
          .from('profiles')
          .update({'status': 'OFFLINE'}).match({'email': email});
    }
  }

  @override
  void addAction(ActionClass actionClass) async {
    print("In repository addAction");
    print(actionClass.action);
    print(actionClass.condition);
    print(actionClass.conditionValue);
    print(actionClass.sensorId);

    try {
      /* final response = await client.from('dependency').insert({
        'action_logic': 'notification',
        'action_condition': 'above',
        'action_condition_value': 23.5,
        'independent_sensor_id': 12345,
      });*/
      await supabaseManager.supabaseClient.from('dependency').insert({
        'action_logic': actionClass.action,
        'action_condition': actionClass.condition,
        'action_condition_value': actionClass.conditionValue,
        'independent_sensor_id': actionClass.sensorId,
      });
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  @override
  Future<Either<Failure, String>> saveSensorCustomization(String iconName,
      String nickname, int sensorId, String sensorPlacement) async {
    try {
      print("nickname: $nickname");
      print("sensorId: $sensorId");
      print("sensorPlacement: $sensorPlacement");
      final result = await supabaseManager.supabaseClient
          .from('sensor')
          .update({
        'nickname': nickname,
        'placement': sensorPlacement,
        'icon': iconName
      }).match({'sensor_mac': sensorId});
      print("saveSensorCustomization result $result");
      return Right('Update successful');
    } catch (e) {
      print(e);
      return Left(DatabaseUpdateError(
          message: 'Error updating sensor configurations', statusCode: 500));
    }
  }
  
  @override
  Future<Either<Failure, List<SensorClass>>> getHistoricalData(String email) async{
    try{
      final clientId =
          (await supabaseManager.supabaseClient.from('profiles').select('''
    id
  ''').eq('email', email));
      print("CLIENT ID IN pintunnel_repository: $clientId");

      if (clientId.isEmpty || clientId == null) {
        return Left(NotFoundFailure(
            message: "ClientId not found for given email", statusCode: 404));
      }

      print(clientId[0]['id']);


      final pintunnelData = await supabaseManager.supabaseClient
          .from('pintunnel')
          .select('mac_address')
          .eq('user_id', clientId[0]['id']);

      print("PINTUNNEL DATA IN pintunnel_repository: $pintunnelData");
      if (pintunnelData.isEmpty) {
        return Left(NotFoundFailure(
            message: "Pintunnel not found for given email", statusCode: 404));
      }
      

      final sensorData = (await supabaseManager.supabaseClient
          .from('sensor')
          .select('''cfg_code, sensor_mac''').eq(
              'mac_address', pintunnelData[0]['mac_address']));
      print("SENSOR DATA $sensorData");
      if (sensorData.isEmpty || sensorData == null) {
        return Left(
            NotFoundFailure(message: "Sensor data is null", statusCode: 404));
      }

      List<dynamic> sensor_macs =
          sensorData.map((data) => data['sensor_mac'] as int).toList();

      final missingSensors = await supabaseManager.supabaseClient
      .from('missing_sensors')
      .select('sensor_id, missing_day')
      .in_('sensor_id', sensor_macs);


      List<SensorClass> sensorClassList = [];
      for (int index = 0; index < missingSensors.length; index++) {
        final sensorConfig = await supabaseManager.supabaseClient.from('sensor_config').select('''description, isActuator, unit, version,
         min_value, max_value, image, name''').eq('cfg_code', sensorData[index]['cfg_code']);
        print("sensor config: $sensorConfig");
        final sensor = SensorDAO.fromJSON(missingSensors[index] as Map<String, dynamic>);
        sensor.sensorMac = sensorData[index]['sensor_mac'].toString();
        sensor.sensorDescription = sensorConfig[0]['description'].toString();
        sensor.isActuator = sensorConfig[0]['isActuator'];
        sensor.unit = sensorConfig[0]['unit'].toString();
        sensor.version = sensorConfig[0]['version'].toString();
        sensor.minValue = sensorConfig[0]['min_value'].toString();
        sensor.maxValue = sensorConfig[0]['max_value'].toString();
        sensor.sensorImage = sensorConfig[0]['image'].toString();
        sensor.sensorName = sensorConfig[0]['name'].toString();
        sensor.missingDay = missingSensors[index]['missing_day'].toString();
        sensorClassList.add(sensor);
      }
      if (sensorClassList.isNotEmpty) {
        return Right(sensorClassList);
      }
      return Left(
          NotFoundFailure(message: "Sensors not found", statusCode: 404));
    }on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }
}
