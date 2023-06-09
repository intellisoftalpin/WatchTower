class ServerModel {
  //NodeAuthData
  String? name;
  String? uuid;
  String? blockchain;
  String? ticker;
  String? type;
  String? firstParam;
  String? secondParam;
  String? thirdParam;
  String? firstParamStatus;
  String? secondParamStatus;
  String? thirdParamStatus;

  String? serverStatus;

  //NodeBasicData
  String? tickerNodeBasicData;
  String? typeNodeBasicData;
  String? location;
  String? nodeVersion;
  String? nodeBasicDataStatus;

  //ServerBasicData
  String? ipv4;
  String? ipv6;
  String? linuxName;
  String? linuxVersion;
  String? serverBasicDataStatus;

  //Epoch
  dynamic epochNumber;
  String? epochStatus;

  //KesExpData
  String? kesExpData;
  dynamic kesCurrent;
  dynamic kesRemaining;
  String? kesDataStatus;

  // Blocks
  dynamic blockLeader;
  dynamic blockAdopted;
  dynamic blockInvalid;
  String? blocksStatus;

  // StakeInfo
  dynamic liveStake;
  dynamic activeStake;
  dynamic pledge;
  String? stakeInfoStatus;

  //Online
  dynamic sinceStart;
  dynamic pings;
  dynamic nodeActive;
  dynamic nodeActivePings;
  dynamic serverActive;
  String? onlineStatus;

  //Memory State
  dynamic totalSpace;
  dynamic used;
  dynamic buffers;
  dynamic cached;
  dynamic freeSpace;
  dynamic available;
  dynamic active;
  dynamic inactive;
  dynamic swapTotal;
  dynamic swapUsed;
  dynamic swapCached;
  dynamic swapFree;
  dynamic memAvailableEnabled;
  String? memoryStateStatus;

  //CpuState
  dynamic cpuQty;
  dynamic averageWorkload;
  String? cpuQtyStatus;

  //Updates
  String? udapterActual;
  String? udapterAvailable;
  String? informerActual;
  String? informerAvailable;
  dynamic packagesAvailable;
  String? updatesStatus;

  //Security
  dynamic sshAttackAttempts;
  dynamic securityPackagesAvailable;
  String? securityStatus;

  //NodeState
  dynamic tipDiff;
  dynamic density;
  String? nodeStateStatus;

  //NodePerformance
  dynamic proceedTx;
  dynamic peersIn;
  dynamic peersOut;
  String? nodePerformanceStatus;

  ServerModel(
      {this.name,
      this.ticker,
      this.uuid,
      this.blockchain,
      this.type,
      this.tickerNodeBasicData,
      this.typeNodeBasicData,
      this.location,
      this.firstParam,
      this.secondParam,
      this.thirdParam,
      this.firstParamStatus,
      this.secondParamStatus,
      this.thirdParamStatus,
      this.serverStatus,
      this.kesDataStatus,
      this.nodeVersion,
      this.nodeBasicDataStatus,
      this.serverBasicDataStatus,
      this.epochNumber,
      this.epochStatus,
      this.kesExpData,
      this.kesCurrent,
      this.kesRemaining,
      this.blockLeader,
      this.blockAdopted,
      this.blockInvalid,
      this.blocksStatus,
      this.liveStake,
      this.activeStake,
      this.pledge,
      this.stakeInfoStatus,
      this.sinceStart,
      this.pings,
      this.nodeActive,
      this.nodeActivePings,
      this.serverActive,
      this.onlineStatus,
      this.memoryStateStatus,
      this.totalSpace,
      this.used,
      this.buffers,
      this.cached,
      this.freeSpace,
      this.available,
      this.active,
      this.inactive,
      this.swapTotal,
      this.swapUsed,
      this.swapCached,
      this.swapFree,
      this.memAvailableEnabled,
      this.cpuQty,
      this.cpuQtyStatus,
      this.averageWorkload,
      this.udapterActual,
      this.udapterAvailable,
      this.packagesAvailable,
      this.updatesStatus,
      this.informerActual,
      this.informerAvailable,
      this.sshAttackAttempts,
      this.securityPackagesAvailable,
      this.securityStatus,
      this.tipDiff,
      this.density,
      this.nodeStateStatus,
      this.proceedTx,
      this.peersIn,
      this.peersOut,
      this.nodePerformanceStatus});
}

class Errors{
  String? errorCode;
  String? errorMessage;
  Errors(this.errorCode, this.errorMessage);
}

class NodeBasicDataModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  NodeBasicDataModel(
      {this.rang, this.status, this.errors, this.blockName = 'Node Basic Data'});
}

class ServerBasicDataModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  ServerBasicDataModel(
      {this.status, this.rang, this.errors, this.blockName = 'Server Basic Data'});
}

class UpdatesModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;
  UpdatesModel({this.blockName = 'Updates', this.status, this.rang,
    this.errors,

  });
}

class SecurityModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  SecurityModel({this.blockName = 'Security', this.status, this.rang, this.errors});
}

class EpochModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  EpochModel({this.status, this.rang, this.errors, this.blockName = 'Epoch'});
}

class KesDataModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  KesDataModel({this.blockName = 'Kes Data', this.status, this.rang, this.errors});
}

class BlocksModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  BlocksModel({this.blockName = 'Blocks', this.status, this.rang, this.errors});
}

class StakeInfoModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  StakeInfoModel({this.rang, this.status, this.errors, this.blockName = 'Stake Info'});
}

class OnlineModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  OnlineModel({this.rang, this.blockName = 'Online', this.status, this.errors});
}

class MemoryStateModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  MemoryStateModel({this.rang, this.blockName = 'Memory State', this.status, this.errors});
}

class CpuStateModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  CpuStateModel({this.rang, this.blockName = 'Cpu State', this.status, this.errors});
}

class NodeStateModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  NodeStateModel({this.rang, this.blockName = 'Node State', this.status, this.errors});
}

class NodePerformanceModel {
  String blockName;
  String? status;
  List<Map<String, dynamic>> data = [];
  int? rang;
  Errors? errors;

  NodePerformanceModel(
      {this.rang, this.blockName = 'Node Performance', this.status, this.errors});
}

class ServerModelDetailsScreen {
  String? name;
  String? uuid;
  String? blockchain;
  String? serverStatus;

  //NodeBasicData
  NodeBasicDataModel? nodeBasicData;

  //ServerBasicData
  ServerBasicDataModel? serverBasicData;

  //Epoch
  EpochModel? epoch;

  //KesExpData
  KesDataModel? kesExpData;

  // Blocks
  BlocksModel? blocks;

  // StakeInfo
  StakeInfoModel? stakeInfo;

  //Online
  OnlineModel? online;

  //Memory State
  MemoryStateModel? memoryState;

  //CpuState
  CpuStateModel? cpuState;

  //Updates
  UpdatesModel? updates;

  //Security
  SecurityModel? security;

  //NodeState
  NodeStateModel? nodeState;

  //NodePerformance
  NodePerformanceModel? nodePerformance;

  ServerModelDetailsScreen(
      {this.name,
      this.uuid,
      this.blockchain,
      this.serverStatus,
      this.nodeBasicData,
      this.serverBasicData,
      this.epoch,
      this.kesExpData,
      this.blocks,
      this.stakeInfo,
      this.online,
      this.memoryState,
      this.cpuState,
      this.updates,
      this.security,
      this.nodeState,
      this.nodePerformance});
}

class NodeGroupModel {
  String? nodeStatus;
  String? ticker;
  List<ServerModel>? servers;

  NodeGroupModel({this.ticker, this.servers, this.nodeStatus});
}
