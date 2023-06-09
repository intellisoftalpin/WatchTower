import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:proto/auth/auth_service.pbgrpc.dart';
import 'package:proto/cardano/cardano.pbgrpc.dart';
import 'package:proto/common/common.pbgrpc.dart';
import 'package:tower/data/models/node_model.dart';
import '../../main.dart';
import '../../ui/screens/login_screen.dart';
import '../shared_preferences/shared_preferences_repository.dart';

String _serverIP = '';
int _serverPort = 0;
//String? _accessToken;
String? tokenJWT;
List<String> _uuid = [];
late GetStatisticResponse _response;
late ClientChannel _channel;
late CardanoClient cardanoClient;
List<NodeGroupModel> nodesList = [];
List<ServerModel> serversList1 = [];
List<List<ServerModel>> resultList = [];
List<String?> nodeTickers = [];
List<String?> serverStatuses = [];
final SharedPreferencesRepository _preferences = SharedPreferencesRepository();

/*
serverStatuses list contains the server statuses only for the one node
*/
List<dynamic> sortedDataBlocks = [];

void clearUserData() {
  passwordController.clear();
  nodeTickers.clear();
  serverStatuses.clear();
  serversList1.clear();
  nodesList.clear();
  resultList.clear();
  _uuid.clear();
  tokenJWT = null;
  _serverPort = 0;
  _serverIP = '';
  box.write('serverPort', '');
  box.write('serverIP', '');
  _preferences.removeShPrefByKey('token');
  //box.write('token', null);
}

void clearTextControllers() {
  serverController.clear();
  userController.clear();
}

Future<String?> logIn(
    {required String password,
    required String username,
    required String url}) async {
  try {
    if (url.contains(':')) {
      _serverIP = url.split(":").first;
      _serverPort = int.parse(url.split(":").last);
    } else {
      _serverIP = url;
      _serverPort = 5300;
    }

    box.write('serverIP', _serverIP);
    box.write('serverPort', '$_serverPort');
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  _channel = ClientChannel(
    _serverIP,
    port: _serverPort,
    options: ChannelOptions(
        credentials: ChannelCredentials.secure(onBadCertificate: (certificate, str)=> true),
        connectionTimeout: const Duration(seconds: 15)),
  );

  final authClient = AuthServiceClient(
    _channel,
    options: CallOptions(timeout: const Duration(seconds: 15)),
  );
  LoginResponse? response;

  try {
    response = await authClient.login(LoginRequest()
      ..username = username
      ..password = password);
    if (kDebugMode) {
      print('Response received: $response');
      print('has access token: ${response.hasAccessToken()}');
    }

    tokenJWT = response.accessToken;
  } catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
  if (kDebugMode) {
    print('\n\n\n');
  }
  return tokenJWT;
}

void getDataFromLocStorage() {
  int serverPort = int.parse(box.read('serverPort'));
  String serverIP = box.read('serverIP');
  _channel = ClientChannel(
    serverIP,
    port: serverPort,
    options: ChannelOptions(credentials: ChannelCredentials.secure(onBadCertificate: (certificate, str)=> true)),
  );
}

Future<List<NodeGroupModel>> getNodes(BuildContext context) async {
  List<ServerModel> nodes = [];
  List<String?> tickers = [];

  if (kDebugMode) {
    print('getNodes-----NODES LIST: $nodesList');
    print('getNodes-----NODES TICKERS: $nodeTickers');
    print('getNodes-----RESULT LIST: $resultList');
    print('getNodes------_UUID LIST: $_uuid');
  }

  /*
  It is necessary to clear old previous data, because data will duplicated
  if a user had an error in the port number.
  */

  serversList1.clear();
  nodeTickers.clear();
  serverStatuses.clear();
  nodesList.clear();
  resultList.clear();
  _uuid.clear();

  //String token = box.read('token');
  final controllerClient = ControllerClient(_channel,
      options: CallOptions(metadata: {'authorization': tokenJWT!}));

  try {
    GetNodeListResponse response =
        await controllerClient.getNodeList(GetNodeListRequest());
    for (int i = 0; i < response.nodeAuthData.length; i++) {
      ServerModel node = ServerModel(
        ticker: response.nodeAuthData[i].ticker,
        name: response.nodeAuthData[i].name,
        uuid: response.nodeAuthData[i].uuid,
        blockchain: response.nodeAuthData[i].blockchain,
        type: response.nodeAuthData[i].type,
      );
      nodes.add(node);
      tickers.add(node.ticker);
    }

    /*
     Delete in the ticker list similar strings
    */
    nodeTickers = tickers.toSet().toList();

    for (int k = 0; k < nodeTickers.length; k++) {
      List<ServerModel> list = [];

      // bm
      for (int i = 0; i < nodes.length; i++) {
        if (nodes[i].ticker!.contains(nodeTickers[k]!)) {
          list.add(nodes[i]);
          if (kDebugMode) {
            print('added  k $k i $i  ${nodeTickers[k]}');
          }
        } else {
          if (kDebugMode) {
            print('not  k $k i $i  ${nodeTickers[k]}');
          }
        }
      }
      if (kDebugMode) {
        print(list);
      }
      resultList.add(list);
    }

    for (int y = 0; y < resultList.length; y++) {
      if (kDebugMode) {
        print('node$y: ${resultList[y]}}');
      }

      NodeGroupModel node = NodeGroupModel(ticker: nodeTickers[y], servers: []);
     // List<String?> serverStatuses = [];
      for (int i = 0; i < resultList[y].length; i++) {
        ServerModel server = ServerModel(
          ticker: resultList[y][i].ticker,
         name: resultList[y][i].name,
          uuid: resultList[y][i].uuid,
          type: resultList[y][i].type,
          blockchain: resultList[y][i].blockchain,
        );
        // getServerStatuses(server, context);
         node.servers?.add(server);
        // serverStatuses.add(server.serverStatus);
        if (kDebugMode) {
          print('node$y: ${resultList[y][i].name}  ${resultList[y][i].type}}');
        }
      }
     // defineTheNodeStatus(serverStatuses);
      nodesList.add(node);
    }

    for (int i = 0; i < response.nodeAuthData.length; i++) {
      _uuid.add(response.nodeAuthData[i].uuid);
    }
    if (kDebugMode) {
      print('uuid: $_uuid');
      print('response nodes list: $response');
    }
  } catch (e) {
    if (kDebugMode) {
      print('exception get nodes');
      print(e);
    }

    if (e.toString().contains('code: 16')) {
      /* Token expired code*/
      timer?.cancel();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      clearUserData();
    }
  }
  if (kDebugMode) {
    print('\n\n\n');
  }
  return nodesList;
}

Future<dynamic> getStatistics(String uuid, BuildContext context, [NodeGroupModel? node]) async {
 // String token = box.read('token');
  cardanoClient = CardanoClient(_channel,
      options: CallOptions(metadata: {'authorization': tokenJWT!}));

  try {
    _response = await cardanoClient
        .getStatistic(GetStatisticRequest()..uuid = uuid).then((_response) async {

      if (kDebugMode) {
        log(' response statistics log: $_response');
      }

      ServerModel serverModel = ServerModel();

      serverModel.ticker = _response.nodeAuthData.ticker;
      serverModel.blockchain = _response.nodeAuthData.blockchain;
      serverModel.type = _response.nodeAuthData.type;
      serverModel.name = _response.nodeAuthData.name;
      serverModel.uuid = _response.nodeAuthData.uuid;


      serverModel.tickerNodeBasicData = _response.statistic.nodeBasicData.data.ticker;
      serverModel.typeNodeBasicData = _response.statistic.nodeBasicData.data.type;
      serverModel.location = _response.statistic.nodeBasicData.data.location;
      serverModel.nodeVersion = _response.statistic.nodeBasicData.data.nodeVersion;
      serverModel.nodeBasicDataStatus =
          _response.statistic.nodeBasicData.status.status;


      serverModel.ipv4 = _response.statistic.serverBasicData.data.ipv4;
      serverModel.ipv6 = _response.statistic.serverBasicData.data.ipv6;
      serverModel.linuxName = _response.statistic.serverBasicData.data.linuxName;
      serverModel.linuxVersion =
          _response.statistic.serverBasicData.data.linuxVersion;
      serverModel.serverBasicDataStatus =
          _response.statistic.serverBasicData.status.status;


      serverModel.informerActual = _response.statistic.updates.data.informerActual;
      serverModel.informerAvailable =
          _response.statistic.updates.data.informerAvailable;
      serverModel.udapterActual = _response.statistic.updates.data.updaterActual;
      serverModel.udapterAvailable =
          _response.statistic.updates.data.updaterAvailable;
      serverModel.packagesAvailable =
          _response.statistic.updates.data.packagesAvailable;
      serverModel.updatesStatus = _response.statistic.updates.status.status;

      serverModel.epochNumber = _response.statistic.epoch.data.epochNumber;
      serverModel.epochStatus = _response.statistic.epoch.status.status;

      serverModel.kesExpData = _response.statistic.kesData.data.kesExpDate;
      List<String> listKesExpData = serverModel.kesExpData!.split('+');
      serverModel.kesExpData = listKesExpData[0];
      serverModel.kesRemaining = _response.statistic.kesData.data.kesRemaining;
      serverModel.kesCurrent = _response.statistic.kesData.data.kesCurrent;
      serverModel.kesDataStatus = _response.statistic.kesData.status.status;

      serverModel.blockLeader = _response.statistic.blocks.data.blockLeader;
      serverModel.blockAdopted = _response.statistic.blocks.data.blockAdopted;
      serverModel.blockInvalid = _response.statistic.blocks.data.blockInvalid;
      serverModel.blocksStatus = _response.statistic.blocks.status.status;

      serverModel.liveStake = _response.statistic.stakeInfo.data.liveStake;
      serverModel.activeStake = _response.statistic.stakeInfo.data.activeStake;
      serverModel.pledge = _response.statistic.stakeInfo.data.pledge;
      serverModel.stakeInfoStatus = _response.statistic.stakeInfo.status.status;

      serverModel.sinceStart = _response.statistic.online.data.sinceStart;
      serverModel.pings = _response.statistic.online.data.pings;
      serverModel.nodeActive = _response.statistic.online.data.nodeActive;
      serverModel.nodeActivePings = _response.statistic.online.data.nodeActivePings;
      serverModel.serverActive = _response.statistic.online.data.serverActive;
      serverModel.onlineStatus = _response.statistic.online.status.status;

      serverModel.totalSpace = _response.statistic.memoryState.data.total;
      serverModel.used = _response.statistic.memoryState.data.used;
      serverModel.buffers = _response.statistic.memoryState.data.buffers;
      serverModel.cached = _response.statistic.memoryState.data.cached;
      serverModel.freeSpace = _response.statistic.memoryState.data.free;
      serverModel.available = _response.statistic.memoryState.data.available;
      serverModel.active = _response.statistic.memoryState.data.active;
      serverModel.inactive = _response.statistic.memoryState.data.inactive;
      serverModel.swapTotal = _response.statistic.memoryState.data.swapTotal;
      serverModel.swapUsed = _response.statistic.memoryState.data.swapUsed;
      serverModel.swapCached = _response.statistic.memoryState.data.swapCached;
      serverModel.swapFree = _response.statistic.memoryState.data.swapFree;
      serverModel.memAvailableEnabled =
          _response.statistic.memoryState.data.memAvailableEnabled;
      serverModel.memoryStateStatus = _response.statistic.memoryState.status.status;

      serverModel.cpuQty = _response.statistic.cpuState.data.cpuQty;
      serverModel.averageWorkload =
          _response.statistic.cpuState.data.averageWorkload;
      serverModel.cpuQtyStatus = _response.statistic.cpuState.status.status;

      serverModel.tipDiff = _response.statistic.nodeState.data.tipDiff;
      serverModel.density = _response.statistic.nodeState.data.density;
      serverModel.nodeStateStatus = _response.statistic.nodeState.status.status;

      serverModel.sshAttackAttempts =
          _response.statistic.security.data.sshAttackAttempts;
      serverModel.securityPackagesAvailable =
          _response.statistic.security.data.securityPackagesAvailable;
      serverModel.securityStatus = _response.statistic.security.status.status;

      serverModel.proceedTx = _response.statistic.nodePerformance.data.processedTx;
      serverModel.peersIn = _response.statistic.nodePerformance.data.peersIn;
      serverModel.peersOut = _response.statistic.nodePerformance.data.peersOut;
      serverModel.nodePerformanceStatus =
          _response.statistic.nodePerformance.status.status;

      //NodeBasicData
      if (serverModel.nodeVersion!.isEmpty ||
          serverModel.nodeVersion!.contains(' ')) {
        serverModel.nodeVersion = 'N/A';
      }
      if (serverModel.nodeBasicDataStatus!.isEmpty ||
          serverModel.nodeBasicDataStatus!.contains(' ')) {
        serverModel.nodeBasicDataStatus = 'N/A';
      }
      if (serverModel.location!.isEmpty || serverModel.location!.contains(' ')) {
        serverModel.location = 'N/A';
      }
      if (serverModel.type!.isEmpty || serverModel.type!.contains(' ')) {
        serverModel.type = 'N/A';
      }
      if (serverModel.ticker!.isEmpty || serverModel.ticker!.contains(' ')) {
        serverModel.ticker = 'N/A';
      }

      //ServerBasicData
      if (serverModel.ipv4!.isEmpty) {
        serverModel.ipv4 = 'N/A';
      }
      if (serverModel.ipv6!.isEmpty) {
        serverModel.ipv6 = 'N/A';
      }
      if (serverModel.linuxName!.isEmpty) {
        serverModel.linuxName = 'N/A';
      }
      if (serverModel.linuxVersion!.isEmpty) {
        serverModel.linuxVersion = 'N/A';
      }
      if (serverModel.serverBasicDataStatus!.isEmpty) {
        serverModel.serverBasicDataStatus = 'N/A';
      }

      //Epoch
      if (serverModel.epochStatus!.isEmpty) {
        serverModel.epochStatus = 'N/A';
      }

      //KesExpData
      if (serverModel.kesExpData!.isEmpty) {
        serverModel.kesExpData = 'N/A';
      }
      if (serverModel.kesDataStatus!.isEmpty) {
        serverModel.kesDataStatus = 'N/A';
      }

      //Blocks
      if (serverModel.blocksStatus!.isEmpty) {
        serverModel.blocksStatus = 'N/A';
      }

      //StakeInfo
      if (serverModel.stakeInfoStatus!.isEmpty) {
        serverModel.stakeInfoStatus = 'N/A';
      }

      //Online
      if (serverModel.onlineStatus!.isEmpty) {
        serverModel.onlineStatus = 'N/A';
      }

      //Memory State
      if (serverModel.memoryStateStatus!.isEmpty) {
        serverModel.memoryStateStatus = 'N/A';
      }

      //CpuState
      if (serverModel.cpuQtyStatus!.isEmpty) {
        serverModel.cpuQtyStatus = 'N/A';
      }

      //Updates
      if (serverModel.informerAvailable!.isEmpty) {
        serverModel.informerAvailable = 'N/A';
      }
      if (serverModel.informerActual!.isEmpty) {
        serverModel.informerActual = 'N/A';
      }
      if (serverModel.udapterActual!.isEmpty) {
        serverModel.udapterActual = 'N/A';
      }
      if (serverModel.udapterAvailable!.isEmpty) {
        serverModel.udapterAvailable = 'N/A';
      }
      if (serverModel.updatesStatus!.isEmpty) {
        serverModel.updatesStatus = 'N/A';
      }

      //Security
      if (serverModel.securityStatus!.isEmpty) {
        serverModel.securityStatus = 'N/A';
      }

      //NodePerformance
      if (serverModel.nodePerformanceStatus!.isEmpty) {
        serverModel.nodePerformanceStatus = 'N/A';
      }

      //TODO: Check all fields of the NodeModel with type String?

      serversList1.add(serverModel);
       defineTheServerStatus(serverModel, node);
       defineFirstThreeParams(serverModel);
      dataParsingForTheServerDetails(_response);

      return _response;
    });

  }
   catch (e) {
    if (kDebugMode) {
      print('exception get statistics');
      print(e);
    }

    if (e.toString().contains('code: 16')) {
      /* Token expired code*/
      timer?.cancel();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      clearUserData();
    }
  }
   return _response;
}

void defineFirstThreeParams(ServerModel serverModel) {
  String error = 'error';
  String warning = 'warning';
  String success = 'ok';

  /*DEFINE THE FIRST PARAM*/
  if (serverModel.nodeBasicDataStatus!.contains(error)){
    serverModel.firstParam = 'Node Basic Data';
    serverModel.firstParamStatus = serverModel.nodeBasicDataStatus;
  }else if(serverModel.serverBasicDataStatus!.contains(error)){
    serverModel.firstParam = 'Server Basic Data';
    serverModel.firstParamStatus = serverModel.serverBasicDataStatus;
  }
  else if(serverModel.updatesStatus!.contains(error)){
    serverModel.firstParam = 'Updates';
    serverModel.firstParamStatus = serverModel.updatesStatus;
  }
  else if(serverModel.securityStatus!.contains(error)){
    serverModel.firstParam = 'Security';
    serverModel.firstParamStatus = serverModel.securityStatus;
  }
  else if(serverModel.epochStatus!.contains(error)){
    serverModel.firstParam = 'Epoch';
    serverModel.firstParamStatus = serverModel.epochStatus;
  }
  else if(serverModel.kesDataStatus!.contains(error)){
    serverModel.firstParam = 'Kes Data';
    serverModel.firstParamStatus = serverModel.kesDataStatus;
  }
  else if(serverModel.blocksStatus!.contains(error)){
    serverModel.firstParam = 'Blocks';
    serverModel.firstParamStatus = serverModel.blocksStatus;
  }
  else if(serverModel.stakeInfoStatus!.contains(error)){
    serverModel.firstParam = 'Stake Info';
    serverModel.firstParamStatus = serverModel.stakeInfoStatus;
  }
  else if(serverModel.onlineStatus!.contains(error)){
    serverModel.firstParam = 'Online';
    serverModel.firstParamStatus = serverModel.onlineStatus;
  }
  else if(serverModel.memoryStateStatus!.contains(error)){
    serverModel.firstParam = 'Memory State';
    serverModel.firstParamStatus = serverModel.memoryStateStatus;
  }
  else if(serverModel.cpuQtyStatus!.contains(error)){
    serverModel.firstParam = 'Cpu State';
    serverModel.firstParamStatus = serverModel.cpuQtyStatus;
  }
  else if(serverModel.nodeStateStatus!.contains(error)){
    serverModel.firstParam = 'Node State';
    serverModel.firstParamStatus = serverModel.nodeStateStatus;
  }
  else if(serverModel.nodePerformanceStatus!.contains(error)){
    serverModel.firstParam = 'Node Performance';
    serverModel.firstParamStatus = serverModel.nodePerformanceStatus;
  }




  else if (serverModel.nodeBasicDataStatus!.contains(warning)){
    serverModel.firstParam = 'Node Basic Data';
    serverModel.firstParamStatus = serverModel.nodeBasicDataStatus;
  }else if(serverModel.serverBasicDataStatus!.contains(warning)){
    serverModel.firstParam = 'Server Basic Data';
    serverModel.firstParamStatus = serverModel.serverBasicDataStatus;
  }
  else if(serverModel.updatesStatus!.contains(warning)){
    serverModel.firstParam = 'Updates';
    serverModel.firstParamStatus = serverModel.updatesStatus;
  }
  else if(serverModel.securityStatus!.contains(warning)){
    serverModel.firstParam = 'Security';
    serverModel.firstParamStatus = serverModel.securityStatus;
  }
  else if(serverModel.epochStatus!.contains(warning)){
    serverModel.firstParam = 'Epoch';
    serverModel.firstParamStatus = serverModel.epochStatus;
  }
  else if(serverModel.kesDataStatus!.contains(warning)){
    serverModel.firstParam = 'Kes Data';
    serverModel.firstParamStatus = serverModel.kesDataStatus;
  }
  else if(serverModel.blocksStatus!.contains(warning)){
    serverModel.firstParam = 'Blocks';
    serverModel.firstParamStatus = serverModel.blocksStatus;
  }
  else if(serverModel.stakeInfoStatus!.contains(warning)){
    serverModel.firstParam = 'Stake Info';
    serverModel.firstParamStatus = serverModel.stakeInfoStatus;
  }
  else if(serverModel.onlineStatus!.contains(warning)){
    serverModel.firstParam = 'Online';
    serverModel.firstParamStatus = serverModel.onlineStatus;
  }
  else if(serverModel.memoryStateStatus!.contains(warning)){
    serverModel.firstParam = 'Memory State';
    serverModel.firstParamStatus = serverModel.memoryStateStatus;
  }
  else if(serverModel.cpuQtyStatus!.contains(warning)){
    serverModel.firstParam = 'Cpu State';
    serverModel.firstParamStatus = serverModel.cpuQtyStatus;
  }
  else if(serverModel.nodeStateStatus!.contains(warning)){
    serverModel.firstParam = 'Node State';
    serverModel.firstParamStatus = serverModel.nodeStateStatus;
  }
  else if(serverModel.nodePerformanceStatus!.contains(warning)){
    serverModel.firstParam = 'Node Performance';
    serverModel.firstParamStatus = serverModel.nodePerformanceStatus;
  }


  else if (serverModel.nodeBasicDataStatus!.contains(success)){
    serverModel.firstParam = 'Node Basic Data';
    serverModel.firstParamStatus = serverModel.nodeBasicDataStatus;
  }else if(serverModel.serverBasicDataStatus!.contains(success)){
    serverModel.firstParam = 'Server Basic Data';
    serverModel.firstParamStatus = serverModel.serverBasicDataStatus;
  }
  else if(serverModel.updatesStatus!.contains(success)){
    serverModel.firstParam = 'Updates';
    serverModel.firstParamStatus = serverModel.updatesStatus;
  }
  else if(serverModel.securityStatus!.contains(success)){
    serverModel.firstParam = 'Security';
    serverModel.firstParamStatus = serverModel.securityStatus;
  }
  else if(serverModel.epochStatus!.contains(success)){
    serverModel.firstParam = 'Epoch';
    serverModel.firstParamStatus = serverModel.epochStatus;
  }
  else if(serverModel.kesDataStatus!.contains(success)){
    serverModel.firstParam = 'Kes Data';
    serverModel.firstParamStatus = serverModel.kesDataStatus;
  }
  else if(serverModel.blocksStatus!.contains(success)){
    serverModel.firstParam = 'Blocks';
    serverModel.firstParamStatus = serverModel.blocksStatus;
  }
  else if(serverModel.stakeInfoStatus!.contains(success)){
    serverModel.firstParam = 'Stake Info';
    serverModel.firstParamStatus = serverModel.stakeInfoStatus;
  }
  else if(serverModel.onlineStatus!.contains(success)){
    serverModel.firstParam = 'Online';
    serverModel.firstParamStatus = serverModel.onlineStatus;
  }
  else if(serverModel.memoryStateStatus!.contains(success)){
    serverModel.firstParam = 'Memory State';
    serverModel.firstParamStatus = serverModel.memoryStateStatus;
  }
  else if(serverModel.cpuQtyStatus!.contains(success)){
    serverModel.firstParam = 'Cpu State';
    serverModel.firstParamStatus = serverModel.cpuQtyStatus;
  }
  else if(serverModel.nodeStateStatus!.contains(success)){
    serverModel.firstParam = 'Node State';
    serverModel.firstParamStatus = serverModel.nodeStateStatus;
  }
  else if(serverModel.nodePerformanceStatus!.contains(success)){
    serverModel.firstParam = 'Node Performance';
    serverModel.firstParamStatus = serverModel.nodePerformanceStatus;
  }else{
    serverModel.firstParam = 'N/A';
    serverModel.firstParamStatus = 'N/A';
  }

  /*DEFINE THE SECOND PARAM*/

  if ((!serverModel.firstParam!.contains('Node Basic Data')) && serverModel.nodeBasicDataStatus!.contains(error)){
    serverModel.secondParam = 'Node Basic Data';
    serverModel.secondParamStatus = serverModel.nodeBasicDataStatus;
  }else if((!serverModel.firstParam!.contains('Server Basic Data')) && serverModel.serverBasicDataStatus!.contains(error)){
    serverModel.secondParam = 'Server Basic Data';
    serverModel.secondParamStatus = serverModel.serverBasicDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Updates')) && serverModel.updatesStatus!.contains(error)){
    serverModel.secondParam = 'Updates';
    serverModel.secondParamStatus = serverModel.updatesStatus;
  }
  else if((!serverModel.firstParam!.contains('Security')) && serverModel.securityStatus!.contains(error)){
    serverModel.secondParam = 'Security';
    serverModel.secondParamStatus = serverModel.securityStatus;
  }
  else if((!serverModel.firstParam!.contains('Epoch')) && serverModel.epochStatus!.contains(error)){
    serverModel.secondParam = 'Epoch';
    serverModel.secondParamStatus = serverModel.epochStatus;
  }
  else if((!serverModel.firstParam!.contains('Kes Data')) && serverModel.kesDataStatus!.contains(error)){
    serverModel.secondParam = 'Kes Data';
    serverModel.secondParamStatus = serverModel.kesDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Blocks')) && serverModel.blocksStatus!.contains(error)){
    serverModel.secondParam = 'Blocks';
    serverModel.secondParamStatus = serverModel.blocksStatus;
  }
  else if((!serverModel.firstParam!.contains('Stake Info')) && serverModel.stakeInfoStatus!.contains(error)){
    serverModel.secondParam = 'Stake Info';
    serverModel.secondParamStatus = serverModel.stakeInfoStatus;
  }
  else if((!serverModel.firstParam!.contains('Online')) && serverModel.onlineStatus!.contains(error)){
    serverModel.secondParam = 'Online';
    serverModel.secondParamStatus = serverModel.onlineStatus;
  }
  else if((!serverModel.firstParam!.contains('Memory State')) && serverModel.memoryStateStatus!.contains(error)){
    serverModel.secondParam = 'Memory State';
    serverModel.secondParamStatus = serverModel.memoryStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Cpu State')) && serverModel.cpuQtyStatus!.contains(error)){
    serverModel.secondParam = 'Cpu State';
    serverModel.secondParamStatus = serverModel.cpuQtyStatus;
  }
  else if((!serverModel.firstParam!.contains('Node State')) && serverModel.nodeStateStatus!.contains(error)){
    serverModel.secondParam = 'Node State';
    serverModel.secondParamStatus = serverModel.nodeStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Node Performance')) && serverModel.nodePerformanceStatus!.contains(error)){
    serverModel.secondParam = 'Node Performance';
    serverModel.secondParamStatus = serverModel.nodePerformanceStatus;
  }



  else if ((!serverModel.firstParam!.contains('Node Basic Data')) && serverModel.nodeBasicDataStatus!.contains(warning)){
    serverModel.secondParam = 'Node Basic Data';
    serverModel.secondParamStatus = serverModel.nodeBasicDataStatus;
  }else if((!serverModel.firstParam!.contains('Server Basic Data')) && serverModel.serverBasicDataStatus!.contains(warning)){
    serverModel.secondParam = 'Server Basic Data';
    serverModel.secondParamStatus = serverModel.serverBasicDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Updates')) && serverModel.updatesStatus!.contains(warning)){
    serverModel.secondParam = 'Updates';
    serverModel.secondParamStatus = serverModel.updatesStatus;
  }
  else if((!serverModel.firstParam!.contains('Security')) && serverModel.securityStatus!.contains(warning)){
    serverModel.secondParam = 'Security';
    serverModel.secondParamStatus = serverModel.securityStatus;
  }
  else if((!serverModel.firstParam!.contains('Epoch')) && serverModel.epochStatus!.contains(warning)){
    serverModel.secondParam = 'Epoch';
    serverModel.secondParamStatus = serverModel.epochStatus;
  }
  else if((!serverModel.firstParam!.contains('Kes Data')) && serverModel.kesDataStatus!.contains(warning)){
    serverModel.secondParam = 'Kes Data';
    serverModel.secondParamStatus = serverModel.kesDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Blocks')) && serverModel.blocksStatus!.contains(warning)){
    serverModel.secondParam = 'Blocks';
    serverModel.secondParamStatus = serverModel.blocksStatus;
  }
  else if((!serverModel.firstParam!.contains('Stake Info')) && serverModel.stakeInfoStatus!.contains(warning)){
    serverModel.secondParam = 'Stake Info';
    serverModel.secondParamStatus = serverModel.stakeInfoStatus;
  }
  else if((!serverModel.firstParam!.contains('Online')) && serverModel.onlineStatus!.contains(warning)){
    serverModel.secondParam = 'Online';
    serverModel.secondParamStatus = serverModel.onlineStatus;
  }
  else if((!serverModel.firstParam!.contains('Memory State')) && serverModel.memoryStateStatus!.contains(warning)){
    serverModel.secondParam = 'Memory State';
    serverModel.secondParamStatus = serverModel.memoryStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Cpu State')) && serverModel.cpuQtyStatus!.contains(warning)){
    serverModel.secondParam = 'Cpu State';
    serverModel.secondParamStatus = serverModel.cpuQtyStatus;
  }
  else if((!serverModel.firstParam!.contains('Node State')) && serverModel.nodeStateStatus!.contains(warning)){
    serverModel.secondParam = 'Node State';
    serverModel.secondParamStatus = serverModel.nodeStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Node Performance')) && serverModel.nodePerformanceStatus!.contains(warning)){
    serverModel.secondParam = 'Node Performance';
    serverModel.secondParamStatus = serverModel.nodePerformanceStatus;
  }


  else if ((!serverModel.firstParam!.contains('Node Basic Data')) && serverModel.nodeBasicDataStatus!.contains(success)){
    serverModel.secondParam = 'Node Basic Data';
    serverModel.secondParamStatus = serverModel.nodeBasicDataStatus;
  }else if((!serverModel.firstParam!.contains('Server Basic Data')) && serverModel.serverBasicDataStatus!.contains(success)){
    serverModel.secondParam = 'Server Basic Data';
    serverModel.secondParamStatus = serverModel.serverBasicDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Updates')) && serverModel.updatesStatus!.contains(success)){
    serverModel.secondParam = 'Updates';
    serverModel.secondParamStatus = serverModel.updatesStatus;
  }
  else if((!serverModel.firstParam!.contains('Security')) && serverModel.securityStatus!.contains(success)){
    serverModel.secondParam = 'Security';
    serverModel.secondParamStatus = serverModel.securityStatus;
  }
  else if((!serverModel.firstParam!.contains('Epoch')) && serverModel.epochStatus!.contains(success)){
    serverModel.secondParam = 'Epoch';
    serverModel.secondParamStatus = serverModel.epochStatus;
  }
  else if((!serverModel.firstParam!.contains('Kes Data')) && serverModel.kesDataStatus!.contains(success)){
    serverModel.secondParam = 'Kes Data';
    serverModel.secondParamStatus = serverModel.kesDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Blocks')) && serverModel.blocksStatus!.contains(success)){
    serverModel.secondParam = 'Blocks';
    serverModel.secondParamStatus = serverModel.blocksStatus;
  }
  else if((!serverModel.firstParam!.contains('Stake Info')) && serverModel.stakeInfoStatus!.contains(success)){
    serverModel.secondParam = 'Stake Info';
    serverModel.secondParamStatus = serverModel.stakeInfoStatus;
  }
  else if((!serverModel.firstParam!.contains('Online')) && serverModel.onlineStatus!.contains(success)){
    serverModel.secondParam = 'Online';
    serverModel.secondParamStatus = serverModel.onlineStatus;
  }
  else if((!serverModel.firstParam!.contains('Memory State')) && serverModel.memoryStateStatus!.contains(success)){
    serverModel.secondParam = 'Memory State';
    serverModel.secondParamStatus = serverModel.memoryStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Cpu State')) && serverModel.cpuQtyStatus!.contains(success)){
    serverModel.secondParam = 'Cpu State';
    serverModel.secondParamStatus = serverModel.cpuQtyStatus;
  }
  else if((!serverModel.firstParam!.contains('Node State')) && serverModel.nodeStateStatus!.contains(success)){
    serverModel.secondParam = 'Node State';
    serverModel.secondParamStatus = serverModel.nodeStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Node Performance')) && serverModel.nodePerformanceStatus!.contains(success)){
    serverModel.secondParam = 'Node Performance';
    serverModel.secondParamStatus = serverModel.nodePerformanceStatus;
  }else{
    serverModel.secondParam = 'N/A';
    serverModel.secondParamStatus = 'N/A';
  }

  /*DEFINE THE THIRD PARAM*/

  if ((!serverModel.firstParam!.contains('Node Basic Data')) && (!serverModel.secondParam!.contains('Node Basic Data')) && serverModel.nodeBasicDataStatus!.contains(error)){
    serverModel.thirdParam = 'Node Basic Data';
    serverModel.thirdParamStatus = serverModel.nodeBasicDataStatus;
  }else if((!serverModel.firstParam!.contains('Server Basic Data')) && (!serverModel.secondParam!.contains('Server Basic Data')) && serverModel.serverBasicDataStatus!.contains(error)){
    serverModel.thirdParam = 'Server Basic Data';
    serverModel.thirdParamStatus = serverModel.serverBasicDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Updates')) && (!serverModel.secondParam!.contains('Updates')) && serverModel.updatesStatus!.contains(error)){
    serverModel.thirdParam = 'Updates';
    serverModel.thirdParamStatus = serverModel.updatesStatus;
  }
  else if((!serverModel.firstParam!.contains('Security')) && (!serverModel.secondParam!.contains('Security')) &&serverModel.securityStatus!.contains(error)){
    serverModel.thirdParam = 'Security';
    serverModel.thirdParamStatus = serverModel.securityStatus;
  }
  else if((!serverModel.firstParam!.contains('Epoch')) && (!serverModel.secondParam!.contains('Epoch')) &&  serverModel.epochStatus!.contains(error)){
    serverModel.thirdParam = 'Epoch';
    serverModel.thirdParamStatus = serverModel.epochStatus;
  }
  else if((!serverModel.firstParam!.contains('Kes Data')) && (!serverModel.secondParam!.contains('Kes Data')) &&  serverModel.kesDataStatus!.contains(error)){
    serverModel.thirdParam = 'Kes Data';
    serverModel.thirdParamStatus = serverModel.kesDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Blocks')) && (!serverModel.secondParam!.contains('Blocks')) && serverModel.blocksStatus!.contains(error)){
    serverModel.thirdParam = 'Blocks';
    serverModel.thirdParamStatus = serverModel.blocksStatus;
  }
  else if((!serverModel.firstParam!.contains('Stake Info')) && (!serverModel.secondParam!.contains('Stake Info')) && serverModel.stakeInfoStatus!.contains(error)){
    serverModel.thirdParam = 'Stake Info';
    serverModel.thirdParamStatus = serverModel.stakeInfoStatus;
  }
  else if((!serverModel.firstParam!.contains('Online')) && (!serverModel.secondParam!.contains('Online')) && serverModel.onlineStatus!.contains(error)){
    serverModel.thirdParam = 'Online';
    serverModel.thirdParamStatus = serverModel.onlineStatus;
  }
  else if((!serverModel.firstParam!.contains('Memory State')) && (!serverModel.secondParam!.contains('Memory State')) && serverModel.memoryStateStatus!.contains(error)){
    serverModel.thirdParam = 'Memory State';
    serverModel.thirdParamStatus = serverModel.memoryStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Cpu State')) && (!serverModel.secondParam!.contains('Cpu State')) && serverModel.cpuQtyStatus!.contains(error)){
    serverModel.thirdParam = 'Cpu State';
    serverModel.thirdParamStatus = serverModel.cpuQtyStatus;
  }
  else if((!serverModel.firstParam!.contains('Node State')) && (!serverModel.secondParam!.contains('Node State')) && serverModel.nodeStateStatus!.contains(error)){
    serverModel.thirdParam = 'Node State';
    serverModel.thirdParamStatus = serverModel.nodeStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Node Performance')) && (!serverModel.secondParam!.contains('Node Performance')) &&serverModel.nodePerformanceStatus!.contains(error)){
    serverModel.thirdParam = 'Node Performance';
    serverModel.thirdParamStatus = serverModel.nodePerformanceStatus;
  }
  else if ((!serverModel.firstParam!.contains('Node Basic Data')) && (!serverModel.secondParam!.contains('Node Basic Data')) && serverModel.nodeBasicDataStatus!.contains(warning)){
    serverModel.thirdParam = 'Node Basic Data';
    serverModel.thirdParamStatus = serverModel.nodeBasicDataStatus;
  }else if((!serverModel.firstParam!.contains('Server Basic Data')) && (!serverModel.secondParam!.contains('Server Basic Data')) && serverModel.serverBasicDataStatus!.contains(warning)){
    serverModel.thirdParam = 'Server Basic Data';
    serverModel.thirdParamStatus = serverModel.serverBasicDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Updates')) && (!serverModel.secondParam!.contains('Updates')) && serverModel.updatesStatus!.contains(warning)){
    serverModel.thirdParam = 'Updates';
    serverModel.thirdParamStatus = serverModel.updatesStatus;
  }
  else if((!serverModel.firstParam!.contains('Security')) && (!serverModel.secondParam!.contains('Security')) && serverModel.securityStatus!.contains(warning)){
    serverModel.thirdParam = 'Security';
    serverModel.thirdParamStatus = serverModel.securityStatus;
  }
  else if((!serverModel.firstParam!.contains('Epoch')) && (!serverModel.secondParam!.contains('Epoch')) && serverModel.epochStatus!.contains(warning)){
    serverModel.thirdParam = 'Epoch';
    serverModel.thirdParamStatus = serverModel.epochStatus;
  }
  else if((!serverModel.firstParam!.contains('Kes Data')) && (!serverModel.secondParam!.contains('Kes Data')) && serverModel.kesDataStatus!.contains(warning)){
    serverModel.thirdParam = 'Kes Data';
    serverModel.thirdParamStatus = serverModel.kesDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Blocks')) && (!serverModel.secondParam!.contains('Blocks')) && serverModel.blocksStatus!.contains(warning)){
    serverModel.thirdParam = 'Blocks';
    serverModel.thirdParamStatus = serverModel.blocksStatus;
  }
  else if((!serverModel.firstParam!.contains('Stake Info')) && (!serverModel.secondParam!.contains('Stake Info')) && serverModel.stakeInfoStatus!.contains(warning)){
    serverModel.thirdParam = 'Stake Info';
    serverModel.thirdParamStatus = serverModel.stakeInfoStatus;
  }
  else if((!serverModel.firstParam!.contains('Online')) && (!serverModel.secondParam!.contains('Online')) && serverModel.onlineStatus!.contains(warning)){
    serverModel.thirdParam = 'Online';
    serverModel.thirdParamStatus = serverModel.onlineStatus;
  }
  else if((!serverModel.firstParam!.contains('Memory State')) && (!serverModel.secondParam!.contains('Memory State')) && serverModel.memoryStateStatus!.contains(warning)){
    serverModel.thirdParam = 'Memory State';
    serverModel.thirdParamStatus = serverModel.memoryStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Cpu State')) && (!serverModel.secondParam!.contains('Cpu State')) && serverModel.cpuQtyStatus!.contains(warning)){
    serverModel.thirdParam = 'Cpu State';
    serverModel.thirdParamStatus = serverModel.cpuQtyStatus;
  }
  else if((!serverModel.firstParam!.contains('Node State')) && (!serverModel.secondParam!.contains('Node State')) && serverModel.nodeStateStatus!.contains(warning)){
    serverModel.thirdParam = 'Node State';
    serverModel.thirdParamStatus = serverModel.nodeStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Node Performance')) && (!serverModel.secondParam!.contains('Node Performance')) && serverModel.nodePerformanceStatus!.contains(warning)){
    serverModel.thirdParam = 'Node Performance';
    serverModel.thirdParamStatus = serverModel.nodePerformanceStatus;
  }

  else if ((!serverModel.firstParam!.contains('Node Basic Data')) && (!serverModel.secondParam!.contains('Node Basic Data')) && serverModel.nodeBasicDataStatus!.contains(success)){
    serverModel.thirdParam = 'Node Basic Data';
    serverModel.thirdParamStatus = serverModel.nodeBasicDataStatus;
  }else if((!serverModel.firstParam!.contains('Server Basic Data')) && (!serverModel.secondParam!.contains('Server Basic Data')) && serverModel.serverBasicDataStatus!.contains(success)){
    serverModel.thirdParam = 'Server Basic Data';
    serverModel.thirdParamStatus = serverModel.serverBasicDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Updates')) && (!serverModel.secondParam!.contains('Updates')) && serverModel.updatesStatus!.contains(success)){
    serverModel.thirdParam = 'Updates';
    serverModel.thirdParamStatus = serverModel.updatesStatus;
  }
  else if((!serverModel.firstParam!.contains('Security')) && (!serverModel.secondParam!.contains('Security')) && serverModel.securityStatus!.contains(success)){
    serverModel.thirdParam = 'Security';
    serverModel.thirdParamStatus = serverModel.securityStatus;
  }
  else if((!serverModel.firstParam!.contains('Epoch')) && (!serverModel.secondParam!.contains('Epoch')) && serverModel.epochStatus!.contains(success)){
    serverModel.thirdParam = 'Epoch';
    serverModel.thirdParamStatus = serverModel.epochStatus;
  }
  else if((!serverModel.firstParam!.contains('Kes Data')) && (!serverModel.secondParam!.contains('Kes Data')) && serverModel.kesDataStatus!.contains(success)){
    serverModel.thirdParam = 'Kes Data';
    serverModel.thirdParamStatus = serverModel.kesDataStatus;
  }
  else if((!serverModel.firstParam!.contains('Blocks')) && (!serverModel.secondParam!.contains('Blocks')) && serverModel.blocksStatus!.contains(success)){
    serverModel.thirdParam = 'Blocks';
    serverModel.thirdParamStatus = serverModel.blocksStatus;
  }
  else if((!serverModel.firstParam!.contains('Stake Info')) && (!serverModel.secondParam!.contains('Stake Info')) && serverModel.stakeInfoStatus!.contains(success)){
    serverModel.thirdParam = 'Stake Info';
    serverModel.thirdParamStatus = serverModel.stakeInfoStatus;
  }
  else if((!serverModel.firstParam!.contains('Online')) && (!serverModel.secondParam!.contains('Online')) && serverModel.onlineStatus!.contains(success)){
    serverModel.thirdParam = 'Online';
    serverModel.thirdParamStatus = serverModel.onlineStatus;
  }
  else if((!serverModel.firstParam!.contains('Memory State')) && (!serverModel.secondParam!.contains('Memory State')) && serverModel.memoryStateStatus!.contains(success)){
    serverModel.thirdParam = 'Memory State';
    serverModel.thirdParamStatus = serverModel.memoryStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Cpu State')) && (!serverModel.secondParam!.contains('Cpu State')) && serverModel.cpuQtyStatus!.contains(success)){
    serverModel.thirdParam = 'Cpu State';
    serverModel.thirdParamStatus = serverModel.cpuQtyStatus;
  }
  else if((!serverModel.firstParam!.contains('Node State')) && (!serverModel.secondParam!.contains('Node State')) && serverModel.nodeStateStatus!.contains(success)){
    serverModel.thirdParam = 'Node State';
    serverModel.thirdParamStatus = serverModel.nodeStateStatus;
  }
  else if((!serverModel.firstParam!.contains('Node Performance')) && (!serverModel.secondParam!.contains('Node Performance')) && serverModel.nodePerformanceStatus!.contains(success)){
    serverModel.thirdParam = 'Node Performance';
    serverModel.thirdParamStatus = serverModel.nodePerformanceStatus;
  }else{
    serverModel.thirdParam = 'N/A';
    serverModel.thirdParamStatus = 'N/A';
  }
}

void defineTheServerStatus(ServerModel serverModel, NodeGroupModel? node) {
  String error = 'error';
  String ok = 'ok';
  String warning = 'warning';
  if (serverModel.nodeBasicDataStatus!.contains(error) ||
      serverModel.serverBasicDataStatus!.contains(error) ||
      serverModel.epochStatus!.contains(error) ||
      serverModel.kesDataStatus!.contains(error) ||
      serverModel.blocksStatus!.contains(error) ||
      serverModel.stakeInfoStatus!.contains(error) ||
      serverModel.onlineStatus!.contains(error) ||
      serverModel.memoryStateStatus!.contains(error) ||
      serverModel.cpuQtyStatus!.contains(error) ||
      serverModel.updatesStatus!.contains(error) ||
      serverModel.securityStatus!.contains(error) ||
      serverModel.nodeStateStatus!.contains(error) ||
      serverModel.nodePerformanceStatus!.contains(error)) {
    serverModel.serverStatus = error;
  } else if (serverModel.nodeBasicDataStatus!.contains(warning) ||
      serverModel.serverBasicDataStatus!.contains(warning) ||
      serverModel.epochStatus!.contains(warning) ||
      serverModel.kesDataStatus!.contains(warning) ||
      serverModel.blocksStatus!.contains(warning) ||
      serverModel.stakeInfoStatus!.contains(warning) ||
      serverModel.onlineStatus!.contains(warning) ||
      serverModel.memoryStateStatus!.contains(warning) ||
      serverModel.cpuQtyStatus!.contains(warning) ||
      serverModel.updatesStatus!.contains(warning) ||
      serverModel.securityStatus!.contains(warning) ||
      serverModel.nodeStateStatus!.contains(warning) ||
      serverModel.nodePerformanceStatus!.contains(warning)) {
    serverModel.serverStatus = warning;
  } else if (serverModel.nodeBasicDataStatus!.contains(ok) ||
      serverModel.serverBasicDataStatus!.contains(ok) ||
      serverModel.epochStatus!.contains(ok) ||
      serverModel.kesDataStatus!.contains(ok) ||
      serverModel.blocksStatus!.contains(ok) ||
      serverModel.stakeInfoStatus!.contains(ok) ||
      serverModel.onlineStatus!.contains(ok) ||
      serverModel.memoryStateStatus!.contains(ok) ||
      serverModel.cpuQtyStatus!.contains(ok) ||
      serverModel.updatesStatus!.contains(ok) ||
      serverModel.securityStatus!.contains(ok) ||
      serverModel.nodeStateStatus!.contains(ok) ||
      serverModel.nodePerformanceStatus!.contains(ok)) {
    serverModel.serverStatus = ok;
  }

 if(kDebugMode){
   print('\n\n\n  SERVER STATUS: ${serverModel.serverStatus}   SERVER NAME: ${serverModel.name} \n\n\n');
 }
   serverStatuses.add(serverModel.serverStatus);
   node?.nodeStatus = serverModel.serverStatus;
}

void dataParsingForTheServerDetails(GetStatisticResponse _response){
  String error = 'error';
  String ok = 'ok';
  String warning = 'warning';
  ///TODO: we need to clear sortedDataBlocks in several places because it is file variable

  sortedDataBlocks.clear();

  NodeBasicDataModel nodeBasicData = NodeBasicDataModel();
  nodeBasicData.data.add({'Ticker' : _response.statistic.nodeBasicData.data.ticker});
  nodeBasicData.data.add({'Type' : _response.statistic.nodeBasicData.data.type});
  nodeBasicData.data.add({'Location' : _response.statistic.nodeBasicData.data.location});
  nodeBasicData.data.add({'Node Version' : _response.statistic.nodeBasicData.data.nodeVersion});
  nodeBasicData.status = _response.statistic.nodeBasicData.status.status;
  if(_response.statistic.nodeBasicData.status.errors.isNotEmpty){
    String errorCode = _response.statistic.nodeBasicData.status.errors[0].errorCode;
    String errorMessage = _response.statistic.nodeBasicData.status.errors[0].errorMessage;
    nodeBasicData.errors = Errors(errorCode, errorMessage);
  }

  if(nodeBasicData.status!.contains(error)){
    nodeBasicData.rang  = 1;
  }else if(nodeBasicData.status!.contains(warning)){
    nodeBasicData.rang  = 2;
  }else if(nodeBasicData.status !.contains(ok)){
    nodeBasicData.rang  = 3;
  }
  sortedDataBlocks.add(nodeBasicData);


  ServerBasicDataModel serverBasicData = ServerBasicDataModel();
  if (_response.statistic.serverBasicData.data.ipv4.isEmpty) {
    serverBasicData.data.add({'ipv4' : 'N/A'});
  }else{
    serverBasicData.data.add({'ipv4' : _response.statistic.serverBasicData.data.ipv4});
  }
  if (_response.statistic.serverBasicData.data.ipv6.isEmpty) {
    serverBasicData.data.add({'ipv6' : 'N/A'});
  }else{
    serverBasicData.data.add({'ipv6' : _response.statistic.serverBasicData.data.ipv6});
  }
  if (_response.statistic.serverBasicData.data.linuxName.isEmpty) {
    serverBasicData.data.add({'Linux Name' : 'N/A'});
  }else{
    serverBasicData.data.add({'Linux Name' : _response.statistic.serverBasicData.data.linuxName});
  }
  if (_response.statistic.serverBasicData.data.linuxVersion.isEmpty) {
    serverBasicData.data.add({'Linux Version' : 'N/A'});
  }else{
    serverBasicData.data.add({'Linux Version' : _response.statistic.serverBasicData.data.linuxVersion});
  }

  serverBasicData.status = _response.statistic.serverBasicData.status.status;

  if(_response.statistic.serverBasicData.status.errors.isNotEmpty){
    String errorCode = _response.statistic.serverBasicData.status.errors[0].errorCode;
    String errorMessage = _response.statistic.serverBasicData.status.errors[0].errorMessage;
    serverBasicData.errors = Errors(errorCode, errorMessage);
  }

  if(serverBasicData.status!.contains(error)){
    serverBasicData.rang  = 1;
  }else if(serverBasicData.status!.contains(warning)){
    serverBasicData.rang  = 2;
  }else if(serverBasicData.status!.contains(ok)){
    serverBasicData.rang  = 3;
  }
   sortedDataBlocks.add(serverBasicData);


  UpdatesModel updates = UpdatesModel();
  if (_response.statistic.updates.data.updaterActual.isEmpty) {
    updates.data.add({'Updater Actual' : 'N/A'});
  }else{
    updates.data.add({'Updater Actual' : _response.statistic.updates.data.updaterActual});
  }
  if (_response.statistic.updates.data.updaterAvailable.isEmpty) {
    updates.data.add({'Updater Available' : 'N/A'});
  }else{
    updates.data.add({'Updater Available' : _response.statistic.updates.data.updaterAvailable});
  }
  if (_response.statistic.updates.data.informerActual.isEmpty) {
    updates.data.add({'Informer Actual' : 'N/A'});
  }else{
    updates.data.add({'Informer Actual' : _response.statistic.updates.data.informerActual});
  }
  if (_response.statistic.updates.data.informerAvailable.isEmpty) {
    updates.data.add({'Informer Available' : 'N/A'});
  }else{
    updates.data.add({'Informer Available' : _response.statistic.updates.data.informerAvailable});
  }
  updates.data.add({'Packages Available' : _response.statistic.updates.data.packagesAvailable});
  updates.status = _response.statistic.updates.status.status;

  if(_response.statistic.updates.status.errors.isNotEmpty){
    String errorCode = _response.statistic.updates.status.errors[0].errorCode;
    String errorMessage = _response.statistic.updates.status.errors[0].errorMessage;
    updates.errors = Errors(errorCode, errorMessage);
  }

  if(updates.status!.contains(error)){
    updates.rang  = 1;
  }else if(updates.status!.contains(warning)){
    updates.rang  = 2;
  }else if(updates.status!.contains(ok)){
    updates.rang  = 3;
  }
  sortedDataBlocks.add(updates);


  SecurityModel security = SecurityModel();
  security.data.add({'ssh Attack Attempts' : _response.statistic.security.data.sshAttackAttempts});
  security.data.add({'Security Packages Available' : _response.statistic.security.data.securityPackagesAvailable});
  security.status = _response.statistic.security.status.status;

  if(_response.statistic.security.status.errors.isNotEmpty){
    String errorCode = _response.statistic.security.status.errors[0].errorCode;
    String errorMessage = _response.statistic.security.status.errors[0].errorMessage;
    security.errors = Errors(errorCode, errorMessage);
  }

  if(security.status!.contains(error)){
    security.rang  = 1;
  }else if(security.status!.contains(warning)){
    security.rang  = 2;
  }else if(security.status!.contains(ok)){
    security.rang  = 3;
  }
  sortedDataBlocks.add(security);



  EpochModel epoch = EpochModel();
  epoch.data.add({'Epoch Number' : _response.statistic.epoch.data.epochNumber});
  epoch.status = _response.statistic.epoch.status.status;

  if(_response.statistic.epoch.status.errors.isNotEmpty){
    String errorCode = _response.statistic.epoch.status.errors[0].errorCode;
    String errorMessage = _response.statistic.epoch.status.errors[0].errorMessage;
    epoch.errors = Errors(errorCode, errorMessage);
  }

  if(epoch.status!.contains(error)){
    epoch.rang  = 1;
  }else if(epoch.status!.contains(warning)){
    epoch.rang  = 2;
  }else if(epoch.status!.contains(ok)){
    epoch.rang  = 3;
  }
  sortedDataBlocks.add(epoch);



  KesDataModel kesData = KesDataModel();

  List<String> listKesExpDate = _response.statistic.kesData.data.kesExpDate.split('+');
  kesData.data.add({'Kes Expiration Date' : '${listKesExpDate[0]}(UTC)'});
  kesData.data.add({'Kes Current' : _response.statistic.kesData.data.kesCurrent});
  kesData.data.add({'Kes Remaining' : _response.statistic.kesData.data.kesRemaining});
  kesData.status = _response.statistic.kesData.status.status;

  if(_response.statistic.kesData.status.errors.isNotEmpty){
    String errorCode = _response.statistic.kesData.status.errors[0].errorCode;
    String errorMessage = _response.statistic.kesData.status.errors[0].errorMessage;
    kesData.errors = Errors(errorCode, errorMessage);
  }

  if(kesData.status!.contains(error)){
    kesData.rang  = 1;
  }else if(epoch.status!.contains(warning)){
    kesData.rang  = 2;
  }else if(epoch.status!.contains(ok)){
    kesData.rang  = 3;
  }
  sortedDataBlocks.add(kesData);



  BlocksModel blocks = BlocksModel();
  blocks.data.add({'Block Leader' : _response.statistic.blocks.data.blockLeader});
  blocks.data.add({'Block Adopted' : _response.statistic.blocks.data.blockAdopted});
  blocks.data.add({'Block Invalid' : _response.statistic.blocks.data.blockInvalid});
  blocks.status = _response.statistic.blocks.status.status;

  if(_response.statistic.blocks.status.errors.isNotEmpty){
    String errorCode = _response.statistic.blocks.status.errors[0].errorCode;
    String errorMessage = _response.statistic.blocks.status.errors[0].errorMessage;
    blocks.errors = Errors(errorCode, errorMessage);
  }

  if(blocks.status!.contains(error)){
    blocks.rang  = 1;
  }else if(blocks.status!.contains(warning)){
    blocks.rang  = 2;
  }else if(blocks.status!.contains(ok)){
    blocks.rang  = 3;
  }
  sortedDataBlocks.add(blocks);



  StakeInfoModel stakeInfo = StakeInfoModel();
  stakeInfo.data.add({'Live Stake' : _response.statistic.stakeInfo.data.liveStake});
  stakeInfo.data.add({'Active Stake' : _response.statistic.stakeInfo.data.activeStake});
  stakeInfo.data.add({'Pledge' : _response.statistic.stakeInfo.data.pledge});
  stakeInfo.status = _response.statistic.stakeInfo.status.status;

  if(_response.statistic.stakeInfo.status.errors.isNotEmpty){
    String errorCode = _response.statistic.stakeInfo.status.errors[0].errorCode;
    String errorMessage = _response.statistic.stakeInfo.status.errors[0].errorMessage;
    stakeInfo.errors = Errors(errorCode, errorMessage);
  }

  if(stakeInfo.status!.contains(error)){
    stakeInfo.rang  = 1;
  }else if(blocks.status!.contains(warning)){
    stakeInfo.rang  = 2;
  }else if(blocks.status!.contains(ok)){
    stakeInfo.rang  = 3;
  }
  sortedDataBlocks.add(stakeInfo);



  OnlineModel online = OnlineModel();
  online.data.add({'Since Start' : _response.statistic.online.data.sinceStart});
  online.data.add({'Pings' : _response.statistic.online.data.pings});
  online.data.add({'Node Active' : _response.statistic.online.data.nodeActive});
  online.data.add({'Node Active Pings' : _response.statistic.online.data.nodeActivePings});
  online.data.add({'Server Active' : _response.statistic.online.data.serverActive});
  online.status = _response.statistic.online.status.status;

  if(_response.statistic.online.status.errors.isNotEmpty){
    String errorCode = _response.statistic.online.status.errors[0].errorCode;
    String errorMessage = _response.statistic.online.status.errors[0].errorMessage;
    online.errors = Errors(errorCode, errorMessage);
  }

  if(online.status!.contains(error)){
    online.rang  = 1;
  }else if(online.status!.contains(warning)){
    online.rang  = 2;
  }else if(online.status!.contains(ok)){
    online.rang  = 3;
  }
  sortedDataBlocks.add(online);



  MemoryStateModel memoryState = MemoryStateModel();
  memoryState.data.add({'Total' :  _response.statistic.memoryState.data.total});
  memoryState.data.add({'Used' :  _response.statistic.memoryState.data.used});
  memoryState.data.add({'Buffers' :  _response.statistic.memoryState.data.buffers});
  memoryState.data.add({'Cached' :  _response.statistic.memoryState.data.cached});
  memoryState.data.add({'Free' :  _response.statistic.memoryState.data.free});
  memoryState.data.add({'Available' :  _response.statistic.memoryState.data.available});
  memoryState.data.add({'Active' :  _response.statistic.memoryState.data.active});
  memoryState.data.add({'Inactive' :  _response.statistic.memoryState.data.inactive});
  memoryState.data.add({'Swap Total' :  _response.statistic.memoryState.data.swapTotal});
  memoryState.data.add({'Swap Used' :  _response.statistic.memoryState.data.swapUsed});
  memoryState.data.add({'Swap Cached' :  _response.statistic.memoryState.data.swapCached});
  memoryState.data.add({'Swap Free' :  _response.statistic.memoryState.data.swapFree});
  memoryState.data.add({'Mem Available Enabled' :  _response.statistic.memoryState.data.memAvailableEnabled});
  memoryState.status = _response.statistic.memoryState.status.status;

  if(_response.statistic.memoryState.status.errors.isNotEmpty){
    String errorCode = _response.statistic.memoryState.status.errors[0].errorCode;
    String errorMessage = _response.statistic.memoryState.status.errors[0].errorMessage;
    memoryState.errors = Errors(errorCode, errorMessage);
  }

  if(memoryState.status!.contains(error)){
    memoryState.rang  = 1;
  }else if(memoryState.status!.contains(warning)){
    memoryState.rang  = 2;
  }else if(memoryState.status!.contains(ok)){
    memoryState.rang  = 3;
  }
  sortedDataBlocks.add(memoryState);



  CpuStateModel cpuState = CpuStateModel();
  cpuState.data.add({'Cpu Qty' : _response.statistic.cpuState.data.cpuQty});
  cpuState.data.add({'Average Workload' : _response.statistic.cpuState.data.averageWorkload});
  cpuState.status = _response.statistic.cpuState.status.status;

  if(_response.statistic.cpuState.status.errors.isNotEmpty){
    String errorCode = _response.statistic.cpuState.status.errors[0].errorCode;
    String errorMessage = _response.statistic.cpuState.status.errors[0].errorMessage;
    cpuState.errors = Errors(errorCode, errorMessage);
  }

  if(cpuState.status!.contains(error)){
    cpuState.rang  = 1;
  }else if(cpuState.status!.contains(warning)){
    cpuState.rang  = 2;
  }else if(cpuState.status!.contains(ok)){
    cpuState.rang  = 3;
  }
  sortedDataBlocks.add(cpuState);



  NodeStateModel nodeState = NodeStateModel();
  nodeState.data.add({'Tip Diff' : _response.statistic.nodeState.data.tipDiff});
  nodeState.data.add({'Density' : _response.statistic.nodeState.data.density});
  nodeState.status = _response.statistic.nodeState.status.status;

  if(_response.statistic.nodeState.status.errors.isNotEmpty){
    String errorCode = _response.statistic.nodeState.status.errors[0].errorCode;
    String errorMessage = _response.statistic.nodeState.status.errors[0].errorMessage;
    nodeState.errors = Errors(errorCode, errorMessage);
  }

  if(nodeState.status!.contains(error)){
    nodeState.rang  = 1;
  }else if(nodeState.status!.contains(warning)){
    nodeState.rang  = 2;
  }else if(nodeState.status!.contains(ok)){
    nodeState.rang  = 3;
  }
  sortedDataBlocks.add(nodeState);



  NodePerformanceModel nodePerformance = NodePerformanceModel();
  nodePerformance.data.add({'ProcessedTx' : _response.statistic.nodePerformance.data.processedTx});
  nodePerformance.data.add({'Peers In' : _response.statistic.nodePerformance.data.peersIn});
  nodePerformance.data.add({'Peers Out' : _response.statistic.nodePerformance.data.peersOut});
  nodePerformance.status = _response.statistic.nodePerformance.status.status;

  if(_response.statistic.nodePerformance.status.errors.isNotEmpty){
    String errorCode = _response.statistic.nodePerformance.status.errors[0].errorCode;
    String errorMessage = _response.statistic.nodePerformance.status.errors[0].errorMessage;
    nodePerformance.errors = Errors(errorCode, errorMessage);
  }

  if(nodePerformance.status!.contains(error)){
    nodePerformance.rang  = 1;
  }else if(nodePerformance.status!.contains(warning)){
    nodePerformance.rang  = 2;
  }else if(nodePerformance.status!.contains(ok)){
    nodePerformance.rang  = 3;
  }
  sortedDataBlocks.add(nodePerformance);

  if(kDebugMode){
    print('\n\n\n\n not sorted blocks data list: $sortedDataBlocks\n\n\n\n\n');
  }
  sortedDataBlocks.sort((a,b) => a.rang.compareTo(b.rang));
  if(kDebugMode){
    print('\n\n\n\nsorted blocks data list  $sortedDataBlocks\n\n\n\n\n');
  }
}